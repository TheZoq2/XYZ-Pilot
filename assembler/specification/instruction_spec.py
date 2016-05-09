from instructions.instruction_set import INSTRUCTIONS


def generate_instruction_bytes(op_code, reg1=0, reg2=0, reg3=0, data=0):
    return [
        op_code,
        reg1 << 4 | (reg2 & 0x0F),
        reg3 << 4 | ((data & 0xF0000000) >> 28),
        (data & 0x0FF00000) >> 20,
        (data & 0x000FF000) >> 12,
        (data & 0x00000FF0) >> 4,
        (data & 0x0000000F) << 4,
        0
    ]


def get_op_code(instruction_name):
    return INSTRUCTIONS[instruction_name]['identifier']
