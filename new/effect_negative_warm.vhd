library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_negative_warm is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_negative;

architecture RTL of effect_negative_warm is
    signal r_Red8       :   unsigned(7 downto 0)    :=(others=>'0');
    begin
    
        r_Red8 <= not (i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 5));

        o_pixel(23 downto 16) <= ((not r_Red8) + 50) when ((not r_Red8) + 50) < 256 else (others=>'1');
        o_pixel(15 downto 8)  <= not (i_RGB332(4 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 3));
        o_pixel(7 downto 0)   <= not (i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0));

    end RTL;