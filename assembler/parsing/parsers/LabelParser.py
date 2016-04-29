from parsing.parsers.ParseException import ParseException
from parsing.parsers.Parser import Parser
from parts.Label import Label


class LabelParser(Parser):
    LABEL_END_TOKEN = ':'

    def __init__(self):
        super().__init__()

        self.label = ""
        self.was_opened = False
        self.was_closed = False

    def build(self):
        assert self.get_error() is None

        return Label(self.label)

    def get_error(self):
        if not self.was_closed:
            return 'Expected label end token, found nothing'

        return None

    def handle_token(self, c):
        if not self.was_opened and c == ' ':
            raise ParseException('Unexpected token')

        if c == ':':
            if not self.was_opened:
                raise ParseException('Label does not contain any text')

            self.was_closed = True
        elif c == ' ' and not self.was_closed:
            raise ParseException('Whitespace not allowed in label')
        elif c != ' ' and self.was_closed:
            raise ParseException('Unexpected character found after label')
        else:
            self.was_opened = True
            self.label += c
