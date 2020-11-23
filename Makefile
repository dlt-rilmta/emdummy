# Bash is needed for time
SHELL := /bin/bash -o pipefail
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)
NOCOLOR := $(shell tput sgr0)
PYTHON := python3
VENVDIR := $(CURDIR)/venv
VENVPIP := $(VENVDIR)/bin/python -m pip
VENVPYTHON := $(VENVDIR)/bin/python

# Module specific parameters
# DEP_COMMAND := command
# DEP_FILE := file
MODULE := emdummy
MODULE_PARAMS :=
TEST_INPUT := input.xtsv
TEST_OUTPUT := output.xtsv

# Parse version string and create new version. Originally from: https://github.com/mittelholcz/contextfun
# Variable is empty in Travis-CI if not git tag present
TRAVIS_TAG ?= ""
OLDVER := $$(grep -P -o "(?<=__version__ = ')[^']+" $(MODULE)/version.py)

MAJOR := $$(echo $(OLDVER) | sed -r s"/([0-9]+)\.([0-9]+)\.([0-9]+)/\1/")
MINOR := $$(echo $(OLDVER) | sed -r s"/([0-9]+)\.([0-9]+)\.([0-9]+)/\2/")
PATCH := $$(echo $(OLDVER) | sed -r s"/([0-9]+)\.([0-9]+)\.([0-9]+)/\3/")

NEWMAJORVER="$$(( $(MAJOR)+1 )).0.0"
NEWMINORVER="$(MAJOR).$$(( $(MINOR)+1 )).0"
NEWPATCHVER="$(MAJOR).$(MINOR).$$(( $(PATCH)+1 ))"

all:
	@echo "See Makefile for possible targets!"

venv:
	rm -rf $(VENVDIR)
	$(PYTHON) -m venv $(VENVDIR)
	$(VENVPIP) install wheel
	$(VENVPIP) install -r requirements-dev.txt
.PHONY: venv

# extra:
# 	# Do extra stuff (e.g. compiling, downloading) before building the package

# clean-extra:
# 	rm -rf extra stuff

# install-dep-packages:
# 	# Install packages in Aptfile
# 	sudo -E apt-get update
# 	sudo -E apt-get -yq --no-install-suggests --no-install-recommends $(travis_apt_get_options) install `cat Aptfile`

# check:
# 	# Check for file or command
# 	@test -f $(DEP_FILE) >/dev/null 2>&1 || \
# 		 { echo >&2 "File \`$(DEP_FILE)\` could not be found!"; exit 1; }
# 	@command -v $(DEP_COMMAND) >/dev/null 2>&1 || { echo >&2 "Command \`$(DEP_COMMAND)\`could not be found!"; exit 1; }

dist/*.whl dist/*.tar.gz: venv  # check extra
	@echo "Building package..."
	$(VENVPYTHON) setup.py sdist bdist_wheel

build: dist/*.whl dist/*.tar.gz

install-user: build
	@echo "Installing package to user..."
	$(VENVPIP) install dist/*.whl

test:
	@echo "Running tests..."
	time (cd /tmp && $(VENVPYTHON) -m $(MODULE) $(MODULE_PARAMS) -i $(CURDIR)/tests/$(TEST_INPUT) | \
	diff -sy --suppress-common-lines - $(CURDIR)/tests/$(TEST_OUTPUT) 2>&1 | head -n100)

install-user-test: install-user test
	@echo "$(GREEN)The test was completed successfully!$(NOCOLOR)"

check-version:
	@echo "Comparing GIT TAG (\"$(TRAVIS_TAG)\") with pacakge version (\"v$(OLDVER)\")..."
	@[[ "$(TRAVIS_TAG)" == "v$(OLDVER)" || "$(TRAVIS_TAG)" == "" ]] && \
	  echo "$(GREEN)OK!$(NOCOLOR)" || \
	  (echo "$(RED)Versions do not match!$(NOCOLOR)" && exit 1)

ci-test: install-user-test check-version

uninstall:
	@echo "Uninstalling..."
	$(VENVPIP) uninstall -y $(MODULE)

install-user-test-uninstall: install-user-test uninstall

clean: # clean-extra
	rm -rf $(VENVDIR) dist/ build/ $(MODULE).egg-info/

clean-build: clean build

# Do actual release with new version. Originally from: https://github.com/mittelholcz/contextfun
release-major:
	@make -s __release NEWVER=$(NEWMAJORVER)
.PHONY: release-major


release-minor:
	@make -s __release NEWVER=$(NEWMINORVER)
.PHONY: release-minor


release-patch:
	@make -s __release NEWVER=$(NEWPATCHVER)
.PHONY: release-patch


__release:
	@if [[ -z "$(NEWVER)" ]] ; then \
		echo 'Do not call this target!' ; \
		echo 'Use "release-major", "release-minor" or "release-patch"!' ; \
		exit 1 ; \
		fi
	@if [[ $$(git status --porcelain) ]] ; then \
		echo 'Working dir is dirty!' ; \
		exit 1 ; \
		fi
	@echo "NEW VERSION: $(NEWVER)"
	@make clean uninstall install-user-test-uninstall
	@sed -i -r "s/__version__ = '$(OLDVER)'/__version__ = '$(NEWVER)'/" $(MODULE)/version.py
	@make check-version
	@git add $(MODULE)/version.py
	@git commit -m "Release $(NEWVER)"
	@git tag -a "v$(NEWVER)" -m "Release $(NEWVER)"
	@git push
	@git push --tags
.PHONY: __release
