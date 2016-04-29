library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab_tb is
end lab_tb;

architecture Behavioral of lab_tb is

	component lab
		port(clk,rx 	: in std_logic;						-- System clock,rx
			h_sync		: out std_logic;					-- Horizontal sync
	 		v_sync		: out std_logic;					-- Vertical sync
			pixel_data	: out std_logic_vector(7 downto 0);	-- Data to be sent to the screen
			rst			: in std_logic;					-- Reset
            ps2_kbd_clk	 : in std_logic; 		-- USB keyboard PS2 clock
            ps2_kbd_data : in std_logic         -- USB keyboard PS2 data
        );
	end component;
	
	signal clk						:	std_logic	:= '0';
	signal rst						:	std_logic	:= '0';
	signal h_sync,v_sync			:	std_logic;	
	signal pixel_data				:	std_logic_vector(7 downto 0);
	signal rx 						:	std_logic 	:= '1';
	signal rxs :  std_logic_vector(0 to 239) := "010000000100100000010110000001000100000100010000010110000001001000000101000000010100000001011000000101100000010001000001000100000101100000010010000001010000000101111111110111111111011111111101111111110111111111011111111101111111110111111111";
	

begin
	uut: lab port map(
                clk=>clk,
                rx=>rx,
                h_sync=>h_sync,
                v_sync=>v_sync,
                pixel_data=>pixel_data,
                ps2_kbd_clk => '0',
                ps2_kbd_data => '0',
                rst=>rst
            );

	stimuli_generator : process
    variable i : integer;
  	begin
    wait for 1 us;
    
    for i in 0 to 239 loop
      rx <= rxs(i);
      wait for 8.68 us;
    end loop;  -- i
    
    for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
      wait until rising_edge(clk);
    end loop;  -- i
    wait;
  	end process;

	-- clk 100 MHz
	clk <= not clk after 5 ns;

end;

