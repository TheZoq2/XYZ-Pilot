--Behaviour code
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Line_Fetch_State is
    subtype type_t is unsigned(1 downto 0);

    constant SET_START: type_t := "00";
    constant STORE_START: type_t := "01";
    constant SET_END: type_t := "10";
    constant STORE_END: type_t := "11";
end package;

--Behaviour code
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.GPU_Info;
use work.Vector;
use work.Line_Fetch_State;

entity GPU is
    port(
            clk: in std_logic;

            obj_mem_addr: out GPU_Info.ObjAddr_t;
            obj_mem_data: in GPU_Info.ObjData_t := x"0000000000000000";

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;


            dbg_draw_start: in Vector.Elements_t;
            dbg_draw_end: in Vector.Elements_t
        );
end entity;

architecture Behavioral of GPU is
    --The mux which decides if we want to start reading a new model or read more lines in the  current  one
    signal line_mux_in: std_logic_vector(1 downto 0);
    signal line_mux_out: std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1  downto 0);

    signal next_line_reg: std_logic_vector(GPU_Info.MODEL_ADDR_SIZE -1 downto 0);

    signal gpu_state: GPU_Info.gpu_state_type := GPU_Info.READ_OBJECT_STATE;

    --The offset from the start of the current object pointer in memory to the current 'line' in the memory
    signal current_obj_start: unsigned(15 downto 0) := x"0000";
    signal current_obj_offset: unsigned(2 downto 0) := "000";

    --Decides which vector register in the gpu to write the current line in the model memory  to
    signal set_start_or_end: std_logic := '0';

    signal start_vector: work.Vector.InMemory_t;
    signal end_vector: work.Vector.InMemory_t;

    --The coordinate that is being drawn
    signal current_pixel: Vector.Elements_t;

    signal draw_start: Vector.Elements_t; --The start of the vector to be drawn on the screen
    signal draw_end: Vector.Elements_t; --The end of ^^
    signal draw_diff: Vector.Elements_t := (to_signed(0, 16), to_signed(0, 16), to_signed(0, 16), to_signed(0, 16)); --The vector between draw_start and  draw_end
    signal pixel_out: Vector.Elements_t;

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
    signal model_mem_addr: GPU_Info.ModelAddr_t;
    signal model_mem_data: GPU_Info.ModelData_t;

    --The address in the model memory that the next 
    signal line_start_addr: GPU_Info.ModelAddr_t := x"0000";

    signal fetch_line_state: Line_Fetch_State.type_t := Line_Fetch_State.SET_START;

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

    obj_mem_addr <= current_obj_start + current_obj_offset;

    with fetch_line_state select
        model_mem_addr <= line_start_addr when Line_Fetch_State.SET_START,
                          line_start_addr when Line_Fetch_State.STORE_START,
                          line_start_addr + 1 when others;

    --###########################################################################
    --      Main GPU state machine
    --###########################################################################
    process(clk) begin
        if rising_edge(clk) then
            if gpu_state = GPU_Info.READ_OBJECT_STATE then
                gpu_state <= GPU_Info.FETCH_LINE_STATE;

                if current_obj_offset = 4 then
                    line_start_addr <= unsigned(obj_mem_data(15 downto 0));
                else
                    current_obj_offset <= current_obj_offset + 1;
                end if;
            elsif gpu_state = GPU_Info.FETCH_LINE_STATE then
                --Wait for model memory to update the data
                if fetch_line_state = Line_Fetch_State.SET_START then
                    fetch_line_state <= Line_Fetch_State.STORE_START;
                --Store the result in the start vector
                elsif fetch_line_state = Line_Fetch_State.STORE_START then
                    start_vector  <= model_mem_data;

                    fetch_line_state <= Line_Fetch_State.SET_END;
                --Wait for model memory  to update again
                elsif fetch_line_state = Line_Fetch_State.SET_END then
                    fetch_line_state <= Line_Fetch_State.STORE_END;

                --Store in end vector and start drawing
                else
                    end_vector <= model_mem_data;

                    fetch_line_state <= Line_Fetch_State.SET_START;
                    gpu_state <= GPU_Info.START_PIXEL_CALC;
                end if;
                
            elsif gpu_state = GPU_Info.START_PIXEL_CALC then
                --Set up the pixel drawing calculation
                --Since start.x = 0, dx = end.x in bresenham's algorithm
                if end_vector = x"ffffffffffffffff" then
                    gpu_state <= GPU_Info.READ_OBJECT_STATE;
                else
                    draw_d_var <= draw_end(1) - draw_end(0);
                    current_pixel(0) <= draw_start(0);
                    current_pixel(1) <= draw_start(1);

                    gpu_state <= GPU_Info.CALCULATE_PIXELS_STATE;
                end if;
            elsif gpu_state = GPU_Info.CALCULATE_PIXELS_STATE then
                if current_pixel(0) > draw_end(0) then
                    gpu_state <= GPU_Info.NEXT_LINE_STATE;
                else
                    current_pixel(0) <= current_pixel(0) + 1;
                    if draw_d_var >= 0 then
                        current_pixel(1) <= current_pixel(1) + 1;
                        draw_d_var <= draw_d_var + draw_end(1) - draw_end(0);
                    else
                        draw_d_var <= draw_d_var + draw_end(1);
                    end if;
                end if;
            elsif gpu_state = GPU_Info.NEXT_LINE_STATE then
                line_start_addr <= line_start_addr + 2;

                gpu_state <= GPU_Info.FETCH_LINE_STATE;
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

    pixel_address(16 downto 8) <= std_logic_vector(pixel_out(0)(8 downto 0));
    pixel_address(7 downto 0) <= std_logic_vector(pixel_out(1)(7 downto 0));
    pixel_data <= '1';
    with gpu_state select
        pixel_write_enable <= '1' when GPU_Info.CALCULATE_PIXELS_STATE,
                              '0' when others;
end Behavioral;
