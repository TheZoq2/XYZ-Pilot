from parts.LoopStart import LoopStart
from specification.instruction_spec import get_op_code, generate_instruction_bytes


class InvertedLoopStart(LoopStart):
    def occupied_addresses(self):
        return 6

    def get_bytes(self):
        return \
            generate_instruction_bytes(get_op_code('NOP')) + \
            generate_instruction_bytes(get_op_code('LOAD'), LoopStart.USED_REGISTER_LHS, data=int(self.lhs, base=16)) + \
            generate_instruction_bytes(get_op_code('LOAD'), LoopStart.USED_REGISTER_RHS, data=int(self.rhs, base=16)) + \
            generate_instruction_bytes(get_op_code('CMP'), LoopStart.USED_REGISTER_LHS, LoopStart.USED_REGISTER_RHS) + \
            generate_instruction_bytes(get_op_code('BNE'), data=self.address + 6) + \
            generate_instruction_bytes(get_op_code('BRA'), data=self.end_address)
