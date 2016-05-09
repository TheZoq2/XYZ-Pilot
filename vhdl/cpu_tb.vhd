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
            pc_re       : out std_logic := '1'; -- Read Enable to be sent to program mem
            obj_mem_data : out std_logic_vector(63 downto 0);
            obj_mem_adress : out std_logic_vector(8 downto 0);
            obj_mem_we  : out std_logic;
            debuginfo   : out std_logic_vector(15 downto 0) := (others => '0')); 
end component;

type mem_t is array (0 to 127) of std_logic_vector(63 downto 0);
signal memory: mem_t := (1 => X"05_0_0_0_00010002_000",  -- addhi to reg(0)
                         2 => X"06_0_0_0_00030004_000",  -- addlo to reg(0)
                         3 => X"05_1_0_0_00050006_000",  -- addhi to reg(1)
                         4 => X"06_1_0_0_00070008_000",  -- addlo to reg(1)
                         5 => X"0E_2_1_0_00000000_000", -- vec reg(2)=reg(1)+reg(0)
                         6 => X"0F_3_1_0_00000000_000", -- vec reg(3)=reg(1)-reg(0)
                         7 => X"07_2_0_0_00000000_000", -- store reg(1) in datamem(0)
                         8 => X"07_3_0_0_00000001_000", -- store reg(1) in datamem(0)
                         9 => X"06_4_0_0_00000003_000",  -- add 3 to reg(4)
                         10 => X"06_5_0_0_00000005_000",  -- add 5 to reg(5)
                         11 => X"0C_6_4_5_00000000_000",  -- reg(6)=reg(5)*reg(4) 
                         12 => X"06_7_0_0_00000005_000",  -- add 5 to reg(7)
                         13 => X"0B_5_7_0_00000000_000",  -- cmp reg(5) reg(7) Z=1
                         14 => X"0B_6_5_0_00000000_000",  -- cmp reg(6) reg(5) Nothing
                         15 => X"0B_5_6_0_00000000_000",  -- cmp reg(5) reg(6) N=1 
                         16 => X"13_1_0_0_00000123_000",  -- Writing to obj mem
                         0 => X"0000000000000000",
                         others => (others => '0'));
	
signal clk : std_logic := '0';
signal pm_instruction : std_logic_vector(63 downto 0) := (others => '0');
signal pc_out : std_logic_vector(15 downto 0) := (others => '0');	
signal pc_re : std_logic;
signal obj_mem_data : std_logic_vector(63 downto 0);
signal obj_mem_adress : std_logic_vector(8 downto 0);
signal obj_mem_we  : std_logic;
signal debuginfo : std_logic_vector(15 downto 0);

begin
	uut: cpu port map(
	clk=>clk,
	pm_instruction=>pm_instruction,
    pc_out=>pc_out,
    pc_re=>pc_re,
    obj_mem_data => obj_mem_data,
    obj_mem_adress => obj_mem_adress,
    obj_mem_we => obj_mem_we,
    debuginfo=>debuginfo);
   
    process(clk)
    begin
      if rising_edge(clk) then
        if pc_re <= '1' then
          pm_instruction <= memory(conv_integer(pc_out));
        end if;
      end if;
    end process;

	-- clk 100 MHz
	clk <= not clk after 5 ns;

end;

