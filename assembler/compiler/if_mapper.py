from compiler.mapper import Mapper
from parts.IfEnd import IfEnd
from parts.IfStart import IfStart


class IfMapper(Mapper):

    def __init__(self):
        super(IfMapper, self).__init__()

        self.if_constructs = []

    def prepare_part(self, part):
        if isinstance(part, IfStart):
            self.if_constructs.append(part)
        if isinstance(part, IfEnd):
            if len(self.if_constructs) == 0:
                self.fail('Error: Unexpected ENDIF. If statement was never opened')
            else:
                if_start = self.if_constructs.pop()
                if_start.end_address = self.address

    def apply_part(self, part):
        pass

    def verify(self):
        if len(self.if_constructs) > 0:
            self.fail('Error: Expected ENDIF, but found nothing')
