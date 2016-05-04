from parsing.line_reader import LineReader
from parts.Instruction import Instruction
from parts.Label import Label
from parts.Variable import Variable


class QuickAndDirtyCompiler(object):
    def __init__(self, filename):
        self.filename = filename
        self.parts = []
        self.labels = {}

    def compile(self):
        if self.parse() and self.map_labels():
            self.output()
            print('Compilation success')
        else:
            print('Compilation finished with errors')

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

    def map_labels(self):
        address = 0
        error = False
        for part in self.parts:
            if isinstance(part, Label) or isinstance(part, Variable):
                if part.label in self.labels:
                    error = True
                    print('Error: Multiple definitions of label \'' + part.label + '\'')

                self.labels[part.label] = address

            if part.in_output():
                address += 1

        if not error:
            for part in self.parts:
                if isinstance(part, Instruction):
                    for i in range(len(part.args)):
                        if part.args[i] in self.labels:
                            part.args[i] = hex(self.labels[part.args[i]])[2:]

                    if part.data in self.labels:
                        part.data = hex(self.labels[part.data])[2:]
                if isinstance(part, Variable):
                    if part.value in self.labels:
                        part.value = hex(self.labels[part.value])[2:]

        return not error

    def output(self):
        with open(self.filename + '.out', 'wb') as fp:
            for part in self.parts:
                b = part.get_bytes()
                if b is not None:
                    fp.write(bytearray(b))

            fp.write(bytearray([0xFF for x in range(8)]))
