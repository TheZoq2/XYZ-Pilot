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

            obj_mem_addr: out GPU_Info.ObjAddr_t;
            obj_mem_data: in GPU_Info.ObjData_t := x"0000000000000000";

            pixel_address: out std_logic_vector(16 downto 0);
            pixel_data: out std_logic;
            pixel_write_enable: out std_logic;
        
            vga_done: in std_logic
        );
    end component;

    component vga_motor is
        port(
            clk : in std_logic;
            data		: in std_logic;							-- Data from pixel memory
            addr		: out std_logic_vector(16 downto 0);	-- Adress for pixel memory
            re			: out std_logic;						-- Read enable for pixel memory
            rst			: in std_logic;							-- Reset
            h_sync	  	: out std_logic;						-- Horizontal sync
            v_sync		: out std_logic;						-- Vertical sync
            pixel_data	: out std_logic_vector(7 downto 0);     -- Data to be sent to the screen

            write_addr  : out std_logic_vector(16 downto 0);
            write_data  : out std_logic;
            write_enable: out std_logic;
            vga_done : out std_logic                      -- 1 when gpu and vga should switch buffers
        );
    end component;

    component pixel_mem is
        port(
            clk : in std_logic;
            switch_buffer: in std_logic;

            -- port IN
            gpu_write_adress: in std_logic_vector(16 downto 0);
            gpu_we : in std_logic;
            gpu_write_data : in std_logic;

            -- port IN
            vga_write_adress: in std_logic_vector(16 downto 0);
            vga_we : in std_logic;
            vga_write_data : in std_logic;
            -- port OUT
            vga_read_adress: in std_logic_vector(16 downto 0);
            vga_re : in std_logic;
            vga_read_data : out std_logic
        );
    end component;

    component ObjMem is
    port (
            clk : in std_logic;
            -- port 1
            read_addr : in GPU_Info.ModelAddr_t;
            read_data : out GPU_Info.ModelData_t
        );
    end component;

    signal clk: std_logic := '0';
    signal gpu_clk: std_logic := '0';
    signal clk_div: unsigned(1 downto 0) := "00";

    signal draw_start: Vector.Elements_t;
    signal draw_end: Vector.Elements_t;

    signal pixel_out: Vector.Elements_t;
    
    signal gpu_write_address : std_logic_vector(16 downto 0);
    signal gpu_write_data : std_logic;

    signal gpu_write_enable : std_logic;
    signal vga_done : std_logic;

    signal vga_write_address : std_logic_vector(16 downto 0);
    signal vga_write_data : std_logic;
    signal vga_we: std_logic;
    signal vga_read_address: std_logic_vector(16 downto 0);
    signal vga_read_data: std_logic;
    signal vga_re : std_logic;

    signal obj_mem_addr: GPU_Info.ObjAddr_t;
    signal obj_mem_data: GPU_Info.ObjData_t;
begin
    uut_len: gpu PORT MAP(
            clk => gpu_clk,
            obj_mem_data  => obj_mem_data,
            obj_mem_addr => obj_mem_addr,
            vga_done => vga_done,
            
            pixel_address => gpu_write_address,
            pixel_data => gpu_write_data,
            pixel_write_enable => gpu_write_enable
        );

    uut_vga_motor : vga_motor port map (
            clk => clk,
            vga_done => vga_done,
            rst => '0',

            addr => vga_read_address,
            data => vga_read_data,
            re => vga_re,

            write_addr => vga_write_address,
            write_data => vga_write_data,
            write_enable => vga_we
        );

    uut_pix_mem : pixel_mem port map (
            clk => clk,
            switch_buffer => vga_done,
            gpu_write_data => gpu_write_data,
            gpu_write_adress => gpu_write_address,
            gpu_we => gpu_write_enable,
            
            vga_write_adress => vga_write_address,
            vga_write_data => vga_write_data,
            vga_we => vga_we,
            vga_read_adress => vga_read_address,
            vga_read_data => vga_read_data,
            vga_re => vga_re
        );

    uut_obj_mem : ObjMem port map (
            clk => clk,
            read_addr => obj_mem_addr,
            read_data => obj_mem_data
        );

    clk <= not clk after 5 ns;

    process(clk) begin
        clk_div <= clk_div + 1;
    end process;

    gpu_clk <= '1' when (clk_div = "11") else '0';
    
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
