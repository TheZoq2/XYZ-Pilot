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
use work.datatypes;

entity GPU is
    port(
            clk: in std_logic;

            obj_mem_addr: out GPU_Info.ObjAddr_t;
            obj_mem_data: in GPU_Info.ObjData_t := x"0000000000000000";

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;
        
            vga_done: in std_logic
        );
end entity;

architecture Behavioral of GPU is
	type gpu_state_type is (
 							READ_OBJECT,
                            FETCH_LINE,
                            START_PIXEL_CALC,
                            WAIT_FOR_COMB,
                            CALC_PIXELS,
                            PREPARE_NEXT_LINE,
                            WAIT_FOR_VGA
                        );
    signal gpu_state: gpu_state_type := READ_OBJECT;

    signal delay_counter: unsigned(2 downto 0) := "000";

    --The offset from the start of the current object pointer in memory to the current 'line' in the memory
    signal current_obj_start: unsigned(15 downto 0) := x"0000";
    signal current_obj_offset: unsigned(2 downto 0) := "000";
    signal obj_mem_vec: vector.Elements_t;

    signal start_vector: work.Vector.InMemory_t;
    signal end_vector: work.Vector.InMemory_t;

    signal screen_start: Vector.Elements_t;
    signal screen_end: Vector.Elements_t;

    --The coordinate that is being drawn
    signal current_pixel: Vector.Elements_t;

    signal draw_start: Vector.Elements_t; --The start of the vector to be drawn on the screen
    signal draw_end: Vector.Elements_t; --The end of ^^
    signal draw_diff: Vector.Elements_t := (to_signed(0, 16), to_signed(0, 16), to_signed(0, 16), to_signed(0, 16)); --The vector between draw_start and  draw_end
    signal pixel_out: Vector.Elements_t;
    signal draw_d_var: signed(15 downto 0);

    signal obj_position: Vector.Elements_t;
    signal obj_angle: Vector.Elements_t;
    signal obj_scale: Vector.Elements_t;

    --Versions of draw_start and end that have not been corrected for the line to be in the first
    --octant
    signal raw_start: Vector.Elements_t;
    signal raw_end: Vector.Elements_t; 

    signal octant: unsigned(2 downto 0) := "000";
    signal octant_selector: std_logic_vector(2 downto 0);

    --Model data signals
    signal model_mem_addr: GPU_Info.ModelAddr_t;
    signal model_mem_data: GPU_Info.ModelData_t;

    --The address in the model memory that the next 
    signal line_start_addr: GPU_Info.ModelAddr_t := x"0000";

    signal fetch_line_state: Line_Fetch_State.type_t := Line_Fetch_State.SET_START;

    signal angle: unsigned(7 downto 0) := x"00";
    signal cos_val: datatypes.small_number_t;
    signal sin_val: datatypes.small_number_t;

    signal y_cos: datatypes.std_number_t;
    signal z_sin: datatypes.std_number_t;
    signal y_cos_end: datatypes.std_number_t;
    signal z_sin_end: datatypes.std_number_t;

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
            
    component cos_table is
        port(
                angle: in unsigned (7 downto 0);
                result: out datatypes.small_number_t
            );
    end component;
    component sin_table is
        port(
                angle: in unsigned (7 downto 0);
                result: out datatypes.small_number_t
            );
    end component;

    component FractionalMultiplyer is
        port(
                big_num: in Datatypes.std_number_t;
                small_num: in Datatypes.small_number_t;
                result: out Datatypes.std_number_t
            );
    end component;
    
begin
    draw_diff_calculator: VectorSubtractor port map(
                vec2 => screen_start,
                vec1 => screen_end,
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

    obj_mem_vec_splitter: VectorSplitter port map(
                memory => obj_mem_data,
                vec => obj_mem_vec
            );

    sin_calculator: sin_table port map(
                        angle => angle,
                        result => sin_val
                  );
    cos_calculator: cos_table port map(
                        angle => angle,
                        result => cos_val
                  );
    y_cos_calculator: FractionalMultiplyer port map(
                big_num => raw_start(1),
                small_num => cos_val,
                result => y_cos
            );
    z_sin_calculator: FractionalMultiplyer port map(
                big_num => raw_start(2),
                small_num => sin_val,
                result => z_sin
            );

    y_cos_end_calculator: FractionalMultiplyer port map(
                big_num => raw_end(1),
                small_num => cos_val,
                result => y_cos_end
            );
    z_sin_end_calculator: FractionalMultiplyer port map(
                big_num => raw_end(2),
                small_num => sin_val,
                result => z_sin_end
            );

    obj_mem_addr <= current_obj_start + current_obj_offset;

    screen_start(0) <= raw_start(0);
    --screen_start(1) <= raw_start(1);
    screen_start(1) <= y_cos - z_sin;

    screen_start(2) <= x"0000";
    screen_start(3) <= x"0000";
    screen_end(0) <= raw_end(0);
    --screen_end(1) <= raw_end(1);
    screen_end(1) <= y_cos_end - z_sin_end;
    screen_end(2) <= x"0000";
    screen_end(3) <= x"0000";

    with fetch_line_state select
        model_mem_addr <= line_start_addr when Line_Fetch_State.SET_START,
                          line_start_addr when Line_Fetch_State.STORE_START,
                          line_start_addr + 1 when others;

    --###########################################################################
    --      Main GPU state machine
    --###########################################################################
    process(clk) begin
        if rising_edge(clk) then
            if gpu_state = READ_OBJECT then
                line_start_addr <= x"0000";

                --Incrememnt the current offset and switch states
                if current_obj_offset = 3 then
                    current_obj_offset <= "000";
                    gpu_state <= FETCH_LINE;
                else
                    current_obj_offset <= current_obj_offset + 1;
                end if;


                if current_obj_offset = 3 then
                    line_start_addr <= unsigned(obj_mem_data(15 downto 0));
                elsif current_obj_offset = 2 then --If this is the position value
                    obj_scale <=  obj_mem_vec;
                elsif current_obj_offset = 1 then
                    obj_angle <=  obj_mem_vec;
                elsif current_obj_offset = 0 then
                    obj_position <=  obj_mem_vec;
                end if;
            elsif gpu_state = FETCH_LINE then
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
                    gpu_state <= START_PIXEL_CALC;
                end if;
                
            elsif gpu_state = START_PIXEL_CALC then
                --Set up the pixel drawing calculation
                --Since start.x = 0, dx = end.x in bresenham's algorithm
                if end_vector = x"ffffffffffffffff" then
                    gpu_state <= WAIT_FOR_VGA;
                else
                    draw_d_var <= draw_end(1) - draw_end(0);
                    current_pixel(0) <= draw_start(0);
                    current_pixel(1) <= draw_start(1);

                    gpu_state <= WAIT_FOR_COMB;
                    delay_counter <= "000";
                end if;
            elsif gpu_state = WAIT_FOR_COMB then
                if delay_counter = "111" then
                    gpu_state <= CALC_PIXELS;
                else
                    delay_counter <= delay_counter + 1;
                end if;
            elsif gpu_state = CALC_PIXELS then
                if current_pixel(0) > draw_end(0) then
                    gpu_state <= PREPARE_NEXT_LINE;
                else
                    current_pixel(0) <= current_pixel(0) + 1;
                    if draw_d_var >= 0 then
                        current_pixel(1) <= current_pixel(1) + 1;
                        draw_d_var <= draw_d_var + draw_end(1) - draw_end(0);
                    else
                        draw_d_var <= draw_d_var + draw_end(1);
                    end if;
                end if;
            elsif gpu_state = PREPARE_NEXT_LINE then
                line_start_addr <= line_start_addr + 2;

                gpu_state <= FETCH_LINE;
            elsif gpu_state = WAIT_FOR_VGA then
                if vga_done = '1' then
                    gpu_state <= READ_OBJECT;
                    angle <= angle + 1;
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
                      (x"0000", x"0000",-draw_diff(0), draw_diff(1)) when "010",
                      (x"0000", x"0000", draw_diff(1),-draw_diff(0)) when "011",
                      (x"0000", x"0000",-draw_diff(1),-draw_diff(0)) when "100",
                      (x"0000", x"0000",-draw_diff(0),-draw_diff(1)) when "101",
                      (x"0000", x"0000", draw_diff(0),-draw_diff(1)) when "110",
                      (x"0000", x"0000",-draw_diff(1), draw_diff(0)) when others;


    with octant select
        pixel_out <=  (x"0000", x"0000", screen_start(1) + current_pixel(1) + obj_position(1),  screen_start(0) + current_pixel(0) + obj_position(0)) when "000",
                      (x"0000", x"0000", screen_start(1) + current_pixel(0) + obj_position(1),  screen_start(0) + current_pixel(1) + obj_position(0)) when "001",
                      (x"0000", x"0000", screen_start(1) + current_pixel(0) + obj_position(1),  screen_start(0) - current_pixel(1) + obj_position(0)) when "010",
                      (x"0000", x"0000", screen_start(1) + current_pixel(1) + obj_position(1),  screen_start(0) - current_pixel(0) + obj_position(0)) when "011",
                      (x"0000", x"0000", screen_start(1) - current_pixel(1) + obj_position(1),  screen_start(0) - current_pixel(0) + obj_position(0)) when "100",
                      (x"0000", x"0000", screen_start(1) - current_pixel(0) + obj_position(1),  screen_start(0) - current_pixel(1) + obj_position(0)) when "101",
                      (x"0000", x"0000", screen_start(1) - current_pixel(0) + obj_position(1),  screen_start(0) + current_pixel(1) + obj_position(0)) when "110",
                      (x"0000", x"0000", screen_start(1) - current_pixel(1) + obj_position(1),  screen_start(0) + current_pixel(0) + obj_position(0)) when others;

    pixel_address(16 downto 8) <= std_logic_vector(pixel_out(0)(8 downto 0));
    pixel_address(7 downto 0) <= std_logic_vector(pixel_out(1)(7 downto 0));
    pixel_data <= '1';

    pixel_write_enable <= '1' when gpu_state = CALC_PIXELS and pixel_out(0) > 0 and pixel_out(1) > 0 else '0';
    --with gpu_state select
    --    pixel_write_enable <= '1' when CALC_PIXELS,
    --                          '0' when others;
end Behavioral;
