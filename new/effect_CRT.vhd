library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_CRT is
    port (
        i_y         :   in      unsigned(9 downto 0);
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_CRT;

architecture RTL of effect_CRT is
    signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');
    begin

        -----------------------------------------------------
        --Convert RGB332 to RGB888 by replicating the bits
        -----------------------------------------------------
        r_Red8 <= i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6);
        r_Green8 <= i_RGB332(4 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 3);
        r_Blue8 <= i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0);
        
        --------------
        --CRT Effect
        --------------
        --To get this effect we divide the pixel color by two in areas that i_y(0)= '1'
        o_pixel(23 downto 16) <= shift_right(r_Red8 , 1) when i_y(0) = '1' else r_Red8;
        o_pixel(15 downto 8)  <= shift_right(r_Green8 , 1) when i_y(0) = '1' else r_Green8;
        o_pixel(7 downto 0)   <= shift_right(r_Blue8 , 1) when i_y(0) = '1' else r_Blue8;

    end RTL;