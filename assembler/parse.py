# coding=utf-8
# Compiled assembly parser for debugging purposes.

from __future__ import print_function
from sys import argv

from instructions.instruction_set import INSTRUCTIONS


MAX_INSTRUCTION_LENGTH = 0
for instruction in INSTRUCTIONS.itervalues():
    MAX_INSTRUCTION_LENGTH = max(MAX_INSTRUCTION_LENGTH, len(instruction['name']))


JUMP_INSTRUCTIONS = ['BRA', 'BNE', 'BEQ', 'BGE', 'BLE']


def debug_instruction(b):
    op_code = b[0]
    if op_code == 0xFF:
        is_stop = True
        for i in b:
            if i != 0xFF:
                is_stop = False
                break

        if is_stop:
            return '# PROGRAM END', None

    op_code_name = next((name for name, x in INSTRUCTIONS.iteritems() if x['identifier'] == op_code), None)
    if op_code_name is None:
        return '# ERROR: Unsupported instruction op code ' + str(op_code), None

    reg1 = (b[1] & 0xF0) >> 4
    reg2 = (b[1] & 0x0F)
    reg3 = (b[2] & 0xF0) >> 4
    data = ((b[2] & 0x0F) << 28) | (b[3] << 20) | (b[4] << 12) | (b[5] << 4) | ((b[6] & 0xF0) >> 4)

    jump_address = None
    if op_code_name in JUMP_INSTRUCTIONS:
        jump_address = data

    return \
        op_code_name.ljust(MAX_INSTRUCTION_LENGTH) + ' ' + \
        hex(reg1)[2:].upper() + ' ' + \
        hex(reg2)[2:].upper() + ' ' + \
        hex(reg3)[2:].upper() + ' ' + \
        hex(data)[2:].upper().zfill(8), \
        jump_address


def main():
    if len(argv) > 1:
        filename = argv[1]
    else:
        filename = 'test.asm.out'

    current_address = 0
    rows = []
    jumps = []
    with open(filename, 'rb') as fp:
        b = fp.read(8)
        while len(b) == 8:
            row = hex(current_address)[2:].upper().zfill(3) + ': '
            debug_string, jump_address = debug_instruction([ord(x) for x in b])
            row += debug_string

            if jump_address is not None:
                jumps.append((current_address, jump_address))

            rows.append(row)

            current_address += 1
            b = fp.read(8)

    if len(rows) == 0:
        return

    indication_start = len(rows[0]) + 1
    max_indiciations = len(jumps) * 2

    for i in range(len(rows)):
        rows[i] = list(rows[i].ljust(indication_start + max_indiciations))

    for jump in jumps:
        addr_from = jump[0]
        addr_to = jump[1]

        arrow_start = min(addr_from, addr_to)
        arrow_end = max(addr_from, addr_to)

        for offset in range(max_indiciations):
            valid_offset = True
            for i in range(arrow_start, arrow_end + 1):
                if rows[i][indication_start + offset * 2] != ' ':
                    valid_offset = False
                    break

            if valid_offset:
                for i in range(arrow_start, arrow_end + 1):
                    rows[i][indication_start + offset * 2] = '|'

                if addr_from < addr_to:
                    c_start = '\\'
                    c_stop = '↲'
                elif addr_from > addr_to:
                    c_start = '/'
                    c_stop = '↰'
                else:
                    c_start = '←'
                    c_stop = '←'

                rows[addr_from][indication_start + offset * 2] = c_start
                rows[addr_to][indication_start + offset * 2] = c_stop
                break

    for row in rows:
        print(''.join(row).strip())


if __name__ == "__main__":
    main()
