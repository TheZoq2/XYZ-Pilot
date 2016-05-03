---- TOP MODULE ----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;   			-- IEEE library for the unsigned type
use work.Vector;
use work.GPU_Info;

entity lab is
	port(clk,rx 	 : in std_logic;						-- System clock,rx
		h_sync		 : out std_logic;					-- Horizontal sync
	 	v_sync		 : out std_logic;					-- Vertical sync
		pixel_data	 : out std_logic_vector(7 downto 0);	-- Data to be sent to the screen
        ps2_kbd_clk	 : in std_logic; 		-- USB keyboard PS2 clock
        ps2_kbd_data : in std_logic;         -- USB keyboard PS2 data
		rst			 : in std_logic;					-- Reset
                seg : out std_logic_vector(7 downto 0);
                an : out std_logic_vector(3 downto 0));
end lab;

architecture Behavioral of lab is

-- UART
component uart is
	port (clk,rx		: in std_logic;								-- System clock
			cpu_clk,we	: out std_logic;
			mem_instr	: out std_logic_vector(63 downto 0) := (others => '0');
			mem_pos		: out std_logic_vector(15 downto 0) := (others => '0'));
end component;

-- KEYBOARD ENCODER
component kbd_enc is
  port ( clk	                : in std_logic;			-- system clock
         ps2_kbd_clk	        : in std_logic; 		-- USB keyboard PS2 clock
         ps2_kbd_data	        : in std_logic;         -- USB keyboard PS2 data
         kbd_reg                : out std_logic_vector(0 to 8) := (others => '0')); 
        -- [SPACE,LEFT,RIGHT,UP,DOWN,W,A,S,D] 1 means key is pushed down, 0 means key is up	
end component;

-- VGA Motor
component vga_motor is
	port (
        clk			    : in std_logic;							-- System clock
		data			: in std_logic;							-- Data from pixel memory
		addr			: out std_logic_vector(16 downto 0);	-- Adress for pixel memory
		re				: out std_logic;						-- Read enable for pixel memory
	 	rst				: in std_logic;							-- Reset
	 	h_sync		    : out std_logic;						-- Horizontal sync
	 	v_sync		    : out std_logic;						-- Vertical sync
		pixel_data		: out std_logic_vector(7 downto 0);	-- Data to be sent to the screen

        write_addr      : out std_logic_vector(16 downto 0);
        write_data      : out std_logic;
        write_enable    : out std_logic;
        vga_done        : out std_logic
    );
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
port (
        clk : in std_logic;
        switch_buffer: in std_logic;

        -- port IN
        gpu_write_adress: in std_logic_vector(16 downto 0);
        gpu_we : in std_logic;
        gpu_write_data : in std_logic;

        -- port IN
        vga_write_adress: in std_logic_vector(16 downto 0);
        vga_we : in std_logic;
        vga_write_data : in std_logic;
        -- port OUT
        vga_read_adress: in std_logic_vector(16 downto 0);
        vga_re : in std_logic;
        vga_read_data : out std_logic
);							-- Read data

end component;

--GPU
component gpu is 
    port(
            clk: in std_logic;

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;

            vga_done: in std_logic
        );
end component;

component dbg_segment
  port (
    clk : in std_logic;
    debug_value : in std_logic_vector(15 downto 0);
    segment_out : out std_logic_vector(7 downto 0);
    segment_n : out std_logic_vector(3 downto 0));
end component;

-- "Fake" signals for writin to pixel_mem
signal gpu_pixel_write_data	:	std_logic;
signal gpu_pixel_write_addr	: 	std_logic_vector(16 downto 0);
signal gpu_pixel_we			:	std_logic;

-- "Fake" signals for reading program_mem
signal program_mem_read_instruction	:	std_logic_vector(63 downto 0);
signal program_mem_read_adress	: 	std_logic_vector(15 downto 0);
signal program_mem_re			:	std_logic;

-- Signals to CPU
signal cpu_clk					: std_logic := '0';
signal kbd_reg                  : std_logic_vector(0 to 8);

-- Signals between vga_motor and pixel_mem
signal vga_pixel_read_data	:	std_logic;
signal vga_pixel_read_addr	: 	std_logic_vector(16 downto 0);
signal vga_pixel_re			:	std_logic;
signal vga_pixel_write_data	:	std_logic;
signal vga_pixel_write_addr	: 	std_logic_vector(16 downto 0);
signal vga_pixel_we			:	std_logic;

signal current_line: unsigned(7 downto 0) := to_unsigned(0, 8);
signal time_at_current: unsigned(31 downto 0) := to_unsigned(0, 32);

-- Signals between uart and program_mem
signal program_mem_write_instruction: std_logic_vector(63 downto 0);
signal program_mem_write_adress: std_logic_vector(15 downto 0);
signal program_mem_we : std_logic;

signal vga_done: std_logic;

-- Debug signals
signal debug_data : std_logic_vector(15 downto 0);

begin
    -- PLS IGNORE
    program_mem_re <= '0';
    program_mem_read_adress <= (others => '0');
    program_mem_read_instruction <= (others => '0');

    --GPU port map
    gpu_map: gpu port map(
                             clk => clk, 
                             pixel_address => gpu_pixel_write_addr,
                             pixel_data => gpu_pixel_write_data,
                             pixel_write_enable => gpu_pixel_we,
                             vga_done => vga_done
                         );

-- Debug
debug_data <= program_mem_write_adress;

-- VGA motor component connection
	U0 : vga_motor port map(
                            clk=>clk,
                            data=>vga_pixel_read_data,
                            addr=>vga_pixel_read_addr, 
                            re=>vga_pixel_re,
                            rst=>rst,
                            h_sync=>h_sync,
                            v_sync=>v_sync,
                            pixel_data=>pixel_data, 
                            vga_done=>vga_done,
                            
                            write_addr => vga_pixel_write_addr,
                            write_data => vga_pixel_write_data,
                            write_enable => vga_pixel_we
                        );
-- Pixel memory component connection
	U1 : pixel_mem port map(
                        clk=>clk,
                        gpu_write_adress => gpu_pixel_write_addr,
                        gpu_write_data => gpu_pixel_write_data,
                        gpu_we => gpu_pixel_we,
                        
                        vga_write_adress => vga_pixel_write_addr,
                        vga_write_data => vga_pixel_write_data,
                        vga_we => vga_pixel_we,
                        vga_read_adress => vga_pixel_read_addr,
                        vga_read_data => vga_pixel_read_data,
                        vga_re  => vga_pixel_re,

                        switch_buffer => vga_done
                    );

-- Program memory component connection
	U2: program_mem port map(clk=>clk, write_adress=>program_mem_write_adress, we=>program_mem_we,
	write_instruction=>program_mem_write_instruction, read_adress=>program_mem_write_adress,
	re=>program_mem_re, read_instruction=>program_mem_read_instruction);
-- UART component connection
	U3: uart port map(clk=>clk,rx=>rx,cpu_clk=>cpu_clk,we=>program_mem_we,
	mem_instr=>program_mem_write_instruction,mem_pos=>program_mem_write_adress);
-- Keyboard Encoder component connection
	U4: kbd_enc port map(clk=>clk,ps2_kbd_clk=>ps2_kbd_clk,ps2_kbd_data=>ps2_kbd_data,
    kbd_reg=>kbd_reg);
-- Debug
        U5 : dbg_segment port map (
          clk         => clk,
          debug_value => debug_data,
          segment_out => seg,
          segment_n   => an);
end Behavioral;
