library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_grayscale_averaged is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_grayscale_averaged;

architecture RTL of effect_grayscale_averaged is
    signal r_gray           :   unsigned(2 downto 0)    :=(others=>'0');
	signal sum_RGB 			:	integer                 :=0;

    begin
        sum_RGB <= to_integer(i_RGB332(7 downto 5)) + to_integer(i_RGB332(4 downto 2)) + to_integer(i_RGB332(1 downto 0));
        r_gray <= to_unsigned((Sum_RGB / 3)  , r_gray'length);

        o_pixel(23 downto 16) <= r_gray & r_gray & r_gray(2 downto 1);
        o_pixel(15 downto 8)  <= r_gray & r_gray & r_gray(2 downto 1);
        o_pixel(7 downto 0)   <= r_gray & r_gray & r_gray(2 downto 1);

    end RTL;