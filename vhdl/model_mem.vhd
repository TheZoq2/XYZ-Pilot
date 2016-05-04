
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;

--Constants
package GPU_Info is
    --TODO: Optimse the size of obj addr and model addr
    --The length of the addresses and data in the object memory
    constant OBJ_ADDR_SIZE: positive := 16;
    constant OBJ_DATA_SIZE: positive := Vector.MEMORY_SIZE;

    subtype ObjAddr_t is unsigned(OBJ_ADDR_SIZE - 1 downto 0);
    subtype ObjData_t is std_logic_vector(OBJ_DATA_SIZE - 1 downto 0);

    constant MODEL_ADDR_SIZE: positive := 16;

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
    0 => x"00e600aa00000000",
    1 => x"00e500af00000000",
    2 => x"00e400b500000000",
    3 => x"00e300bb00000000",
    4 => x"00e100c000000000",
    5 => x"00de00c600000000",
    6 => x"00db00cb00000000",
    7 => x"00d800d000000000",
    8 => x"00d400d400000000",
    9 => x"00d000d800000000",
    10 => x"00cb00db00000000",
    11 => x"00c600de00000000",
    12 => x"00c000e100000000",
    13 => x"00bb00e300000000",
    14 => x"00b500e400000000",
    15 => x"00af00e500000000",
    16 => x"00aa00e600000000",
    17 => x"00a500e500000000",
    18 => x"009f00e400000000",
    19 => x"009900e300000000",
    20 => x"009400e100000000",
    21 => x"008e00de00000000",
    22 => x"008900db00000000",
    23 => x"008400d800000000",
    24 => x"008000d400000000",
    25 => x"007c00d000000000",
    26 => x"007900cb00000000",
    27 => x"007600c600000000",
    28 => x"007300c000000000",
    29 => x"007100bb00000000",
    30 => x"007000b500000000",
    31 => x"006f00af00000000",
    32 => x"006e00aa00000000",
    33 => x"006f00a500000000",
    34 => x"0070009f00000000",
    35 => x"0071009900000000",
    36 => x"0073009400000000",
    37 => x"0076008e00000000",
    38 => x"0079008900000000",
    39 => x"007c008400000000",
    40 => x"0080008000000000",
    41 => x"0084007c00000000",
    42 => x"0089007900000000",
    43 => x"008e007600000000",
    44 => x"0094007300000000",
    45 => x"0099007100000000",
    46 => x"009f007000000000",
    47 => x"00a5006f00000000",
    48 => x"00aa006e00000000",
    49 => x"00af006f00000000",
    50 => x"00b5007000000000",
    51 => x"00bb007100000000",
    52 => x"00c0007300000000",
    53 => x"00c6007600000000",
    54 => x"00cb007900000000",
    55 => x"00d0007c00000000",
    56 => x"00d4008000000000",
    57 => x"00d8008400000000",
    58 => x"00db008900000000",
    59 => x"00de008e00000000",
    60 => x"00e1009400000000",
    61 => x"00e3009900000000",
    62 => x"00e4009f00000000",
    63 => x"00e500a500000000",
    64 => x"ffffffffffffffff",
    65 => x"ffffffffffffffff",
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
