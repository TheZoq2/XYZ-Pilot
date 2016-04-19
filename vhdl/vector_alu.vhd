-----------------------------------------------------------
--                  Square root algoritm
--Code taken from http://vhdlguru.blogspot.se/2010/03/vhdl-function-for-finding-square-root.html
-----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;    -- for UNSIGNED

package sqrt_pkg is 
    function sqrt ( d: unsigned) 
        return UNSIGNED;
end sqrt_pkg;

package body sqrt_pkg is
    function sqrt (d: unsigned) 
        return UNSIGNED is
        variable a : unsigned(31 downto 0):=d;  --original input.
        variable q : unsigned(15 downto 0):=(others => '0');  --result.
        variable left,right,r : unsigned(17 downto 0):=(others => '0');  --input to adder/sub.r-remainder.
        variable i : integer:=0;

    begin
        for i in 0 to 15 loop
            right(0):='1';
            right(1):=r(17);
            right(17 downto 2):=q;
            left(1 downto 0):=a(31 downto 30);
            left(17 downto 2):=r(15 downto 0);
            a(31 downto 2):=a(29 downto 0);  --shifting by 2 bit.
            if ( r(17) = '1') then
                r := left + right;
            else
                r := left - right;
            end if;
            q(15 downto 1) := q(14 downto 0);
            q(0) := not r(17);
        end loop;
        return q;
    
    end sqrt;
end sqrt_pkg;
-----------------------------------------------------------
--              Vector adder
-----------------------------------------------------------
library IEEE;
use IEEE.numeric_std.all;

use work.Vector;

entity VectorAdder is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t;
            vec2: in Vector.Elements_t;

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

-----------------------------------------------------------
--              Vector subtractor
-----------------------------------------------------------
library IEEE;
use  IEEE.numeric_std.all;

use work.Vector;

entity VectorSubtractor is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t;
            vec2: in Vector.Elements_t;

            result: out Vector.Elements_t
        );
end VectorSubtractor;

architecture Behavioral of VectorSubtractor is
begin
    result(0) <= vec1(0) - vec2(0);
    result(1) <= vec1(1) - vec2(1);
    result(2) <= vec1(2) - vec2(2);
    result(3) <= vec1(3) - vec2(3);
end Behavioral;
----------------------------------------------------------

library IEEE;
use IEEE.numeric_std.all;

use work.Vector;
use work.sqrt_pkg.all;

entity VectorLength is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t;

            result: out unsigned(15 downto 0)
        );
end VectorLength;

architecture Behavioral of VectorLength is
    signal sum: signed(31 downto 0);
    signal sqrt_result: unsigned(15 downto 0);
begin
    sum <= vec1(0) * vec1(0) + vec1(1) * vec1(1) + vec1(2) * vec1(2) + vec1(3) * vec1(3);

    result <= sqrt(unsigned(sum));
end Behavioral;
