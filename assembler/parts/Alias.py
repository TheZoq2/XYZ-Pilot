from parts.Part import Part


class Alias(Part):
    def __init__(self, register, name):
        super(Alias, self).__init__()

        self.register = register
        self.name = name

    def occupied_addresses(self):
        return 0

    def get_bytes(self):
        return None

    def in_output(self):
        return False
