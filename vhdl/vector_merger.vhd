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

