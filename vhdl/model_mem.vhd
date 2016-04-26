
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
    
    subtype gpu_state_type is std_logic_vector(2 downto 0);

    --'Enums' for the states of the GPU
    constant READ_OBJECT_STATE: gpu_state_type := "000";
    constant FETCH_LINE_STATE: gpu_state_type := "001";
    constant START_PIXEL_CALC: gpu_state_type := "010";
    constant CALCULATE_PIXELS_STATE: gpu_state_type := "011";
    constant NEXT_LINE_STATE: gpu_state_type := "100";
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
        --170,120 - 170,150
        0  => x"00aa007800000000",
        1  => x"00aa009600000000",

        --170,120 - 140,120
        2  => x"00aa007800000000",
        3  => x"008C007800000000",

        4  => x"00aa007800000000",
        5  => x"00c8005A00000000",


        6  => x"00aa007800000000",
        7  => x"00C8007800000000",

        8  => x"ffffffffffffffff",
        9  => x"ffffffffffffffff",

        --6  => x"0001000100000000",
        --7  => x"0002000100000000",
        --8  => x"0003000100000000",
        --9  => x"0004000100000000",
        --10 => x"ffffffffffffffff",
        --11 => x"ffffffffffffffff",

        --12 => x"0001000200000000",
        --13 => x"0002000200000000",
        --14 => x"ffffffffffffffff",
        --15 => x"ffffffffffffffff",
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
