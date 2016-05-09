from parts.Part import Part
from specification.instruction_spec import get_op_code, generate_instruction_bytes


# TODO: Add support for register checking?
class LoopStart(Part):
    USED_REGISTER_LHS = 0xE
    USED_REGISTER_RHS = 0xF

    def __init__(self, lhs, rhs):
        self.lhs = lhs
        self.rhs = rhs
        self.address = None
        self.end_address = None

    def occupied_addresses(self):
        return 5

    def get_bytes(self):
        return \
            generate_instruction_bytes(get_op_code('NOP')) + \
            generate_instruction_bytes(get_op_code('LOAD'), LoopStart.USED_REGISTER_LHS, data=int(self.lhs, base=16)) + \
            generate_instruction_bytes(get_op_code('LOAD'), LoopStart.USED_REGISTER_RHS, data=int(self.rhs, base=16)) + \
            generate_instruction_bytes(get_op_code('CMP'), LoopStart.USED_REGISTER_LHS, LoopStart.USED_REGISTER_RHS) + \
            generate_instruction_bytes(get_op_code('BNE'), data=self.end_address)

    def in_output(self):
        return True
