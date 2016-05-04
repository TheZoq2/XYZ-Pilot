from log import syntax_error
from parsing.parsers.CommentParser import CommentParser
from parsing.parsers.InstructionParser import InstructionParser
from parsing.parsers.LabelParser import LabelParser
from parsing.parsers.NoOpParser import NoOpParser
from parsing.parsers.VariableParser import VariableParser


class LineReader:
    def __init__(self, line, line_no):
        super().__init__()

        self.line = line
        self.line_no = line_no

    def parse(self):
        # Available parsers ordered by priority
        parsers = [
            CommentParser(),
            InstructionParser(),
            VariableParser(),
            LabelParser(),
            NoOpParser()
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

        return parsers[0].build()
