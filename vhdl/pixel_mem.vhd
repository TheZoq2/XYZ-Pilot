library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pixel_mem is
port (clk : in std_logic;
    -- port IN
    write_adress: in std_logic_vector(16 downto 0);
    we : in std_logic;
    write_data : in std_logic;
    -- port OUT
    read_adress: in std_logic_vector(16 downto 0);
    re : in std_logic;
    read_data : out std_logic;
end pixel_mem;

architecture Behavioral of pixel_mem is

signal write_x :std_logic_vector(8 downto 0); -- X pos for input
signal write_y :std_logic_vector(7 downto 0); -- X pos for input
signal read_x :std_logic_vector(8 downto 0); -- X pos for input
signal read_y :std_logic_vector(7 downto 0); -- X pos for input


-- Declaration of pixel memory of 131072 adresses
type ram_t is array (0 to 131071) of std_logic;

-- Clears all adresses
signal ram : ram_t := (others => '0');

begin
		write_x <= write_adress(16 downto 8);
		write_y <= write_adress(7 downto 0);
		read_x <= read_adress(16 downto 8);
		read_y <= read_adress(7 downto 0);
    process(clk)
    begin
        if (rising_edge(clk)) then
            -- WRITE
            if (we = '1') then
                pixel_mem(320*conv_integer(write_y)+
                conv_integer(write_x)) <= write_data;
            end if;
            -- READ
            if (re = '1') then
                read_data <= pixel_mem(320*conv_integer(read_y)+
                conv_integer(read_x));
            end if;
        end if;
    end process;
end Behavioral;
