
class Mapper(object):

    def __init__(self):
        super(Mapper, self).__init__()

        self.error = False
        self.address = 0

    def map(self, parts):
        for part in parts:
            self.prepare_part(part)

            if part.in_output():
                self.address += part.occupied_addresses()

        self.verify()

        if not self.error:
            for part in parts:
                self.apply_part(part)

        return not self.error

    def fail(self, message):
        self.error = True
        print(message)

    def prepare_part(self, part):
        raise NotImplementedError('prepare_part must be implemented')

    def apply_part(self, part):
        raise NotImplementedError('apply_part must be implemented')

    def verify(self):
        pass



