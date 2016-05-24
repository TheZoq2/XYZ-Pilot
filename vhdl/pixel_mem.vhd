-- Consisting of two buffers, the pixel memory switches between these two, where the gpu is
-- writing to one and the vga motor is reading from the other (and clearing)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pixel_mem is
port (
        clk : in std_logic;
        switch_buffer: in std_logic; -- One pulse, decides when to switch buffers

        -- port IN
        gpu_write_adress: in std_logic_vector(16 downto 0);
        gpu_we : in std_logic;
        gpu_write_data : in std_logic;

        -- port IN (for clearing after reading)
        vga_write_adress: in std_logic_vector(16 downto 0);
        vga_we : in std_logic;
        vga_write_data : in std_logic;

        -- port OUT
        vga_read_adress: in std_logic_vector(16 downto 0);
        vga_re : in std_logic;
        vga_read_data : out std_logic
    );

end pixel_mem;

architecture Behavioral of pixel_mem is
    -- Declaration of pixel memory of 131072 adresses
    type ram_t is array (0 to 131071) of std_logic;

    -- Clears all adresses
    signal ram1 : ram_t := (others => '0');

    -- Clears all adresses
    signal ram2 : ram_t := (others => '0');


    signal current_memory: std_logic := '1';

    --The outputs from the two RAMs
    signal r1_read_data :std_logic;
    signal r2_read_data :std_logic;


    --- The input to the two rams ---
    -- Adresses are divided into aliases
    alias gpu_write_x: std_logic_vector(8 downto 0) is gpu_write_adress(16 downto 8);
    alias gpu_write_y: std_logic_vector(7 downto 0) is gpu_write_adress(7 downto 0);

    alias vga_write_x: std_logic_vector(8 downto 0) is vga_write_adress(16 downto 8);
    alias vga_write_y: std_logic_vector(7 downto 0) is vga_write_adress(7 downto 0);

    alias vga_read_x: std_logic_vector(8 downto 0) is vga_read_adress(16 downto 8);
    alias vga_read_y: std_logic_vector(7 downto 0) is vga_read_adress(7 downto 0);

    signal r1_write_data :std_logic;
    signal r2_write_data :std_logic;

    signal r1_write_x: std_logic_vector(8 downto 0);
    signal r1_write_y: std_logic_vector(7 downto 0);
    alias r1_read_x: std_logic_vector(8 downto 0) is vga_read_x;
    alias r1_read_y: std_logic_vector(7 downto 0) is vga_read_y;

    signal r2_write_x: std_logic_vector(8 downto 0);
    signal r2_write_y: std_logic_vector(7 downto 0);
    alias r2_read_x: std_logic_vector(8 downto 0) is vga_read_x;
    alias r2_read_y: std_logic_vector(7 downto 0) is vga_read_y;

    signal r1_we: std_logic;
    signal r2_we: std_logic;
    signal r1_re: std_logic;
    signal r2_re: std_logic;

begin
    --- Which buffer to write to and read from is decided here ---
    vga_read_data <= r2_read_data when current_memory = '1' else r1_read_data;

    --Read enable pins
    r1_re <= '0'                when current_memory = '1' else vga_re;
    r2_re <= vga_re             when current_memory = '1' else '0';

    --write pins
    r1_write_data <= gpu_write_data when current_memory = '1' else vga_write_data;
    r2_write_data <= gpu_write_data when current_memory = '0' else vga_write_data;

    r1_write_x <= gpu_write_x       when current_memory = '1' else vga_write_x;
    r1_write_y <= gpu_write_y       when current_memory = '1' else vga_write_y;

    r2_write_x <= gpu_write_x       when current_memory = '0' else vga_write_x;
    r2_write_y <= gpu_write_y       when current_memory = '0' else vga_write_y;

    r1_we      <= gpu_we            when current_memory = '1' else vga_we;
    r2_we      <= gpu_we            when current_memory = '0' else vga_we;

    process(clk) begin
        if rising_edge(clk) then
            if switch_buffer = '1' then
                current_memory <= not current_memory;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if (rising_edge(clk)) then
            -- WRITE
            if (r1_we = '1') then
                ram1(320*conv_integer(r1_write_y)+conv_integer(r1_write_x)) <= r1_write_data;
            end if;
            -- READ
            if (r1_re = '1') then
                r1_read_data <= ram1(320*conv_integer(r1_read_y)+conv_integer(r1_read_x));
            end if;

            -- WRITE
            if (r2_we = '1') then
                ram2(320*conv_integer(r2_write_y)+conv_integer(r2_write_x)) <= r2_write_data;
            end if;
            -- READ
            if (r2_re = '1') then
                r2_read_data <= ram2(320*conv_integer(r2_read_y)+conv_integer(r2_read_x));
            end if;
        end if;
    end process;
end Behavioral;
