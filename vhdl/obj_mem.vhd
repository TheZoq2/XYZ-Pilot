library IEEE;

use IEEE.Numeric_std.all;
use IEEE.std_logic_1164.all;

use work.Vector;
use work.GPU_Info;

entity ObjMem is
port (
        clk : in std_logic;
        -- port 1
        read_addr : in GPU_Info.ModelAddr_t;
        read_data : out GPU_Info.ModelData_t;
        -- port 2
        write_addr : in GPU_Info.ModelAddr_t;
        write_data : in GPU_Info.ModelData_t;
        we         : in std_logic := '0'
    );
end entity;

architecture Behavioral of ObjMem is

-- Deklaration av ett dubbelportat block-RAM
-- med 512 adresser av 8 bitars bredd.
type ram_t is array (0 to 511) of Vector.InMemory_t;

    -- Nollställ alla bitar på alla adresser
    signal ram : ram_t := (others => (others => '0'));

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
