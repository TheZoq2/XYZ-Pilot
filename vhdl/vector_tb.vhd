library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Include the  types required by the splitter
use work.Vector;
use work.Datatypes;


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

    component VectorLength is
        port(
                vec1: in Vector.Elements_t;
                result: out unsigned(15 downto 0)
            );
    end  component;

    component VectorAdder is
        port(
                --The two vectors that should be added together
                vec1: in Vector.Elements_t;
                vec2: in Vector.Elements_t;

                result: out Vector.Elements_t
            );
    end component;

    signal memory: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal vec: Vector.Elements_t;
    signal memory2: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal vec2: Vector.Elements_t;

    signal merge_memory: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal merge_vec: Vector.Elements_t;

begin
    
    uut: VectorSplitter PORT MAP(
                memory => memory,
                vec => vec
            );
    uut_split2: VectorSplitter PORT MAP(
                memory => memory2,
                vec => vec2
            );

    uut_merge: VectorMerger PORT MAP(
                memory => merge_memory,
                vec => merge_vec
            );


    vec_add : VectorAdder port map (
            vec1 => vec,
            vec2 => vec2,
            result => merge_vec
        );

    merge_vec <= vec;
    
    process begin
        memory <= x"00000000" & x"00000000";
        memory2 <= x"ffffffff" & x"00000000";

        wait for 5 ns;

        wait for 100 ns;
    end process;
end;
