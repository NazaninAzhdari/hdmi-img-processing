library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_dark is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel      :   out     unsigned(23 downto 0)
    );
end effect_dark;

architecture RTL of effect_dark is
    signal r_RGB332_dark    :   unsigned(7 downto 0)    :=(others=>'0');

    begin
        r_RGB332_dark <= to_unsigned((to_integer(i_RGB332) - 128) , 8) 
                            when (to_integer(i_RGB332) - 128) > 0  
                            else (others=>'0');

        o_pixel(23 downto 16) <= r_RGB332_dark(7 downto 5) & r_RGB332_dark(7 downto 5) & r_RGB332_dark(7 downto 6);
        o_pixel(15 downto 8)  <= r_RGB332_dark(4 downto 2) & r_RGB332_dark(4 downto 2) & r_RGB332_dark(4 downto 3);
        o_pixel(7 downto 0)   <= r_RGB332_dark(1 downto 0) & r_RGB332_dark(1 downto 0) & r_RGB332_dark(1 downto 0) & r_RGB332_dark(1 downto 0);

    end RTL;