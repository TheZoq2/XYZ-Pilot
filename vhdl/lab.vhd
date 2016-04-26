---- TOP MODULE ----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;   			-- IEEE library for the unsigned type

entity lab is
	port(clk,rx 	: in std_logic;						-- System clock,rx
		h_sync		: out std_logic;					-- Horizontal sync
	 	v_sync		: out std_logic;					-- Vertical sync
		pixel_data	: out std_logic_vector(7 downto 0);	-- Data to be sent to the screen
		rst			: in std_logic);					-- Reset
end lab;

architecture Behavioral of lab is

-- UART
component uart is
	port (clk,rx		: in std_logic;								-- System clock
			cpu_clk,we	: out std_logic;
			mem_instr	: out std_logic_vector(63 downto 0) := (others => '0');
			mem_pos		: out std_logic_vector(15 downto 0) := (others => '0'));
end component;

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

 -- Program Memory
component program_mem is
port (clk : in std_logic;
    -- port IN
    write_adress: in std_logic_vector(15 downto 0);
    we : in std_logic;
    write_instruction : in std_logic_vector(63 downto 0);
    -- port OUT
    read_adress: in std_logic_vector(15 downto 0);
    re : in std_logic;
    read_instruction : out std_logic_vector(63 downto 0));
end component;

-- Pixel Memory
component pixel_mem is
port (clk : in std_logic;
    -- port IN
    write_adress: in std_logic_vector(16 downto 0);		-- Write adress	
    we : in std_logic;									-- Write Enable
    write_data : in std_logic;							-- Write data
    -- port OUT
    read_adress: in std_logic_vector(16 downto 0);		-- Read adress
    re : in std_logic;									-- Read Enable
    read_data : out std_logic);							-- Read data
end component;

-- Signals 
signal cpu_clk					: std_logic := '0';

-- "Fake" signals for writin to pixel_mem
signal pixel_mem_write_data	:	std_logic;
signal pixel_mem_write_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_we			:	std_logic;

-- "Fake" signals for reading program_mem
signal program_mem_read_instruction	:	std_logic_vector(63 downto 0);
signal program_mem_read_adress	: 	std_logic_vector(15 downto 0);
signal program_mem_re			:	std_logic;

-- Signals between vga_motor and pixel_mem
signal pixel_mem_read_data	:	std_logic;
signal pixel_mem_read_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_re			:	std_logic;

-- Signals between uart and program_mem
signal program_mem_write_instruction: std_logic_vector(63 downto 0);
signal program_mem_write_adress: std_logic_vector(15 downto 0);
signal program_mem_we : std_logic;


begin

-- PLS IGNORE
pixel_mem_we <= '0';
pixel_mem_write_data <= '0';
pixel_mem_write_addr <= (others => '0');
program_mem_re <= '0';
program_mem_read_adress <= (others => '0');
program_mem_read_instruction <= (others => '0');

-- VGA motor component connection
	U0 : vga_motor port map(clk=>clk, data=>pixel_mem_read_data, addr=>pixel_mem_read_addr,
	re=>pixel_mem_re, rst=>rst, h_sync=>h_sync, v_sync=>v_sync, pixel_data=>pixel_data);
-- Pixel memory component connection
	U1 : pixel_mem port map(clk=>clk, write_adress=>pixel_mem_write_addr, we=>pixel_mem_we, 
	write_data=>pixel_mem_write_data, read_adress=>pixel_mem_read_addr, re=>pixel_mem_re,
	read_data=>pixel_mem_read_data);
-- Program memory component connection
	U2: program_mem port map(clk=>clk, write_adress=>program_mem_write_adress, we=>program_mem_we,
	write_instruction=>program_mem_write_instruction, read_adress=>program_mem_write_adress,
	re=>program_mem_re, read_instruction=>program_mem_read_instruction);
-- UART component connection
	U3: uart port map(clk=>clk,rx=>rx,cpu_clk=>cpu_clk,we=>program_mem_we,
	mem_instr=>program_mem_write_instruction,mem_pos=>program_mem_write_adress);


end Behavioral;
