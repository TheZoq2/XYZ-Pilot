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

  	signal	x_pixel	   	: std_logic_vector(9 downto 0);   	-- Horizontal pixel counter
	signal	y_pixel	  	: std_logic_vector(9 downto 0);		-- Vertical pixel counter
  	signal	clk_div	   	: std_logic_vector(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  	signal	clk_25		: std_logic;						-- One pulse width 25 MHz signal

  	signal  blank		: std_logic;                   		-- blanking signal

	constant x_max 			: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(799,10));
	constant x_blank		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(639,10));
	constant x_sync_start	: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(655,10));
	constant x_sync_end		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(751,10));
	constant y_max			: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(520,10));
	constant y_blank		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(479,10));
	constant y_sync_start	: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(489,10));
	constant y_sync_end		: std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(492,10));


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
	
  	-- 25 MHz clock (one system clock pulse width)
  	clk_25 <= '1' when (clk_div = 3) else '0';
	
	
  	-- Horizontal pixel counter

	process(clk)
  	begin
  		if rising_edge(clk) then
      		if(clk_25 = '1') then
				if(x_pixel = x_max) then
					x_pixel <= "0";
				else
					x_pixel <= x_pixel + 1;
				end if;
			end if;
    	end if;
  	end process;


  
  -- Horizontal sync

	process(clk)
  	begin
    	if rising_edge(clk) then
      		if (x_pixel >= x_sync_start and x_pixel < x_sync_end) then
				h_sync <= '0';
			else
				h_sync <= '1';
			end if;
    	end if;
  	end process;
  

  
  -- Vertical pixel counter

 	process(clk)
  	begin
    	if rising_edge(clk) then
      		if(clk_25 = '1') then
				if(y_pixel = y_max) then
					y_pixel <= "0";
				else
					y_pixel <= y_pixel + 1;
				end if;
			end if;
    	end if;
  	end process;

	

  -- Vertical sync

	process(clk)
  	begin
    	if rising_edge(clk) then
      		if (y_pixel >= y_sync_start and y_pixel < y_sync_end) then
				v_sync <= '0';
			else
				v_sync <= '1';
			end if;
    	end if;
  end process;



  
  -- Video blanking signal
	process(clk)
  	begin
    	if rising_edge(clk) then
      		if(x_pixel >= x_blank or y_pixel >= y_blank) then
				blank <= '1';
			else
				blank <= '0';
			end if;
		end if;
  	end process;

	
	-- Read enable 
	process(clk)
	begin
		if rising_edge(clk) then
			if(clk_25 = '1') then
				re <= '1';
			end if;
		else
			re <= '0';
		end if;
	end process;
				

	

	-- Conversion from pixel count to position in memory
	x_mem_pos <= x_pixel(9 downto 1); -- "x_pixel / 2"
	y_mem_pos <= y_pixel(8 downto 1); -- "y_pixel / 2"
	addr <= x_mem_pos & y_mem_pos;

	-- MUX
	pixel_data <= "00000000" when blank = '1' else
								"11111111" when data = '1' else
								"00000000";


end Behavioral;

