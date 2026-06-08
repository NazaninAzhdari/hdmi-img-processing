library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_cool_tint is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_cool_tint;

architecture RTL of effect_cool_tint is
    begin
        
        o_pixel(23 downto 16) <= to_unsigned( shift_right((i_RGB332 * 3) , 1) , 8) 
                            when to_unsigned( shift_right((i_RGB332 * 3) , 1) , 8) < 256 
                            else (others=>'1');
        o_pixel(15 downto 8)  <= to_unsigned( shift_right((i_RGB332 * 3) , 2) , 8) 
                            when to_unsigned( shift_right((i_RGB332 * 3) , 2) , 8) > 0 
                            else (others=>'0');

        o_pixel(7 downto 0)   <= i_RGB332;
    end RTL;