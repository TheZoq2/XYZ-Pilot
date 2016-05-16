from parts.Part import Part
from specification.instruction_spec import generate_instruction_bytes, get_op_code


class Label(Part):
    def occupied_addresses(self):
        return 0

    def in_output(self):
        return False

    def __init__(self, label):
        self.label = label

    def get_bytes(self):
        return None
