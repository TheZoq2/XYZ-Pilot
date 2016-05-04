from parts.Part import Part


class Variable(Part):
    def __init__(self, name, value):
        self.label = name
        self.value = value

    def in_output(self):
        return True

    def get_bytes(self):
        value = int(self.value, base=16)
        return [
            (value & 0xFF00000000000000) >> 56,
            (value & 0x00FF000000000000) >> 48,
            (value & 0x0000FF0000000000) >> 40,
            (value & 0x000000FF00000000) >> 32,
            (value & 0x00000000FF000000) >> 24,
            (value & 0x0000000000FF0000) >> 16,
            (value & 0x000000000000FF00) >> 8,
            (value & 0x00000000000000FF),
        ]
