library IEEE;

use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

use work.Vector;

entity LinearFeedbackSR is
port (
        clk : in std_logic;
        data : out Vector.InMemory_t
    );
end entity;

architecture Behavioral of LinearFeedbackSR is
  signal state : Vector.InMemory_t := x"040815162342_2760";  -- Vino Tinto Español!

  signal state_lsr1 : Vector.InMemory_t;
  signal state_lsr3 : Vector.InMemory_t;
  signal state_lsr4 : Vector.InMemory_t;
  signal xor_result : Vector.InMemory_t;
  signal next_bit : std_logic;

begin
  data <= state;

  state_lsr1 <= "0"    & state(Vector.MEMORY_SIZE - 1 downto 1);
  state_lsr3 <= "000"  & state(Vector.MEMORY_SIZE - 3 downto 1);
  state_lsr4 <= "0000" & state(Vector.MEMORY_SIZE - 4 downto 1);

  xor_result <= (state xor state_lsr1 xor state_lsr3 xor state_lsr4);
  next_bit <= xor_result(0);
  
  process(clk)
    begin
      if rising_edge(clk) then
        state <= next_bit & state(Vector.MEMORY_SIZE - 1 downto 1);
      end if;
    end process;

end Behavioral;
