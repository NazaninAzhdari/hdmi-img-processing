library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_warm_tint is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_warm_tint;

architecture RTL of effect_warm_tint is
    begin
        
        o_pixel(23 downto 16) <= i_RGB332;
        o_pixel(15 downto 8)  <= to_unsigned( shift_right((i_RGB332 * 3) , 2) , 8) 
                            when to_unsigned( shift_right((i_RGB332 * 3) , 2) , 8) > 0 
                            else (others=>'0');

        o_pixel(7 downto 0)   <= to_unsigned( shift_right((i_RGB332 * 3) , 1) , 8) 
                            when to_unsigned( shift_right((i_RGB332 * 3) , 1) , 8) < 256 
                            else (others=>'1');
    end RTL;