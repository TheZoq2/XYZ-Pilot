
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
    -- Start of ship
    0 => x"fff00000fff90000",
    1 => x"fff0000000050000",
    2 => x"00170000ffff0000",
    3 => x"fff00000fff90000",
    4 => x"0005fff8ffff0000",
    5 => x"00170000ffff0000",
    6 => x"0005000000020000",
    7 => x"00170000ffff0000",
    8 => x"fff00000fff90000",
    9 => x"fff3fff3ffff0000",
    10 => x"fff3fff3ffff0000",
    11 => x"fff0000000050000",
    12 => x"fff3fff3ffff0000",
    13 => x"0005fff8ffff0000",
    14 => x"fff0000000050000",
    15 => x"fff8000000040000",
    16 => x"0001000000050000",
    17 => x"0005000000020000",
    18 => x"0005000000020000",
    19 => x"fffffffd00010000",
    20 => x"fff8000000040000",
    21 => x"fffcfffd00020000",
    22 => x"fffffffd00010000",
    23 => x"fffcfffd00020000",
    24 => x"fff8000000040000",
    25 => x"fffc000000050000",
    26 => x"fffc000000050000",
    27 => x"0001000000050000",
    28 => x"fffcfffd00020000",
    29 => x"fffc000000050000",
    30 => x"fffffffd00010000",
    31 => x"0001000000050000",
    32 => x"0005fff8ffff0000",
    33 => x"000cfff8ffff0000",
    34 => x"fff1fffdfffc0000",
    35 => x"fff1fffd00010000",
    36 => x"fff1fffdfffc0000",
    37 => x"fff2fff6ffff0000",
    38 => x"fff2fff6ffff0000",
    39 => x"fff1fffd00010000",
    40 => x"fff0000000050000",
    41 => x"fff1fffd00010000",
    42 => x"fff2fff6ffff0000",
    43 => x"fff3fff3ffff0000",
    44 => x"fff1fffdfffc0000",
    45 => x"fff00000fff90000",
    46 => x"ffeefffcfffc0000",
    47 => x"ffeefffc00010000",
    48 => x"ffeefffcfffc0000",
    49 => x"ffeffff6ffff0000",
    50 => x"ffeffff6ffff0000",
    51 => x"ffeefffc00010000",
    52 => x"fff1fffd00010000",
    53 => x"ffeefffc00010000",
    54 => x"ffeffff6ffff0000",
    55 => x"fff2fff6ffff0000",
    56 => x"ffeefffcfffc0000",
    57 => x"fff1fffdfffc0000",
    58 => x"fff3fff3ffff0000",
    59 => x"fffcfffd00020000",
    60 => x"0005fff8ffff0000",
    61 => x"fffffffd00010000",
    62 => x"00050008ffff0000",
    63 => x"00170000ffff0000",
    64 => x"fff00000fff90000",
    65 => x"fff3000dffff0000",
    66 => x"fff3000dffff0000",
    67 => x"fff0000000050000",
    68 => x"fff3000dffff0000",
    69 => x"00050008ffff0000",
    70 => x"0005000000020000",
    71 => x"ffff000300010000",
    72 => x"fff8000000040000",
    73 => x"fffc000300020000",
    74 => x"ffff000300010000",
    75 => x"fffc000300020000",
    76 => x"fffc000300020000",
    77 => x"fffc000000050000",
    78 => x"ffff000300010000",
    79 => x"0001000000050000",
    80 => x"00050008ffff0000",
    81 => x"000c0008ffff0000",
    82 => x"fff10003fffc0000",
    83 => x"fff1000300010000",
    84 => x"fff10003fffc0000",
    85 => x"fff2000affff0000",
    86 => x"fff2000affff0000",
    87 => x"fff1000300010000",
    88 => x"fff0000000050000",
    89 => x"fff1000300010000",
    90 => x"fff2000affff0000",
    91 => x"fff3000dffff0000",
    92 => x"fff10003fffc0000",
    93 => x"fff00000fff90000",
    94 => x"ffee0004fffc0000",
    95 => x"ffee000400010000",
    96 => x"ffee0004fffc0000",
    97 => x"ffef000affff0000",
    98 => x"ffef000affff0000",
    99 => x"ffee000400010000",
    100 => x"fff1000300010000",
    101 => x"ffee000400010000",
    102 => x"ffef000affff0000",
    103 => x"fff2000affff0000",
    104 => x"ffee0004fffc0000",
    105 => x"fff10003fffc0000",
    106 => x"fff3000dffff0000",
    107 => x"fffc000300020000",
    108 => x"00050008ffff0000",
    109 => x"ffff000300010000",
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


    508 => x"0000000000000000",
    509 => x"0fff000000000000",
    510 => x"ffffffffffffffff",
    511 => x"ffffffffffffffff",
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
