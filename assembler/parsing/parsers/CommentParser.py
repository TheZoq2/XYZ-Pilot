from parsing.parsers.ParseException import ParseException
from parsing.parsers.Parser import Parser
from parts.Comment import Comment


class CommentParser(Parser):
    def __init__(self):
        self.has_read_start = False

    def get_error(self):
        if not self.has_read_start:
            return 'Comment was not started'

        return None

    def build(self):
        return Comment()

    def handle_token(self, c):
        if c == '#':
            self.has_read_start = True
        elif c != ' ' and not self.has_read_start:
            raise ParseException('Unexpected token')
