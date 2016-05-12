
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
    0 => x"000e0000fffb0000",
    1 => x"000e000000030000",
    2 => x"ffd70000ffff0000",
    3 => x"000e0000fffb0000",
    4 => x"fff0000cffff0000",
    5 => x"ffd70000ffff0000",
    6 => x"fff0000000010000",
    7 => x"ffd70000ffff0000",
    8 => x"000e0000fffb0000",
    9 => x"000a0013ffff0000",
    10 => x"000a0013ffff0000",
    11 => x"000e000000030000",
    12 => x"000a0013ffff0000",
    13 => x"fff0000cffff0000",
    14 => x"000e000000030000",
    15 => x"0003000000030000",
    16 => x"fff7000000050000",
    17 => x"fff0000000010000",
    18 => x"fff0000000010000",
    19 => x"fff9000500010000",
    20 => x"0003000000030000",
    21 => x"fffd000500010000",
    22 => x"fff9000500010000",
    23 => x"fffd000500010000",
    24 => x"0003000000030000",
    25 => x"fffd000000060000",
    26 => x"fffd000000060000",
    27 => x"fff7000000050000",
    28 => x"fffd000500010000",
    29 => x"fffd000000060000",
    30 => x"fff9000500010000",
    31 => x"fff7000000050000",
    32 => x"fff0000cffff0000",
    33 => x"ffe6000cffff0000",
    34 => x"000d0004fffd0000",
    35 => x"000d000400010000",
    36 => x"000d0004fffd0000",
    37 => x"000b000effff0000",
    38 => x"000b000effff0000",
    39 => x"000d000400010000",
    40 => x"000e000000030000",
    41 => x"000d000400010000",
    42 => x"000b000effff0000",
    43 => x"000a0013ffff0000",
    44 => x"000d0004fffd0000",
    45 => x"000e0000fffb0000",
    46 => x"00100005fffd0000",
    47 => x"0010000500010000",
    48 => x"00100005fffd0000",
    49 => x"000f000fffff0000",
    50 => x"000f000fffff0000",
    51 => x"0010000500010000",
    52 => x"000d000400010000",
    53 => x"0010000500010000",
    54 => x"000f000fffff0000",
    55 => x"000b000effff0000",
    56 => x"00100005fffd0000",
    57 => x"000d0004fffd0000",
    58 => x"000a0013ffff0000",
    59 => x"fffd000500010000",
    60 => x"fff0000cffff0000",
    61 => x"fff9000500010000",
    62 => x"fff0fff4ffff0000",
    63 => x"ffd70000ffff0000",
    64 => x"000e0000fffb0000",
    65 => x"000affedffff0000",
    66 => x"000affedffff0000",
    67 => x"000e000000030000",
    68 => x"000affedffff0000",
    69 => x"fff0fff4ffff0000",
    70 => x"fff0000000010000",
    71 => x"fff9fffb00010000",
    72 => x"0003000000030000",
    73 => x"fffdfffb00010000",
    74 => x"fff9fffb00010000",
    75 => x"fffdfffb00010000",
    76 => x"fffdfffb00010000",
    77 => x"fffd000000060000",
    78 => x"fff9fffb00010000",
    79 => x"fff7000000050000",
    80 => x"fff0fff4ffff0000",
    81 => x"ffe6fff4ffff0000",
    82 => x"000dfffcfffd0000",
    83 => x"000dfffc00010000",
    84 => x"000dfffcfffd0000",
    85 => x"000bfff2ffff0000",
    86 => x"000bfff2ffff0000",
    87 => x"000dfffc00010000",
    88 => x"000e000000030000",
    89 => x"000dfffc00010000",
    90 => x"000bfff2ffff0000",
    91 => x"000affedffff0000",
    92 => x"000dfffcfffd0000",
    93 => x"000e0000fffb0000",
    94 => x"0010fffbfffd0000",
    95 => x"0010fffb00010000",
    96 => x"0010fffbfffd0000",
    97 => x"000ffff1ffff0000",
    98 => x"000ffff1ffff0000",
    99 => x"0010fffb00010000",
    100 => x"000dfffc00010000",
    101 => x"0010fffb00010000",
    102 => x"000ffff1ffff0000",
    103 => x"000bfff2ffff0000",
    104 => x"0010fffbfffd0000",
    105 => x"000dfffcfffd0000",
    106 => x"000affedffff0000",
    107 => x"fffdfffb00010000",
    108 => x"fff0fff4ffff0000",
    109 => x"fff9fffb00010000",
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
