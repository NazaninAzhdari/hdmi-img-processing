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
        o_pixel(23 downto 16) <= not i_RGB332;
        o_pixel(15 downto 8)  <= not i_RGB332;
        o_pixel(7 downto 0)   <= not i_RGB332;

    end RTL;