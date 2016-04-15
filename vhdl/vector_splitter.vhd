library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.Vector;

entity VectorSplitter is
    port(
            memory: in Vector.InMemory_t;
            vec: out Vector.Elements_t
        );
end VectorSplitter;

architecture Behavioral of VectorSplitter is
begin
    vec(0) <= memory(Vector.MEMORY_SIZE / 4 * 1 - 1 downto Vector.MEMORY_SIZE / 4 * 0);
    vec(1) <= memory(Vector.MEMORY_SIZE / 4 * 2 - 1 downto Vector.MEMORY_SIZE / 4 * 1);
    vec(2) <= memory(Vector.MEMORY_SIZE / 4 * 3 - 1 downto Vector.MEMORY_SIZE / 4 * 2);
    vec(3) <= memory(Vector.MEMORY_SIZE / 4 * 4 - 1 downto Vector.MEMORY_SIZE / 4 * 3);
end Behavioral;

