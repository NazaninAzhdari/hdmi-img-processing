library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_negative is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_negative;

architecture RTL of effect_negative is
    begin
        --------------------------------
        --Negative Effect
        --------------------------------
        --Note that: i_RGB888 == 8-bit-Red & 8-bit_Green & 8-bit_Blue

        --To get this effect, we should invert the pixels:
        --8-bit Red     <= not 8-bit Red
        --8-bit Green   <= not 8-bit Green
        --8-bit Blue    <= not 8-bit Blue
        o_pixel(23 downto 16) <= not (i_RGB888(23 downto 16));
        o_pixel(15 downto 8)  <= not (i_RGB888(15 downto 8));
        o_pixel(7 downto 0)   <= not (i_RGB888(7 downto 0));

    end RTL;