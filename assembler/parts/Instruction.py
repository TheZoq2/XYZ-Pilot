from instructions.instruction_set import INSTRUCTIONS
from parsing.parsers.ParseException import ParseException
from parts.Part import Part
from specification.instruction_spec import generate_instruction_bytes


class Instruction(Part):
    def occupied_addresses(self):
        return 1

    def in_output(self):
        return True

    def __init__(self, instruction_identifier, *arguments):
        self.instruction_def = INSTRUCTIONS.get(instruction_identifier)
        if self.instruction_def is None:
            raise ParseException('Invalid instruction')

        self.args = list(arguments)
        if len(self.args) > self.instruction_def['num_registers']:
            self.data = self.args.pop()
        else:
            self.data = None

        if self.instruction_def['num_registers'] != len(self.args):
            raise ParseException(
                    'Invalid number of registers. Expected ' + str(self.instruction_def['num_registers']) + ', found ' + str(len(
                            self.args)))

        if self.instruction_def['has_data'] == (self.data is None):
            raise ParseException('Expected data, found nothing')

    def get_bytes(self):
        if len(self.args) > 0:
            reg1 = int(self.args[0], base=16)
        else:
            reg1 = 0
        if len(self.args) > 1:
            reg2 = int(self.args[1], base=16)
        else:
            reg2 = 0
        if len(self.args) > 2:
            reg3 = int(self.args[2], base=16)
        else:
            reg3 = 0

        if self.data:
            data = int(self.data, base=16)
        else:
            data = 0

        return generate_instruction_bytes(self.instruction_def['identifier'], reg1, reg2, reg3, data)
