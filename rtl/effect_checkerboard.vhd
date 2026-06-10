library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_checkerboard is
    port (
        i_x         :   in      unsigned(9 downto 0);
        i_y         :   in      unsigned(9 downto 0);
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_checkerboard;

architecture RTL of effect_checkerboard is
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

        ------------------------
        --Checkerboard Effect
        ------------------------
        --i_Red8/i_Green8/i_Blue8 could be a number between 0 to 255.
        --shift_right(i_Red8/i_Green8/i_Blue8 , 1) == (i_Red8/i_Green8/i_Blue8 ) / 2.
        --In the areas that (i_x(4) xor i_y(4)) = '1' , the i_Red8/i_Green8/i_Blue8 will be divided by two. (goes toward darkness)
        --and this make a checkerboard effect on the picture.

        o_pixel(23 downto 16) <= resize(shift_right(r_Red8 , 1 ), 8) when (i_x(4) xor i_y(4)) = '1' else r_Red8;
        o_pixel(15 downto 8)  <= resize(shift_right(r_Green8 , 1 ), 8) when (i_x(4) xor i_y(4)) = '1' else r_Green8;
        o_pixel(7 downto 0)   <= resize(shift_right(r_Blue8 , 1 ), 8) when (i_x(4) xor i_y(4)) = '1' else r_Blue8;

    end RTL;