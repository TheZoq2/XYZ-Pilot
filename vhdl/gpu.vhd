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
use IEEE.numeric_std.all;

use work.GPU_Info;
use work.Vector;
--use work.vector_alu.all;

entity GPU is
    port(
            clk: in std_logic;

            ----The address of the current object in the  object memory
            --obj_ptr: out unsigned(GPU_Info.OBJ_ADDR_SIZE - 1 downto 0);
            ----The output of the object memory
            --obj_data: in std_logic_vector(GPU_Info.OBJ_DATA_SIZE - 1 downto 0);

            ----Data from the  model memory
            --line_register: inout std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1 downto 0);
            --line_data: in std_logic_vector(GPU_Info.MODEL_DATA_SIZE - 1 downto 0);

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
    signal write_start_or_end: std_logic;

    signal start_vector: work.Vector.InMemory_t;
    signal end_vector: work.Vector.InMemory_t;

    --The coordinate that is being drawn
    signal current_pixel: Vector.Elements_t;

    signal draw_start: Vector.Elements_t; --The start of the vector to be drawn on the screen
    signal draw_end: Vector.Elements_t; --The end of ^^
    signal draw_diff: Vector.Elements_t; --The vector between draw_start and  draw_end

    --Versions of draw_start and end that have not been corrected for the line to be in the first
    --octant
    signal raw_start: Vector.Elements_t;
    signal raw_end: Vector.Elements_t; 

    signal octant: unsigned(2 downto 0);

    signal draw_d_var: signed(15 downto 0);
    component VectorSubtractor is
        port(
                --The two vectors that should be added together
                vec1: in Vector.Elements_t;
                vec2: in Vector.Elements_t;

                result: out Vector.Elements_t
            );
    end component ;

begin
    draw_diff_calculator: VectorSubtractor port map(
                vec2 => draw_start,
                vec1 => draw_end,
                result => draw_diff
            );

    raw_start <= dbg_draw_start;
    raw_end <= dbg_draw_end;
    
    with octant select
        draw_start <= ( raw_start(0), raw_start(1), x"0000", x"0000") when "000",
                      ( raw_start(1), raw_start(0), x"0000", x"0000") when "001",
                      ( raw_start(0),-raw_start(0), x"0000", x"0000") when "010",
                      (-raw_start(0), raw_start(1), x"0000", x"0000") when "011",
                      (-raw_start(0),-raw_start(1), x"0000", x"0000") when "100",
                      (-raw_start(1),-raw_start(0), x"0000", x"0000") when "101",
                      (-raw_start(1), raw_start(0), x"0000", x"0000") when "110",
                      ( raw_start(0),-raw_start(1), x"0000", x"0000") when others;
    with octant select
        draw_end   <= ( raw_end(0), raw_end(1), x"0000", x"0000") when "000",
                      ( raw_end(1), raw_end(0), x"0000", x"0000") when "001",
                      ( raw_end(0),-raw_end(0), x"0000", x"0000") when "010",
                      (-raw_end(0), raw_end(1), x"0000", x"0000") when "011",
                      (-raw_end(0),-raw_end(1), x"0000", x"0000") when "100",
                      (-raw_end(1),-raw_end(0), x"0000", x"0000") when "101",
                      (-raw_end(1), raw_end(0), x"0000", x"0000") when "110",
                      ( raw_end(0),-raw_end(1), x"0000", x"0000") when others;

    --Main GPU state machine
    process(clk) begin
        if rising_edge(clk) then
            if gpu_state = GPU_Info.READ_OBJECT_STATE then
                gpu_state <= GPU_Info.FETCH_LINE_STATE;
            elsif gpu_state = GPU_Info.FETCH_LINE_STATE then
                gpu_state <= GPU_Info.CALCULATE_LENGTH_STATE;
            elsif gpu_state = GPU_Info.CALCULATE_LENGTH_STATE then
                --Set up the pixel drawing calculation
                draw_d_var <= draw_diff(1) - draw_diff(0);
                current_pixel(0) <= draw_start(0);
                current_pixel(1) <= draw_start(1);

                gpu_state <= GPU_Info.CALCULATE_PIXELS_STATE;
            else
                if current_pixel(0) > draw_end(0) then
                    gpu_state <= GPU_Info.READ_OBJECT_STATE;
                else
                    current_pixel(0) <= current_pixel(0) + 1;
                    if draw_d_var >= 0 then
                        current_pixel(1) <= current_pixel(1) + 1;
                        draw_d_var <= draw_d_var + draw_diff(1) - draw_diff(0);
                    else
                        draw_d_var <= draw_d_var + draw_diff(1);
                    end if;
                end if;
            end if;
        end if;
    end process;

    with octant select
        pixel_out <=  ( current_pixel(0), current_pixel(1), x"0000", x"0000") when "000",
                      ( current_pixel(1), current_pixel(0), x"0000", x"0000") when "001",
                      (-current_pixel(1), current_pixel(0), x"0000", x"0000") when "010",
                      (-current_pixel(0), current_pixel(1), x"0000", x"0000") when "011",
                      (-current_pixel(0),-current_pixel(1), x"0000", x"0000") when "100",
                      (-current_pixel(1),-current_pixel(0), x"0000", x"0000") when "101",
                      ( current_pixel(1),-current_pixel(0), x"0000", x"0000") when "110",
                      ( current_pixel(0),-current_pixel(1), x"0000", x"0000") when others;

    pixel_out(0) <= current_pixel(0);
    pixel_out(1) <= current_pixel(1);
    pixel_out(2) <= x"0000";
    pixel_out(3) <= x"0000";

    pixel_address(16 downto 8) <= std_logic_vector(current_pixel(0)(8 downto 0));
    pixel_address(7 downto 0) <= std_logic_vector(current_pixel(1)(7 downto 0));
    pixel_data <= '1';
    pixel_write_enable <= '1';
end Behavioral;
