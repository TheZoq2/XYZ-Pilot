class Part:
    def get_bytes(self):
        raise NotImplementedError('get_bytes not implemented')

    def in_output(self):
        raise NotImplementedError('in_output not implemented')
