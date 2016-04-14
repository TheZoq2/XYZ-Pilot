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

    component VectorMerger is 
        port(
            memory:  out Vector.InMemory_t;
            vec: in Vector.Elements_t
        );
    end component;

    signal memory: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal vec: Vector.Elements_t;

    signal merge_memory: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal merge_vec: Vector.Elements_t;
begin
    
    uut: VectorSplitter PORT MAP(
                memory => memory,
                vec => vec
            );

    uut_merge: VectorMerger PORT MAP(
                memory => merge_memory,
                vec => merge_vec
            );

    merge_vec <= vec;
    
    process begin
        memory <= std_logic_vector(to_unsigned(0, memory'length));

        wait for 5 ns;
        memory <= (x"0001ffff0001123f");

        wait for 5 ns;
        memory <= (x"ffffffffffffffff");

        wait for 5 ns;
        memory <= std_logic_vector(to_unsigned(0, memory'length));

        wait;
    end process;
end;
