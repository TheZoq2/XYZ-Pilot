library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;

--Constants
package GPU_Info is
    --The length of the addresses and data in the object memory
    constant OBJ_ADDR_SIZE: positive := 16;
    constant OBJ_DATA_SIZE: positive := Vector.MEMORY_SIZE;
    --TODO: Create subtypes for obj data

    constant MODEL_ADDR_SIZE: positive := 16;

    subtype ModelAddr_t is unsigned(MODEL_ADDR_SIZE - 1 downto 0);
    subtype ModelData_t is Vector.InMemory_t;
    
    subtype gpu_state_type is std_logic_vector(1 downto 0);

    --'Enums' for the states of the GPU
    constant READ_OBJECT_STATE: gpu_state_type := "00";
    constant FETCH_LINE_STATE: gpu_state_type := "01";
    constant START_PIXEL_CALC: gpu_state_type := "10";
    constant CALCULATE_PIXELS_STATE: gpu_state_type := "11";
end package;

--Behaviour code
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.GPU_Info;
use work.Vector;

entity GPU is
    port(
            clk: in std_logic;

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;

            pixel_out: out Vector.Elements_t;

            dbg_draw_start: in Vector.Elements_t;
            dbg_draw_end: in Vector.Elements_t
        );
end entity;

architecture Behavioral of GPU is
    --The mux which decides if we want to start reading a new model or read more lines in the  current  one
    signal line_mux_in: std_logic_vector(1 downto 0);
    signal line_mux_out: std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1  downto 0);

    signal next_line_reg: std_logic_vector(GPU_Info.MODEL_ADDR_SIZE -1 downto 0);

    signal gpu_state: std_logic_vector(1 downto 0) := GPU_Info.READ_OBJECT_STATE;

    signal current_obj_offset: unsigned(2 downto 0);
    signal current_obj: unsigned(GPU_Info.OBJ_ADDR_SIZE - 1 downto 0);

    signal transform_reg_addr: unsigned(2 downto 0);
    signal transform_reg_write_enable: std_logic;

    --Decides which vector register in the gpu to write the current line in the model memory  to
    signal set_start_or_end: std_logic := '0';

    signal start_vector: work.Vector.InMemory_t;
    signal end_vector: work.Vector.InMemory_t;

    --The coordinate that is being drawn
    signal current_pixel: Vector.Elements_t;

    signal draw_start: Vector.Elements_t; --The start of the vector to be drawn on the screen
    signal draw_end: Vector.Elements_t; --The end of ^^
    signal draw_diff: Vector.Elements_t := (to_signed(0, 16), to_signed(0, 16), to_signed(0, 16), to_signed(0, 16)); --The vector between draw_start and  draw_end

    --Versions of draw_start and end that have not been corrected for the line to be in the first
    --octant
    signal raw_start: Vector.Elements_t;
    signal raw_end: Vector.Elements_t; 

    signal octant: unsigned(2 downto 0) := "000";
    signal octant_selector: std_logic_vector(2 downto 0);

    signal draw_d_var: signed(15 downto 0);

    --TODO: Remove!
    signal dummy: std_logic := '0';

    --Model data signals
    signal model_mem_addr: GPU_Info.ModelAddr_t := x"0000";
    signal model_mem_data: GPU_Info.ModelData_t;
    --1 When ready to read, 0 when waiting for the next data
    signal model_mem_state: std_logic := '0';

    component VectorSubtractor is
        port(
                --The two vectors that should be added together
                vec1: in Vector.Elements_t;
                vec2: in Vector.Elements_t;

                result: out Vector.Elements_t
            );
    end component;
    component VectorSplitter is
        port( 
                memory: in Vector.InMemory_t;
                vec: out Vector.Elements_t
        );
    end component;

    component ModelMem is
        port(
            clk: in std_logic;
            read_addr: in GPU_Info.ModelAddr_t;
            read_data: out GPU_Info.ModelData_t
        );
    end component;
            
begin
    draw_diff_calculator: VectorSubtractor port map(
                vec2 => raw_start,
                vec1 => raw_end,
                result => draw_diff
            );
    model_mem_map: ModelMem port map(
                clk => clk,
                read_addr => model_mem_addr,
                read_data => model_mem_data
            );

    start_vec_splitter: VectorSplitter port map(
                memory => start_vector,
                vec => raw_start
            );
    end_vec_splitter: VectorSplitter port map(
                memory => end_vector,
                vec => raw_end
            );


    --raw_start <= start_vector;
    --raw_end <= end_vector;


    --###########################################################################
    --      Main GPU state machine
    --###########################################################################
    process(clk) begin
        if rising_edge(clk) then
            if gpu_state = GPU_Info.READ_OBJECT_STATE then
                gpu_state <= GPU_Info.FETCH_LINE_STATE;
            elsif gpu_state = GPU_Info.FETCH_LINE_STATE then
                --Reading the lines to draw
                if set_start_or_end = '0' then
                    start_vector <= model_mem_data;
                else
                    end_vector <= model_mem_data;

                    
                    gpu_state <= GPU_Info.START_PIXEL_CALC;
                end if;

                --Prepare to read the next line
                model_mem_addr <= model_mem_addr + 1;
                --Toggle between reading start or end vectors
                if model_mem_state = '1' then
                    set_start_or_end <= not set_start_or_end;
                end if;
                model_mem_state <= not model_mem_state;

            elsif gpu_state = GPU_Info.START_PIXEL_CALC then
                --Set up the pixel drawing calculation
                --Since start.x = 0, dx = end.x in bresenham's algorithm
                if end_vector = x"ffffffffffffffff" then
                    gpu_state <= GPU_Info.READ_OBJECT_STATE;
                    dummy <= '1';
                else
                    draw_d_var <= draw_end(1) - draw_end(0);
                    current_pixel(0) <= draw_start(0);
                    current_pixel(1) <= draw_start(1);

                    gpu_state <= GPU_Info.CALCULATE_PIXELS_STATE;
                end if;
            else
                if current_pixel(0) > draw_end(0) then
                    gpu_state <= GPU_Info.READ_OBJECT_STATE;
                else
                    current_pixel(0) <= current_pixel(0) + 1;
                    if draw_d_var >= 0 then
                        current_pixel(1) <= current_pixel(1) + 1;
                        draw_d_var <= draw_d_var + draw_end(1) - draw_end(0);
                    else
                        draw_d_var <= draw_d_var + draw_end(1);
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    --###########################################################################
    --                   Octant transform code
    --###########################################################################
    octant_selector(2) <= '1' when draw_diff(0) > 0 else '0';
    octant_selector(1) <= '1' when draw_diff(1) > 0 else '0';
    octant_selector(0) <= '1' when abs(draw_diff(0)) > abs(draw_diff(1)) else '0';
    
    with octant_selector select
        octant <= "000" when "111",
                  "001" when "110",
                  "010" when "010",
                  "011" when "011",
                  "100" when "001",
                  "101" when "000",
                  "110" when "100",
                  "111" when others;

    draw_start <= (to_signed(0, 16), to_signed(0, 16), to_signed(0, 16), to_signed(0, 16));
    with octant select
        draw_end   <= (x"0000", x"0000", draw_diff(1), draw_diff(0)) when "000",
                      (x"0000", x"0000", draw_diff(0), draw_diff(1)) when "001",
                      (x"0000", x"0000",-draw_diff(0), draw_diff(0)) when "010",
                      (x"0000", x"0000", draw_diff(1),-draw_diff(0)) when "011",
                      (x"0000", x"0000",-draw_diff(1),-draw_diff(0)) when "100",
                      (x"0000", x"0000",-draw_diff(0),-draw_diff(1)) when "101",
                      (x"0000", x"0000", draw_diff(0),-draw_diff(1)) when "110",
                      (x"0000", x"0000",-draw_diff(1), draw_diff(0)) when others;


    with octant select
        pixel_out <=  (x"0000", x"0000", raw_start(1) + current_pixel(1),  raw_start(0) + current_pixel(0)) when "000",
                      (x"0000", x"0000", raw_start(1) + current_pixel(0),  raw_start(0) + current_pixel(1)) when "001",
                      (x"0000", x"0000", raw_start(1) + current_pixel(0),  raw_start(0) - current_pixel(1)) when "010",
                      (x"0000", x"0000", raw_start(1) + current_pixel(1),  raw_start(0) - current_pixel(0)) when "011",
                      (x"0000", x"0000", raw_start(1) - current_pixel(1),  raw_start(0) - current_pixel(0)) when "100",
                      (x"0000", x"0000", raw_start(1) - current_pixel(0),  raw_start(0) - current_pixel(1)) when "101",
                      (x"0000", x"0000", raw_start(1) - current_pixel(0),  raw_start(0) + current_pixel(1)) when "110",
                      (x"0000", x"0000", raw_start(1) - current_pixel(1),  raw_start(0) + current_pixel(0)) when others;

    pixel_address(16 downto 8) <= std_logic_vector(current_pixel(0)(8 downto 0));
    pixel_address(7 downto 0) <= std_logic_vector(current_pixel(1)(7 downto 0));
    pixel_data <= '1';
    with gpu_state select
        pixel_write_enable <= '1' when GPU_Info.CALCULATE_PIXELS_STATE,
                              '0' when others;
end Behavioral;
