library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_negative_warm is
    generic (
        g_WARM_TINT     :   integer     :=50   --could be a number between 0 to 255
    );
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_negative_warm;

architecture RTL of effect_negative_warm is
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

        --------------------------
        --Warm Negative Effect
        --------------------------
        --To get this effect we invert color channels, and then we add a warm factor to red channel
        o_pixel(23 downto 16) <= ((not r_Red8) + g_WARM_TINT) when ((not r_Red8) + g_WARM_TINT) < 256 else (others=>'1');
        o_pixel(15 downto 8)  <= not r_Green8;
        o_pixel(7 downto 0)   <= not r_Blue8;

    end RTL;