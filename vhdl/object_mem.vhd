library IEEE;

use work.Vector;

entity ObjectMem is
port (
        clk : in std_logic;
        -- port 1
        read_addr : in std_logic_vector(15 downto 0);
        read_data : out Vector.InMemory_t
        -- port 2
    );
end entity;

architecture Behavioral of ObjectMem is

-- Deklaration av ett dubbelportat block-RAM
-- med 2048 adresser av 8 bitars bredd.
type ram_t is array (0 to 511) of Vector.InMemory_t;

-- Nollställ alla bitar på alla adresser
signal ram : ram_t := (others => (others => '0'));

begin

PROCESS(clk)
BEGIN
  if (rising_edge(clk)) then
    -- synkron skrivning/läsning port 1
    read_data <= ram(read_addr);
  end if;
END PROCESS;

end Behavioral;
