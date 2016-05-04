from parts.Part import Part


class Label(Part):
    def in_output(self):
        return True

    def __init__(self, label):
        super().__init__()

        self.label = label

    def get_bytes(self):
        return [0 for x in range(8)]
