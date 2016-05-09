from instructions.instruction_set import INSTRUCTIONS
from parts.Part import Part


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
        return [
            INSTRUCTIONS['MOVHI']['identifier'],
            Variable.USED_REGISTER << 4,
            (value_hi & 0xF0000000) >> 28,
            (value_hi & 0x0FF00000) >> 20,
            (value_hi & 0x000FF000) >> 12,
            (value_hi & 0x00000FF0) >> 4,
            (value_hi & 0x0000000F) << 4,
            0x0,
            INSTRUCTIONS['MOVLO']['identifier'],
            Variable.USED_REGISTER << 4,
            (value_lo & 0xF0000000) >> 28,
            (value_lo & 0x0FF00000) >> 20,
            (value_lo & 0x000FF000) >> 12,
            (value_lo & 0x00000FF0) >> 4,
            (value_lo & 0x0000000F) << 4,
            0x0,
            INSTRUCTIONS['STORE']['identifier'],
            Variable.USED_REGISTER << 4,
            (address & 0xF0000000) >> 28,
            (address & 0x0FF00000) >> 20,
            (address & 0x000FF000) >> 12,
            (address & 0x00000FF0) >> 4,
            (address & 0x0000000F) << 4,
            0x0
        ]
