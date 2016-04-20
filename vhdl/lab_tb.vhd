library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab_tb is
end lab_tb;

architecture Behavioral of lab_tb is

	component lab
		port(clk 		: in std_logic;						-- System clock
			h_sync		: out std_logic;					-- Horizontal sync
	 		v_sync		: out std_logic;					-- Vertical sync
			pixel_data	: out std_logic_vector(7 downto 0);	-- Data to be sent to the screen
			rst			: in std_logic);					-- Reset
	end component;
	
	signal clk						:	std_logic	:= '0';
	signal rst						:	std_logic	:= '0';
	signal h_sync,v_sync			:	std_logic;	
	signal pixel_data				:	std_logic_vector(7 downto 0);
	

begin
	uut: lab port map(
	clk=>clk,
	h_sync=>h_sync,
	v_sync=>v_sync,
	pixel_data=>pixel_data,
	rst=>rst);

	-- clk 100 MHz
	clk <= not clk after 5 ns;

end;

