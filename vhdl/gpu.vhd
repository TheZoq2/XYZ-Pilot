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
          -- Read the object from object memory.
          READ_OBJECT,

          -- Read line data from model memory pointer to by object.
          FETCH_LINE,

          -- Prepare initial state for line drawing.
          PREPARE_LINE,

          -- Choose whether to iterate over the x-axis or y-axis.
          START_LINE,

          -- Draw the current pixel of the line to the pixel memory.
          DRAW_LINE_PIXEL,

          -- Update line pixel position and loop index.
          PREPARE_NEXT_LINE_PIXEL,

          -- Increase line pointer to next line and fetch it.
          PREPARE_NEXT_LINE,

          -- Suspend GPU operation until the next frame.
          WAIT_FOR_VGA,

          -- Calculate trigonometry functions for various data. 
          CALC_TRIG,

          -- Use values from trigonometry calculations to perform rotation transform.
          CALC_ROTATED
        );

    function add_small_num(num1: datatypes.small_number_t; num2: datatypes.small_number_t)
        return datatypes.small_number_t is

        variable result: datatypes.small_number_t;

        variable abs1: unsigned(9 downto 0);
        variable abs2: unsigned(9 downto 0);

        variable sign1: std_logic;
        variable sign2: std_logic;
    begin
        abs1 := num1(9 downto 0);
        abs2 := num2(9 downto 0);
        sign1 := num1(15);
        sign2 := num2(15);

        result := (others => '0');
        if sign1 = sign2 then --The signs are  the same. Preserve sign, add values.
            result(15) := sign1;
            result(9 downto 0) := abs1 + abs2;
        elsif sign1 = '1' then --The First number is negative
            if num1(9 downto 0) > num2(9 downto 0) then
                result(15) := '1';
                result(9 downto 0) := abs1 - abs2;
            else
                result(15) := '0';
                result(9 downto 0) := unsigned(abs ((signed(abs1) - signed(abs2))));
            end if;
        else    --The second number is negative
            if num2(9 downto 0) > num1(9 downto 0) then
                result(15) := '1';
                result(9 downto 0) := abs2 - abs1;
            else
                result(15) := '0';
                result(9 downto 0) := unsigned(abs (signed(abs2) - signed(abs1)));
            end if;
        end if;

        return result;
    end function;

    signal gpu_state: gpu_state_type := READ_OBJECT;

    signal delay_counter: unsigned(2 downto 0) := "000";

    --The offset from the start of the current object pointer in memory to the current 'line' in the memory
    signal current_obj_start: GPU_Info.ObjAddr_t := (others => '0');
    signal current_obj_offset: unsigned(2 downto 0) := (others => '0');
    signal obj_mem_vec: vector.Elements_t;

    --Decides which vector register in the gpu to write the current line in the model memory  to
    signal set_start_or_end: std_logic := '0';

    signal start_vector: work.Vector.InMemory_t := (others => '0');
    signal end_vector: work.Vector.InMemory_t := (others => '0');

    signal screen_start: Vector.Elements_t;
    signal screen_end: Vector.Elements_t;

    signal obj_position: Vector.Elements_t;
    signal obj_angle: Vector.Elements_t;
    signal obj_scale: Vector.Elements_t;

    --Versions of draw_start and end that have not been corrected for the line to be in the first
    --octant
    signal raw_start: Vector.Elements_t;
    signal raw_end: Vector.Elements_t; 

    --Model data signals
    signal model_mem_addr: GPU_Info.ModelAddr_t;
    signal model_mem_data: GPU_Info.ModelData_t;

    --The address in the model memory that the next 
    signal line_start_addr: GPU_Info.ModelAddr_t := (others => '0');

    signal fetch_line_state: Line_Fetch_State.type_t := Line_Fetch_State.SET_START;

    signal calc_angle: unsigned(7 downto 0) := x"00";
    signal sin_val: datatypes.small_number_t;

    signal trig_calc_stage: unsigned(2 downto 0) := (others => '0');

    signal calc_rotation_start_or_end: std_logic := '0';
    signal rotation_calc_stage: unsigned(4 downto 0) := (others => '0');

    type big_mul_in_selector_t is (
        SEL_TRIG_BUFF,
        SEL_TRIG_RESULT
    );
    signal big_mul_in_selector: big_mul_in_selector_t;

    --Buffers to store calculated trig values for all the angles
    signal sin_a: datatypes.small_number_t;
    signal sin_b: datatypes.small_number_t;
    signal sin_c: datatypes.small_number_t;

    signal cos_a: datatypes.small_number_t;
    signal cos_b: datatypes.small_number_t;
    signal cos_c: datatypes.small_number_t;


    --The regsiters where intermediate results of trigonometric functions are stored
    signal current_trig: datatypes.small_number_t;
    signal current_coord: datatypes.std_number_t;

    --Input into the small  fraction multiplyer
    signal trig_in_1: datatypes.small_number_t;
    signal trig_in_2: datatypes.small_number_t;
    signal trig_result: datatypes.small_number_t;
    signal trig_buff: datatypes.small_number_t;

    --Result and input to the fractional number multiplyer
    signal big_mult_num: datatypes.std_number_t;
    signal big_mult_result: datatypes.std_number_t;

    signal big_mul_trig_in: datatypes.small_number_t;

    signal current_rotated_vector: Vector.Elements_t;
    signal rotation_result: Vector.Elements_t;

    -- Variables for Bresenham's line algorithm
    signal dx : signed(15 downto 0);
    signal dy : signed(15 downto 0);
    signal D : signed(31 downto 0);
    signal i : signed(15 downto 0);
    signal len : signed(15 downto 0);
    signal x : signed(15 downto 0);
    signal y : signed(15 downto 0);
    signal x_out : signed(15 downto 0);
    signal y_out : signed(15 downto 0);
    signal x_incr : signed(15 downto 0);
    signal y_incr : signed(15 downto 0);

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

    component SmallNumberMultiplyer is
        port(
                num1: in Datatypes.small_number_t;
                num2: in Datatypes.small_number_t;
                result: out Datatypes.small_number_t
            );
    end component;
    
begin
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

    sin_map : sin_table port map (
            angle => calc_angle,
            result => sin_val
        );

    frac_map : FractionalMultiplyer port map (
            big_num => big_mult_num,
            small_num => big_mul_trig_in,
            result => big_mult_result
        );
    small_num_map : SmallNumberMultiplyer port map (
            num1 => trig_in_1,
            num2 => trig_in_2,
            result => trig_result
        );

    obj_mem_addr <= current_obj_start + current_obj_offset;

    --screen_start(0) <= raw_start(0);
    --screen_start(1) <= raw_start(1);
    ----screen_start(1) <= y_cos - z_sin;

    --screen_start(2) <= x"0000";
    --screen_start(3) <= x"0000";
    --screen_end(0) <= raw_end(0);
    --screen_end(1) <= raw_end(1);
    ----screen_end(1) <= y_cos_end - z_sin_end;
    --screen_end(2) <= x"0000";
    --screen_end(3) <= x"0000";

    with fetch_line_state select
        model_mem_addr <= line_start_addr when Line_Fetch_State.SET_START,
                          line_start_addr when Line_Fetch_State.STORE_START,
                          line_start_addr + 1 when others;

    --Change between calculating the rotation of the start or end vector
    current_rotated_vector <= raw_start when calc_rotation_start_or_end = '1' and gpu_state = CALC_ROTATED else raw_end;
    
    big_mul_trig_in <= trig_result when big_mul_in_selector = SEL_TRIG_RESULT else trig_buff;

    --###########################################################################
    --      Main GPU state machine
    --###########################################################################
    process(clk) begin
        if rising_edge(clk) then
            if gpu_state = READ_OBJECT then
                --Going to the next state if all the object data for the current object
                --has been read
                if current_obj_offset = 4 then
                    current_obj_offset <= "000";
                    current_obj_start <= current_obj_start + 4;

                    if obj_mem_data = x"ffffffffffffffff" then 
                        gpu_state <= WAIT_FOR_VGA;
                    else
                        gpu_state <= CALC_TRIG;
                    end if;
                else
                    current_obj_offset <= current_obj_offset + 1;
                end if;

                --Reading object data
                if current_obj_offset = 4 then
                    line_start_addr <= unsigned(obj_mem_data(GPU_Info.MODEL_ADDR_SIZE - 1 downto 0));
                elsif current_obj_offset = 3 then --If this is the position value
                    obj_scale <=  obj_mem_vec;
                elsif current_obj_offset = 2 then
                    obj_angle <=  obj_mem_vec;
                elsif current_obj_offset = 1 then
                    obj_position <=  obj_mem_vec;
                end if;
            elsif gpu_state = CALC_TRIG then

                trig_calc_stage <= trig_calc_stage + 1;
                --Do the actual calculations
                case trig_calc_stage is
                    when "000" =>
                        calc_angle <= unsigned(obj_angle(0)(7 downto 0));
                    when "001" =>
                        calc_angle <= unsigned(obj_angle(1)(7 downto 0));
                        sin_a <= sin_val;
                    when "010" =>
                        calc_angle <= unsigned(obj_angle(2)(7 downto 0));
                        sin_b <= sin_val;
                    when "011" =>
                        calc_angle <= unsigned(obj_angle(0)(7 downto 0) + 64);
                        sin_c <= sin_val;
                    when "100" =>
                        calc_angle <= unsigned(obj_angle(1)(7 downto 0) + 64);
                        cos_a <= sin_val;
                    when "101" =>
                        calc_angle <= unsigned(obj_angle(2)(7 downto 0) + 64);
                        cos_b <= sin_val;
                    when "110" =>
                        cos_c <= sin_val;
                    when others =>
                        gpu_state <= FETCH_LINE;
                        trig_calc_stage <= (others => '0');
                end case;
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
                    gpu_state <= CALC_ROTATED;
                end if;
            elsif gpu_state = CALC_ROTATED then
                rotation_calc_stage <= rotation_calc_stage + 1;


                case rotation_calc_stage is
                    when "00000" => --cos(a)*cos(b) * x
                        trig_in_1 <= cos_b;
                        trig_in_2 <= cos_c;
                        big_mult_num <= current_rotated_vector(0);

                        big_mul_in_selector <= SEL_TRIG_RESULT;
                    when "00001" => --Save x, calc cos(c)*sin(b)
                        current_coord <= big_mult_result;
                        
                        trig_in_1 <= cos_c;
                        trig_in_2 <= sin_a;
                    when "00010" => --Calc result*sin(b)
                        trig_in_1 <= trig_result;
                        trig_in_2 <= sin_b;
                    when "00011" => --Store result and calculate cos(a) * sin(c)
                        trig_buff <= trig_result;
                        trig_in_1 <= cos_a;
                        trig_in_2 <= sin_c;
                    when "00100" => --Subtract the previous two results from each other
                        --Subtract result from the  buffer content
                        trig_buff <= add_small_num(trig_buff, not trig_result(15) & trig_result(14 downto 0));
                        big_mult_num <= current_rotated_vector(1);

                        big_mul_in_selector <= SEL_TRIG_BUFF;
                    when "00101" => --Store trig_buff * y, calculate cos(a)*cos(c)
                        --Add the result of the y variable to the result
                        current_coord <= current_coord + big_mult_result;

                        trig_in_1 <= cos_a;
                        trig_in_2 <= cos_c;
                    when "00110" => --Old result * sin(b)
                        trig_in_1 <= trig_result;
                        trig_in_2 <= sin_b;
                    when "00111" => --Store in buff, calcl sin(a)*sin(c)
                        trig_buff <= trig_result;
                        trig_in_1 <= sin_a;
                        trig_in_2 <= sin_c;
                    when "01000" =>  --Part1 + part2. Start y element
                        big_mul_in_selector <= SEL_TRIG_BUFF;
                        big_mult_num <= current_rotated_vector(2);

                        trig_buff <= add_small_num(trig_buff, trig_result);
                        
                        big_mul_in_selector <= SEL_TRIG_BUFF;
                    when "01001" => --Start the y element and store the x element
                        rotation_result(0) <= current_coord + big_mult_result;

                        big_mul_in_selector <= SEL_TRIG_RESULT;
                        big_mult_num <= current_rotated_vector(0);
                        trig_in_1 <= cos_b;
                        trig_in_2 <= sin_c;
                    when "01010" => --Store cos(b)*sin(c) * x, calc cos(a)*cos(c)
                        current_coord <= big_mult_result;

                        trig_in_1 <= cos_a;
                        trig_in_2 <= cos_c;
                    when "01011" =>  --sin(a)*sin(b)
                        trig_buff <= trig_result;
                        trig_in_1 <= sin_a;
                        trig_in_2 <= sin_b;
                    when "01100" => --trig_buff * sin(c)
                        trig_in_1 <= trig_result;
                        trig_in_2 <= sin_c;
                    when "01101" => --Store the result of the y trig  function, start z
                        trig_buff <= add_small_num(trig_buff, trig_result);
                        big_mult_num <= current_rotated_vector(1);
                        
                        big_mul_in_selector <= SEL_TRIG_BUFF;
                    when "01110" => --Calculate the final z term
                        current_coord <= current_coord + big_mult_result;

                        trig_in_1 <= cos_a;
                        trig_in_2 <= sin_b;
                    when "01111" =>
                        trig_in_1 <= trig_result;
                        trig_in_2 <= sin_c;
                    when "10000"  =>
                        trig_buff <= trig_result;
                        trig_in_1 <= cos_c;
                        trig_in_2 <= sin_a;
                    when "10001" =>
                        --Subtract result from the  buffer content
                        trig_buff <= add_small_num(trig_buff, not trig_result(15) & trig_result(14 downto 0));
                        big_mult_num <= current_rotated_vector(2);

                        big_mul_in_selector <= SEL_TRIG_BUFF;
                    when "10010" =>
                        rotation_result(1) <= current_coord + big_mult_Result;
                    when others =>
                        if calc_rotation_start_or_end = '1' then
                            screen_end <= rotation_result;
                            gpu_state <= PREPARE_LINE;
                        else
                            screen_start <= rotation_result;
                        end if;

                        calc_rotation_start_or_end <= not calc_rotation_start_or_end;

                        rotation_calc_stage <= (others => '0');
                end case;
            elsif gpu_state = PREPARE_LINE then
              if end_vector = x"ffffffffffffffff" then
                -- Last line in object was found. Parse next object.
                gpu_state <= READ_OBJECT;
              else
                -- Calculate pre-conditions for the line algorithm.
                dx <= abs(screen_end(0) - screen_start(0));
                dy <= abs(screen_end(1) - screen_start(1));
                x <= (others => '0');
                y <= (others => '0');
                i <= (others => '0');
                
                gpu_state <= START_LINE;
              end if;
            elsif gpu_state = START_LINE then
              -- Finalize pre-conditions. Loop over the longest axis.
              if dx > dy then
                len <= dx;
                D <= 2 * dy - dx;
              else
                len <= dy;
                D <= 2 * dx - dy;
              end if;

              gpu_state <= DRAW_LINE_PIXEL;
            elsif gpu_state = DRAW_LINE_PIXEL then
              -- The current x and y values are sent to the pixel memory while
              -- this state is active.
              
              if i >= len then
                -- Stop looping when all pixels on the chosen axis has been processed.
                gpu_state <= PREPARE_NEXT_LINE;
              else
                if D > 0 then
                  -- Increase the opposite axis if the algorithm says so.
                  if dx > dy then
                    y <= y + y_incr;
                    D <= D - 2 * dx;
                  else
                    x <= x + x_incr;
                    D <= D - 2 * dy;
                  end if;
                end if;

                gpu_state <= PREPARE_NEXT_LINE_PIXEL;
              end if;
            elsif gpu_state = PREPARE_NEXT_LINE_PIXEL then
              -- Increase the loop index as well as the current position along the
              -- loop axis before drawing the next pixel.
              i <= i + 1;
              if dx > dy then
                x <= x + x_incr;
                D <= D + 2 * dy;
              else
                y <= y + y_incr;
                D <= D + 2 * dx;
              end if;

              gpu_state <= DRAW_LINE_PIXEL;
            elsif gpu_state = PREPARE_NEXT_LINE then
                line_start_addr <= line_start_addr + 2;

                gpu_state <= FETCH_LINE;
            elsif gpu_state = WAIT_FOR_VGA then
                if vga_done = '1' then
                    gpu_state <= READ_OBJECT;
                    --angle <= angle + 1;
                end if;
                current_obj_start <= (others => '0');
            end if;
        end if;
    end process;

    -- Direction from line start to line end.
    x_incr <= to_signed(1, 16) when screen_end(0) > screen_start(0) else to_signed(-1, 16);
    y_incr <= to_signed(1, 16) when screen_end(1) > screen_start(1) else to_signed(-1, 16);

    -- Complete x and y positions to render to pixel memory.
    x_out <= obj_position(0) + screen_start(0) + x;
    y_out <= obj_position(1) + screen_start(1) + y;

    pixel_address(16 downto 8) <= std_logic_vector(x_out(8 downto 0));
    pixel_address(7 downto 0) <= std_logic_vector(y_out(7 downto 0));
    pixel_data <= '1';

    pixel_write_enable <= '1' when gpu_state = DRAW_LINE_PIXEL and 
                          x_out > 0 and
                          y_out > 0 and
                          x_out < 321 and
                          y_out < 241
                    else '0';

end Behavioral;
