---- TOP MODULE ----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;   			-- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;
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
        seg : out std_logic_vector(7 downto 0);   -- Data for the 7-seg display
        an : out std_logic_vector(3 downto 0);    -- Data for the 7-seg display
        Led :  out  std_logic_vector(7 downto 0) := (others => '0')); -- Debug info for leds
end lab;

architecture Behavioral of lab is

-- CPU
component cpu is
	port (clk		: in std_logic;								-- System clock
			pm_instruction : in std_logic_vector(63 downto 0);	-- Instruction from program memory
			pc_out		: out std_logic_vector(15 downto 0) := (others => '0'); -- Program Counter
            pc_re       : out std_logic := '1'; -- Read Enable to be sent to program mem
            obj_mem_data : out std_logic_vector(63 downto 0); -- Data to be sent to object memory
            obj_mem_adress : out std_logic_vector(8 downto 0); -- The adress to be sent to object memory
            obj_mem_we  : out std_logic; -- Write Enable for object memory
            frame_done  : in std_logic; -- Signal from vga_motor informing that a full frame has been displayed
            kbd_reg     : in std_logic_vector(6 downto 0) := (others => '0'); -- Signal from kbd_enc showing which 
                                                                              -- keys are being pressed down
            debuginfo   : out std_logic_vector(15 downto 0) := (others => '0')); -- Info to be shown on the 7-seg
end component;

-- UART
component uart is
	port (clk,rx		: in std_logic;								-- System clock
			we	        : out std_logic;                            -- Write Enable to program mem
			mem_instr	: out std_logic_vector(63 downto 0) := (others => '0'); -- Instruction to be sent to pm
			mem_pos		: out std_logic_vector(15 downto 0) := (others => '0')); -- The adress to be sent to pm
end component;

-- KEYBOARD ENCODER
component kbd_enc is
  port ( clk	                : in std_logic;			-- system clock (100 MHz)
         ps2_kbd_clk	        : in std_logic; 		-- USB keyboard PS2 clock
         ps2_kbd_data	        : in std_logic;         -- USB keyboard PS2 data
         kbd_reg                : out std_logic_vector(0 to 6) := (others => '0')); 
        -- [W,A,S,D,SPACE,J,L] 1 means key is pushed down, 0 means key is up	
end component;

-- VGA Motor
component vga_motor is
	port (
        clk		    : in std_logic;							-- System clock, because this already is 25 MHz, we dont 
                                                            -- have to use clk_25
		data		: in std_logic;							-- Data from pixel memory
		addr		: out std_logic_vector(16 downto 0);	-- Adress for pixel memory
		re			: out std_logic;						-- Read enable for pixel memory
	 	rst			: in std_logic;							-- Reset
	 	h_sync	  	: out std_logic;						-- Horizontal sync
	 	v_sync		: out std_logic;						-- Vertical sync
		pixel_data	: out std_logic_vector(7 downto 0);     -- Data to be sent to the screen

        write_addr  : out std_logic_vector(16 downto 0);    -- Adress for clearing pixel_mem
        write_data  : out std_logic;                        -- Data to be sent to pixel_mem (=0)
        write_enable: out std_logic;                        -- Write Enable to be sent to pixel_mem
        vga_done : out std_logic                      -- 1 when gpu and vga should switch buffers,
                                                      -- and when cpu should start working, if waiting

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
        switch_buffer: in std_logic; -- One pulse, decides when to switch buffers
        -- port IN
        gpu_write_adress: in std_logic_vector(16 downto 0);
        gpu_we : in std_logic;
        gpu_write_data : in std_logic;
        -- port IN (for clearing after reading)
        vga_write_adress: in std_logic_vector(16 downto 0);
        vga_we : in std_logic;
        vga_write_data : in std_logic;
        -- port OUT
        vga_read_adress: in std_logic_vector(16 downto 0);
        vga_re : in std_logic;
        vga_read_data : out std_logic
    );
end component;

-- Object memory
component ObjMem is
port (
        clk : in std_logic;
        -- port 1
        read_addr : in GPU_Info.ObjAddr_t;
        read_data : out GPU_Info.ObjData_t;
        -- port 2
        write_addr : in GPU_Info.ObjAddr_t;
        write_data : in GPU_Info.ObjData_t;
        we         : in std_logic := '0'
    );
end component;

--GPU
component GPU is
    port(
            clk: in std_logic;

            obj_mem_addr: out GPU_Info.ObjAddr_t;
            obj_mem_data: in GPU_Info.ObjData_t := x"0000000000000000";

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;
        
            vga_done: in std_logic
        );
end component;




-- Debuf component (score display in final product)
component dbg_segment
  port (
    clk : in std_logic;
    debug_value : in std_logic_vector(15 downto 0);
    segment_out : out std_logic_vector(7 downto 0);
    segment_n : out std_logic_vector(3 downto 0));
end component;

-- Signals between gpu and pixel_mem
signal gpu_pixel_write_data	:	std_logic;
signal gpu_pixel_write_addr	: 	std_logic_vector(16 downto 0);
signal gpu_pixel_we			:	std_logic;

-- Signals between program_mem and cpu 
signal program_mem_read_instruction	:	std_logic_vector(63 downto 0);
signal program_mem_read_adress	: 	std_logic_vector(15 downto 0) := (others => '0');
signal program_mem_re			:	std_logic;

-- Signals between cpu and object memory
signal object_mem_write_adress :   std_logic_vector(8 downto 0) := (others => '0');
signal object_mem_write_adress_unsigned :   GPU_Info.ObjAddr_t := (others => '0');
signal object_mem_write_data :   GPU_Info.ObjData_t := (others => '0');
signal object_mem_we :   std_logic := '0';

-- Signals between object memory and gpu
signal object_mem_read_adress :   GPU_Info.ObjAddr_t;
signal object_mem_read_data :   GPU_Info.ObjData_t;


-- Signal between kbd_enc and cpu
signal kbd_reg                  : std_logic_vector(6 downto 0);

-- Signals between vga_motor and pixel_mem
signal vga_pixel_read_data	:	std_logic;
signal vga_pixel_read_addr	: 	std_logic_vector(16 downto 0);
signal vga_pixel_re			:	std_logic;
signal vga_pixel_write_data	:	std_logic;
signal vga_pixel_write_addr	: 	std_logic_vector(16 downto 0);
signal vga_pixel_we			:	std_logic;


-- Signals between uart and program_mem
signal program_mem_write_instruction: std_logic_vector(63 downto 0);
signal program_mem_write_adress: std_logic_vector(15 downto 0);
signal program_mem_we : std_logic;

-- In order to function correctly we have to slow the system down to 25 MHz
signal slow_clk_counter: std_logic_vector(1 downto 0) := "00";
signal slow_clk: std_logic;

-- Signal between vga_motor and cpu
signal vga_done: std_logic;

-- Debug signals that in the final product shows score in game
signal debug_data : std_logic_vector(15 downto 0);
signal cpu_debug_data : std_logic_vector(15 downto 0);



begin
  -- Converting signal from std_logic_vector to unsigned
  object_mem_write_adress_unsigned <= unsigned(object_mem_write_adress);

    process(clk) begin
        if rising_edge(clk) then
            slow_clk_counter <= slow_clk_counter + 1;
        end if;
    end process;

    slow_clk <= '1' when slow_clk_counter = 0 else '0';

  Led <=  program_mem_read_adress(7 downto 0);

    --GPU port map
    gpu_map: gpu port map(
                             clk => slow_clk, 
                             obj_mem_addr=>object_mem_read_adress,
                             obj_mem_data=>object_mem_read_data,
                             pixel_address => gpu_pixel_write_addr,
                             pixel_data => gpu_pixel_write_data,
                             pixel_write_enable => gpu_pixel_we,
                             vga_done => vga_done
                         );

    -- Debug / Score
    debug_data <= cpu_debug_data;

    -- CPU component connection
    CPUCOMP : cpu port map(clk=>slow_clk,pm_instruction=>program_mem_read_instruction,
            pc_out=>program_mem_read_adress,
            pc_re=>program_mem_re,
            obj_mem_data=>object_mem_write_data,
            obj_mem_adress=>object_mem_write_adress,
            obj_mem_we=>object_mem_we,
            frame_done=>vga_done,
            kbd_reg=>kbd_reg,
            debuginfo=>cpu_debug_data);

    -- VGA motor component connection
	VGAMOTOR : vga_motor port map(
                            clk=>slow_clk,
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
   -- Object memory component connection
   OBJECTMEM : ObjMem port map(
                           clk=>slow_clk,
                           read_addr=>object_mem_read_adress,
                           read_data=>object_mem_read_data,
                           write_addr=>object_mem_write_adress_unsigned,
                           write_data=>object_mem_write_data,
                           we=>object_mem_we);

    -- Pixel memory component connection
	PIXELMEM : pixel_mem port map(
                        clk=>slow_clk,
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
	PROGRAMMEM: program_mem port map(clk=>slow_clk, write_adress=>program_mem_write_adress, we=>program_mem_we,
	write_instruction=>program_mem_write_instruction, read_adress=>program_mem_read_adress,
	re=>program_mem_re, read_instruction=>program_mem_read_instruction);
-- UART component connection
	UARTCOMP: uart port map(clk=>slow_clk,rx=>rx,we=>program_mem_we,
	mem_instr=>program_mem_write_instruction,mem_pos=>program_mem_write_adress);
-- Keyboard Encoder component connection
	KBDENC: kbd_enc port map(clk=>slow_clk,ps2_kbd_clk=>ps2_kbd_clk,ps2_kbd_data=>ps2_kbd_data,
    kbd_reg=>kbd_reg);
-- Debug / Score display
   DEBUG : dbg_segment port map (
          clk         => slow_clk,
          debug_value => debug_data,
          segment_out => seg,
          segment_n   => an);
end Behavioral;
