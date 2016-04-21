-- UART

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- entity
entity uart is
	port (clk,rx		: in std_logic;								-- System clock
			cpu_clk,we	: out std_logic;
			mem_instr	: out std_logic_vector(63 downto 0) := (others => '0');
			mem_pos		: out std_logic_vector(15 downto 0) := (others => '0'));
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
process(uart_clk)
begin
	if rising_edge(uart_clk) then
		rx1 <= rx;
		rx2 <= rx1;
	end if;
end process;

 -- Shift Instruction Register
process(uart_clk)
begin
	if rising_edge(uart_clk) then
		if (lp = '1') then
			instr <= instr(55 downto 0) & read_byte(8 downto 1);
		end if;
	end if;
end process;

 -- Shift Byte Register
process(uart_clk)
begin
	if rising_edge(uart_clk) then
		if (sp = '1')then
			read_byte <= rx2 & read_byte(9 downto 1);
		end if;
	end if;
end process;

 -- Control Unit
process(uart_clk) begin
	if rising_edge(uart_clk) then
      if sp='1' then
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
        lp <= '0';
		if bitn2 = 0 then
			mp <= '1';
		end if;
      end if;

	  if mp='1' then
	  	mp <= '0';
		pos <= pos + 1;
	  end if;

      if ce='1' then
        if clkn=868 then
          clkn <= "0000000000";
        else
          clkn <= clkn + '1';
          if clkn=434 then
            bitn <= bitn + '1';
			bitn2 <= bitn2 + '1';
            sp <= '1';
          end if;
        end if;
      elsif rx2='1' AND rx1='0' then
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
 cpu_clk <= clk when is_eof = '1' else '0';
 uart_clk <= clk when is_eof = '0' else '0';

end Behavioral;

