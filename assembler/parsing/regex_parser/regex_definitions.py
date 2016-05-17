from parts.Alias import Alias
from parts.Comment import Comment
from parts.IfEnd import IfEnd
from parts.IfStart import IfStart
from parts.Instruction import Instruction
from parts.Label import Label
from parts.LoopEnd import LoopEnd
from parts.LoopStart import LoopStart
from parts.NoOp import NoOp
from parts.Variable import Variable

REGEX_TOKENS = []


def define(cls, definition):
    REGEX_TOKENS.append({
        'class': cls,
        'definition': definition
    })


define(Comment, r'\s*#.*')
define(Instruction, r'\s*(\S+)(\s*\S+)?(\s*\S+)?(\s*\S+)?(\s*\S+)?\s*')
define(Label, r'\s*(\S+):\s*')
define(NoOp, r'\s*')
define(Variable, r'\s*(\S+)\s*=\s*(\S+)\s*')
define(LoopStart, r'\s*WHILE\s+(\S+)\s*(=|!|>|<)=\s*(\S+)\s*')
define(LoopEnd, r'\s*ENDWHILE\s*')
define(IfStart, r'\s*IF\s*(\S+)\s*(=|!|>|<)=\s*(\S+)\s*')
define(IfEnd, r'\s*ENDIF\s*')
define(Alias, r'\s*ALIAS\s+([0-9]+)\s+(\S+)\s*')
