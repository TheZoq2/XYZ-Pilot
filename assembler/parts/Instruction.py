from parts.Part import Part


class Instruction(Part):
    def in_output(self):
        return True

    def __init__(self, instruction_def, args, data):
        super().__init__()

        self.instruction_def = instruction_def
        self.args = args
        self.data = data

    def get_bytes(self):
        if len(self.args) > 0:
            reg1 = int(self.args[0], base=16)
        else:
            reg1 = 0
        if len(self.args) > 1:
            reg2 = int(self.args[1], base=16)
        else:
            reg2 = 0
        if len(self.args) > 2:
            reg3 = int(self.args[2], base=16)
        else:
            reg3 = 0

        if self.data:
            data = int(self.data, base=16)
        else:
            data = 0

        instruction = [
            self.instruction_def['identifier'],
            reg1 << 4 | (reg2 & 0x0F),
            reg3 << 4 | ((data & 0xF0000000) >> 28),
            (data & 0x0FF00000) >> 20,
            (data & 0x000FF000) >> 12,
            (data & 0x00000FF0) >> 4,
            (data & 0x0000000F) << 4,
            0
        ]

        return instruction
