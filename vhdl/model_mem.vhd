
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;

--Constants
package GPU_Info is
    --TODO: Optimse the size of obj addr and model addr
    --The length of the addresses and data in the object memory
    constant OBJ_ADDR_SIZE: positive := 9;
    constant OBJ_DATA_SIZE: positive := Vector.MEMORY_SIZE;

    subtype ObjAddr_t is unsigned(OBJ_ADDR_SIZE - 1 downto 0);
    subtype ObjData_t is std_logic_vector(OBJ_DATA_SIZE - 1 downto 0);

    constant MODEL_ADDR_SIZE: positive := 9;

    subtype ModelAddr_t is unsigned(MODEL_ADDR_SIZE - 1 downto 0);
    subtype ModelData_t is Vector.InMemory_t;
end package;

library IEEE;

use IEEE.Numeric_std.all;
use IEEE.std_logic_1164.all;

use work.Vector;
use work.GPU_Info;

entity ModelMem is
port (
        clk : in std_logic;
        -- port 1
        read_addr : in GPU_Info.ModelAddr_t;
        read_data : out GPU_Info.ModelData_t
    );
end entity;

architecture Behavioral of ModelMem is

-- Deklaration av ett dubbelportat block-RAM
-- med 2048 adresser av 8 bitars bredd.
type ram_t is array (0 to 511) of Vector.InMemory_t;

    -- Nollställ alla bitar på alla adresser
    signal ram : ram_t := (
    0 => x"000e0000fffd0000",
    1 => x"000e000000020000",
    2 => x"ffeb000000000000",
    3 => x"000e0000fffd0000",
    4 => x"fffb000700000000",
    5 => x"ffeb000000000000",
    6 => x"fffc000000010000",
    7 => x"ffeb000000000000",
    8 => x"000e0000fffd0000",
    9 => x"000c000c00000000",
    10 => x"000c000c00000000",
    11 => x"000e000000020000",
    12 => x"000c000c00000000",
    13 => x"fffb000700000000",
    14 => x"000e000000020000",
    15 => x"0007000000020000",
    16 => x"0000000000030000",
    17 => x"fffc000000010000",
    18 => x"fffc000000010000",
    19 => x"0001000300000000",
    20 => x"0007000000020000",
    21 => x"0004000300010000",
    22 => x"0001000300000000",
    23 => x"0004000300010000",
    24 => x"0007000000020000",
    25 => x"0004000000040000",
    26 => x"0004000000040000",
    27 => x"0000000000030000",
    28 => x"0004000300010000",
    29 => x"0004000000040000",
    30 => x"0001000300000000",
    31 => x"0000000000030000",
    32 => x"fffb000700000000",
    33 => x"fff5000700000000",
    34 => x"000e0003fffe0000",
    35 => x"000e000300010000",
    36 => x"000e0003fffe0000",
    37 => x"000d000900000000",
    38 => x"000d000900000000",
    39 => x"000e000300010000",
    40 => x"000e000000020000",
    41 => x"000e000300010000",
    42 => x"000d000900000000",
    43 => x"000c000c00000000",
    44 => x"000e0003fffe0000",
    45 => x"000e0000fffd0000",
    46 => x"00100003fffe0000",
    47 => x"0010000300010000",
    48 => x"00100003fffe0000",
    49 => x"000f000900000000",
    50 => x"000f000900000000",
    51 => x"0010000300010000",
    52 => x"000e000300010000",
    53 => x"0010000300010000",
    54 => x"000f000900000000",
    55 => x"000d000900000000",
    56 => x"00100003fffe0000",
    57 => x"000e0003fffe0000",
    58 => x"000c000c00000000",
    59 => x"0004000300010000",
    60 => x"fffb000700000000",
    61 => x"0001000300000000",
    62 => x"fffbfff900000000",
    63 => x"ffeb000000000000",
    64 => x"000e0000fffd0000",
    65 => x"000cfff400000000",
    66 => x"000cfff400000000",
    67 => x"000e000000020000",
    68 => x"000cfff400000000",
    69 => x"fffbfff900000000",
    70 => x"fffc000000010000",
    71 => x"0001fffd00000000",
    72 => x"0007000000020000",
    73 => x"0004fffd00010000",
    74 => x"0001fffd00000000",
    75 => x"0004fffd00010000",
    76 => x"0004fffd00010000",
    77 => x"0004000000040000",
    78 => x"0001fffd00000000",
    79 => x"0000000000030000",
    80 => x"fffbfff900000000",
    81 => x"fff5fff900000000",
    82 => x"000efffdfffe0000",
    83 => x"000efffd00010000",
    84 => x"000efffdfffe0000",
    85 => x"000dfff700000000",
    86 => x"000dfff700000000",
    87 => x"000efffd00010000",
    88 => x"000e000000020000",
    89 => x"000efffd00010000",
    90 => x"000dfff700000000",
    91 => x"000cfff400000000",
    92 => x"000efffdfffe0000",
    93 => x"000e0000fffd0000",
    94 => x"0010fffdfffe0000",
    95 => x"0010fffd00010000",
    96 => x"0010fffdfffe0000",
    97 => x"000ffff700000000",
    98 => x"000ffff700000000",
    99 => x"0010fffd00010000",
    100 => x"000efffd00010000",
    101 => x"0010fffd00010000",
    102 => x"000ffff700000000",
    103 => x"000dfff700000000",
    104 => x"0010fffdfffe0000",
    105 => x"000efffdfffe0000",
    106 => x"000cfff400000000",
    107 => x"0004fffd00010000",
    108 => x"fffbfff900000000",
    109 => x"0001fffd00000000",
    110 => x"ffffffffffffffff",
    111 => x"ffffffffffffffff",

    --Start of asteroid
    122 => x"fffaffee00160000",
    123 => x"fff8ffe900000000",
    124 => x"fff8ffe900000000",
    125 => x"0010fff6000c0000",
    126 => x"0010fff6000c0000",
    127 => x"fffaffee00160000",
    128 => x"0010fff6fff40000",
    129 => x"0010fff6000c0000",
    130 => x"fff8ffe900000000",
    131 => x"0010fff6fff40000",
    132 => x"ffeefffb00000000",
    133 => x"fff8ffe900000000",
    134 => x"fffaffee00160000",
    135 => x"ffeefffb00000000",
    136 => x"fffffff5ffec0000",
    137 => x"fff8ffe900000000",
    138 => x"ffeefffb00000000",
    139 => x"fffffff5ffec0000",
    140 => x"fffffff5ffec0000",
    141 => x"0010fff6fff40000",
    142 => x"0014000a00000000",
    143 => x"0010fff6000c0000",
    144 => x"0010fff6fff40000",
    145 => x"0014000a00000000",
    146 => x"0006000a00130000",
    147 => x"fffaffee00160000",
    148 => x"0010fff6000c0000",
    149 => x"0006000a00130000",
    150 => x"fff0000a000c0000",
    151 => x"ffeefffb00000000",
    152 => x"fffaffee00160000",
    153 => x"fff0000a000c0000",
    154 => x"ffec0007fff00000",
    155 => x"fffffff5ffec0000",
    156 => x"ffeefffb00000000",
    157 => x"ffec0007fff00000",
    158 => x"0006000affed0000",
    159 => x"0010fff6fff40000",
    160 => x"fffffff5ffec0000",
    161 => x"0006000affed0000",
    162 => x"0014000a00000000",
    163 => x"0006000a00130000",
    164 => x"0006000a00130000",
    165 => x"fff0000a000c0000",
    166 => x"fff0000a000c0000",
    167 => x"ffec0007fff00000",
    168 => x"ffec0007fff00000",
    169 => x"0006000affed0000",
    170 => x"0006000affed0000",
    171 => x"0014000a00000000",
    172 => x"0002001300060000",
    173 => x"0006000a00130000",
    174 => x"0014000a00000000",
    175 => x"0002001300060000",
    176 => x"0002001300060000",
    177 => x"fff0000a000c0000",
    178 => x"0002001300060000",
    179 => x"ffec0007fff00000",
    180 => x"0002001300060000",
    181 => x"0006000affed0000",
    182 => x"ffffffffffffffff",
    183 => x"ffffffffffffffff",


        others => (others => '0'));

begin

PROCESS(clk)
BEGIN
  if (rising_edge(clk)) then
    -- synkron skrivning/läsning port 1
    read_data <= ram(to_integer(read_addr));
  end if;
END PROCESS;

end Behavioral;
