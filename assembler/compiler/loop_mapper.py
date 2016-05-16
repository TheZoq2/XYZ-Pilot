from compiler.mapper import Mapper
from parts.LoopEnd import LoopEnd
from parts.LoopStart import LoopStart


class LoopMapper(Mapper):

    def __init__(self):
        super(LoopMapper, self).__init__()

        self.while_constructs = []

    def prepare_part(self, part):
        if isinstance(part, LoopStart):
            part.address = self.address
            self.while_constructs.append(part)
        if isinstance(part, LoopEnd):
            if len(self.while_constructs) == 0:
                self.fail('Error: Unexpected ENDWHILE. Loop was never opened')
            else:
                loop_start = self.while_constructs.pop()
                loop_start.end_address = self.address + 1
                part.start_address = loop_start.address

    def apply_part(self, part):
        pass

    def verify(self):
        if len(self.while_constructs) > 0:
            self.fail('Error: Expected ENDWHILE, but found nothing')
