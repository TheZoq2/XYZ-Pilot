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
--              Small  number multiplyer
-----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;
use work.Datatypes;

entity SmallNumberMultiplyer is
    port(
            num1: in Datatypes.small_number_t;
            num2: in Datatypes.small_number_t;
            result: out Datatypes.small_number_t
        );
end entity;

architecture Behavioral of SmallNumberMultiplyer is
    signal big_num: unsigned(17 downto 0);

    signal sign: std_logic;
begin
    big_num <= (num1(8 downto 0) * num2(8 downto 0));

    result <= (num1(15) xor num2(15)) & "000000" & SHIFT_RIGHT(big_num, 8)(8 downto 0);
end Behavioral;

-----------------------------------------------------------
--              Decimal number multiplyer
-----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;
use work.Datatypes;

entity FractionalMultiplyer is
    port(
            big_num: in Datatypes.std_number_t;
            small_num: in Datatypes.small_number_t;
            result: out Datatypes.std_number_t
        );
end entity;

architecture Behavioral of FractionalMultiplyer is
    signal padded_big: unsigned(23 downto 0);

    signal small_cut: unsigned(8 downto 0);

    signal sign: std_logic;

    signal unsigned_result: unsigned(15 downto 0);
begin
    --padded_big(7 downto 0) <= "00000000";
    padded_big(23 downto 0) <= unsigned(abs big_num) & x"00";
    small_cut <= small_num(8 downto 0);

    sign <= big_num(15) xor small_num(15);

    unsigned_result <= SHIFT_RIGHT((padded_big * small_cut), 16)(15 downto 0);

    with sign select
        result <= signed(unsigned_result) when '0',
                  -signed(unsigned_result) when others;
end Behavioral;


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
    result(0) <= vec2(0) - vec1(0);
    result(1) <= vec2(1) - vec1(1);
    result(2) <= vec2(2) - vec1(2);
    result(3) <= vec2(3) - vec1(3);
end Behavioral;
----------------------------------------------------------

library IEEE;
use IEEE.numeric_std.all;

use work.Vector;
use work.sqrt_pkg.all;

entity VectorLength is
    port(
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


--########################################################
--             Vector dot  product
--########################################################
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;

entity VectorDot is
    port(
            vec1: in Vector.Elements_t;
            vec2: in Vector.Elements_t;
            result: out signed(63 downto 0)
        );
end entity;

architecture Behavioral of VectorDot is
begin
    result <= x"00000000" & (vec1(0) * vec2(0)) + 
                  (vec1(1) * vec2(1)) +
                  (vec1(2) * vec2(2)) +
                  (vec1(3) * vec2(3));
end behavioral;

--########################################################
--             Vector splitter / merger
--########################################################
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Vector;

entity VectorSplitter is
    port(
            memory: in Vector.InMemory_t;
            vec: out Vector.Elements_t
        );
end VectorSplitter;

architecture Behavioral of VectorSplitter is
begin
    vec(3) <= signed(memory(Vector.MEMORY_SIZE / 4 * 1 - 1 downto Vector.MEMORY_SIZE / 4 * 0));
    vec(2) <= signed(memory(Vector.MEMORY_SIZE / 4 * 2 - 1 downto Vector.MEMORY_SIZE / 4 * 1));
    vec(1) <= signed(memory(Vector.MEMORY_SIZE / 4 * 3 - 1 downto Vector.MEMORY_SIZE / 4 * 2));
    vec(0) <= signed(memory(Vector.MEMORY_SIZE / 4 * 4 - 1 downto Vector.MEMORY_SIZE / 4 * 3));
end behavioral;

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
     memory(Vector.MEMORY_SIZE / 4 * 1 - 1 downto Vector.MEMORY_SIZE / 4 * 0) <= std_logic_vector(vec(3));
     memory(Vector.MEMORY_SIZE / 4 * 2 - 1 downto Vector.MEMORY_SIZE / 4 * 1) <= std_logic_vector(vec(2));
     memory(Vector.MEMORY_SIZE / 4 * 3 - 1 downto Vector.MEMORY_SIZE / 4 * 2) <= std_logic_vector(vec(1));
     memory(Vector.MEMORY_SIZE / 4 * 4 - 1 downto Vector.MEMORY_SIZE / 4 * 3) <= std_logic_vector(vec(0));
end Behavioral;


