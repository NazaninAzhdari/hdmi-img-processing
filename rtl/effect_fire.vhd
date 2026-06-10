library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_fire is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_fire;

architecture RTL of effect_fire is
    signal sum_RGB          :    unsigned(9 downto 0)       := (others=>'0');
    signal Sum_RGB_div_3    :    unsigned(7 downto 0)       := (others=>'0');

    begin
        --Note that: i_RGB888 == 8-bit-Red & 8-bit-Green & 8-bit-Blue
        --Sum_RGB has a value between 0 to 765. ("0000000000" to "1011111101")
        sum_RGB <= resize(i_RGB888(23 downto 16), 10) + resize(i_RGB888(15 downto 8), 10)  + resize(i_RGB888(7 downto 0), 10);

        -------------------------------
        --Fire Effect
        -------------------------------
        --To get this effect:
        --o_Red8   <= sum_RGB / 3       (Strong Red)
        --o_Green8 <= (sum_RGB / 3) / 2 (Medium Green)
        --o_Blue8  <= (sum_RGB / 3) / 4 (Weak Blue)

        -- scaled to full 0–255 range (average of Sum_RGB)
        Sum_RGB_div_3 <= to_unsigned((to_integer(sum_RGB) / 3), 8) when to_unsigned((to_integer(sum_RGB) / 3), 8) < 256 
        else (others=>'1');

        --Strong Red
        o_pixel(23 downto 16) <= Sum_RGB_div_3;
        --Medium Green
        o_pixel(15 downto 8)  <= shift_right(Sum_RGB_div_3, 1);
        --Weak Blue
        o_pixel(7 downto 0)   <= shift_right(Sum_RGB_div_3, 2);

        end RTL;