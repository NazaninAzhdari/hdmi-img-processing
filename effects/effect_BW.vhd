library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_BW is
    generic (
        g_THRESHOLD     :   integer     :=5 --could be a number between 0 to 17
    );
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_BW;

architecture RTL of effect_BW is
    signal Sum_RGB    :   integer range 0 to 17   := 0;
    begin
        
        Sum_RGB <= to_integer(i_RGB332(7 downto 5)) + to_integer(i_RGB332(4 downto 2)) + to_integer(i_RGB332(1 downto 0));

        ---------------------------------
        --Black-White Threshold Effect
        ---------------------------------
        --To get this effect, we paint white all the pixels that they have higher value than the threshold value.
        --we also paint black all the pixels that they have lower value that threshold.
        o_pixel(23 downto 16) <= (others=>'1') when Sum_RGB > g_THRESHOLD else (others=>'0');
        o_pixel(15 downto 8)  <= (others=>'1') when Sum_RGB > g_THRESHOLD else (others=>'0');
        o_pixel(7 downto 0)   <= (others=>'1') when Sum_RGB > g_THRESHOLD else (others=>'0');


    end RTL;