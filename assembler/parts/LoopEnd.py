from parts.Part import Part
from specification.instruction_spec import generate_instruction_bytes, get_op_code


class LoopEnd(Part):
    def __init__(self):
        self.start_address = None

    def occupied_addresses(self):
        return 1

    def in_output(self):
        return True

    def get_bytes(self):
        return generate_instruction_bytes(get_op_code('BRA'), data=self.start_address)
