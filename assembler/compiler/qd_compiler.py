from parsing.line_reader import LineReader
from parts.IfEnd import IfEnd
from parts.IfStart import IfStart
from parts.LoopStart import LoopStart
from parts.Instruction import Instruction
from parts.Label import Label
from parts.LoopEnd import LoopEnd
from parts.Variable import Variable


class QuickAndDirtyCompiler(object):
    def __init__(self, filename):
        self.filename = filename
        self.parts = []
        self.labels = {}
        self.variables = {}
        self.while_constructs = []
        self.if_constructs = []

    def compile(self):
        if self.parse() and self.map_labels() and self.map_loops() and self.map_ifs():
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
            if isinstance(part, Label):
                if part.label in self.labels:
                    error = True
                    print('Error: Multiple definitions of label \'' + part.label + '\'')
                else:
                    self.labels[part.label] = address
            if isinstance(part, Variable):
                if part.label not in self.variables:
                    self.variables[part.label] = len(self.variables)

                part.address = self.variables[part.label]

            if part.in_output():
                address += part.occupied_addresses()

        if not error:
            for part in self.parts:
                if isinstance(part, Instruction):
                    if part.data in self.labels:
                        part.data = hex(self.labels[part.data])[2:]
                    elif part.data in self.variables:
                        part.data = hex(self.variables[part.data])[2:]
                if isinstance(part, LoopStart) or isinstance(part, IfStart):
                    if part.lhs in self.variables:
                        part.lhs = hex(self.variables[part.lhs])[2:]
                    if part.rhs in self.variables:
                        part.rhs = hex(self.variables[part.rhs])[2:]

        return not error

    def map_loops(self):
        address = 0
        error = False
        for part in self.parts:
            if isinstance(part, LoopStart):
                part.address = address
                self.while_constructs.append(part)
            if isinstance(part, LoopEnd):
                if len(self.while_constructs) == 0:
                    error = True
                    print('Error: Unexpected ENDWHILE. Loop was never opened')
                else:
                    loop_start = self.while_constructs.pop()
                    loop_start.end_address = address + 1  # TODO: Verify if this is needed. Same situation as NOPs
                    part.start_address = loop_start.address

            if part.in_output():
                address += part.occupied_addresses()

        if len(self.while_constructs) > 0:
            error = True
            print('Error: Expected ENDWHILE, but found nothing')

        return not error

    def map_ifs(self):
        address = 0
        error = False
        for part in self.parts:
            if isinstance(part, IfStart):
                self.if_constructs.append(part)
            if isinstance(part, IfEnd):
                if len(self.if_constructs) == 0:
                    error = True
                    print('Error: Unexpected ENDIF. If statement was never opened')
                else:
                    if_start = self.if_constructs.pop()
                    if_start.end_address = address + 1  # TODO: Verify if this is needed. Same situation as NOPs

            if part.in_output():
                address += part.occupied_addresses()

        if len(self.if_constructs) > 0:
            error = True
            print('Error: Expected ENDIF, but found nothing')

        return not error

    def output(self):
        with open(self.filename + '.out', 'wb') as fp:
            for part in self.parts:
                b = part.get_bytes()
                if b is not None:
                    fp.write(bytearray(b))

            fp.write(bytearray([0xFF for x in range(8)]))
