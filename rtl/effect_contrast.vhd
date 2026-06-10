library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_contrast is
    generic (
        g_CONTRAST  :   integer     :=2
    );
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_contrast;

architecture RTL of effect_contrast is
    signal r_Red8     :   integer   :=0;
    signal r_Green8   :   integer   :=0;
    signal r_Blue8    :   integer   :=0;
    signal r_R        :   integer   :=0;
    signal r_G        :   integer   :=0;
    signal r_B        :   integer   :=0;

    begin
        ---------------------------------------------------
        --Converting a 8-bit unsigned RGB to integer
        ---------------------------------------------------
        r_Red8 <= to_integer(i_RGB888(23 downto 16)); 
        r_Green8 <= to_integer(i_RGB888(15 downto 8));
        r_Blue8 <= to_integer(i_RGB888(7 downto 0));
        
        ----------------------------------------------
        --Mathematical computation of Contrast Effect
        ----------------------------------------------
        --g_CONTRAST = 1 → no change
        --g_CONTRAST = 2 → strong, clean contrast boost
        --g_CONTRAST = 3 → very strong, almost HDR‑like
        --g_CONTRAST = 4+ → harsh, posterized, may clip too much

        r_R <= ((r_Red8 - 128) * g_CONTRAST) + 128;
        r_G <= ((r_Green8 - 128) * g_CONTRAST) + 128;
        r_B <= ((r_Blue8 - 128) * g_CONTRAST) + 128;

        o_pixel(23 downto 16) <= to_unsigned(r_R, 8) when r_R > 0 and r_R < 256 else 
                                (others=>'1') when r_R >= 256 else
                                (others =>'0');

        o_pixel(15 downto 8)  <= to_unsigned(r_G, 8) when r_G > 0 and r_G < 256 else 
                                (others=>'1') when r_G >= 256 else
                                (others =>'0');

        o_pixel(7 downto 0)   <= to_unsigned(r_B, 8) when r_B > 0 and r_B < 256 else 
                                (others=>'1') when r_B >= 256 else
                                (others =>'0');


    end RTL;

    