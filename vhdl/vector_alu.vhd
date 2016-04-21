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
--                  Division algoritm
--Code taken from http://vhdlguru.blogspot.se/2010/03/vhdl-function-for-division-two-signed.html 
-----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;    -- for UNSIGNED

package div_pkg is 
    function  divide  (a : UNSIGNED; b : UNSIGNED) return UNSIGNED;
    
end div_pkg;

package body div_pkg is
    function  divide  (a : UNSIGNED; b : UNSIGNED) return UNSIGNED is
        variable a1 : unsigned(a'length-1 downto 0):=a;
        variable b1 : unsigned(b'length-1 downto 0):=b;
        variable p1 : unsigned(b'length downto 0):= (others => '0');
        variable i : integer:=0;

    begin
        for i in 0 to b'length-1 loop
            p1(b'length-1 downto 1) := p1(b'length-2 downto 0);
            p1(0) := a1(a'length-1);
            a1(a'length-1 downto 1) := a1(a'length-2 downto 0);
            p1 := p1-b1;
            if(p1(b'length-1) ='1') then
                a1(0) :='0';
                p1 := p1+b1;
            else
                a1(0) :='1';
            end if;
        end loop;
        return a1;

    end divide;
end div_pkg;

-----------------------------------------------------------
--                  Signed division
-----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;    -- for UNSIGNED

use work.div_pkg.all;

entity signed_divide is
    port(
        val: in signed(31 downto 0);
        div: in signed(31 downto 0);
        result: out signed(31 downto 0)
    );
end entity;

architecture Behaviour of signed_divide is
    signal unsigned_val: unsigned(31 downto 0);
    signal unsigned_div: unsigned(31 downto 0);

    signal div_result: unsigned(31 downto 0);
begin
    unsigned_val <= unsigned(abs(val));
    unsigned_div <= unsigned(abs(div));

    div_result <= divide(unsigned_val, unsigned_div);

    with (val(31) xor div(31)) select
        result <= signed(div_result) when '0',
                  -signed(div_result) when others;
end architecture;
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

--########################################################
--               Normal calculator
--########################################################
library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

use work.Vector;
use work.div_pkg.all;
use work.signed_divide;

entity VectorNormal is
    port(
            --The two vectors that should be added together
            vec1: in Vector.Elements_t;
            len: in unsigned(15 downto 0);

            result: out Vector.Elements_Big_t
        );
end VectorNormal;

architecture Behavioral of VectorNormal is
    signal long_version: Vector.Elements_Big_t;
    signal long_len: signed(31 downto 0);

    component signed_divide is
        port(
            val: in signed(31 downto 0);
            div: in signed(31 downto 0);
            result: out signed(31 downto 0)
        );
    end component;
begin
    divider0: signed_divide port  map(
                    val => long_version(0),
                    div => long_len,
                    result => result(0)
                );
    divider1: signed_divide port  map(
                    val => long_version(1),
                    div => long_len,
                    result => result(1)
                );

    long_len(31 downto 16) <= (others => '0');
    long_len(15 downto 0) <= signed(len);

    long_version(0)(15 downto 0) <= (others => '0');
    long_version(1)(15 downto 0) <= (others => '0');
    long_version(2)(15 downto 0) <= (others => '0');
    long_version(3)(15 downto 0) <= (others => '0');

    long_version(0)(31 downto 16) <= vec1(0);
    long_version(1)(31 downto 16) <= vec1(1);
    long_version(2)(31 downto 16) <= vec1(2);
   long_version(3)(31 downto 16) <= vec1(3);
end Behavioral;

