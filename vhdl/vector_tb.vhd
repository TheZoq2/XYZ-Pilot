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

    component FractionalMultiplyer is 
        port(
                big_num: in Datatypes.std_number_t;
                small_num: in Datatypes.small_number_t;
                result: out Datatypes.std_number_t
            );
    end component;
    component SmallNumberMultiplyer is 
        port(
                num1: in Datatypes.small_number_t;
                num2: in Datatypes.small_number_t;
                result: out Datatypes.small_number_t
            );
    end component;

    signal memory: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal vec: Vector.Elements_t;

    signal merge_memory: Vector.InMemory_t := std_logic_vector(to_unsigned(0, Vector.MEMORY_SIZE));
    signal merge_vec: Vector.Elements_t;

    signal vec_length: unsigned(15 downto 0);

    signal big_test_num: Datatypes.std_number_t;
    signal small_test_num: Datatypes.small_number_t;
    signal small_num1: Datatypes.small_number_t;
    signal small_num2: Datatypes.small_number_t;
    signal mul_result: Datatypes.std_number_t;
begin
    uut_len: VectorLength PORT MAP(
            vec1 => vec,
            result => vec_length
        );
    
    uut: VectorSplitter PORT MAP(
                memory => memory,
                vec => vec
            );

    uut_merge: VectorMerger PORT MAP(
                memory => merge_memory,
                vec => merge_vec
            );

    uut_frac_mul: FractionalMultiplyer port map(
                        big_num => big_test_num,
                        small_num => small_test_num,
                        result => mul_result
                   );
    uut_small_mul: SmallNumberMultiplyer port map(
                        num1 => small_num1,
                        num2 => small_num2,
                        result => small_test_num
                   );

    merge_vec <= vec;
    
    process begin
        memory <= std_logic_vector(to_unsigned(0, memory'length));
        big_test_num <= to_signed(1000, big_test_num'length);

        small_num1 <= "00000000" & "10000000"; --0.5
        small_num2 <= "00000000" & "10000000"; --0.5

        wait for 5 ns;
        memory <= (x"0001ffff0001123f");

        big_test_num <= to_signed(1000, big_test_num'length);
        small_num1 <= "00000000" & "01000000"; --0.5
        small_num2 <= "00000000" & "10000000"; --0.5

        wait for 5 ns;
        memory <= (x"ffffffffffffffff");

        big_test_num <= to_signed(1000, big_test_num'length);
        small_num1 <= "00000000" & "11000000"; --0.5
        small_num2 <= "00000000" & "11000000"; --0.5

        wait for 5 ns;
        memory <= (x"0001000100010001");

        big_test_num <= to_signed(1000, big_test_num'length);
        small_num1 <= "00000001" & "00000000"; --1
        small_num2 <= "00000000" & "10000000"; --0.5

        wait for  5 ns;
        big_test_num <= to_signed(1000, big_test_num'length);
        small_num1 <= "00000001" & "00000000"; --1
        small_num2 <= "00000001" & "00000000"; --0.5

        wait for  5 ns;
        big_test_num <= to_signed(1000, big_test_num'length);
        small_num1 <= "00000001" & "10000000"; --1.5
        small_num2 <= "00000000" & "10000000"; --0.5

        wait for 100 ns;
    end process;
end;
