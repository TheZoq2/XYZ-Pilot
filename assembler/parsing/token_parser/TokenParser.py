from parsing.parsers.ParseException import ParseException
from parsing.parsers.Parser import Parser

READ_IDLE = 0
READ_SEARCHING = 1
READ_OPENED = 2


class TokenParser(Parser):
    def __init__(self, cls, definition):
        self.cls = cls
        self.definition = definition
        self.definition_index = 0
        self.variables = []
        self.optionals_opened = 0

        self.expand()

    def expand(self):
        final_definition = ''
        repeated_token = ''
        repeated_count = 0
        read_status = READ_IDLE
        for i in range(len(self.definition)):
            c = self.definition[i]
            if c in '0123456789':
                if read_status != READ_IDLE:
                    raise ParseException('Nested repetitions are unsupported')

                repeated_token = ''
                repeated_count = int(self.definition[i])
                read_status = READ_SEARCHING
                continue
            if read_status == READ_SEARCHING and c == '[':
                read_status = READ_OPENED
                # Fall through
            if read_status == READ_OPENED:
                repeated_token += c
                if c == ']':
                    read_status = READ_IDLE
                    final_definition += repeated_token * repeated_count

                continue

            final_definition += c

        self.definition = final_definition

    def build(self):
        part = self.cls.__new__(self.cls)
        part.__init__(*self.variables)
        return part

    def get_error(self):
        if self.definition_index != len(self.definition) - 1:
            if self.definition_index == len(self.definition) - 2 and self.definition[-1] == '_':
                pass
            else:
                opened_optionals = self.optionals_opened
                valid = True
                for i in range(self.definition_index + 1, len(self.definition)):
                    c = self.definition[i]
                    if c == '[':
                        opened_optionals += 1
                    elif c == ']':
                        opened_optionals -= 1
                    elif c != '_' and opened_optionals == 0:
                        valid = False

                if not valid:
                    return 'Parsing didn\'nt finish'

        return None

    def handle_token(self, c):
        if c == '[':
            self.optionals_opened += 1
            return
        if c == ']':
            self.optionals_opened -= 1
            return

        if self.matches_class(c):
            if self.is_greedy():
                # Check if next token matches
                if self.matches_next(c):
                    self.definition_index += 1
                    if self.definition[self.definition_index] == '@':
                        self.variables.append('')
                else:
                    if self.is_optional(offset=1) and self.matches_next(c, offset=2, limit=4):
                        self.definition_index += 2
                        if self.definition[self.definition_index] == '@':
                            self.variables.append('')
        else:
            if self.matches_next(c):
                self.definition_index += 1
                if self.definition[self.definition_index] == '@':
                    self.variables.append('')
            elif self.is_optional(offset=1) and self.matches_next(c, offset=2, limit=4):
                self.definition_index += 2
                if self.definition[self.definition_index] == '@':
                    self.variables.append('')
            else:
                # TODO: Give more reasonable error
                if self.optionals_opened == 0:
                    raise ParseException('Parser error on character ' + c)

        token_class = self.definition[self.definition_index]
        if token_class == '@':
            self.variables[-1] += c

    def matches_next(self, c, offset=1, limit=3):
        if offset > limit:
            return False

        index = self.definition_index + offset
        if index >= len(self.definition):
            return False

        token_class = self.definition[index]
        if token_class == '[' or token_class == ']':
            match = self.matches_next(c, offset + 1, limit)
            if match:
                # Update opened optionals only if there was a match. Requires that all entry points which receives a
                # result of True increases self.definition index in order to work correctly.
                if token_class == '[':
                    self.optionals_opened += 1
                if token_class == ']':
                    self.optionals_opened -= 1

            return match

        match = self.matches_class(c, offset)
        # TODO: Remove this VERY ugly workaround
        if match and offset == 3:
            self.definition_index += 1

        return match

    def matches_class(self, c, offset=0):
        if self.definition_index + offset >= len(self.definition):
            return False

        token_class = self.definition[self.definition_index + offset]

        if token_class == '_':
            return c == ' '
        if token_class == '*':
            return True
        if token_class == '@':
            return c != ' '

        match = (c == token_class)
        if match and offset == 0:
            self.definition_index += 1

        return match

    def is_greedy(self):
        token_class = self.definition[self.definition_index]

        return token_class == '*' or token_class == '@'

    def is_optional(self, offset):
        if self.definition_index + offset >= len(self.definition):
            return False

        token_class = self.definition[self.definition_index + offset]

        return token_class == '_'

    def is_token(self):
        token_class = self.definition[self.definition_index]

        return token_class in ['_', '*', '@']
