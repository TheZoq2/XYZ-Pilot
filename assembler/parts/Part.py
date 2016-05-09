class Part(object):
    def get_bytes(self):
        raise NotImplementedError('get_bytes not implemented')

    def in_output(self):
        raise NotImplementedError('in_output not implemented')

    def occupied_addresses(self):
        raise NotImplementedError('occupied_addresses not implemented')
