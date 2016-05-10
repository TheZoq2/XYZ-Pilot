
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
    0 => x"0096007800000000",
    1 => x"0095007d00000000",
    2 => x"0093008300000000",
    3 => x"0090008800000000",
    4 => x"008d008d00000000",
    5 => x"0088009000000000",
    6 => x"0083009300000000",
    7 => x"007d009500000000",
    8 => x"0078009600000000",
    9 => x"0073009500000000",
    10 => x"006d009300000000",
    11 => x"0068009000000000",
    12 => x"0063008d00000000",
    13 => x"0060008800000000",
    14 => x"005d008300000000",
    15 => x"005b007d00000000",
    16 => x"005a007800000000",
    17 => x"005b007300000000",
    18 => x"005d006d00000000",
    19 => x"0060006800000000",
    20 => x"0063006300000000",
    21 => x"0068006000000000",
    22 => x"006d005d00000000",
    23 => x"0073005b00000000",
    24 => x"0078005a00000000",
    25 => x"007d005b00000000",
    26 => x"0083005d00000000",
    27 => x"0088006000000000",
    28 => x"008d006300000000",
    29 => x"0090006800000000",
    30 => x"0093006d00000000",
    31 => x"0095007300000000",
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
