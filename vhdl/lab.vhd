---- TOP MODULE ----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;   			-- IEEE library for the unsigned type
use work.Vector;
use work.GPU_Info;

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
    we : in std_logic;									-- Write Enable
    write_data : in std_logic;							-- Write data
    -- port OUT
    read_adress: in std_logic_vector(16 downto 0);		-- Read adress
    re : in std_logic;									-- Read Enable
    read_data : out std_logic);							-- Read data
end component;

--GPU
component gpu is 
    port(
            clk: in std_logic;

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;

            dbg_draw_start: in Vector.Elements_t;
            dbg_draw_end: in Vector.Elements_t
        );
end component;
--signals for the gpu
signal draw_start: Vector.Elements_t;
signal draw_end: Vector.Elements_t;


-- "Fake" signals for writin to pixel_mem
signal pixel_mem_write_data	:	std_logic;
signal pixel_mem_write_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_we			:	std_logic;

-- Signals between vga_motor and pixel_mem
signal pixel_mem_read_data	:	std_logic;
signal pixel_mem_read_addr	: 	std_logic_vector(16 downto 0);
signal pixel_mem_re			:	std_logic;

signal current_line: unsigned(7 downto 0) := to_unsigned(0, 8);
signal time_at_current: unsigned(31 downto 0) := to_unsigned(0, 32);

begin

    process(clk) begin
        if rising_edge(clk) then
            time_at_current <= time_at_current + 1;

            if time_at_current = to_unsigned(100000000, 32) then
                if current_line = 7 then
                    current_line <= current_line + 1;
                else
                    current_line <= current_line + 1;
                end if;

                time_at_current <= to_unsigned(0, time_at_current'length);
            else
                if current_line = 0 then
                    draw_start(0) <= to_signed(170, 16);
                    draw_start(1) <= to_signed(120, 16);

                    draw_end(0) <= to_signed(140, 16);
                    draw_end(1) <= to_signed(120, 16);
                elsif current_line = 1 then
                    draw_end(0) <= to_signed(200, 16);
                    draw_end(1) <= to_signed(120, 16);
                elsif current_line = 2 then
                    draw_end(0) <= to_signed(170, 16);
                    draw_end(1) <= to_signed(90, 16);
                elsif current_line = 3 then
                    draw_end(0) <= to_signed(170, 16);
                    draw_end(1) <= to_signed(150, 16);
                elsif current_line = 4 then
                    draw_end(0) <= to_signed(100, 16);
                    draw_end(1) <= to_signed(25, 16);
                elsif current_line = 5 then
                    draw_end(0) <= to_signed(100, 16);
                    draw_end(1) <= to_signed(25, 16);
                elsif current_line = 6 then
                    draw_end(0) <= to_signed(100, 16);
                    draw_end(1) <= to_signed(25, 16);
                elsif current_line = 7 then
                    draw_end(0) <= to_signed(100, 16);
                    draw_end(1) <= to_signed(25, 16);
                end if;
            end if;
        end if;
    end process;

    gpu_map: gpu port map(
                             clk => clk, 
                             pixel_address => pixel_mem_write_addr,
                             pixel_data => pixel_mem_write_data,
                             pixel_write_enable =>pixel_mem_we,
                             dbg_draw_start => draw_start,
                             dbg_draw_end => draw_end
                         );

-- VGA motor component connection
	U0 : vga_motor port map(clk=>clk, data=>pixel_mem_read_data, addr=>pixel_mem_read_addr,
	re=>pixel_mem_re, rst=>rst, h_sync=>h_sync, v_sync=>v_sync, pixel_data=>pixel_data);

-- Pixel memory component connection
	U1 : pixel_mem port map(clk=>clk, write_adress=>pixel_mem_write_addr, we=>pixel_mem_we, 
	write_data=>pixel_mem_write_data, read_adress=>pixel_mem_read_addr, re=>pixel_mem_re,
	read_data=>pixel_mem_read_data);

end Behavioral;
