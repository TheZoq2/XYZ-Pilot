
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
    0 => x"001e000000000000",
    1 => x"001d000500000000",
    2 => x"001b000b00000000",
    3 => x"0018001000000000",
    4 => x"0015001500000000",
    5 => x"0010001800000000",
    6 => x"000b001b00000000",
    7 => x"0005001d00000000",
    8 => x"0000001e00000000",
    9 => x"000a001d00000000",
    10 => x"0016001b00000000",
    11 => x"0020001800000000",
    12 => x"002a001500000000",
    13 => x"0030001000000000",
    14 => x"0036000b00000000",
    15 => x"003a000500000000",
    16 => x"003c000000000000",
    17 => x"003a000a00000000",
    18 => x"0036001600000000",
    19 => x"0030002000000000",
    20 => x"002a002a00000000",
    21 => x"0020003000000000",
    22 => x"0016003600000000",
    23 => x"000a003a00000000",
    24 => x"0000003c00000000",
    25 => x"0005003a00000000",
    26 => x"000b003600000000",
    27 => x"0010003000000000",
    28 => x"0015002a00000000",
    29 => x"0018002000000000",
    30 => x"001b001600000000",
    31 => x"001d000a00000000",
    32 => x"ffffffffffffffff",
    33 => x"ffffffffffffffff",
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
