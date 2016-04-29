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
signal sr               : std_logic_vector(1 downto 0)  := (others => '0'); --  [Z,N]
signal ir1,ir2,ir3,ir4	: std_logic_vector(63 downto 0) := (others => '0'); --  NOP at start

-- Registers --
signal we               : std_logic := '1';
signal pc		        : std_logic_vector(15 downto 0)	:= (others => '0');	--	PC
signal pc_next		    : std_logic_vector(15 downto 0)	:= (others => '0');	--	PC+4
signal pc_2		        : std_logic_vector(15 downto 0)	:= (others => '0');	--	PC2
signal im_2             : std_logic_vector(31 downto 0)	:= (others => '0');	--	IM2
signal d_1              : std_logic_vector(63 downto 0)	:= (others => '0');	--	D1
signal d_2              : std_logic_vector(63 downto 0)	:= (others => '0');	--	D2
signal z_3              : std_logic_vector(63 downto 0)	:= (others => '0');	--	Z3
signal alu_1            : std_logic_vector(63 downto 0)	:= (others => '0');	--	ALU1
signal alu_2            : std_logic_vector(63 downto 0)	:= (others => '0');	--	ALU2
signal alu_res          : std_logic_vector(63 downto 0)	:= (others => '0');	--	ALU RESULT
signal d_3              : std_logic_vector(63 downto 0)	:= (others => '0');	--	D3
signal d_4              : std_logic_vector(63 downto 0)	:= (others => '0');	--	D4
signal z_4              : std_logic_vector(63 downto 0)	:= (others => '0');	--	Z4
signal write_reg        : std_logic_vector(63 downto 0)	:= (others => '0');	--	Register to be written to Register File


type register_t is array (0 to 15) of std_logic_vector(63 downto 0);
signal reg_file : register_t := (others =>(others=>'0'));   

type data_mem_t is array (0 to 1023) of std_logic_vector(63 downto 0);
signal data_mem : data_mem_t := (others =>(others=>'0'));   

constant nop_op_code       : std_logic_vector(7 downto 0)  := X"00";
constant bra_op_code       : std_logic_vector(7 downto 0)  := X"01";
constant bne_op_code       : std_logic_vector(7 downto 0)  := X"02";
constant add_op_code       : std_logic_vector(7 downto 0)  := X"03";
constant addi_op_code       : std_logic_vector(7 downto 0)  := X"04";
constant movhi_op_code       : std_logic_vector(7 downto 0)  := X"05";
constant movlo_op_code       : std_logic_vector(7 downto 0)  := X"06";
constant store_op_code       : std_logic_vector(7 downto 0)  := X"07";
constant load_op_code       : std_logic_vector(7 downto 0)  := X"08";
constant sub_op_code       : std_logic_vector(7 downto 0)  := X"09";
constant subi_op_code       : std_logic_vector(7 downto 0)  := X"0A";
constant cmp_op_code       : std_logic_vector(7 downto 0)  := X"0B";
constant mult_op_code       : std_logic_vector(7 downto 0)  := X"0C";
constant multi_op_code       : std_logic_vector(7 downto 0)  := X"0D";

-- ALIASES --
alias ir1_op 				: std_logic_vector(7 downto 0) is ir1(63 downto 56);
alias ir1_reg1 				: std_logic_vector(3 downto 0) is ir1(55 downto 52);
alias ir1_reg2 				: std_logic_vector(3 downto 0) is ir1(51 downto 48);
alias ir1_reg3				: std_logic_vector(3 downto 0) is ir1(47 downto 44);
alias ir1_data 				: std_logic_vector(31 downto 0) is ir1(43 downto 12);

alias ir2_op 				: std_logic_vector(7 downto 0) is ir2(63 downto 56);

alias ir3_op 				: std_logic_vector(7 downto 0) is ir3(63 downto 56);

alias ir4_op 				: std_logic_vector(7 downto 0) is ir4(63 downto 56);
alias ir4_reg1 				: std_logic_vector(3 downto 0) is ir4(55 downto 52);

begin

  pc_out <= pc;
  pc_we <= we;

  -- IR SWITCHES --
  ir1 <= pm_instruction;
  process(clk)
  begin
	if rising_edge(clk) then
      ir2 <= ir1;
      ir3 <= ir2;
      ir4 <= ir3;		
      end if;
  end process;
    
  ---- 1. IF ----
  process(clk)
  begin
    if rising_edge(clk) then
      pc_next <= pc + 1;
    end if;
  end process;
  
  pc <= pc_2 when (ir1_op = bra_op_code) or 
        (ir1_op = bne_op_code and sr(1) = '0') else
        pc_next;

  ---- 2. RR ----
  -- Register File --
  process(clk)
  begin
    if rising_edge(clk) then
      pc_2 <= ir1_data(15 downto 0);
      im_2 <= ir1_data;

      case ir1_op is
        when store_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when load_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when cmp_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when others => d_1 <= reg_file(conv_integer(ir1_reg3));
      end case;

      case ir1_op is
        when movhi_op_code => d_2 <= reg_file(conv_integer(ir1_reg1));
        when movlo_op_code => d_2 <= reg_file(conv_integer(ir1_reg1));
        when others => d_2 <= reg_file(conv_integer(ir1_reg2));
      end case;

    end if;
  end process;
  ---- 3. EXE ----
  alu_2 <= d_2;
  -- MUX deciding if IM2 or D1 should be put in ALU
  alu_1 <= X"00000000" & im_2 when ir2_op = addi_op_code or 
                     ir2_op = multi_op_code or
                     ir2_op = movhi_op_code or 
                     ir2_op = movlo_op_code or
                     ir2_op = store_op_code or
                     ir2_op = load_op_code else
           d_1;

  -- ALU --
  with ir2_op select
    alu_res <= alu_1 + alu_2 when add_op_code,
               alu_1 + alu_2 when addi_op_code,
               alu_1(31 downto 0) & alu_2(31 downto 0) when movhi_op_code,
               alu_2(63 downto 32) & alu_1(31 downto 0) when movlo_op_code,
               alu_1 when store_op_code,
               alu_1 when load_op_code,
               alu_2 - alu_1 when sub_op_code,
               alu_2 - alu_1 when subi_op_code,
               alu_1 * alu_2 when mult_op_code,
               alu_1 * alu_2 when multi_op_code,
               X"0000000000000000" when others;
  sr <= "10" when (ir2_op=cmp_op_code and alu_1=alu_2) else
        "01" when (ir2_op=cmp_op_code and alu_1<alu_2) else
        "00";
  
  process(clk)
  begin
    if rising_edge(clk) then
      d_3 <= alu_res;
      z_3 <= d_1;
    end if;
  end process;

  ---- 4. MEM ----
  process(clk)
  begin
    if rising_edge(clk) then
      d_4 <= d_3;
      if(ir3_op = store_op_code) then
        data_mem(conv_integer(d_3(9 downto 0))) <= z_3;
      else
        z_4 <= data_mem(conv_integer(d_3(9 downto 0)));
      end if;
    end if;
  end process;

  ---- 5. WB ----
  write_reg <= z_4 when ir4_op = load_op_code else
               d_4;

  reg_file(conv_integer(ir4_reg1)) <= write_reg when (ir4_op = load_op_code or 
      ir4_op = movhi_op_code or 
      ir4_op = movlo_op_code or 
      ir4_op = add_op_code or 
      ir4_op = addi_op_code) or
      ir4_op = sub_op_code or
      ir4_op = subi_op_code or
      ir4_op = mult_op_code or
      ir4_op = multi_op_code else
      reg_file(conv_integer(ir4_reg1));





end Behavioral;
