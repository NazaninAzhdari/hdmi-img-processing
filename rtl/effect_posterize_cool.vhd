library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_posterize_cool is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_posterize_cool;

architecture RTL of effect_posterize_cool is
    begin  
        --------------------------------
        --Cool Posterize Effect
        --------------------------------
        --Note that: i_RGB888 == 8-bit-Red & 8-bit_Green & 8-bit_Blue

        --To get this effect:
        --8-bit Red     <= 3-bit-Red   & "11111"
        --8-bit Green   <= 3-bit-Green & "11111"
        --8-bit Blue    <= 3-bit-Blue  & "11111"  
        o_pixel(23 downto 16) <= i_RGB888(23 downto 21) & "11111";
        o_pixel(15 downto 8)  <= i_RGB888(15 downto 13) & "11111";
        o_pixel(7 downto 0)   <= i_RGB888(7 downto 5)   & "11111";
    end RTL;