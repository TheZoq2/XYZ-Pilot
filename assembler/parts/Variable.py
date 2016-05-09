from instructions.instruction_set import INSTRUCTIONS
from parts.Part import Part
from specification.instruction_spec import generate_instruction_bytes
from specification.instruction_spec import get_op_code


class Variable(Part):
    USED_REGISTER = 0xF

    def __init__(self, name, value):
        self.label = name
        self.value = value
        self.address = None

    def in_output(self):
        return True

    def occupied_addresses(self):
        return 3

    def get_bytes(self):
        value_hi = int(self.value, base=16) >> 32
        value_lo = int(self.value, base=16) & 0xFFFFFFFF
        address = self.address

        return generate_instruction_bytes(get_op_code('MOVHI'), Variable.USED_REGISTER, data=value_hi) + \
            generate_instruction_bytes(get_op_code('MOVLO'), Variable.USED_REGISTER, data=value_lo) + \
            generate_instruction_bytes(get_op_code('STORE'), Variable.USED_REGISTER, data=address)
