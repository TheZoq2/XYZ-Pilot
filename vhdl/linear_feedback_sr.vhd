library IEEE;

use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

use work.Vector;

entity LinearFeedbackSR is
port (
        clk : in std_logic;
        next_bit_out : out Vector.InMemory_t;
        data : out Vector.InMemory_t
    );
end entity;

architecture Behavioral of LinearFeedbackSR is
  signal state : Vector.InMemory_t := x"040815162342_2760";  -- Vino Tinto Español!
  signal next_bit : Vector.InMemory_t := (others => '0');
  signal action : std_logic := '0';

begin

  data <= state;
  next_bit_out <= next_bit;

  process(clk)
    begin
      if rising_edge(clk) then
        action <= not action;
        if action='0' then
          next_bit <= (((state XOR ("0" & state(Vector.MEMORY_SIZE - 1 downto 1))) XOR ("000" & state(Vector.MEMORY_SIZE - 3 downto 1))) XOR ("0000" & state(Vector.MEMORY_SIZE - 4 downto 1))) and x"0000000000000001";
        else
          state <= next_bit(0) & state(Vector.MEMORY_SIZE - 1 downto 1);
        end if;
      end if;
    end process;

end Behavioral;
