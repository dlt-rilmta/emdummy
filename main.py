#!/usr/bin/python3
# -*- coding: utf-8, vim: expandtab:ts=4 -*-

# Test the module with xtsv before integration to a pipeline

import sys

# TODO: Before testing please clone the xtsv module in the working directory to be able to import it
#  (Please add xtsv as git submodule iff you want to use the module alone!)
from xtsv import init_everything, build_pipeline

from dummytagger.dummytagger import DummyTagger


def main():
    # Set input and output iterators...
    input_iterator = sys.stdin
    output_iterator = sys.stdout

    # Set the tagger name as in the tools dictionary
    used_tools = ['dummy-tagger']
    presets = []

    # Init and run the module as it were in xtsv

    # The relevant part of config.py
    # from emdummy import DummyTagger
    em_dummy = (DummyTagger, (), {'source_fields': {'form'}, 'target_fields': []})
    tools = {'dummy-tagger': em_dummy}

    # Init the selected tools
    inited_tools = init_everything(tools)

    # Run the pipeline on input and write result to the output...
    output_iterator.writelines(build_pipeline(input_iterator, used_tools, inited_tools, presets))

    # TODO this method is recommended when debugging the tool
    # Alternative: Run specific tool for input (still in emtsv format):
    # output_iterator.writelines(process(input_iterator, inited_tools[used_tools[0]]))

    # Alternative2: Run REST API debug server
    # app = pipeline_rest_api('TEST', inited_tools, presets,  False)
    # app.run()


if __name__ == '__main__':
    main()