---- TOP MODULE ----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;   			-- IEEE library for the unsigned type

entity lab is
	port(clk 		: in std_logic;						-- System clock
		h_sync		: out std_logic;					-- Horizontal sync
	 	v_sync		: out std_logic;					-- Vertical sync
		pixel_data	: out std_logic_vector(7 downto 0);	-- Data to be sent to the screen
		rst			: in std_logic);					-- Reset
end lab;

architecture Behavioral of lab is

-- VGA Motor
component vga_motor is
	port (clk			: in std_logic;							-- System clock
		data			: in std_logic;							-- Data from pixel memory
		addr			: out std_logic_vector(16 downto 0);	-- Adress for pixel memory
		re				: out std_logic;						-- Read enable for pixel memory
	 	rst				: in std_logic;							-- Reset
	 	h_sync		    : out std_logic;						-- Horizontal sync
	 	v_sync		    : out std_logic;						-- Vertical sync
		pixel_data		: out std_logic_vector(7 downto 0));	-- Data to be sent to the screen
end component;

-- Pixel Memory
component pixel_mem is
port (clk : in std_logic;
    -- port IN
    write_adress: in std_logic_vector(16 downto 0);		-- Write adress	
    we : in std_logic;									-- Write enable
    write_data : in std_logic;							-- Write data
    -- port OUT
    read_adress: in std_logic_vector(16 downto 0);		-- Read adress
    re : in std_logic;									-- Read enable
    read_data : out std_logic);							-- Read data
end component;

-- "Fake" signals for writin to pixel_mem
signal pixel_mem_write_data	:	std_logic;
signal pixel_mem_write_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_we			:	std_logic;

-- Signals between vga_motor and pixel_mem
signal pixel_mem_read_data	:	std_logic;
signal pixel_mem_read_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_re			:	std_logic;

begin

-- PLS IGNORE
pixel_mem_write_data <= '0';
pixel_mem_write_addr <= std_logic_vector(to_unsigned(0,17));
pixel_mem_we <= '0';

-- VGA motor component connection
	U0 : vga_motor port map(clk=>clk, data=>pixel_mem_read_data, addr=>pixel_mem_read_addr,
	re=>pixel_mem_re, rst=>rst, h_sync=>h_sync, v_sync=>v_sync, pixel_data=>pixel_data);

-- Pixel memory component connection
	U1 : pixel_mem port map(clk=>clk, write_adress=>pixel_mem_write_addr, we=>pixel_mem_we, 
	write_data=>pixel_mem_write_data, read_adress=>pixel_mem_read_addr, re=>pixel_mem_we,
	read_data=>pixel_mem_read_data);

end Behavioral;
