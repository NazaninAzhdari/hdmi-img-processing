library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity no_effect is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end no_effect;

architecture RTL of no_effect is
    --signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    --signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    --signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');
    begin
        ---------------------------------------------------
        --Converting a 8-bit RGB image to 24-bit RGB Scale
        ---------------------------------------------------
        --Based on your desire you can use one of these approaches.(comment the approach you dont want to use)
        --I will use the first approach, because it is more accurate and i have enough resources to handle it.
        --Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue

        --First Approach: Use more resources, but more accurate.
        o_pixel(23 downto 16) <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 255 / 7), 8) ;
        o_pixel(15 downto 8)  <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 255 / 7), 8) ;
        o_pixel(7 downto 0)   <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 255 / 3), 8) ;


        --Second Approach: Use less resources than first approaches, but less accurate than first one.
        --r_Red8   <= shift_left(resize(i_RGB332(7 downto 5), 8) , 5);
        --r_Green8 <= shift_left(resize(i_RGB332(4 downto 2), 8) , 5);
        --r_Blue8  <= shift_left(resize(i_RGB332(1 downto 0), 8) , 6);

        --o_pixel(23 downto 16) <= r_Red8;
        --o_pixel(15 downto 8)  <= r_Green8;
        --o_pixel(7 downto 0)   <= r_Blue8;

        
        --Third Approach: Use less resources than others, but less accurate than first approch.
        --o_pixel(23 downto 16) <= i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6);
        --o_pixel(15 downto 8)  <= i_RGB332(4 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 3);
        --o_pixel(7 downto 0)   <= i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0);

    end RTL;