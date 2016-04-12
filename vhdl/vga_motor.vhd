-- VGA MOTOR

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity vga_motor is
	port ( clk			: in std_logic;
		data			: in std_logic;
		addr			: out std_logic_vector(16 downto 0);
	 	rst			: in std_logic;
	 	h_sync		        : out std_logic;
	 	v_sync		        : out std_logic
		pixel_data	: out std_logic_vector(7 downto 0));
		
end vga_motor;


-- architecture
architecture Behavioral of vga_motor is

	signal 	x_mem_pos				: std_logic_vector(8 downto 0); 	-- X memory position
	signal 	y_mem_pos				: std_logic_vector(7 downto 0);		-- Y memory position

  signal	x_pixel	        : std_logic_vector(9 downto 0);   -- Horizontal pixel counter
  signal	y_pixel	        : std_logic_vector(9 downto 0);		-- Vertical pixel counter
  signal	clk_div	        : std_logic_vector(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	clk_25					: std_logic;			-- One pulse width 25 MHz signal

  signal  blank				    : std_logic;                    -- blanking signal

	constant x_max 						: std_logic_vector(9 downto 0) := 799;
	constant x_blank					: std_logic_vector(9 downto 0) := 639;
	constant x_sync_start			: std_logic_vector(9 downto 0) := 655;
	constant x_sync_end				: std_logic_vector(9 downto 0) := 751;
	constant y_max						: std_logic_vector(9 downto 0) := 520;
	constant y_blank					: std_logic_vector(9 downto 0) := 479;
	constant y_sync_start			: std_logic_vector(9 downto 0) := 489;
	constant y_sync_end				: std_logic_vector(9 downto 0) := 492;


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
					x_pixel <= '0';
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
				h_sync = '0';
			else
				h_sync = '1';
			end if;
    end if;
  end process;
  

  
  -- Vertical pixel counter

 	process(clk)
  begin
    if rising_edge(clk) then
      if(clk_25 = '1') then
				if(y_pixel = y_max) then
					y_pixel <= '0';
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
				v_sync = '0';
			else
				v_sync = '1';
			end if;
    end if;
  end process;



  
  -- Video blanking signal
	process(clk)
  begin
    if rising_edge(clk) then
      if(x_pixel >= x_blank or y_pixel >= y_blank) then
				blank = '1';
			else
				blank = '0';
			end if;
		end if;
  end process;

	

	-- Conversion from pixel count to position in memory
	x_mem_pos <= x_pixel/2;
	y_mem_pos <= y_pixel/2;
	addr <= x_mem_pos & y_mem_pos;

	-- MUX
	with blank select
		pixel_data <= 0 when 1,
									data*255 when others;
  
	


  -- Tile memory address composite
  tileAddr <= unsigned(data(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);


  -- Picture memory address composite
  addr <= to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);


end Behavioral;

