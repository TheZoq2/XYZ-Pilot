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
          PREPARE_LINE,
          START_LINE,
          DRAW_LINE_PIXEL,
          PREPARE_NEXT_LINE_PIXEL,
          PREPARE_NEXT_LINE,
          WAIT_FOR_VGA
                        );
    signal gpu_state: gpu_state_type := READ_OBJECT;

    signal delay_counter: unsigned(2 downto 0) := "000";

    --The offset from the start of the current object pointer in memory to the current 'line' in the memory
    signal current_obj_start: GPU_Info.ObjAddr_t := (others => '0');
    signal current_obj_offset: unsigned(2 downto 0) := (others => '0');
    signal obj_mem_vec: vector.Elements_t;

    --Decides which vector register in the gpu to write the current line in the model memory  to
    signal set_start_or_end: std_logic := '0';

    signal start_vector: work.Vector.InMemory_t;
    signal end_vector: work.Vector.InMemory_t;

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

    signal angle: unsigned(7 downto 0) := x"00";
    signal cos_val: datatypes.small_number_t;
    signal sin_val: datatypes.small_number_t;

    signal y_cos: datatypes.std_number_t;
    signal z_sin: datatypes.std_number_t;
    signal y_cos_end: datatypes.std_number_t;
    signal z_sin_end: datatypes.std_number_t;

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

    obj_mem_addr <= current_obj_start + current_obj_offset;

    screen_start(0) <= raw_start(0);
    screen_start(1) <= raw_start(1);
    --screen_start(1) <= y_cos - z_sin;

    screen_start(2) <= x"0000";
    screen_start(3) <= x"0000";
    screen_end(0) <= raw_end(0);
    screen_end(1) <= raw_end(1);
    --screen_end(1) <= y_cos_end - z_sin_end;
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
                --line_start_addr <= (others => '0');

                    --report("Reading new line");
                --Incrememnt the current offset and switch states
                if current_obj_offset = 3 then
                    current_obj_offset <= "000";
                    current_obj_start <= current_obj_start + 4;

                    if obj_mem_data = x"ffffffffffffffff" then 
                        gpu_state <= WAIT_FOR_VGA;
                        report("Going into WAIT");
                    else
                        gpu_state <= FETCH_LINE;
                    end if;
                else
                    current_obj_offset <= current_obj_offset + 1;
                end if;

                if current_obj_offset = 3 then
                    line_start_addr <= unsigned(obj_mem_data(GPU_Info.MODEL_ADDR_SIZE - 1 downto 0));
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
                    gpu_state <= PREPARE_LINE;
                end if;
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

                    current_obj_start <= (others => '0');
                end if;
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
