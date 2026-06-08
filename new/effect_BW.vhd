library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_BW is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_BW;

architecture RTL of effect_BW is
    signal r_RGB332_effect  :   unsigned(7 downto 0)    :=(others=>'0');

    begin
        --i_RGB332 could be a number between 0 to 255
        --i_intensity could be a number between 0 to 100
        --shift_right(i_RGB332, 1) == i_RGB332 / 2
        r_RGB332_effect <= (others=>'1') when (to_integer(i_RGB332) > shift_right(i_RGB332, 1)) else (others=>'0');

        o_pixel(23 downto 16) <= r_RGB332_effect(7 downto 5) & r_RGB332_effect(7 downto 5) & r_RGB332_effect(7 downto 6);
        o_pixel(15 downto 8)  <= r_RGB332_effect(4 downto 2) & r_RGB332_effect(4 downto 2) & r_RGB332_effect(4 downto 3);
        o_pixel(7 downto 0)   <= r_RGB332_effect(1 downto 0) & r_RGB332_effect(1 downto 0) & r_RGB332_effect(1 downto 0) & r_RGB332_effect(1 downto 0);


    end RTL;