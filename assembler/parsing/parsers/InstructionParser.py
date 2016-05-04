from instructions.instruction_set import INSTRUCTIONS
from parsing.parsers.ParseException import ParseException
from parsing.parsers.Parser import Parser
from parts.Instruction import Instruction


class InstructionParser(Parser):
    def __init__(self):
        self.instruction = ''
        self.instruction_def = None
        self.found_instruction = False
        self.args = []
        self.current_arg = ''
        self.data = ''

    def get_error(self):
        if not self.found_instruction and len(self.instruction) > 0:
            self.instruction_def = INSTRUCTIONS.get(self.instruction)
            if self.instruction_def is None:
                return 'Unsupported instruction ({0})'.format(self.instruction)
            self.found_instruction = True

        if self.instruction_def is not None and len(self.args) < self.instruction_def['num_registers'] and len(self.current_arg) > 0:
            self.args.append(self.current_arg)

        if not self.found_instruction:
            return 'Instruction not found'

        if len(self.args) != self.instruction_def['num_registers']:
            return 'Unexpected number of registers'

        if self.instruction_def['has_data'] and len(self.data) == 0:
            return 'Expected data but found nothing'

        return None

    def build(self):
        return Instruction(self.instruction_def, self.args, self.data)

    def handle_token(self, c):
        if not self.found_instruction:
            if c != ' ':
                self.instruction += c
            else:
                self.instruction_def = INSTRUCTIONS.get(self.instruction)
                if self.instruction_def is None:
                    raise ParseException('Unsupported instruction ({0})'.format(self.instruction))
                self.found_instruction = True
        elif len(self.args) < self.instruction_def['num_registers']:
            if c != ' ':
                self.current_arg += c
            else:
                self.args.append(self.current_arg)
                self.current_arg = ''
        else:
            if not self.instruction_def['has_data']:
                raise ParseException('Found unexpected data')

            if c == ' ':
                raise ParseException('Unexpected whitespace while parsing data')

            self.data += c


