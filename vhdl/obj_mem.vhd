library IEEE;

use IEEE.Numeric_std.all;
use IEEE.std_logic_1164.all;

use work.Vector;
use work.GPU_Info;

entity ObjMem is
port (
        clk : in std_logic;
        -- port 1
        read_addr : in GPU_Info.ObjAddr_t;
        read_data : out GPU_Info.ObjData_t;
        -- port 2
        write_addr : in GPU_Info.ObjAddr_t;
        write_data : in GPU_Info.ObjData_t;
        we         : in std_logic := '0';
        debuginfo  : out std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of ObjMem is

--Memory which stores data about each object that should be drawn on the screen. The CPU writes
--to this memory while the GPU reads from it.

--The format of the models is as follows:
--0: position
--1: angle
--2: scale (unused)
--3: model_address. The start of the model to be drawn in the model memory

--The GPU will read continuously until it encounters an object that is entirely FFFF...FF at which point it
--knows that all objects have been drawn and it will wait until the current frame is done drawing.
type ram_t is array (0 to 511) of Vector.InMemory_t;
    -- Storing some starting data along with FF...F i the rest of the memory
    signal ram : ram_t := (
        0  => x"0070_0070_0000_0000",
        1  => x"0000_0000_0000_0000",
        2  => x"0000_0000_0000_0000",
        3  => x"0000_0000_0000_0000",

        4  => x"00a0_00a0_0000_0000",
        5  => x"0000_0000_0000_0000",
        6  => x"0000_0000_0000_0000",
        7  => x"0000_0000_0000_0000",

        --4  => x"0020_0020_0000_0000",
        --5  => x"0000_0000_0040_0000",
        --6  => x"0000_0000_0000_0000",
        --7  => x"0000_0000_0000_0000",


        --8  => x"0090_0021_0000_0000",
        --9  => x"0000_0000_0090_0000",
        --10  => x"0000_0000_0000_0000",
        --11  => x"0000_0000_0000_0000",
        --
        --12 => x"0020_0009_0000_0000",
        --13 => x"0000_0000_0000_0000",
        --14 => x"0000_0000_0000_0000",
        --15 => x"0000_0000_0000_0000",

        --16 => x"0080_0090_0000_0000",
        --17 => x"0000_0000_0000_0000",
        --18 => x"0000_0000_0000_0000",
        --19 => x"0000_0000_0000_0000",
        others => (others => '1'));

begin


PROCESS(clk)
BEGIN
  if (rising_edge(clk)) then
    -- synkron skrivning/läsning port 1
    read_data <= ram(to_integer(read_addr));
    if(we = '1') then
      ram(to_integer(write_addr)) <= write_data;
    end if;
  end if;
END PROCESS;

end Behavioral;
