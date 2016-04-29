-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_tb IS
END uart_tb;

ARCHITECTURE behavior OF uart_tb IS 

  -- Component Declaration
  	component uart is
	port (clk,rx		: in std_logic;								-- System clock
		cpu_clk,we	: out std_logic;
		mem_instr	: out std_logic_vector(63 downto 0) := (others => '0'));
		
	end component;

  SIGNAL clk : std_logic := '0';
  signal rx : std_logic := '1';


  -- alla bitar för 12344321,13344321,eof
  SIGNAL rxs :  std_logic_vector(0 to 239) := "010000000100100000010110000001000100000100010000010110000001001000000101000000010100000001011000000101100000010001000001000100000101100000010010000001010000000101111111110111111111011111111101111111110111111111011111111101111111110111111111";
BEGIN

  -- Component Instantiation
  uut: uart PORT MAP(
    clk => clk,
    rx => rx);

  	stimuli_generator : process
    variable i : integer;
  	begin
    -- Aktivera reset ett litet tag.
    wait for 1 us;
    
    for i in 0 to 239 loop
      rx <= rxs(i);
      wait for 8.68 us;
    end loop;  -- i
    
    for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
      wait until rising_edge(clk);
    end loop;  -- i
    wait;
  end process;


  clk <= not clk after 5 ns;      
END;
