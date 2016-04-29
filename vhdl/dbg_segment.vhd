-- DEBUG SEGMENT DISPLAY

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- entity
entity dbg_segment is
	port (clk		: in std_logic;								-- System clock
              debug_value : in std_logic_vector(15 downto 0);
              segment_out : out std_logic_vector(7 downto 0);
              segment_n : out std_logic_vector(3 downto 0));
end dbg_segment;


-- architecture
architecture Behavioral of dbg_segment is
  constant clk_mod : std_logic_vector(23 downto 0) := X"0186A0";

  signal clk_n : std_logic_vector(23 downto 0) := (others => '0');

  signal displayed_value : std_logic_vector(3 downto 0) := (others => '0');
  signal displayed_n : std_logic_vector(3 downto 0) := "1110";

  begin

    -- Number counter
    segment_n <= displayed_n;
    process(clk)
      begin
        if rising_edge(clk) then
          if clk_n = clk_mod then
            clk_n <= X"000000";
            displayed_n <= displayed_n(2 downto 0) & displayed_n(3);
          else
            clk_n <= clk_n + '1';
          end if;
        end if;
      end process;

    -- Display mapping
    with displayed_n select
      displayed_value <=
      debug_value(3 downto 0) when "1110",
      debug_value(7 downto 4) when "1101",
      debug_value(11 downto 8) when "1011",
      debug_value(15 downto 12) when others;

    -- Segment mapping
    with displayed_value select
      segment_out <=
      "11000000" when "0000",
      "11111001" when "0001",
      "10100100" when "0010",
      "10110000" when "0011",
      "10011001" when "0100",
      "10010010" when "0101",
      "10000010" when "0110",
      "11111000" when "0111",
      "10000000" when "1000",
      "10010000" when "1001",
      "10001000" when "1010",
      "10000011" when "1011",
      "11000110" when "1100",
      "10100001" when "1101",
      "10000110" when "1110",
      "10001110" when "1111",
      "11000001" when others;

end Behavioral;

