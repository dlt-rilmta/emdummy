#!/usr/bin/python3
# -*- coding: utf-8, vim: expandtab:ts=4 -*-


class DummyTagger:
    """
    This is a dummy xtsv module. I can be used as a tutorial to write new modules to xtsv
    As some of the modules use JAVA we need to prepare with the static properties in advance before we init those
     modules. Some of the following properties serves this purpose. They can be left as emtpy string when the module
      does not use JAVA.
    : class_path: Path to append to the end of CLASS_PATH environment variable when loading in JAVA classes
    : vm_opts: Additional JAVA VM options, when needed appended to the end of the options list
    : pass_header: Pass or strip header when generating output. (Default: True)
     One may strip header only when the module is the last in the pipeline! Eg. to generate ConLL-U formated output
    """
    class_path = ''  # TODO set
    vm_opts = ''  # TODO set
    pass_header = True  # TODO set

    def __init__(self, *_, source_fields=None, target_fields=None):
        """
        The initialisation of the module. One can extend the lsit of parameters as needed. The mandatory fields which
         should be set by keywords are the following:
        :param source_fields: the set of names of the input fields
        :param target_fields: the list of names of the output fields in generation order
        """
        # Custom code goes here

        # Field names for xtsv (the code below is mandatory for an xtsv module)
        if source_fields is None:
            source_fields = set()

        if target_fields is None:
            target_fields = []

        self.source_fields = source_fields
        self.target_fields = target_fields

    def process_sentence(self, sen, field_names):
        """
        Process one sentence per function call
        :param sen: the list of all tokens in the sentence, each token contain all fields
        :param field_names: the prepared field_names from prepare_fields() to select the appropriate input field
         to process
        :return: the sen object augmented with the output field values for each token
        """
        return sen                                   # TODO: Implement or overload on inherit

    def prepare_fields(self, field_names):
        """
        This function is called once before processing the input. It can be used to initialise field conversion classes
         to accomodate the current order of fields (eg. field to features)
        :param field_names: the dictionary of the names of the input fields mapped to their order in the input stream
        :return: the list of the initialised feature classes as required for process_sentence (in most cases the
         columnnumbers of the required field in the required order are sufficient
         eg. return [field_names['form'], field_names['lemma'], field_names['xpostag'], ...] )
        """
        return field_names                           # TODO: Implement or overload on inherit


def main():
    # Test the module with xtsv before integration to a pipeline

    import sys

    # TODO: Before testing please clone the xtsv module in the working directory to be able to import it
    #  (Please add xtsv as git submodule iff you want to use the module alone!)
    from xtsv import init_everything, build_pipeline, process, pipeline_rest_api

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