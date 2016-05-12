
-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity kbd_enc is
  port ( clk	                : in std_logic;			-- system clock (100 MHz)
         ps2_kbd_clk	        : in std_logic; 		-- USB keyboard PS2 clock
         ps2_kbd_data	        : in std_logic;         -- USB keyboard PS2 data
         test                   : out std_logic_vector(3 downto 0) := "0000";
         testbit                : out std_logic := '0';
         kbd_reg                : out std_logic_vector(0 to 6) := (others => '0')); 
        -- [W,A,S,D,SPACE,J,L] 1 means key is pushed down, 0 means key is up	
end kbd_enc;

-- architecture
architecture behavioral of kbd_enc is
  signal ps2_clk		: std_logic;			-- Synchronized PS2 clock
  signal ps2_data		: std_logic;			-- Synchronized PS2 data
  signal ps2_clk_q1     : std_logic := '1';
  signal ps2_clk_q2 	: std_logic := '0';	    -- PS2 clock one pulse flip flop
  signal ps2_clk_op 		: std_logic;		-- PS2 clock one pulse 
	
  signal ps2_data_sr 		: std_logic_vector(10 downto 0) := (others=>'0');-- PS2 data shift register
	
  signal ps2_bit_counter	: unsigned(3 downto 0) := "1010";		-- PS2 bit counter
  signal bc11               : std_logic := '0';

  type state_type is (IDLE, BREAK);			-- declare state types for PS2
  signal ps2_state : state_type;					-- PS2 state

  signal scan_code		: std_logic_vector(7 downto 0) := (others => '0');	-- scan code

begin

  -- Synchronize PS2-KBD signals
  process(clk)
  begin
    if rising_edge(clk) then
      ps2_clk <= ps2_kbd_clk;
      ps2_data <= ps2_kbd_data;
    end if;
  end process;

	
  -- Generate one cycle pulse from PS2 clock, negative edge

  process(clk)
  begin
    if rising_edge(clk) then
      ps2_clk_q1 <= ps2_clk;
      ps2_clk_q2 <= not ps2_clk_q1;
    end if;
  end process;
	
  ps2_clk_op <= (not ps2_clk_q1) and (not ps2_clk_q2);
	

  
  -- PS2 data shift register

 process(clk)
 begin
   if rising_edge(clk) then
     if ps2_clk_op = '1' then
       ps2_data_sr <= ps2_data & ps2_data_sr(10 downto 1);
     end if;
   end if;
 end process;

  scan_code <= ps2_data_sr(8 downto 1);
	
  -- PS2 bit counter
  -- The purpose of the PS2 bit counter is to tell the PS2 state machine when to change state

  process(clk)
  begin
    if rising_edge(clk) then
      if ps2_bit_counter = 11 then
      	ps2_bit_counter <= "0000";
		testbit <= '1';
      elsif(ps2_clk_op = '1') then
        ps2_bit_counter <= ps2_bit_counter + 1;
      end if;
    end if;
  end process;

  test <= std_logic_vector(ps2_bit_counter);

  bc11 <= '1' when ps2_bit_counter=11 else '0';

  -- PS2 state
  process(clk)
  begin
  if rising_edge(clk) then
    if bc11 = '1' then
      if ps2_state = IDLE then
		case scan_code is
			when X"F0" => ps2_state <= BREAK;
			when X"1D" => kbd_reg(0) <= '1'; ps2_state <= IDLE; -- SET W
			when X"1C" => kbd_reg(1) <= '1'; ps2_state <= IDLE; -- SET A
            when X"1B" => kbd_reg(2) <= '1'; ps2_state <= IDLE; -- SET S
			when X"23" => kbd_reg(3) <= '1'; ps2_state <= IDLE; -- SET D
            when X"29" => kbd_reg(4) <= '1'; ps2_state <= IDLE; -- SET SPACE
            when X"3B" => kbd_reg(5) <= '1'; ps2_state <= IDLE; -- SET J
            when X"4B" => kbd_reg(6) <= '1'; ps2_state <= IDLE; -- SET L
            when others => ps2_state <= IDLE;
        end case;
      elsif ps2_state = BREAK then
        case scan_code is
			when X"1D" => kbd_reg(0) <= '0'; ps2_state <= IDLE; -- UNSET W
			when X"1C" => kbd_reg(1) <= '0'; ps2_state <= IDLE; -- UNSET A
            when X"1B" => kbd_reg(2) <= '0'; ps2_state <= IDLE; -- UNSET S
			when X"23" => kbd_reg(3) <= '0'; ps2_state <= IDLE; -- UNSET D
            when X"29" => kbd_reg(4) <= '0'; ps2_state <= IDLE; -- UNSET SPACE
            when X"3B" => kbd_reg(5) <= '0'; ps2_state <= IDLE; -- UNSET J
            when X"4B" => kbd_reg(6) <= '0'; ps2_state <= IDLE; -- UNSET L
            when others => ps2_state <= IDLE;
        end case;
      end if;
    end if;
  end if;
  end process;
 
end behavioral;
