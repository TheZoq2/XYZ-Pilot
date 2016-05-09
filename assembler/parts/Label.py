from parts.Part import Part
from specification.instruction_spec import generate_instruction_bytes, get_op_code


class Label(Part):
    def occupied_addresses(self):
        return 1

    def in_output(self):
        return True

    def __init__(self, label):
        self.label = label

    def get_bytes(self):
        return generate_instruction_bytes(get_op_code('NOP'))
