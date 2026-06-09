library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_rainbow is
    port (
        i_y         :   in      unsigned(9 downto 0);
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_rainbow;

architecture RTL of effect_rainbow is
    signal r_y        :   integer range 0 to 480  :=0;
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

        r_y <= to_integer(i_y);

        --------------------------------------------
        --Rainbow Tint Effect Based on Y position 
        --------------------------------------------
        --**Each goes to its corrosponding channel.**
        --0   < r_y < 80    :   Red Tint => r_Red8 no change, r_Green8 / 2, r_Blue8 / 2 . 
        --80  < r_y < 160   :   Orange Tint => r_Red8 no change, r_Green8 no chane, r_Blue8 / 2 . 
        --160 < r_y < 240   :   Yellow Tint => r_Red8 no change, r_Green8 no chane, r_Blue8 / 4 .
        --240 < r_y < 320   :   Green Tint => r_Red8 / 2, r_Green8 no chane, r_Blue8 / 2 .
        --320 < r_y < 400   :   Blue Tint => r_Red8 / 2, r_Green8 / 2, r_Blue8 no change .
        --400 < r_y < 480   :   Violet Tint => r_Red8 no change, r_Green8 / 4, r_Blue8 no change .
        

        o_pixel(23 downto 16) <= r_Red8 when (r_y >= 0 and r_y < 240 ) or (r_y >= 400 and r_y < 480 ) else
                                shift_right(r_Red8, 1) when (r_y >= 240 and r_y < 320 ) else
                                shift_right(r_Red8, 2) when (r_y >= 320 and r_y < 400 ) else
                                (others=>'0');

        o_pixel(15 downto 8)  <= shift_right(r_Green8, 1) when (r_y >= 0 and r_y < 80 ) or (r_y >= 320 and r_y < 400 ) else
                                r_Green8 when (r_y >= 80 and r_y < 320 ) else 
                                shift_right(r_Green8, 2) when (r_y >= 400 and r_y < 480 ) else
                                (others=>'0');

        o_pixel(7 downto 0)   <= shift_right(r_Blue8, 1) when (r_y >= 0 and r_y < 160 ) or (r_y >= 240 and r_y < 320 ) else
                                shift_right(r_Blue8, 2) when (r_y >= 160 and r_y < 240 ) else 
                                r_Blue8 when (r_y >= 320 and r_y < 480 ) else
                                (others=>'0');

    end RTL;