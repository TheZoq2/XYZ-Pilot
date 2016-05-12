
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
    0 => x"0000_0000_0000_0000",
    1 => x"0000_0030_0000_0000",
    2 => x"ffff_ffff_ffff_ffff",
    3 => x"ffff_ffff_ffff_ffff",
    4 => x"0000_0000_0000_0000",
    5 => x"0000_0000_0030_0000",
    6 => x"ffff_ffff_ffff_ffff",
    7 => x"ffff_ffff_ffff_ffff",
    9 => x"ffff_ffff_ffff_ffff",
    10 => x"ffffffffffffffff",
    11 => x"0000000afffd0000",
    12 => x"0008fffafffd0000",
    13 => x"fff8fffafffd0000",
    14 => x"0008fffafffd0000",
    15 => x"0000000afffd0000",
    16 => x"fff8fffafffd0000",
    17 => x"0000000a00030000",
    18 => x"0008fffa00030000",
    19 => x"fff8fffa00030000",
    20 => x"0008fffa00030000",
    21 => x"0000000a00030000",
    22 => x"fff8fffa00030000",
    23 => x"0000000a00030000",
    24 => x"0000000afffd0000",
    25 => x"0008fffa00030000",
    26 => x"0008fffafffd0000",
    27 => x"fff8fffa00030000",
    28 => x"fff8fffafffd0000",
    29 => x"ffffffffffffffff",
    30 => x"ffffffffffffffff",
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
