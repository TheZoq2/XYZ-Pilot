-- UART for loading program code into CPU
-- It is clocked by uart_clk that is the same as system clk when 
-- data is being transferred, else it is 0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- entity
entity uart is
	port (clk,rx		: in std_logic;								-- System clock
			we	        : out std_logic;                            -- Write Enable to program mem
			mem_instr	: out std_logic_vector(63 downto 0) := (others => '0'); -- Instruction to be sent to pm
			mem_pos		: out std_logic_vector(15 downto 0) := (others => '0')); -- The adress to be sent to pm
end uart;


-- architecture
architecture Behavioral of uart is

constant eof 		: std_logic_vector(63 downto 0) := (others => '1'); -- EOF

signal is_eof		: std_logic := '0';									-- Boolean to be set to 1 when finished

signal bitn			: std_logic_vector(3 downto 0) := (others => '0');  -- Counter for bit number in a single byte
signal bitn2		: std_logic_vector(7 downto 0) := (others => '0');  -- Counter for bit number for a whole instruction
signal clkn			: std_logic_vector(9 downto 0) := (others => '0');  -- Counter for the clock number for each bit in every byte sequence
signal pos			: std_logic_vector(15 downto 0) := (others => '0'); -- Position for the instruction in program memory

signal uart_clk,rx1,rx2,sp,lp,mp,ce		: std_logic := '0'; -- sp = shift pulse, lp = load pulse, mp = memory pulse
signal instr		: std_logic_vector(63 downto 0) := (others => '0'); -- Instruction to be set in memory
signal read_byte	: std_logic_vector(9 downto 0) := (others => '0');  -- The byte stored in Shift Byte Register

begin

 -- D-vippor
process(clk)
begin
	if rising_edge(clk) and is_eof = '0' then
		rx1 <= rx;
		rx2 <= rx1;
	end if;
end process;

 -- Shift Instruction Register
 -- When a whole byte has been loaded, it is stored in a 64 bit instruction register
process(clk)
begin
	if rising_edge(clk) and is_eof = '0' then
		if (lp = '1') then
			instr <= instr(55 downto 0) & read_byte(8 downto 1);
		end if;
	end if;
end process;

 -- Shift Byte Register
 -- Shift register storing a byte of data (plus start, end and parity bit)
process(clk)
begin
	if rising_edge(clk) and is_eof = '0' then
		if (sp = '1')then
			read_byte <= rx2 & read_byte(9 downto 1);
		end if;
	end if;
end process;

 -- Control Unit
process(clk) begin
	if rising_edge(clk) and is_eof = '0' then
      if sp='1' then
        -- Shift pulse = 1 -> shift pulse is cleared
        -- If the counters have reached their max value, they are also cleared 
        sp <= '0';
        if bitn=10 then
		  lp <= '1';
          ce <= '0';
		end if;
		if bitn2=80 then	
		  bitn2 <= (others => '0');
        end if;
      end if;

      if lp='1' then
        -- Load pulse = 0 -> memory pulse = 1 if a whole instruction has been loaded
        lp <= '0';
		if bitn2 = 0 then
			mp <= '1';
		end if;
      end if;

	  if mp='1' then
      -- Memory pulse = 0 -> pos for program mem is incremented
	  	mp <= '0';
		pos <= pos + 1;
	  end if;

      if ce='1' then
      -- Byte is loading, counters are incremented
        if clkn=217 then
          clkn <= "0000000000";
        else
          clkn <= clkn + '1';
          if clkn=108 then
            bitn <= bitn + '1';
			bitn2 <= bitn2 + '1';
            sp <= '1';
          end if;
        end if;
      elsif rx2='1' AND rx1='0' then
      -- A new byte has started to load
        ce <= '1';
        bitn <= "0000";
        clkn <= "0000000000";
      end if;
    end if;
 end process;

 -- Setting position and instruction to be set to memory
 mem_instr <= instr;
 mem_pos <= pos;

 -- Write Enable <= Memory Pulse
 we <= mp;

 is_eof <= '1' when instr = eof else '0';

 -- Clock Mux
 uart_clk <= clk when is_eof = '0' else '0';

end Behavioral;

