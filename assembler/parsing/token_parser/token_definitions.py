from parts.Comment import Comment
from parts.IfEnd import IfEnd
from parts.IfStart import IfStart
from parts.Instruction import Instruction
from parts.InvertedLoopStart import InvertedLoopStart
from parts.Label import Label
from parts.LoopEnd import LoopEnd
from parts.LoopStart import LoopStart
from parts.NoOp import NoOp
from parts.Variable import Variable

TOKENS = []


def define(cls, definition):
    TOKENS.append({
        'class': cls,
        'definition': definition
    })


define(Comment, '_#*')
define(Instruction, '_@4[_@]_')
define(Label, '_@:_')
define(NoOp, '_')
define(Variable, '_@_=_@_')
define(LoopStart, '_WHILE @_==_@_')
define(InvertedLoopStart, '_WHILE @_!=_@_')
define(LoopEnd, '_ENDWHILE_')
define(IfStart, '_IF_@_==_@_')
define(IfEnd, '_ENDIF_')
