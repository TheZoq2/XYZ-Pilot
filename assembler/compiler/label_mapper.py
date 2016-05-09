from compiler.mapper import Mapper
from parts.IfStart import IfStart
from parts.Instruction import Instruction
from parts.Label import Label
from parts.LoopStart import LoopStart
from parts.Variable import Variable


class LabelMapper(Mapper):

    def __init__(self):
        super(LabelMapper, self).__init__()

        self.labels = {}
        self.variables = {}

    def prepare_part(self, part):
        if isinstance(part, Label):
            if part.label in self.labels:
                self.fail('Error: Multiple definitions of label \'' + part.label + '\'')
            else:
                self.labels[part.label] = self.address
        if isinstance(part, Variable):
            if part.label not in self.variables:
                self.variables[part.label] = len(self.variables)

            part.address = self.variables[part.label]

    def apply_part(self, part):
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
