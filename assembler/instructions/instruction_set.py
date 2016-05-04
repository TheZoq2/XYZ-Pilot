INSTRUCTIONS = {}


def define(identifier, name, num_registers=0, has_data=False):
    name = name.upper()
    INSTRUCTIONS[name] = {
        'identifier': identifier,
        'name': name,
        'num_registers': num_registers,
        'has_data': has_data
    }


define(0x00, 'NOP')
define(0x01, 'BRA', 0, True)
define(0x02, 'BNE', 0, True)
define(0x03, 'ADD', 3)
define(0x04, 'ADDI', 2, True)
define(0x05, 'MOVHI', 1, True)
define(0x06, 'MOVLO', 1, True)
define(0x07, 'STORE', 1, True)
define(0x08, 'LOAD', 1, True)
define(0x09, 'SUB', 3)
define(0x0A, 'SUBI', 2, True)
define(0x0B, 'CMP', 2)
define(0x0C, 'MULT', 3)
define(0x0D, 'MULTI', 2, True)
define(0x0E, 'VECADD', 3)
define(0x0F, 'VECSUB', 3)
