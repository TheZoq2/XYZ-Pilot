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
        0  => x"0000000000000000",
        1  => x"0001000100000000",
        2  => x"0000000000000000",
        3  => x"0002000200000000",
        4  => x"0000000000000000",
        5  => x"0003000300000000",
        6  => x"0000000000000000",
        7  => x"0004000400000000",
        8  => x"0000000000000000",
        9  => x"0005000500000000",
        10 => x"0000000000000000",
        11 => x"0006000600000000",
        12 => x"0000000000000000",
        13 => x"0007000700000000",
        14 => x"0000000000000000",
        15 => x"ffffffffffffffff",
        16 => x"ffffffffffffffff",
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
