library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_mem is
port (clk : in std_logic;
    -- port IN
    write_adress: in std_logic_vector(15 downto 0);
    we : in std_logic;
    write_instruction : in std_logic_vector(63 downto 0);
    -- port OUT
    read_adress: in std_logic_vector(15 downto 0);
    re : in std_logic;
    read_instruction : out std_logic_vector(63 downto 0) := (others => '0'));
end program_mem;

architecture Behavioral of program_mem is


-- Declaration of program memory of 65535 (2048) adresses with an instruction size of 64 bits
type ram_t is array (0 to 2047) of std_logic_vector(63 downto 0);

-- Clears all adresses
signal ram: ram_t := (others => (others => '0'));


begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            -- WRITE
            if (we = '1') then
                ram(conv_integer(write_adress)) <= write_instruction;
            end if;
            -- READ
            if (re = '1') then
                read_instruction <= ram(conv_integer(read_adress));
            end if;
        end if;
    end process;
end Behavioral;
