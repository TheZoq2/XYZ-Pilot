import unittest

from parsing.line_reader import LineReader
from parts.Comment import Comment
from parts.Instruction import Instruction
from parts.Label import Label
from parts.NoOp import NoOp
from parts.Variable import Variable


class LabelTest(unittest.TestCase):
    def test_parse_valid_label(self):
        part = LineReader('FOO:', 1).parse()
        self.failUnless(isinstance(part, Label))

    def test_parse_valid_label_extra_whitespace(self):
        part = LineReader('FOO: ', 1).parse()
        self.failUnless(isinstance(part, Label))

    def test_parse_invalid_label_whitespace(self):
        part = LineReader('FO O:', 1).parse()
        self.failIf(part is not None)

    def test_parse_invalid_label_no_end(self):
        part = LineReader('FOO', 1).parse()
        self.failIf(part is not None)

    def test_parse_invalid_label_extra(self):
        part = LineReader('FOO:bar', 1).parse()
        self.failIf(part is not None)

    def test_parse_invalid_label_empty(self):
        part = LineReader(':', 1).parse()
        self.failIf(part is not None)


class NoOpTest(unittest.TestCase):
    def test_parse_valid_no_op(self):
        part = LineReader('', 1).parse()
        self.failUnless(isinstance(part, NoOp))

    def test_parse_valid_no_op_whitespace(self):
        part = LineReader(' ', 1).parse()
        self.failUnless(isinstance(part, NoOp))

    def test_parse_valid_no_op_more_whitespace(self):
        part = LineReader('     ', 1).parse()
        self.failUnless(isinstance(part, NoOp))


class CommentTest(unittest.TestCase):
    def test_parse_comment(self):
        part = LineReader('#Comment', 1).parse()
        self.failUnless(isinstance(part, Comment))

    def test_parse_comment_whitespace(self):
        part = LineReader('   # Comment', 1).parse()
        self.failUnless(isinstance(part, Comment))

    def test_do_not_parse_comment_as_label(self):
        part = LineReader('#Comment:', 1).parse()
        self.failUnless(isinstance(part, Comment))


class InstructionNOPTest(unittest.TestCase):
    def test_parse_nop(self):
        part = LineReader('NOP', 1).parse()
        self.failUnless(isinstance(part, Instruction))

    def test_parse_invalid_nop(self):
        part = LineReader('NOP 1', 1).parse()
        self.failIf(part is not None)


class InstructionBRATest(unittest.TestCase):
    def test_parse_bra(self):
        part = LineReader('BRA address', 1).parse()
        self.failUnless(isinstance(part, Instruction))

    def test_parse_invalid_bra(self):
        part = LineReader('BRA', 1).parse()
        self.failIf(part is not None)


class VariableTest(unittest.TestCase):
    def test_parse_valid_variable(self):
        part = LineReader('FOO=000', 1).parse()
        self.failUnless(isinstance(part, Variable))

    def test_parse_valid_variable_ref(self):
        part = LineReader('FOO=BAR', 1).parse()
        self.failUnless(isinstance(part, Variable))

    def test_parse_valid_variable_extra_whitespace(self):
        part = LineReader('  FOO  =   000  ', 1).parse()
        self.failUnless(isinstance(part, Variable))

    def test_parse_invalid_variable_whitespace(self):
        part = LineReader('FO 0=000', 1).parse()
        self.failIf(part is not None)

    def test_parse_invalid_variable_no_value(self):
        part = LineReader('FOO=', 1).parse()
        self.failIf(part is not None)

    def test_parse_invalid_variable_empty(self):
        part = LineReader('=', 1).parse()
        self.failIf(part is not None)
