import unittest

from parsing.parsers.Parser import Parser


class AbstractParserTest(unittest.TestCase):
    def test_parser_is_abstract(self):
        parser = Parser()
        self.assertRaises(NotImplementedError, parser.build)
        self.assertRaises(NotImplementedError, parser.get_error)
        self.assertRaises(NotImplementedError, parser.handle_token, '#')
