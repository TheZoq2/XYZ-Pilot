from parsing.parsers.ParseException import ParseException
from parsing.parsers.Parser import Parser
from parts.NoOp import NoOp


class NoOpParser(Parser):
    def build(self):
        return NoOp()

    def get_error(self):
        return None

    def handle_token(self, c):
        if c != ' ':
            raise ParseException('Unexpected character "' + c + '"')
