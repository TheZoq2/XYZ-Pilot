-- CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- entity
entity cpu is
	port (clk		: in std_logic;								-- System clock
			pm_instruction : in std_logic_vector(63 downto 0);	-- Instruction from program memory
			pc_out		: out std_logic_vector(15 downto 0) := (others => '0'); -- Program Counter
            pc_we       : out std_logic); -- Write Enable to be sent to program mem
		
end cpu;

architecture Behavioral of cpu is
signal flags            : std_logic_vector(3 downto 0)  := (others => '0'); --  [Z,N,O,C]
signal ir1,ir2,ir3,ir4	: std_logic_vector(63 downto 0) := (others => '0'); --  NOP at start

-- Registers --
signal pc		        : std_logic_vector(15 downto 0)	:= (others => '0');	--	PC
signal pc_plus_4		: std_logic_vector(15 downto 0)	:= (others => '0');	--	PC+4
signal pc_2		        : std_logic_vector(15 downto 0)	:= (others => '0');	--	PC2
signal im_2             : std_logic_vector(31 downto 0)	:= (others => '0');	--	IM2
signal d_1              : std_logic_vector(63 downto 0)	:= (others => '0');	--	D1
signal d_2              : std_logic_vector(63 downto 0)	:= (others => '0');	--	D2
signal z_3              : std_logic_vector(63 downto 0)	:= (others => '0');	--	Z3


signal ir1_op           : std_logic_vector(7 downto 0);
signal ir1_reg1         : std_logic_vector(3 downto 0);
signal ir1_reg2         : std_logic_vector(3 downto 0);
signal ir1_reg3         : std_logic_vector(3 downto 0);
signal ir1_data         : std_logic_vector(31 downto 0);


type register_t is array (0 to 15) of std_logic_vector(63 downto 0);
signal reg_file : register_t := (others =>(others=>'0'));   

constant bra_op_code       : std_logic_vector(7 downto 0)  := X"01";
constant bne_op_code       : std_logic_vector(7 downto 0)  := X"02";


begin

    pc_out <= pc;

    -- IR SWITCHES --
	process(clk)
	begin
		if rising_edge(clk) then
			ir1 <= pm_instruction;
			ir2 <= ir1;
			ir3 <= ir2;
			ir4 <= ir3;		
		end if;
	end process;
    ir1_op <= ir1(63 downto 56);
    ir1_reg1 <= ir1(55 downto 52);
    ir1_reg2 <= ir1(51 downto 48);
    ir1_reg2 <= ir1(47 downto 44);
    ir1_data <= ir1(43 downto 12);
    
    ---- 1. IF ----
    pc_plus_4 <= pc + 4;
	pc <= pc_2 when (ir1_op = bra_op_code) or 
          (ir1_op = bne_op_code and flags(3) = '0') else
          pc_plus_4;

    ---- 2. RR ----
    pc_2 <= ir1_data(15 downto 0);
    im_2 <= ir1_data;
    -- Register File --
    d_1 <= reg_file(conv_integer(ir1_reg1));
    d_2 <= reg_file(conv_integer(ir1_reg2));

    ---- 3. EXE ----
    z_3 <= d_1;
    





end Behavioral;
