--DBCE = dark‑biased color expansion

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_DBCE is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_DBCE;

architecture RTL of effect_DBCE is
    begin
        --------------------------------
        --Dark‑biased color expansion
        --------------------------------
        --Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue

        --To get this effect:
        --8-bit Red     <= 2-bit-Red(Remove MSB) & 3-bit-Red & 3-bit-Red
        --8-bit Green   <= 2-bit-Green(Remove MSB) & 3-bit-Green & 3-bit-Green
        --8-bit Blue    <= 2-bit-Blue & 2-bit-Blue & 2-bit-Blue & 2-bit-Blue
        o_pixel(23 downto 16) <= i_RGB332(6 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 5);
        o_pixel(15 downto 8)  <= i_RGB332(3 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 2);
        o_pixel(7 downto 0)   <= i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0);

    end RTL;