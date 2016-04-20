-- VGA MOTOR

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- entity
entity vga_motor is
	port (clk		: in std_logic;								-- System clock
		data		: in std_logic;								-- Data from pixel memory
		addr		: out std_logic_vector(16 downto 0);		-- Adress for pixel memory
		re			: out std_logic;							-- Read enable for pixel memory
	 	rst			: in std_logic;								-- Reset
	 	h_sync	  	: out std_logic;							-- Horizontal sync
	 	v_sync		: out std_logic;							-- Vertical sync
		pixel_data	: out std_logic_vector(7 downto 0));		-- Data to be sent to the screen
		
end vga_motor;


-- architecture
architecture Behavioral of vga_motor is

	signal 	x_mem_pos	: std_logic_vector(8 downto 0); 	-- X memory position
	signal 	y_mem_pos	: std_logic_vector(7 downto 0);		-- Y memory position

  	signal	x_pixel	   	: std_logic_vector(9 downto 0) := "0000000000";   	-- Horizontal pixel counter
	signal	y_pixel	  	: std_logic_vector(9 downto 0) := "0000000000";		-- Vertical pixel counter
  	signal	clk_div	   	: std_logic_vector(1 downto 0) := "00";		-- Clock divisor, to generate 25 MHz signal
  	signal	clk_25		: std_logic;						-- One pulse width 25 MHz signal

  	signal  blank		: std_logic;                   		-- blanking signal

	constant x_max 			: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(799,10));
	constant x_blank		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(641,10));
	constant x_sync_start	: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(656,10));
	constant x_sync_end		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(753,10));
	constant y_max			: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(520,10));
	constant y_blank		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(480,10));
	constant y_sync_start	: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(490,10));
	constant y_sync_end		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(490,10));


begin

  	-- Clock divisor
  	-- Divide system clock (100 MHz) by 4
	process(clk)
  	begin
    	if rising_edge(clk) then
      		if rst='1' then
				clk_div <= (others => '0');
      		else
				clk_div <= clk_div + 1;
     		end if;
   		end if;
  	end process;
	
  	-- Horizontal pixel counter
	process(clk)
  	begin
  		if rising_edge(clk) then
      		if(clk_25 = '1') then
				if(x_pixel = x_max) then
					x_pixel <= "0000000000";
				else
					x_pixel <= x_pixel + 1;
				end if;
			end if;
    	end if;
  	end process;
  
  	-- Vertical pixel counter
 	process(clk)
  	begin
    	if rising_edge(clk) then
      		if(clk_25 = '1') and (x_pixel = x_max)then
				if(y_pixel = y_max) then
					y_pixel <= "0000000000";
				else
					y_pixel <= y_pixel + 1;
				end if;
			end if;
    	end if;
  	end process;
		
  	-- 25 MHz clock (one system clock pulse width)
  	clk_25 <= '1' when (clk_div = 1) else '0';
	
	-- Horizontal sync
	h_sync <= '0' when (x_pixel <= x_sync_end) and (x_pixel >= x_sync_start) else '1';
  
  	-- Vertical sync
	v_sync <= '0' when (y_pixel <= y_sync_end) and (y_pixel >= y_sync_start) else '1';
  
  	-- Video blanking signal
	blank <= '1' when (x_pixel >= x_blank or y_pixel >= y_blank) else '0';

	-- Read Enable
	re <= clk_25;

	-- Conversion from pixel count to position in memory
	x_mem_pos <= x_pixel(9 downto 1) when (blank = '0') else (others => '0'); -- "x_pixel / 2"
	y_mem_pos <= y_pixel(8 downto 1) when (blank = '0') else (others => '0'); -- "y_pixel / 2"
	addr <= (x_mem_pos & y_mem_pos);

	-- MUX
	-- data = 1 represent white pixel, data = 0 represent black pixel
	pixel_data <= "00000000" when blank = '1' else
				"11111111" when data = '1' else
				"00000000";


end Behavioral;

