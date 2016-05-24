-- Object Memory, storing information for each object in the game
-- Every object has:
--                  Position
--                  Rotation
--                  Scale (not used in final product)
--                  Model (start position in model mem)
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
        we         : in std_logic := '0'
    );
end entity;

architecture Behavioral of ObjMem is

-- Declaration of model memory with 512 adresses containing 64 bit data
type ram_t is array (0 to 511) of Vector.InMemory_t;

    signal ram : ram_t := (
        -- Ship is hardcoded, the rest is created by CPU
        0  => x"0070_0070_0000_0000",
        1  => x"0000_0000_0000_0000",
        2  => x"0000_0000_0000_0000",
        3  => x"0000_0000_0000_0000",
        others => (others => '1'));

begin

PROCESS(clk)
BEGIN
  if (rising_edge(clk)) then
    -- Syncronised read/write
    read_data <= ram(to_integer(read_addr));
    if(we = '1') then
      ram(to_integer(write_addr)) <= write_data;
    end if;
  end if;
END PROCESS;

end Behavioral;
