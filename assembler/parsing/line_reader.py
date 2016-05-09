from log import syntax_error
from parsing.parsers.CommentParser import CommentParser
from parsing.parsers.InstructionParser import InstructionParser
from parsing.parsers.LabelParser import LabelParser
from parsing.parsers.NoOpParser import NoOpParser
from parsing.parsers.VariableParser import VariableParser
from parsing.regex_parser.RegexParser import RegexParser
from parsing.regex_parser.regex_definitions import REGEX_TOKENS
from parsing.token_parser.TokenParser import TokenParser
from parsing.token_parser.token_definitions import TOKENS


class LineReader(object):
    def __init__(self, line, line_no):
        self.line = line
        self.line_no = line_no

    def parse(self):
        # Available parsers ordered by priority
        """
        parsers = [
            TokenParser(x['class'], x['definition'])
            for x in TOKENS
        ]
        """
        parsers = [
            RegexParser(x['class'], x['definition'])
            for x in REGEX_TOKENS
        ]

        errors = []

        for c in self.line:
            for parser in parsers[:]:
                try:
                    parser.handle_token(c)
                except Exception as e:
                    parsers.remove(parser)
                    errors.append(e)

        parsers = [x for x in parsers if x.get_error() is None]

        if len(parsers) == 0:
            syntax_error.log(self.line_no, errors.pop())
            return None

        errors = []
        for parser in parsers:
            try:
                part = parser.build()
                return part
            except Exception as e:
                errors.append(e)

        if errors:
            syntax_error.log(self.line_no, errors.pop())

        return None
