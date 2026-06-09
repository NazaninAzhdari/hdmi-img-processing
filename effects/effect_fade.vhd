library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_fade is
    generic (
        g_FADE      :   integer     :=20 --could be a number between 0 to 100
    );
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_fade;

architecture RTL of effect_fade is
    signal r_Red8     :   integer   :=0;
    signal r_Green8   :   integer   :=0;
    signal r_Blue8    :   integer   :=0;
    signal r_R        :   integer   :=0;
    signal r_G        :   integer   :=0;
    signal r_B        :   integer   :=0;

    begin
        ---------------------------------------------------
        --Converting a 8-bit RGB image to 24-bit RGB Scale
        ---------------------------------------------------
        r_Red8 <= to_integer(i_RGB332(7 downto 5)) * 36; 
        r_Green8 <= to_integer(i_RGB332(4 downto 2)) * 36;
        r_Blue8 <= to_integer(i_RGB332(1 downto 0)) * 85;

        -------------------------------------------------------
        --Mathematical computation of Fade to Black Effect
        -------------------------------------------------------
        --g_FADE = 100 => Fade to Black
        --g_Fade = 0 => Original Pic
        r_R <= (r_Red8   * (100 - g_FADE)) / 100;
        r_G <= (r_Green8 * (100 - g_FADE)) / 100;
        r_B <= (r_Blue8  * (100 - g_FADE)) / 100;

        o_pixel(23 downto 16) <= to_unsigned(r_R, 8) when to_unsigned(r_R, 8) > 0 and to_unsigned(r_R, 8) < 256 else 
                                (others=>'1') when to_unsigned(r_R, 8) > 256 else
                                (others =>'0');

        o_pixel(15 downto 8)  <= to_unsigned(r_G, 8) when to_unsigned(r_G, 8) > 0 and to_unsigned(r_G, 8) < 256 else 
                                (others=>'1') when to_unsigned(r_G, 8) > 256 else
                                (others =>'0');

        o_pixel(7 downto 0)   <= to_unsigned(r_B, 8) when to_unsigned(r_B, 8) > 0 and to_unsigned(r_B, 8) < 256 else 
                                (others=>'1') when to_unsigned(r_B, 8) > 256 else
                                (others =>'0');

    end RTL;

    