from compiler.mapper import Mapper
from parts.Alias import Alias
from parts.Instruction import Instruction


class AliasMapper(Mapper):
    def __init__(self):
        super(AliasMapper, self).__init__()

        self.aliases = {}

    def prepare_part(self, part):
        if isinstance(part, Alias):
            self.aliases[part.name] = part.register
        elif isinstance(part, Instruction):
            # Check for load instructions (with support for addressing modes).
            if part.instruction_def['name'].startswith('LOAD'):
                # Don't override already defined register references.
                if part.args[0] not in self.aliases:
                    # Only process load instructions with variable references.
                    try:
                        int(part.data, 16)
                        is_variable = True
                    except ValueError:
                        is_variable = False

                    if not is_variable:
                        # Implicit declaration of register label
                        self.aliases[part.data] = part.args[0]

            for i in range(len(part.args)):
                if part.args[i] in self.aliases:
                    part.args[i] = self.aliases[part.args[i]]

    def apply_part(self, part):
        pass

