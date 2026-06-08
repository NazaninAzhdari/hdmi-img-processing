library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_fire is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_fire;

architecture RTL of effect_fire is
    signal sum_RGB  :   unsigned(4 downto 0)     :=(others=>'0'); 
    begin
        sum_RGB <= resize(i_RGB332(7 downto 5), 5) + i_RGB332(4 downto 2) + i_RGB332(1 downto 0);

        o_pixel(23 downto 16) <= resize(shift_left(sum_RGB , 5), 8) when resize(shift_left(sum_RGB , 5), 8) < 256  else (others=>'1');
        o_pixel(15 downto 8)  <= resize(shift_left(sum_RGB , 4), 8) when resize(shift_left(sum_RGB , 5), 8) < 256  else (others=>'1');
        o_pixel(7 downto 0)   <= resize(shift_right(sum_RGB , 2), 8) when resize(shift_left(sum_RGB , 5), 8) > 0  else (others=>'0');


    end RTL;