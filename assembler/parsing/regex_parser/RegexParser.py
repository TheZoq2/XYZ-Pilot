import re

from parsing.parsers.Parser import Parser


class RegexParser(Parser):
    def __init__(self, cls, definition):
        self.cls = cls
        self.definition = definition
        self.content = ''
        self.regex = re.compile('^' + self.definition + '$')

    def build(self):
        match = self.regex.match(self.content)
        groups = match.groups()

        # In order to capture multiple repeated capture groups their syntax has been changed
        # from (x){y, z) to (x)?(x)?(x)?(x)?... This leaves empty groups (with content None).
        arguments = [x.strip() for x in groups if x is not None]

        part = self.cls.__new__(self.cls)
        part.__init__(*arguments)
        return part

    def get_error(self):
        if not self.regex.match(self.content):
            return 'String does not match regex ' + self.definition
        else:
            return None

    def handle_token(self, c):
        self.content += c
