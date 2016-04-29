library IEEE;
use IEEE.numeric_std.all;

package Datatypes is
    --This is actually a semi signed number. 0.<8 bist> with bit 15 being a sign bit used
    subtype small_number_t is unsigned(15 downto 0);
    subtype std_number_t is signed(15 downto 0);
end package;
