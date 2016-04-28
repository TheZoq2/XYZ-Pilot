library IEEE;
use IEEE.numeric_std.all;

use work.Vector;

package Matrix is 
    type Matrix_vec_t is array(3 downto 0) of Vector.Elements_t;
end package;

-----------------------------------------------------------
--              Matrix storage register
-----------------------------------------------------------
library IEEE;
use IEEE.numeric_std.all;

use work.Vector;
use work.MatrixInfo;

entity MatrixRegister is
    port(
            clk: in std_logic;
            --The two vectors that should be added together
            in_vector: in Vector.Elements_t;
            write_addr: in unsigned(1 downto 0);
            write_enable: in std_logic := '0';

            stored_vectors: out Matrix.Matrix_vec_t
        );
end entity;

architecture Behavioral of MatrixRegister is
begin
    process(clk) begin
        if rising_edge(clk) then
            --Storing the new vector in the matrix if  it has been updated
            if write_enable = '1' then
                stored_vectors(write_addr) <=  in_vector;
            end if;
        end if;
    end process;
end architecture;

-----------------------------------------------------------
--              Matrix multiplyer
-----------------------------------------------------------

library IEEE;
use IEEE.numeric_std.all;

use work.Vector;
use work.MatrixInfo;

entity MatrixMultiplyer is
    port(
        vector: in Vector.Elements_t;
        matrix: in Matrix.Matrix_vec_t;

        result: out Vector.Elements_t
    );
end entity;

architecture Behavioral of MatrixRegister is
begin
    result(0) <= vector(0) * matrix(0)(0) + vector(1) * matrix(0)(1) + 
                 vector(2) * matrix(0)(2) + vector(3) * matrix(0)(3);

    result(1) <= vector(0) * matrix(1)(0) + vector(1) * matrix(1)(1) + 
                 vector(2) * matrix(1)(2) + vector(3) * matrix(1)(3);

    result(2) <= vector(0) * matrix(2)(0) + vector(1) * matrix(2)(1) + 
                 vector(2) * matrix(2)(2) + vector(3) * matrix(2)(3);

    result(3) <= vector(0) * matrix(3)(0) + vector(1) * matrix(3)(1) + 
                 vector(2) * matrix(3)(2) + vector(3) * matrix(3)(3);
end architecture;

