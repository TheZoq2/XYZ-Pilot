INSTRUCTIONS = {}


def define(name, num_registers=0, has_data=False):
    name = name.upper()
    INSTRUCTIONS[name] = {
        'name': name,
        'num_registers': num_registers,
        'has_data': has_data
    }


define('NOP')
define('BRA', 0, True)
define('BNE', 0, True)
