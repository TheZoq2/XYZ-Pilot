from parts.Part import Part


class Label(Part):
    def occupied_addresses(self):
        return 1

    def in_output(self):
        return True

    def __init__(self, label):
        self.label = label

    def get_bytes(self):
        return [0 for x in range(8)]
