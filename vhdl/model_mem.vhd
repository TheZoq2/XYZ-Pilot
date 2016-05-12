
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
    0 => x"001a0000fff60000",
    1 => x"001a000000070000",
    2 => x"ffab0000fffe0000",
    3 => x"001a0000fff60000",
    4 => x"ffdf0017fffe0000",
    5 => x"ffab0000fffe0000",
    6 => x"ffdf000000030000",
    7 => x"ffab0000fffe0000",
    8 => x"001a0000fff60000",
    9 => x"00120025fffe0000",
    10 => x"00120025fffe0000",
    11 => x"001a000000070000",
    12 => x"00120025fffe0000",
    13 => x"ffdf0017fffe0000",
    14 => x"001a000000070000",
    15 => x"0004000000050000",
    16 => x"ffec0000000a0000",
    17 => x"ffdf000000030000",
    18 => x"ffdf000000030000",
    19 => x"fff1000900010000",
    20 => x"0004000000050000",
    21 => x"fff9000900030000",
    22 => x"fff1000900010000",
    23 => x"fff9000900030000",
    24 => x"0004000000050000",
    25 => x"fff80000000b0000",
    26 => x"fff80000000b0000",
    27 => x"ffec0000000a0000",
    28 => x"fff9000900030000",
    29 => x"fff80000000b0000",
    30 => x"fff1000900010000",
    31 => x"ffec0000000a0000",
    32 => x"ffdf0017fffe0000",
    33 => x"ffca0017fffe0000",
    34 => x"00180009fffb0000",
    35 => x"0018000900020000",
    36 => x"00180009fffb0000",
    37 => x"0015001cfffe0000",
    38 => x"0015001cfffe0000",
    39 => x"0018000900020000",
    40 => x"001a000000070000",
    41 => x"0018000900020000",
    42 => x"0015001cfffe0000",
    43 => x"00120025fffe0000",
    44 => x"00180009fffb0000",
    45 => x"001a0000fff60000",
    46 => x"001f000afffb0000",
    47 => x"001f000a00020000",
    48 => x"001f000afffb0000",
    49 => x"001c001dfffe0000",
    50 => x"001c001dfffe0000",
    51 => x"001f000a00020000",
    52 => x"0018000900020000",
    53 => x"001f000a00020000",
    54 => x"001c001dfffe0000",
    55 => x"0015001cfffe0000",
    56 => x"001f000afffb0000",
    57 => x"00180009fffb0000",
    58 => x"00120025fffe0000",
    59 => x"fff9000900030000",
    60 => x"ffdf0017fffe0000",
    61 => x"fff1000900010000",
    62 => x"ffdfffe9fffe0000",
    63 => x"ffab0000fffe0000",
    64 => x"001a0000fff60000",
    65 => x"0012ffdbfffe0000",
    66 => x"0012ffdbfffe0000",
    67 => x"001a000000070000",
    68 => x"0012ffdbfffe0000",
    69 => x"ffdfffe9fffe0000",
    70 => x"ffdf000000030000",
    71 => x"fff1fff700010000",
    72 => x"0004000000050000",
    73 => x"fff9fff700030000",
    74 => x"fff1fff700010000",
    75 => x"fff9fff700030000",
    76 => x"fff9fff700030000",
    77 => x"fff80000000b0000",
    78 => x"fff1fff700010000",
    79 => x"ffec0000000a0000",
    80 => x"ffdfffe9fffe0000",
    81 => x"ffcaffe9fffe0000",
    82 => x"0018fff7fffb0000",
    83 => x"0018fff700020000",
    84 => x"0018fff7fffb0000",
    85 => x"0015ffe4fffe0000",
    86 => x"0015ffe4fffe0000",
    87 => x"0018fff700020000",
    88 => x"001a000000070000",
    89 => x"0018fff700020000",
    90 => x"0015ffe4fffe0000",
    91 => x"0012ffdbfffe0000",
    92 => x"0018fff7fffb0000",
    93 => x"001a0000fff60000",
    94 => x"001ffff6fffb0000",
    95 => x"001ffff600020000",
    96 => x"001ffff6fffb0000",
    97 => x"001cffe3fffe0000",
    98 => x"001cffe3fffe0000",
    99 => x"001ffff600020000",
    100 => x"0018fff700020000",
    101 => x"001ffff600020000",
    102 => x"001cffe3fffe0000",
    103 => x"0015ffe4fffe0000",
    104 => x"001ffff6fffb0000",
    105 => x"0018fff7fffb0000",
    106 => x"0012ffdbfffe0000",
    107 => x"fff9fff700030000",
    108 => x"ffdfffe9fffe0000",
    109 => x"fff1fff700010000",
    110 => x"ffffffffffffffff",
    111 => x"ffffffffffffffff",
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
