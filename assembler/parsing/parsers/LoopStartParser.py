from parsing.parsers.ParseException import ParseException
from parsing.parsers.Parser import Parser
from parts.Variable import Variable


class LoopStartParser(Parser):
    LABEL_END_TOKEN = ':'

    def __init__(self):
        self.name = ""
        self.value = ""
        self.was_declared = False
        self.name_ended = False
        self.value_ended = False

    def build(self):
        assert self.get_error() is None

        return Variable(self.name, self.value)

    def get_error(self):
        if not self.was_declared or not self.value:
            return 'Expected variable declaration, found nothing'

        return None

    def handle_token(self, c):
        if not self.was_declared:
            if len(self.name) > 0 and self.name_ended and c != ' ' and c != '=':
                raise ParseException('Unexpected whitespace')

            if len(self.name) > 0 and c == ' ':
                self.name_ended = True

            if c == '=':
                if len(self.name) > 0:
                    self.name_ended = True
                    self.was_declared = True
                else:
                    raise ParseException('Expected variable name, found nothing')
            elif c != ' ':
                self.name += c
        else:
            if len(self.value) > 0 and self.value_ended and c != ' ' and c != '=':
                raise ParseException('Unexpected whitespace')

            if len(self.value) > 0 and c == ' ':
                self.value_ended = True

            if c == '=':
                raise ParseException('Found unexpected equal token')

            if c != ' ':
                self.value += c
