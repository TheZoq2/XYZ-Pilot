from parts.LoopStart import LoopStart
from specification.instruction_spec import get_op_code, generate_instruction_bytes


class InvertedLoopStart(LoopStart):
    def get_bytes(self):
        instructions = []
        instructions += generate_instruction_bytes(get_op_code('NOP'))

        if self.lhs_register == LoopStart.USED_REGISTER_LHS:
            instructions += generate_instruction_bytes(get_op_code('LOAD'), LoopStart.USED_REGISTER_LHS,
                                                       data=int(self.lhs, base=16))
        if self.rhs_register == LoopStart.USED_REGISTER_RHS:
            instructions += generate_instruction_bytes(get_op_code('LOAD'), LoopStart.USED_REGISTER_RHS,
                                                       data=int(self.rhs, base=16))

        instructions += generate_instruction_bytes(get_op_code('CMP'), self.lhs_register, self.rhs_register)
        instructions += generate_instruction_bytes(get_op_code('BEQ'), data=self.end_address)

        return instructions
