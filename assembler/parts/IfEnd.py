from parts.Part import Part
from specification.instruction_spec import generate_instruction_bytes, get_op_code


class IfEnd(Part):
    def occupied_addresses(self):
        return 1

    def in_output(self):
        return True

    def get_bytes(self):
        return generate_instruction_bytes(get_op_code('NOP'))
