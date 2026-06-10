library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_rainbow is
    port (
        i_y         :   in      unsigned(9 downto 0);
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_rainbow;

architecture RTL of effect_rainbow is
    signal r_y        :   integer range 0 to 480  :=0;
    signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');

    begin
       -----------------------------------------------------
        --Assign RGB888 to corrosponding color channels
        -----------------------------------------------------
        r_Red8 <= i_RGB888(23 downto 16);
        r_Green8 <= i_RGB888(15 downto 8);
        r_Blue8 <= i_RGB888(7 downto 0);

        r_y <= to_integer(i_y);

        --------------------------------------------
        --Rainbow Tint Effect Based on Y position 
        --------------------------------------------
        --**Each goes to its corrosponding channel.**
        --0   < r_y < 80    :   Red Tint => r_Red8 no change, r_Green8 / 2, r_Blue8 / 2 . 
        --80  < r_y < 160   :   Orange Tint => r_Red8 no change, r_Green8 no chane, r_Blue8 / 2 . 
        --160 < r_y < 240   :   Yellow Tint => r_Red8 no change, r_Green8 no chane, r_Blue8 / 4 .
        --240 < r_y < 320   :   Green Tint => r_Red8 / 2, r_Green8 no chane, r_Blue8 / 2 .
        --320 < r_y < 400   :   Blue Tint => r_Red8 / 2, r_Green8 / 2, r_Blue8 no change .
        --400 < r_y < 480   :   Violet Tint => r_Red8 no change, r_Green8 / 4, r_Blue8 no change .
        

        o_pixel(23 downto 16) <= r_Red8 when (r_y >= 0 and r_y < 240 ) or (r_y >= 400 and r_y < 480 ) else
                                shift_right(r_Red8, 1) when (r_y >= 240 and r_y < 320 ) else
                                shift_right(r_Red8, 2) when (r_y >= 320 and r_y < 400 ) else
                                (others=>'0');

        o_pixel(15 downto 8)  <= shift_right(r_Green8, 1) when (r_y >= 0 and r_y < 80 ) or (r_y >= 320 and r_y < 400 ) else
                                r_Green8 when (r_y >= 80 and r_y < 320 ) else 
                                shift_right(r_Green8, 2) when (r_y >= 400 and r_y < 480 ) else
                                (others=>'0');

        o_pixel(7 downto 0)   <= shift_right(r_Blue8, 1) when (r_y >= 0 and r_y < 160 ) or (r_y >= 240 and r_y < 320 ) else
                                shift_right(r_Blue8, 2) when (r_y >= 160 and r_y < 240 ) else 
                                r_Blue8 when (r_y >= 320 and r_y < 480 ) else
                                (others=>'0');

    end RTL;