library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lf_tb is
end lf_tb;

use work.Vector;

architecture Behavioral of lf_tb is

component LinearFeedbackSR is
	port (clk		: in std_logic;								-- System clock
              data : out Vector.InMemory_t); 
end component;
	
signal clk : std_logic := '0';
signal data : Vector.InMemory_t;

begin
	uut: LinearFeedbackSR port map(
	clk=>clk,
        data=>data);

	-- clk 100 MHz
	clk <= not clk after 5 ns;

end;

