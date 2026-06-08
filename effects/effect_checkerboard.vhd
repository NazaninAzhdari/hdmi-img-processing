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
    signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');

    begin
        ---------------------------------------------------
        --Converting a 8-bit RGB image to 24-bit RGB Scale
        ---------------------------------------------------
        --Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue
        -- 3-bit_Red has 8 values between 0 to 7.   
        -- 3-bit-Red * 36 => after conversion, 8-bit-Red has 7 values between 0 to 252. (0, 36, 72, 108, 144, 180, 216, 252)
        -- 3-bit-Green has 8 values between 0 to 7.
        -- 3-bit-Green * 36 => after conversion, 8-bit-Green has 7 values between 0 to 252. (0, 36, 72, 108, 144, 180, 216, 252)
        -- 2-bit_Blue has 4 values between 0 to 3.
        -- 2-bit-Red * 85 => after conversion, 8-bit-Blue has 4 values between 0 to 255. ( 0, 85, 170, 255)
        r_Red8 <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 36), 8); 
        r_Green8 <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 36) , 8);
        r_Blue8 <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 85) , 8);

        ------------------------
        --Checkerboard Effect
        ------------------------
        --i_Red8/i_Green8/i_Blue8 could be a number between 0 to 255.
        --shift_right(i_Red8/i_Green8/i_Blue8 , 1) == (i_Red8/i_Green8/i_Blue8 ) / 2.
        --In the areas that (i_x(4) xor i_y(4)) = '1' , the i_Red8/i_Green8/i_Blue8 will be divided by two. (goes toward darkness)
        --and this make a checkerboard effect on the picture.

        o_pixel(23 downto 16) <= resize(shift_right(r_Red8 , 1 ), 8) when (i_x(4) xor i_y(4)) = '1' else r_Red8;
        o_pixel(15 downto 8)  <= resize(shift_right(r_Green8 , 1 ), 8) when (i_x(4) xor i_y(4)) = '1' else r_Green8;
        o_pixel(7 downto 0)   <= resize(shift_right(r_Blue8 , 1 ), 8) when (i_x(4) xor i_y(4)) = '1' else r_Blue8;

    end RTL;