library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_posterize_cool is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_posterize_cool;

architecture RTL of effect_posterize_cool is
    begin      
        o_pixel(23 downto 16) <= i_RGB332(7 downto 5) & "11111";
        o_pixel(15 downto 8)  <= i_RGB332(4 downto 2) & "11111";
        o_pixel(7 downto 0)   <= i_RGB332(1 downto 0) & "111111";
    end RTL;