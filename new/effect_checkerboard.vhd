library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_checkerboard is
    port (
        i_x         :   in      unsigned(9 downto 0);
        i_y         :   in      unsigned(9 downto 0);
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_checkerboard;

architecture RTL of effect_checkerboard is
    signal r_RGB332_effect  :   unsigned(7 downto 0)    :=(others=>'0');

    begin
        --i_RGB332 could be a number between 0 to 255
        --shift_right(i_RGB332, 1) == i_RGB332 / 2
        --in the areas that (i_x(4) xor i_y(4)) = '1' , the i_RGB332 will be divided by two. (goes toward darkness)
        --and this make a checkerboard effect on the picture.

        r_RGB332_effect <= to_unsigned((shift_right(i_RGB332) , 1 ), 8) 
                            when (i_x(4) xor i_y(4)) = '1' 
                            else i_RGB332;

        o_pixel(23 downto 16) <= r_RGB332_effect(7 downto 5) & r_RGB332_effect(7 downto 5) & r_RGB332_effect(7 downto 6);
        o_pixel(15 downto 8)  <= r_RGB332_effect(4 downto 2) & r_RGB332_effect(4 downto 2) & r_RGB332_effect(4 downto 3);
        o_pixel(7 downto 0)   <= r_RGB332_effect(1 downto 0) & r_RGB332_effect(1 downto 0) & r_RGB332_effect(1 downto 0) & r_RGB332_effect(1 downto 0);

    end RTL;