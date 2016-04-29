library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Include the  types required by the splitter
use work.Vector;
use work.GPU_Info;


entity gpu_tb is
end entity;

architecture Behavioral of gpu_tb is
    component gpu is
        port(
            clk: in std_logic;

            ----The address of the current object in the  object memory
            --obj_ptr: out unsigned(GPU_Info.OBJ_ADDR_SIZE - 1 downto 0);
            ----The output of the object memory
            --obj_data: in std_logic_vector(GPU_Info.OBJ_DATA_SIZE - 1 downto 0);

            ----Data from the  model memory
            --line_register: inout std_logic_vector(GPU_Info.MODEL_ADDR_SIZE - 1 downto 0);
            --line_data: in std_logic_vector(GPU_Info.MODEL_DATA_SIZE - 1 downto 0);

            --pixel_address: out std_logic_vector(16 downto 0);
            --pixel_data: out std_logic;
            --pixel_write_enable: out std_logic;

            switch_buffers: in std_logic
        );
    end component;

    signal clk: std_logic := '0';

    signal draw_start: Vector.Elements_t;
    signal draw_end: Vector.Elements_t;

    signal pixel_out: Vector.Elements_t;
begin
    uut_len: gpu PORT MAP(
            clk => clk,
            switch_buffers => '0'
        );

    clk <= not clk after 5 ns;
    
    process begin
        draw_start(0) <= to_signed(170, 16);
        draw_start(1) <= to_signed(130, 16);

        draw_end(0) <= to_signed(140, 16);
        draw_end(1) <= to_signed(120, 16);
        
        wait for 190 ns;
        --draw_start(0) <= x"0003";
        --draw_start(1) <= x"0007";
        --draw_start(2) <= x"0000";
        --draw_start(3) <= x"0000";

        --draw_end(0) <= x"0005";
        --draw_end(1) <= x"0002";
        --draw_end(2) <= x"0000";
        --draw_end(3) <= x"0000";


        wait;
    end process;
end;
