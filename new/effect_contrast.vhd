library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_contrast is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_contrast;

architecture RTL of effect_contrast is
    signal r_minus_128  :   integer     :=0;
    signal r_multiply_2 :   unsigned(8 downto 0)    :=(others=>'0');
    signal r_contrast   :   unsigned(7 downto 0)    :=(others=>'0');


    begin
        
        r_minus_128 <= to_integer(i_RGB332) - 128;
        r_multiply_2 <= shift_left(to_unsigned(r_minus_128, 8), 1);
        r_contrast <= resize((128 + r_multiply_2), 8);

        o_pixel(23 downto 16) <= r_contrast when r_contrast < 256 else (others=>'1');
        o_pixel(15 downto 8)  <= r_contrast when r_contrast < 256 else (others=>'1');
        o_pixel(7 downto 0)   <= r_contrast when r_contrast < 256 else (others=>'1');


    end RTL;