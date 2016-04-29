
class Parser:

    def build(self):
        raise NotImplementedError('build must be implemented')

    def get_error(self):
        raise NotImplementedError('get_error must be implemented')

    def handle_token(self, c):
        raise NotImplementedError('handle_token must be implemented')
