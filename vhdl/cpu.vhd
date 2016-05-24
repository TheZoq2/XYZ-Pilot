-- CPU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.Vector;                        -- Vector package
use work.Datatypes;


-- entity
entity cpu is
	port (clk		: in std_logic;								-- System clock
			pm_instruction : in std_logic_vector(63 downto 0);	-- Instruction from program memory
			pc_out		: out std_logic_vector(15 downto 0) := (others => '0'); -- Program Counter
            pc_re       : out std_logic := '1'; -- Read Enable to be sent to program mem
            obj_mem_data : out std_logic_vector(63 downto 0); -- Data to be sent to object memory
            obj_mem_adress : out std_logic_vector(8 downto 0); -- The adress to be sent to object memory
            obj_mem_we  : out std_logic; -- Write Enable for object memory
            frame_done  : in std_logic; -- Signal from vga_motor informing that a full frame has been displayed
            kbd_reg     : in std_logic_vector(6 downto 0) := (others => '0'); -- Signal from kbd_enc showing which 
                                                                              -- keys are being pressed down
            debuginfo   : out std_logic_vector(15 downto 0) := (others => '0')); -- Info to be shown on the 7-seg
end cpu;

architecture Behavioral of cpu is

component VectorSplitter is
    port(
            memory: in Vector.InMemory_t;
            vec: out Vector.Elements_t
        );
end component VectorSplitter;

component VectorMerger is
    port(
            memory: out Vector.InMemory_t;
            vec: in Vector.Elements_t
        );
end component;

component VectorAdder is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t;
            vec2: in Vector.Elements_t;

            result: out Vector.Elements_t
        );
end component;

component VectorSubtractor is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t;
            vec2: in Vector.Elements_t;

            result: out Vector.Elements_t
        );
end component;

-- A cosinus lookup table to be used when working with angles
component cos_table is
    port(
        angle: in unsigned(7 downto 0);
        result: out datatypes.small_number_t
    );
end component;
-- FRANS KOMMENTERA DETTA FÖR JAG VET INTE VAD JAG SKA SKRIVA-------------------------------------------------
component FractionalMultiplyer is
    port(
        big_num: in Datatypes.std_number_t;
        small_num: in Datatypes.small_number_t;
        result: out Datatypes.std_number_t
    );
end component;

component LinearFeedbackSR is
port (
  -- System clock
  clk : in std_logic;

  -- Current register data
  data : out Vector.InMemory_t
  );
end component;

component VectorDot is
    port(
            vec1: in Vector.Elements_t;
            vec2: in Vector.Elements_t;
            result: out signed(63 downto 0)
        );
end component;

component VectorLength is
    port(
            vec1: in Vector.Elements_t;

            result: out unsigned(15 downto 0)
        );
end component;

-- The counter to be used when added NOPs between instructions
signal nop_counter : std_logic_vector(1 downto 0) := "00";


-- Registers --
signal sr               : std_logic_vector(1 downto 0)  := (others => '0'); --  [Z,N]
signal sr_last          : std_logic_vector(1 downto 0)  := (others => '0'); --  Store last SR
signal ir1,ir2,ir3,ir4	: std_logic_vector(63 downto 0) := (others => '0'); --  NOP at start
signal re               : std_logic := '1';                                 --  Read Enable for Program Mem
signal pc		        : std_logic_vector(15 downto 0)	:= (others => '0');	--	PC
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


-- Signals connecting to Vector Splitters
signal vec_split_in1 : std_logic_vector(63 downto 0);
signal vec_split_out1 : Vector.Elements_t;
signal vec_split_in2 : std_logic_vector(63 downto 0);
signal vec_split_out2 : Vector.Elements_t;

-- Signals connecting to Vector Merger
signal vec_merge_in : Vector.Elements_t;
signal vec_merge_out : std_logic_vector(63 downto 0);

-- Signals connecting to Vector Adder
signal vec_add_in1 : Vector.Elements_t;
signal vec_add_in2 : Vector.Elements_t;
signal vec_add_res : Vector.Elements_t;

-- Signals connecting to Vector Subtractor
signal vec_sub_in1 : Vector.Elements_t;
signal vec_sub_in2 : Vector.Elements_t;
signal vec_sub_res : Vector.Elements_t;

-- Result signals used in the dot and len instructions
signal vec_dot_result: signed(63 downto 0);
signal vec_len_result: unsigned(15 downto 0);

-- Signals connecting the cos calculator
signal cos_angle: unsigned(7 downto 0);
signal cos_big_num: datatypes.std_number_t;
signal cos_result: datatypes.small_number_t;
signal cos_mul_result: datatypes.std_number_t;

-- Signals connecting the linear feedback shift Register
signal lf_clk : std_logic;
signal lf_data : Vector.InMemory_t;

-- Register files 
type register_t is array (0 to 15) of std_logic_vector(63 downto 0);
signal reg_file : register_t := (others =>(others=>'0'));   

-- Data memory
type data_mem_t is array (0 to 1023) of std_logic_vector(63 downto 0);
signal data_mem : data_mem_t := (others =>(others=>'0'));   

-- Result signal used in the mult instruction
signal mult_result : std_logic_vector(127 downto 0);

-- All op codes
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
constant vecadd_op_code       : std_logic_vector(7 downto 0)  := X"0E";
constant vecsub_op_code       : std_logic_vector(7 downto 0)  := X"0F";
constant beq_op_code       : std_logic_vector(7 downto 0)  := X"10";
constant bge_op_code       : std_logic_vector(7 downto 0)  := X"11";
constant ble_op_code       : std_logic_vector(7 downto 0)  := X"12";
constant storeobj_op_code       : std_logic_vector(7 downto 0)  := X"13";
constant waitframe_op_code       : std_logic_vector(7 downto 0)  := X"14";
constant btst_op_code       : std_logic_vector(7 downto 0)  := X"15";
constant load_rel_op_code : std_logic_vector(7 downto 0) := X"16";
constant store_rel_op_code : std_logic_vector(7 downto 0) := X"17";
constant and_op_code : std_logic_vector(7 downto 0) := X"18";
constant lsli_op_code : std_logic_vector(7 downto 0) := X"19";
constant lsri_op_code : std_logic_vector(7 downto 0) := X"1A";
constant mulcos_op_code : std_logic_vector(7 downto 0) := X"1B";
constant storeobj_rel_op_code : std_logic_vector(7 downto 0) := X"1C";
constant dot_op_code: std_logic_vector(7 downto 0) := X"1D";
constant len_op_code: std_logic_vector(7 downto 0) := X"1E";
constant dbg_op_code: std_logic_vector(7 downto 0) := X"1F";
constant random_op_code : std_logic_vector(7 downto 0) := X"20";

-- Aliases to be used in cpu --
alias ir1_op 				: std_logic_vector(7 downto 0) is ir1(63 downto 56);
alias ir1_reg1 				: std_logic_vector(3 downto 0) is ir1(55 downto 52);
alias ir1_reg2 				: std_logic_vector(3 downto 0) is ir1(51 downto 48);
alias ir1_reg3				: std_logic_vector(3 downto 0) is ir1(47 downto 44);
alias ir1_data 				: std_logic_vector(31 downto 0) is ir1(43 downto 12);

alias ir2_op 				: std_logic_vector(7 downto 0) is ir2(63 downto 56);

alias ir3_op 				: std_logic_vector(7 downto 0) is ir3(63 downto 56);

alias ir4_op 				: std_logic_vector(7 downto 0) is ir4(63 downto 56);
alias ir4_reg1 				: std_logic_vector(3 downto 0) is ir4(55 downto 52);
alias ir4_data				: std_logic_vector(31 downto 0) is ir4(43 downto 12);

-- Signal to be set to 1 when the cpu should wait for the vga motor to finish with a frame
signal wait_for_next_frame : std_logic := '0';

begin
  -- Port maps connecting the components with internal signals --
  vec_split1 : VectorSplitter port map(
               memory=>vec_split_in1, 
               vec=>vec_split_out1
            );
  vec_split2 : VectorSplitter port map(
               memory=>vec_split_in2,
               vec=>vec_split_out2
            );
  vec_add : VectorAdder port map(
               vec1=>vec_add_in1,
               vec2=>vec_add_in2,
               result=>vec_add_res
            );
  vec_sub : VectorSubtractor port map(
               vec1=>vec_sub_in1,
               vec2=>vec_sub_in2,
               result=>vec_sub_res
            );
  vec_merge : VectorMerger port map(
               memory=>vec_merge_out,
               vec=>vec_merge_in
            );
  vec_dot : VectorDot port map (
              vec1 => vec_split_out1,
              vec2 => vec_split_out2,
              result => vec_dot_result
            );
  cos_lut : cos_table port map (
              angle => cos_angle,
              result => cos_result
            );
  cos_mult : FractionalMultiplyer port map (
              big_num => cos_big_num,
              small_num => cos_result,
              result => cos_mul_result
            );
  lf_sr : LinearFeedbackSR port map (
              clk  => lf_clk,
              data => lf_data
            );
  vec_len : VectorLength port map (
             vec1 => vec_split_out2,
             result => vec_len_result
            );
  lf_clk <= clk;
  pc_out <= pc;

  -- Nop counter
  process(clk)
  begin
    if rising_edge(clk) then
      if wait_for_next_frame = '0' then
        nop_counter <= nop_counter + 1;
      end if;
    end if;
  end process;

  -- IR switches --
  -- The program memory is clocked, so the ir1 switch doesnt have to be.
  -- The instruction in memory is only accessed every 4 clk pulses
  ir1 <= pm_instruction when nop_counter = 0 else (others => '0');
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
      if nop_counter = 0 then
        if ir1_op = waitframe_op_code then
          wait_for_next_frame <= '1';
        end if;
        if (ir1_op = bra_op_code) or 
           (ir1_op = bne_op_code and sr(1) = '0') or
           (ir1_op = beq_op_code and sr(1) = '1') or 
           (ir1_op = bge_op_code and sr(0) = '1') or
           (ir1_op = ble_op_code and sr(1) = '0' and sr(0) = '0') then
          pc <= pc_2;
        else
          pc <= pc + 1;
        end if;
      elsif frame_done = '1' then
        wait_for_next_frame <= '0';
      end if;
    end if;
  end process;

  pc_2 <= ir1_data(15 downto 0);

  ---- 2. RR ----
  process(clk)
  begin
    if rising_edge(clk) then
      im_2 <= ir1_data;
      -- The ir1 op code decides which parts of the instruction (reg1, reg2, reg3) 
      -- to be used when reading from registers 
      case ir1_op is
        when store_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when store_rel_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));                              
        when storeobj_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when storeobj_rel_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));                                 
        when load_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when load_rel_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));                             
        when cmp_op_code => d_1 <= reg_file(conv_integer(ir1_reg1));
        when dbg_op_code => d_1 <= reg_file(conv_integer(ir1_reg1)); debuginfo <= reg_file(conv_integer(ir1_reg1))(15 downto 0);
        when others => d_1 <= reg_file(conv_integer(ir1_reg3));
      end case;

      case ir1_op is
        when movhi_op_code => d_2 <= reg_file(conv_integer(ir1_reg1));
        when movlo_op_code => d_2 <= reg_file(conv_integer(ir1_reg1));
        when btst_op_code => d_2 <= reg_file(conv_integer(ir1_reg1));
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
                     ir2_op = store_rel_op_code or
                     ir2_op = load_op_code or
                     ir2_op = load_rel_op_code or
                     ir2_op = btst_op_code or
                     ir2_op = lsli_op_code or
                     ir2_op = lsri_op_code or
                     ir2_op = storeobj_op_code or
                     ir2_op = storeobj_rel_op_code
                 else
           d_1;

  -- ALU --

  -- Cos lookup table
  cos_angle <= unsigned(alu_2(7 downto 0));
  cos_big_num <= signed(alu_1(15 downto 0));

  -- Multiplication
  mult_result <= alu_1 * alu_2;

  -- Splitting the two vectors
  vec_split_in1 <= alu_1;
  vec_split_in2 <= alu_2;

  -- Adding two vectors
  vec_add_in1 <= vec_split_out1;
  vec_add_in2 <= vec_split_out2;

  -- Subtracting two vectors
  vec_sub_in1 <= vec_split_out1;
  vec_sub_in2 <= vec_split_out2;

  -- Choosing what to be merged
  with ir2_op select
    vec_merge_in <= vec_add_res when vecadd_op_code,
                    vec_sub_res when others;

  -- Biggest part of ALU, decides what to be put in alu res
  with ir2_op select
    alu_res <= alu_1 + alu_2 when add_op_code,
               alu_1 + alu_2 when addi_op_code,
               alu_1(31 downto 0) & alu_2(31 downto 0) when movhi_op_code,
               alu_2(63 downto 32) & alu_1(31 downto 0) when movlo_op_code,
               alu_1 when store_op_code,
               alu_1 when load_op_code,
               alu_1 + alu_2 when load_rel_op_code,
               alu_1 + alu_2 when store_rel_op_code,
               alu_2 - alu_1 when sub_op_code,
               alu_2 - alu_1 when subi_op_code,
               mult_result(63 downto 0) when mult_op_code,
               mult_result(63 downto 0) when multi_op_code,
               vec_merge_out when vecadd_op_code,
               vec_merge_out when vecsub_op_code,
               alu_1 when storeobj_op_code,
               alu_1 + alu_2 when storeobj_rel_op_code,
               alu_1 and alu_2 when and_op_code,
               std_logic_vector(shift_left(unsigned(alu_2), conv_integer(alu_1))) when lsli_op_code,
               std_logic_vector(shift_right(unsigned(alu_2), conv_integer(alu_1))) when lsri_op_code,
               x"000000000000" & std_logic_vector(cos_mul_result) when mulcos_op_code,
               std_logic_vector(vec_dot_result) when dot_op_code,
               X"000000000000" & std_logic_vector(vec_len_result) when len_op_code,
               X"0000000000000000" when others;

  -- Sets the status register
  sr <= "10" when (ir2_op=cmp_op_code and alu_1=alu_2) or 
                  (ir2_op=btst_op_code and alu_2(conv_integer(alu_1)) = '1') else
        "01" when (ir2_op=cmp_op_code and signed(alu_1)<signed(alu_2)) else
        "00" when (ir2_op=cmp_op_code or -- Clears sr when jumping
                  ir2_op=beq_op_code or
                  ir2_op=bne_op_code or
                  ir2_op=bge_op_code or
                  ir2_op=ble_op_code or
                  ir2_op=bra_op_code) else
        sr_last;

  -- Updating registers 
  process(clk)
  begin
    if rising_edge(clk) then
      d_3 <= alu_res;
      z_3 <= d_1;
      sr_last <= sr;
    end if;
  end process;

  ---- 4. MEM ----
  -- Stores or loads data in data memory
  process(clk)
  begin
    if rising_edge(clk) then
      d_4 <= d_3;
      if(ir3_op = store_op_code) or (ir3_op = store_rel_op_code) then
        data_mem(conv_integer(d_3(9 downto 0))) <= z_3;
      else
        z_4 <= data_mem(conv_integer(d_3(9 downto 0)));
      end if;
    end if;
  end process;


  ---- 5. WB ----
  -- MUX deciding what to be written back to register files
  write_reg <= z_4 when ir4_op = load_op_code else
               z_4 when ir4_op = load_rel_op_code else
               lf_data when ir4_op = random_op_code else
               d_4;
  
  -- Writing back to register file. If the current instruction doesnt write back,
  -- then the last register is loaded with keyboard information
  process(clk)
  begin
    if rising_edge(clk) then
      if ir4_op = load_op_code or
      ir4_op = load_rel_op_code or
      ir4_op = movhi_op_code or 
      ir4_op = movlo_op_code or 
      ir4_op = add_op_code or 
      ir4_op = addi_op_code or
      ir4_op = sub_op_code or
      ir4_op = subi_op_code or
      ir4_op = mult_op_code or
      ir4_op = multi_op_code or
      ir4_op = vecadd_op_code or
      ir4_op = and_op_code or 
      ir4_op = lsli_op_code or
      ir4_op = lsri_op_code or
      ir4_op = mulcos_op_code or
      ir4_op = and_op_code or
      ir4_op = random_op_code or
      ir4_op = dot_op_code or
      ir4_op = len_op_code or
      ir4_op = vecsub_op_code then
        reg_file(conv_integer(ir4_reg1)) <= write_reg;
      elsif frame_done = '1' then
        reg_file(15) <= X"00000000000000" & '0' & kbd_reg;
      end if;
    end if;
  end process;

  -- Writing to object memory
  obj_mem_data <= z_3;
  obj_mem_adress <= d_3(8 downto 0);
  obj_mem_we <= '1' when ir3_op = storeobj_op_code or ir3_op = storeobj_rel_op_code else '0';


end Behavioral;
