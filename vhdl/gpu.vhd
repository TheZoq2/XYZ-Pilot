library IEEE;
use IEEE.std_logic_1164.all;

--Constants
package GPU_Info is
    --The length of the addresses and data in the object memory
    constant OBJ_ADDR_SIZE: positive := 16;
    constant OBJ_DATA_SIZE: positive := 64;

    constant MODEL_ADDR_SIZE: positive := 16;
    constant MODEL_DATA_SIZE: positive := 64;
end package;

--Behaviour code
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.Vector;
use work.GPU_Info;

entity GPU is
    port(
            --The address of the current object in the  object memory
            obj_ptr: out std_logic_vector(GPU_Info.OBJ_ADDR_SIZE - 1 downto 0);
            --The output of the object memory
            obj_data: in std_logic_vector(GPU_Info.OBJ_DATA_SIZE - 1 downto 0);

            --Data from the  model memory
            line_register: inout std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1 downto 0);
            line_data: in std_logic_vector(GPU_Info.MODEL_DATA_SIZE -1 downto 0);
        );
end GPU;

architecture Behavioral of GPU is
    --The mux which decides if we want to start reading a new model or read more lines in the  current  one
    signal line_mux_in: std_logic;
    signal line_mux_out: std_logic_vector(GPUInfo.MODEL_ADDR_SIZE - 1  downto 0);

    signal next_line_reg: std_logic_vector(GPUInfo.MODEL_ADDR_SIZE -1 downto 0);
begin

    -------------------------------------------
    --Updating the line register
    with line_mux_in select
        line_mux_out <= obj_ptr when '1',
                        next_line_reg when others;

    process(clk) begin
        if rising_edge(clk) then
            line_register <= line_mux_out;
        end if;
    end process;
    -------------------------------------------

    
end Behavioral;

