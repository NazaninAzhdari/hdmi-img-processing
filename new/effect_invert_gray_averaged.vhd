library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_invert_gray_averaged is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_invert_gray_averaged;

architecture RTL of effect_invert_gray_averaged is
    signal r_gray           :   unsigned(2 downto 0)    :=(others=>'0');
    signal r_gray_avg       :   integer range 0 to 6    :=0;
	signal sum_RGB 			:	integer range 0 to 17   :=0;

    begin
        ----------------------------------------------
        --Inversion of the Averaged Gray-Scale Effect
        ----------------------------------------------
        --Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue
        --Sum_RGB has a value between 0 to 17.
        --r_gray_avg can have a value btween 0 to 5.
        --r_gray value would be between 000 to 101.

        sum_RGB <= to_integer(i_RGB332(7 downto 5)) + to_integer(i_RGB332(4 downto 2)) + to_integer(i_RGB332(1 downto 0));
        r_gray_avg <= Sum_RGB / 3;
        r_gray <= to_unsigned(r_gray_avg  , r_gray'length);

        --To get this effect, we first compute the average-gray and then invert the result.
        o_pixel(23 downto 16) <= not (r_gray & r_gray & r_gray(2 downto 1));
        o_pixel(15 downto 8)  <= not (r_gray & r_gray & r_gray(2 downto 1));
        o_pixel(7 downto 0)   <= not (r_gray & r_gray & r_gray(2 downto 1));

    end RTL;