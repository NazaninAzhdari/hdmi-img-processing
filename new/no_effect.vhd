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
    begin
        
        --Based on your desire you can use one of these approaches.(comment the approach you dont want to use)
        --I will use the first approach, because it is more accurate and i have enough resources to handle it.

        --First Approach: Use more resources, but more accurate.
        o_pixel(23 downto 16) <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 255 / 7), 8) ;
        o_pixel(15 downto 8)  <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 255 / 7), 8) ;
        o_pixel(7 downto 0)   <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 255 / 3), 8) ;

        --second Approach: Use less resources, but less accurate.
        o_pixel(23 downto 16) <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 32), 8) ;
        o_pixel(15 downto 8)  <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 32), 8) ;
        o_pixel(7 downto 0)   <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 64), 8) ;

        --third Approach: Use less resources, but less accurate
        --o_pixel(23 downto 16) <= i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6);
        --o_pixel(15 downto 8)  <= i_RGB332(4 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 3);
        --o_pixel(7 downto 0)   <= i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0);


    end RTL;