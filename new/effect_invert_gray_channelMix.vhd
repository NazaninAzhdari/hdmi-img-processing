library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_invert_gray_channelMix  is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_invert_gray_channelMix ;

architecture RTL of effect_invert_gray_channelMix is
    begin
        --------------------------------------------------
        --Inversion of the Channel-Mix Gray-Scale Effect
        --------------------------------------------------
        --Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue

        --To get this effect we mix three channels together and then invert the result.
        --8-bit Red     <= not (3-bit-Red & 3-bit_Green & 2-bit_Blue)
        --8-bit Green   <= not (3-bit-Red & 3-bit_Green & 2-bit_Blue)
        --8-bit Blue    <= not (3-bit-Red & 3-bit_Green & 2-bit_Blue)
        
        o_pixel(23 downto 16) <= not i_RGB332;
        o_pixel(15 downto 8)  <= not i_RGB332;
        o_pixel(7 downto 0)   <= not i_RGB332;

    end RTL;