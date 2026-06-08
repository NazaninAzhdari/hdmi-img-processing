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
        
        --Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue
        --Sum_RGB has a value between 0 to 17. ("00000" to "10001")
        sum_RGB <= resize(i_RGB332(7 downto 5), 5) + i_RGB332(4 downto 2) + i_RGB332(1 downto 0);

        --------------------------------
        --Fire Effect
        --------------------------------
        --To get this effect:
        --o_Red8   <= sum_RGB * 32 (Strong Red)
        --o_Green8 <= sum_RGB * 16 (Medium Green)
        --o_Blue8  <= sum_RGB / 4  (weak Blue)

        --Strong Red
        o_pixel(23 downto 16) <= resize(shift_left(sum_RGB , 5), 8) 
                                when resize(shift_left(sum_RGB , 5), 8) < 256  
                                else (others=>'1');

        --Medium Green
        o_pixel(15 downto 8)  <= resize(shift_left(sum_RGB , 4), 8) 
                                when resize(shift_left(sum_RGB , 5), 8) < 256  
                                else (others=>'1');

        --Weak Blue
        o_pixel(7 downto 0)   <= resize(shift_right(sum_RGB , 2), 8) 
                                when resize(shift_left(sum_RGB , 5), 8) > 0  
                                else (others=>'0');


    end RTL;