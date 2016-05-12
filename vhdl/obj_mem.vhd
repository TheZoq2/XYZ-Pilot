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

-- Deklaration av ett dubbelportat block-RAM
-- med 512 adresser av 8 bitars bredd.
type ram_t is array (0 to 511) of Vector.InMemory_t;

    -- Nollställ alla bitar på alla adresser
    signal ram : ram_t := (
        0  => x"0070007000000000",
        1  => x"0000000000000000",
        2  => x"0000000000000000",
        3  => x"0000000000000000",

        4  => x"0020002000000000",
        5  => x"0030002000400000",
        6  => x"0000000000000000",
        7  => x"0000000000000006",

        8  => x"0090002000000000",
        9  => x"0000000000000000",
        10  => x"0000000000000000",
        11  => x"0000000000000000",
        
        12 => x"0020009000000000",
        13 => x"0000000000000000",
        14 => x"0000000000000000",
        15 => x"0000000000000000",

        16 => x"ffffffffffffffff",
        17 => x"ffffffffffffffff",
        18 => x"ffffffffffffffff",
        19 => x"ffffffffffffffff",
        others => (others => '0'));

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
