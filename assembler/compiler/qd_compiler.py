from compiler.alias_mapper import AliasMapper
from compiler.if_mapper import IfMapper
from compiler.label_mapper import LabelMapper
from compiler.loop_mapper import LoopMapper
from parsing.line_reader import LineReader

import sys


class QuickAndDirtyCompiler(object):
    def __init__(self, filename):
        self.filename = filename
        self.parts = []
        self.mappers = [
            AliasMapper(),
            LabelMapper(),
            LoopMapper(),
            IfMapper()
        ]

    def compile(self):
        if self.parse():
            for mapper in self.mappers:
                if not mapper.map(self.parts):
                    print('Compilation finished with errors')
                    sys.exit(-1)
                    return

            self.output()
            print('Compilation success')
        else:
            print('Compilation finished with errors')
            sys.exit(-1)

    def parse(self):
        line_no = 0
        error = False
        with open(self.filename) as fp:
            for line in fp:
                line_no += 1
                line_reader = LineReader(line.strip(), line_no)
                part = line_reader.parse()
                if part is None:
                    error = True
                else:
                    self.parts.append(part)

        return not error

    def output(self):
        with open(self.filename + '.out', 'wb') as fp:
            for part in self.parts:
                b = part.get_bytes()
                if b is not None:
                    fp.write(bytearray(b))

            fp.write(bytearray([0xFF for x in range(8)]))
