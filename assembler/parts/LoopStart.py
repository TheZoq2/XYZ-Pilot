from parts.Part import Part
from specification.instruction_spec import get_op_code, generate_instruction_bytes


class LoopStart(Part):
    USED_REGISTER_LHS = 0xE
    USED_REGISTER_RHS = 0xF
    BRANCH_MAP = {
        '=': 'BNE',
        '!': 'BEQ',
        '>': 'BLE',
        '<': 'BGE'
    }

    def __init__(self, lhs, compare_type, rhs):
        self.lhs = lhs
        self.rhs = rhs
        self.lhs_register = LoopStart.USED_REGISTER_LHS
        self.rhs_register = LoopStart.USED_REGISTER_RHS
        self.compare_instruction = LoopStart.BRANCH_MAP.get(compare_type)
        self.address = None
        self.end_address = None

    def occupied_addresses(self):
        address_count = 3
        if self.lhs_register == LoopStart.USED_REGISTER_LHS:
            address_count += 1
        if self.rhs_register == LoopStart.USED_REGISTER_RHS:
            address_count += 1

        return address_count

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
        instructions += generate_instruction_bytes(get_op_code(self.compare_instruction), data=self.end_address)

        return instructions

    def in_output(self):
        return True
