library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_dark is
    generic (
        g_DARK      :   integer     :=128 --Shoud be a positive number between 0 to 255  
    );
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_dark;

architecture RTL of effect_dark is
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

        --To get the darkness effect, we subtract a dark-factor from the pixel.
        o_pixel(23 downto 16) <= to_unsigned((to_integer(r_Red8) - g_DARK) , 8) 
                            when (to_integer(r_Red8) - g_DARK) > 0 
                            else (others=>'0');

        o_pixel(15 downto 8)  <= to_unsigned((to_integer(r_Green8) - g_DARK) , 8) 
                            when (to_integer(r_Green8) - g_DARK) > 0  
                            else (others=>'0');

        o_pixel(7 downto 0)   <= to_unsigned((to_integer(r_Blue8) - g_DARK) , 8) 
                            when (to_integer(r_Blue8) - g_DARK) > 0 
                            else (others=>'0');

    end RTL;