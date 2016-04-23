--Package with types used to represent vectors in memory and in modules
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package  Vector is
    constant MEMORY_SIZE: positive := 64;

    subtype InMemory_t is std_logic_vector(MEMORY_SIZE - 1 downto 0);

    type Elements_t is array(3 downto 0) of signed(MEMORY_SIZE / 4 - 1 downto 0);
    type Elements_Big_t is array(3 downto 0) of signed(MEMORY_SIZE / 2 - 1 downto 0);

    type Elements_2D_t is array(1 downto 0) of signed(MEMORY_SIZE / 2 - 1 downto 0); 
end package;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;

entity VectorMerger is
    port(
            memory: out Vector.InMemory_t;
            vec: in Vector.Elements_t
        );
end VectorMerger;

architecture Behavioral of VectorMerger is
begin
     memory(Vector.MEMORY_SIZE / 4 * 1 - 1 downto Vector.MEMORY_SIZE / 4 * 0) <= std_logic_vector(vec(0));
     memory(Vector.MEMORY_SIZE / 4 * 2 - 1 downto Vector.MEMORY_SIZE / 4 * 1) <= std_logic_vector(vec(1));
     memory(Vector.MEMORY_SIZE / 4 * 3 - 1 downto Vector.MEMORY_SIZE / 4 * 2) <= std_logic_vector(vec(2));
     memory(Vector.MEMORY_SIZE / 4 * 4 - 1 downto Vector.MEMORY_SIZE / 4 * 3) <= std_logic_vector(vec(3));
end Behavioral;


