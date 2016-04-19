library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Constants
package GPU_Info is
    --The length of the addresses and data in the object memory
    constant OBJ_ADDR_SIZE: positive := 16;
    constant OBJ_DATA_SIZE: positive := 64;

    constant MODEL_ADDR_SIZE: positive := 16;
    constant MODEL_DATA_SIZE: positive := 64;

    
    subtype gpu_state_type is std_logic_vector(1 downto 0);

    --'Enums' for the states of the GPU
    constant READ_OBJECT_STATE: gpu_state_type := "00";
    constant FETCH_LINE_STATE: gpu_state_type := "01";
    constant CALCULATE_LENGTH_STATE: gpu_state_type := "10";
    constant CALCULATE_PIXELS_STATE: gpu_state_type := "11";
end package;

--Behaviour code
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.Vector;
use work.GPU_Info;
--use work.vector_alu.all;

entity GPU is
    port(
            clk: in std_logic;

            --The address of the current object in the  object memory
            obj_ptr: out std_logic_vector(GPU_Info.OBJ_ADDR_SIZE - 1 downto 0);
            --The output of the object memory
            obj_data: in std_logic_vector(GPU_Info.OBJ_DATA_SIZE - 1 downto 0);

            --Data from the  model memory
            line_register: inout std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1 downto 0);
            line_data: in std_logic_vector(GPU_Info.MODEL_DATA_SIZE - 1 downto 0);

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic

        );
end entity;

architecture Behavioral of GPU is
    component VectorLength is
        port(
                vec1: in Vector.Elements_t;
                result: out std_logic_vector(15 downto 0)
            );
    end component;
    component VectorSubtractor is
        port(
                vec1: in Vector.Elements_t;
                vec2: in Vector.Elements_t;
                result: out Vector.Elements_t
            );
    end component;

    --The mux which decides if we want to start reading a new model or read more lines in the  current  one
    signal line_mux_in: std_logic_vector(1 downto 0);
    signal line_mux_out: std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1  downto 0);

    signal next_line_reg: std_logic_vector(GPU_Info.MODEL_ADDR_SIZE -1 downto 0);

    signal gpu_state: std_logic_vector(1 downto 0);


    signal current_obj_offset: std_logic_vector(2 downto 0);
    signal current_obj: std_logic_vector(GPU_Info.OBJ_ADDR_SIZE - 1 downto 0);

    signal transform_reg_addr: std_logic_vector(2 downto 0);
    signal transform_reg_write_enable: std_logic;

    --Decides which vector register in the gpu to write the current line in the model memory  to
    signal write_start_or_end: std_logic;

    signal start_vector: work.Vector.InMemory_t;
    signal end_vector: work.Vector.InMemory_t;

    --The amount of steps left until the line is  done drawing
    signal length_left: std_logic_vector(15 downto 0); 

    --The coordinate that is being drawn
    signal current_pixel: Vector.Elements_2D_t;

    signal draw_start: Vector.Elements_t; --The start of the vector to be drawn on the screen
    signal draw_end: Vector.Elements_t; --The end of ^^
    signal draw_diff: Vector.Elements_t; --The vector between draw_start and  draw_end
    signal draw_length: std_logic_vector(15 downto 0); --The length of draw_diff which will be put into length_left
    signal draw_normal: Vector.Elements_t; --Normalised version of the draw_diff vector. Will be used  for stepping along the line


begin
    draw_length_calculator: VectorLength port map(
                        vec1 => draw_diff,
                        result => draw_length
                    );
    draw_diff_calculator: VectorSubtractor port map(
                        vec1 => draw_start,
                        vec2 => draw_end,
                        result => draw_diff
                    );

    -------------------------------------------
    --Updating the line register
    with line_mux_in select
        line_mux_out <= obj_data when "00",
                        next_line_reg when "01",
                        line_mux_out when others;

    process(clk) begin
        if rising_edge(clk) then
            line_register <= line_mux_out;
        end if;
    end process;
    -------------------------------------------
    --      Transfrorm register input
    -------------------------------------------
    obj_ptr <= current_obj + current_obj_offset;
    transform_reg_addr <= current_obj_offset(2 downto 0);
    -------------------------------------------

    --Main GPU state machine
    process(clk) begin
        if rising_edge(clk) then
            if gpu_state = GPU_Info.READ_OBJECT_STATE then
                
                --If we have read all the data
                if current_obj_offset = "100" then
                    current_obj_offset <= "000";
                    gpu_state <= GPU_Info.FETCH_LINE_STATE;
                    transform_reg_write_enable <= '0';
                else
                    --Reading a new model and transform
                    current_obj_offset <= current_obj_offset + 1;

                    transform_reg_write_enable <= '1';
                end if;
            elsif gpu_state = GPU_Info.FETCH_LINE_STATE then
                --Reading the next start and end of lines
                if write_start_or_end = '1' then
                    start_vector <= line_data;
                    write_start_or_end <= '1';
                else
                    end_vector <= line_data;
                    write_start_or_end <= '1';

                    gpu_state <= GPU_Info.CALCULATE_LENGTH_STATE;
                end if;
            elsif gpu_state = GPU_Info.CALCULATE_LENGTH_STATE then
                --Do length and  normal calculation
                length_left <= draw_length;

                gpu_state <= GPU_Info.CALCULATE_PIXELS_STATE;
            else
                --Calculating pixels
                --current_pixel(0) <= current_pixel(0)
                
            end if;
        end if;
    end process;
end Behavioral;
