library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--Include the  types required by the splitter
use work.Vector;


entity vector_tb is
end entity;

architecture Behavioral of vector_tb is
    component VectorSplitter is
        port(
            memory: in Vector.InMemory_t;
            vec: out Vector.Elements_t
        );

    end component;

    signal memory: Vector.InMemory_t;
    signal vec: Vector.Elements_t;
begin
    
    uut: VectorSplitter PORT MAP(
                memory => memory
            );
    
    memory <= std_logic_vector(to_unsigned(0, memory'length));

    memory <= std_logic_vector(to_unsigned(0, memory'length)) after 10 ns;

    memory <= std_logic_vector(to_unsigned(1, memory'length)) after 20 ns;

    memory <= std_logic_vector(to_unsigned(0, memory'length)) after 30 ns;
end;
