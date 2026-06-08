library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity no_effect is
    port (
        i_y         :   in      unsigned(9 downto 0);
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end no_effect;

architecture RTL of no_effect is
    signal r_y              :   integer range 0 to 480      :=0;
    begin
        r_y <= to_integer(i_y);

        o_pixel(23 downto 16) <= i_RGB332 when (r_y >= 0 and r_y < 80 ) 
                                        or (r_y >= 320 and r_y < 400) 
                                        else (others=>'0');

        o_pixel(15 downto 8)  <= i_RGB332 when (r_y >= 80 and r_y < 160 ) 
                                        or (r_y >= 240 and r_y < 320) 
                                        or (r_y >= 400 and r_y < 480) 
                                        else (others=>'0');

        o_pixel(7 downto 0)   <= i_RGB332 when (r_y >= 160 and r_y < 400 ) 
                                        else (others=>'0');


    end RTL;