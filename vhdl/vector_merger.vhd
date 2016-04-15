library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.Vector;

entity VectorMerger is
    port(
            memory: out Vector.InMemory_t;
            vec: in Vector.Elements_t
        );
end VectorMerger;

architecture Behavioral of VectorMerger is
begin
     memory(Vector.MEMORY_SIZE / 4 * 1 - 1 downto Vector.MEMORY_SIZE / 4 * 0) <= vec(0);
     memory(Vector.MEMORY_SIZE / 4 * 2 - 1 downto Vector.MEMORY_SIZE / 4 * 1) <= vec(1);
     memory(Vector.MEMORY_SIZE / 4 * 3 - 1 downto Vector.MEMORY_SIZE / 4 * 2) <= vec(2);
     memory(Vector.MEMORY_SIZE / 4 * 4 - 1 downto Vector.MEMORY_SIZE / 4 * 3) <= vec(3);
end Behavioral;

