library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_solarize is
    generic (
        g_THRESHOLD     :   integer     :=225 --could be a number between 0 to 765
    );
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_solarize;

architecture RTL of effect_solarize is
    signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');
    signal Sum_RGB    :   integer range 0 to 765  := 0;

    begin
        -----------------------------------------------------
        --Assign RGB888 to corrosponding color channels
        -----------------------------------------------------
        r_Red8 <= i_RGB888(23 downto 16);
        r_Green8 <= i_RGB888(15 downto 8);
        r_Blue8 <= i_RGB888(7 downto 0);

        Sum_RGB <= to_integer(r_Red8) + to_integer(r_Green8) + to_integer(r_Blue8);

        -------------------
        --Solarize Effect
        -------------------
        --To get this effect, we invert the pixels that they have higher value than the threshold value.
        o_pixel(23 downto 16) <= (to_unsigned(255, 8) - r_Red8) when Sum_RGB > g_THRESHOLD else r_Red8;
        o_pixel(15 downto 8)  <= (to_unsigned(255, 8) - r_Green8) when Sum_RGB > g_THRESHOLD else r_Green8;
        o_pixel(7 downto 0)   <= (to_unsigned(255, 8) - r_Blue8) when Sum_RGB > g_THRESHOLD else r_Blue8;

    end RTL;

    