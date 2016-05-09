import unittest

from parsing.token_parser.TokenParser import TokenParser


class TokenParserTest(unittest.TestCase):
    def test_parser_expansion(self):
        parser = TokenParser(None, '_2[_@]')
        self.assertEqual(parser.definition, '_[_@][_@]')
