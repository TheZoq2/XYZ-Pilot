
--Actual useful code
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

end Behavioral;

