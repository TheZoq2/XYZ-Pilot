---- TOP MODULE ----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;   			-- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Vector;
--use work.GPU_Info;

entity lab is
	port(clk,rx 	 : in std_logic;						-- System clock,rx
		h_sync		 : out std_logic;					-- Horizontal sync
	 	v_sync		 : out std_logic;					-- Vertical sync
		pixel_data	 : out std_logic_vector(7 downto 0);	-- Data to be sent to the screen
        ps2_kbd_clk	 : in std_logic; 		-- USB keyboard PS2 clock
        ps2_kbd_data : in std_logic;         -- USB keyboard PS2 data
		rst			 : in std_logic;					-- Reset
        seg : out std_logic_vector(7 downto 0);
        an : out std_logic_vector(3 downto 0);
        Led :  out  std_logic_vector(7 downto 0) := (others => '0'));
end lab;

architecture Behavioral of lab is

-- CPU
component cpu is
	port (clk		: in std_logic;								-- System clock
			pm_instruction : in std_logic_vector(63 downto 0);	-- Instruction from program memory
			pc_out		: out std_logic_vector(15 downto 0) := (others => '0'); -- Program Counter
            pc_re       : out std_logic; -- Write Enable to be sent to program mem
            debuginfo   : out std_logic_vector(15 downto 0));
end component;

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
    read_data : out std_logic
);							-- Read data

end component;

--GPU
component gpu is 
    port(
            clk: in std_logic;

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic

        );
end component;




-- DEBUG COMPONENT
component dbg_segment
  port (
    clk : in std_logic;
    debug_value : in std_logic_vector(15 downto 0);
    segment_out : out std_logic_vector(7 downto 0);
    segment_n : out std_logic_vector(3 downto 0));
end component;

-- "Fake" signals for writing to pixel_mem
signal pixel_mem_write_data	:	std_logic;
signal pixel_mem_write_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_we			:	std_logic;

-- Signals between cpu and program_mem
signal program_mem_read_instruction	:	std_logic_vector(63 downto 0);
signal program_mem_read_adress	: 	std_logic_vector(15 downto 0) := (others => '0');
signal program_mem_re			:	std_logic;

-- Signals to CPU
signal cpu_clk					: std_logic := '0';
signal kbd_reg                  : std_logic_vector(0 to 8);

-- Signals between vga_motor and pixel_mem
signal pixel_mem_read_data	:	std_logic;
signal pixel_mem_read_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_re			:	std_logic;

signal current_line: unsigned(7 downto 0) := to_unsigned(0, 8);
signal time_at_current: unsigned(31 downto 0) := to_unsigned(0, 32);

-- Signals between uart and program_mem
signal program_mem_write_instruction: std_logic_vector(63 downto 0);
signal program_mem_write_adress: std_logic_vector(15 downto 0);
signal program_mem_we : std_logic;

-- Debug signals
signal debug_data : std_logic_vector(15 downto 0);
signal cpu_debug_data : std_logic_vector(15 downto 0);
signal pm_debug_data : std_logic_vector(15 downto 0);

signal slow_clk_counter : std_logic_vector(21 downto 0) := (0 => '1',others => '0');
signal slow_clk         : std_logic := '0';

signal debug_mem_pos    : std_logic_vector(15 downto 0) := (others => '0'); 
signal debug_mem_instr  : std_logic_vector(63 downto 0) := (others => '0'); 


begin

  -- DEBUG PROCESSES --
  process(clk)
  begin
  if rising_edge(clk) then
    slow_clk_counter <= slow_clk_counter + 1;
  end if;
  end process;
  
  --process(clk)
  --begin
    --if rising_edge(clk) then
      --if slow_clk_counter = 0 then
        --if program_mem_read_adress = 15 then
          --program_mem_read_adress <= (others => '0');
        --else
          --program_mem_read_adress <= program_mem_read_adress + 1;
        --end if;
        --program_mem_re <= '1';
      --end if;
    --end if;
  --end process;
  Led <=  program_mem_read_adress(7 downto 0);
  slow_clk <= cpu_clk when slow_clk_counter = 0 else '0';
    -- PLS IGNORE

    gpu_map: gpu port map(
                             clk => clk, 
                             pixel_address => pixel_mem_write_addr,
                             pixel_data => pixel_mem_write_data,
                             pixel_write_enable => pixel_mem_we
                         );

-- Debug
debug_data <= cpu_debug_data;

-- CPU component connection
    CPUCOMP : cpu port map(clk=>slow_clk,pm_instruction=>program_mem_read_instruction,
    pc_out=>program_mem_read_adress,
pc_re=>program_mem_re,
debuginfo=>cpu_debug_data);
-- VGA motor component connection
	VGAMOTOR : vga_motor port map(clk=>clk, data=>pixel_mem_read_data, addr=>pixel_mem_read_addr,
	re=>pixel_mem_re, rst=>rst, h_sync=>h_sync, v_sync=>v_sync, pixel_data=>pixel_data);
-- Pixel memory component connection
	PIXELMEM : pixel_mem port map(clk=>clk, write_adress=>pixel_mem_write_addr, we=>pixel_mem_we, 
	write_data=>pixel_mem_write_data, read_adress=>pixel_mem_read_addr, re=>pixel_mem_re,
	read_data=>pixel_mem_read_data);
-- Program memory component connection
	PROGRAMMEM: program_mem port map(clk=>clk, write_adress=>program_mem_write_adress, we=>program_mem_we,
	write_instruction=>program_mem_write_instruction, read_adress=>program_mem_read_adress,
	re=>program_mem_re, read_instruction=>program_mem_read_instruction);
-- UART component connection
	UARTCOMP: uart port map(clk=>clk,rx=>rx,cpu_clk=>cpu_clk,we=>program_mem_we,
	mem_instr=>program_mem_write_instruction,mem_pos=>program_mem_write_adress);
-- Keyboard Encoder component connection
	KBDENC: kbd_enc port map(clk=>clk,ps2_kbd_clk=>ps2_kbd_clk,ps2_kbd_data=>ps2_kbd_data,
    kbd_reg=>kbd_reg);
-- Debug
   DEBUG : dbg_segment port map (
          clk         => clk,
          debug_value => debug_data,
          segment_out => seg,
          segment_n   => an);

end Behavioral;
