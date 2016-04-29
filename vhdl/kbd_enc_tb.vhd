library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity kbd_enc_tb is
end kbd_enc_tb;

architecture Behavioral of kbd_enc_tb is

	component kbd_enc is
  	port ( clk	                : in std_logic;			-- system clock (100 MHz)
         ps2_kbd_clk	        : in std_logic; 		-- USB keyboard PS2 clock
         ps2_kbd_data	        : in std_logic;         -- USB keyboard PS2 data
         kbd_reg                : out std_logic_vector(8 downto 0)); 
        -- [SPACE,LEFT,RIGHT,UP,DOWN,W,A,S,D] 1 means key is pushed down, 0 means key is up	
	end component;
	
	signal clk						:	std_logic	:= '0';
	signal ps2_kbd_clk			:	std_logic := '1';	
	signal ps2_kbd_data		: std_logic := '1';
	signal kbd_reg			: std_logic_vector(8 downto 0);
	signal a :  std_logic_vector(0 to 10) := "00011100001";
    signal up:  std_logic_vector(0 to 21) := "0000001110101010111001";
    signal end_a :  std_logic_vector(0 to 21) := "0000011110100011100001";
    signal end_up:  std_logic_vector(0 to 32) := "000001111010000001110101010111001";
	

begin
	uut: kbd_enc port map(
	clk=>clk,
    ps2_kbd_clk=>ps2_kbd_clk,
    ps2_kbd_data=>ps2_kbd_data,
    kbd_reg=>kbd_reg);

	stimuli_generator : process
    variable i : integer;
  	begin
    wait for 1 us;
    
    for i in 0 to 10 loop -- A
      ps2_kbd_data <= a(i);
      ps2_kbd_clk <= '1';
      wait for 1 us;
      ps2_kbd_clk <= '0';
      wait for 1 us;
    end loop;
    ps2_kbd_clk <= '1';
    wait for 50 us;
    for i in 0 to 21 loop -- UP
      ps2_kbd_data <= up(i);
      ps2_kbd_clk <= '1';
      wait for 1 us;
      ps2_kbd_clk <= '0';
      wait for 1 us;
    end loop;
    ps2_kbd_clk <= '1';
    wait for 50 us;
    for i in 0 to 21 loop -- END A
      ps2_kbd_data <= end_a(i);
      ps2_kbd_clk <= '1';
      wait for 1 us;
      ps2_kbd_clk <= '0';
      wait for 1 us;
    end loop;
    ps2_kbd_clk <= '1';
    wait for 50 us;
    for i in 0 to 32 loop -- END UP
      ps2_kbd_data <= end_up(i);
      ps2_kbd_clk <= '1';
      wait for 1 us;
      ps2_kbd_clk <= '0';
      wait for 1 us;
    end loop;
    ps2_kbd_clk <= '1';
    
    for i in 0 to 50000000 loop -- Vänta ett antal klockcykler
      wait until rising_edge(clk);
    end loop;  -- i
    wait;
  	end process;

	-- clk 100 MHz
	clk <= not clk after 5 ns;

end;

