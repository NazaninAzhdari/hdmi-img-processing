library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_grayscale_channelMix is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_grayscale_channelMix;

architecture RTL of effect_grayscale_channelMix is
    signal r_RGB332         :   unsigned(7 downto 0)        :=(others=>'0');
    begin
        --------------------------------------------------
        --Inversion of the Channel-Mix Gray-Scale Effect
        --------------------------------------------------
        --Note that: i_RGB888 == 8-bit-Red & 8-bit_Green & 8-bit_Blue
        r_RGB332 <= i_RGB888(23 downto 21) & i_RGB888(15 downto 13) & i_RGB888(7 downto 6);

        --To get this effect we mix three channels together.
        --8-bit Red     <= 3-bit-Red & 3-bit_Green & 2-bit_Blue
        --8-bit Green   <= 3-bit-Red & 3-bit_Green & 2-bit_Blue
        --8-bit Blue    <= 3-bit-Red & 3-bit_Green & 2-bit_Blue
        o_pixel(23 downto 16) <= r_RGB332;
        o_pixel(15 downto 8)  <= r_RGB332;
        o_pixel(7 downto 0)   <= r_RGB332;

    end RTL;