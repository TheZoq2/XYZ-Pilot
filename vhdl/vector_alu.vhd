library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.Vector;

entity VectorAdder is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t
            vec2: in Vector.Elements_t

            result: out Vector.Elements_t
        );
end VectorAdder;

architecture Behavioral of VectorAdder is
begin
    result(0) <= vec1(0) + vec2(0);
    result(1) <= vec1(1) + vec2(1);
    result(2) <= vec1(2) + vec2(2);
    result(3) <= vec1(3) + vec2(3);
end Behavioral;

