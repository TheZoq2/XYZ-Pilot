library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu_tb is
end cpu_tb;

architecture Behavioral of cpu_tb is

component cpu is
  port (clk		: in std_logic;								-- System clock
    pm_instruction : in std_logic_vector(63 downto 0);	-- Instruction from program memory
    pc_out		: out std_logic_vector(15 downto 0) := (others => '0'); -- Program Counter
    pc_we       : out std_logic); -- Write Enable to be sent to program mem
end component;

type mem_t is array (0 to 31) of std_logic_vector(63 downto 0);
signal memory: mem_t := (0 => X"04_0_1_0_12345678_000",
                         3 => X"",
                         others => (others => '0'));
	
signal clk : std_logic := '0';
signal pm_instruction : std_logic_vector(63 downto 0) := (others => '0');
signal pc_out : std_logic_vector(15 downto 0) := (others => '0');	
signal pc_we : std_logic;

begin
	uut: cpu port map(
	clk=>clk,
	pm_instruction=>pm_instruction,
    pc_out=>pc_out,
    pc_we=>pc_we);
   
    process(clk)
    begin
      if rising_edge(clk) then
        if pc_we <= '1' then
          pm_instruction <= memory(conv_integer(pc_out));
        end if;
      end if;
    end process;

	-- clk 100 MHz
	clk <= not clk after 5 ns;

end;

