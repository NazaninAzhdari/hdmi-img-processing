--DBCE = dark‑biased color expansion

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_DBCE is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_DBCE;

architecture RTL of effect_DBCE is
    begin
        --------------------------------
        --Dark‑biased color expansion
        --------------------------------
        --Note that: i_RGB888 == 8-bit-Red & 8-bit_Green & 8-bit_Blue

        --To get this effect:
        --8-bit Red     <= 2-bit-Red(Remove MSB) & 3-bit-Red & 3-bit-Red
        --8-bit Green   <= 2-bit-Green(Remove MSB) & 3-bit-Green & 3-bit-Green
        --8-bit Blue    <= 2-bit-Blue(remove MSB) & 3-bit-Blue & 3-bit-Blue
        o_pixel(23 downto 16) <= i_RGB888(22 downto 21) & i_RGB888(23 downto 21) & i_RGB888(23 downto 21);
        o_pixel(15 downto 8)  <= i_RGB888(14 downto 13) & i_RGB888(15 downto 13) & i_RGB888(15 downto 13);
        o_pixel(7 downto 0)   <= i_RGB888(6 downto 5) & i_RGB888(7 downto 5) & i_RGB888(7 downto 5);

    end RTL;