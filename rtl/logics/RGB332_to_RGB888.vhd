library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Converting a 8-bit RGB image to 24-bit RGB Scale
--Based on your desire you can use one of these approaches.(comment the approach you dont want to use)
--I will use the second approach, because it uses less resources than first approach and the result would be close enough.
--Note that: i_RGB332 == 3-bit-Red & 3-bit_Green & 2-bit_Blue.
        
entity RGB332_to_RGB888 is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_RGB888    :   out     unsigned(23 downto 0)
    );
end RGB332_to_RGB888;

architecture RTL of RGB332_to_RGB888 is
    --signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    --signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    --signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');
    begin

        --------------------------------------------------------
        --First Approach: Use more resources, but more accurate.
        --------------------------------------------------------
        --o_RGB888(23 downto 16) <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 255 / 7), 8) ;
        --o_RGB888(15 downto 8)  <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 255 / 7), 8) ;
        --o_RGB888(7 downto 0)   <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 255 / 3), 8) ;

        -------------------------------------------------------------
        --Second Approach: Use less resources than first approach.
        -------------------------------------------------------------
        -- 3-bit_Red has 8 values between 0 to 7.   
        -- 3-bit-Red * 36 => after conversion, 8-bit-Red has 7 values between 0 to 252. (0, 36, 72, 108, 144, 180, 216, 252)
        -- 3-bit-Green has 8 values between 0 to 7.
        -- 3-bit-Green * 36 => after conversion, 8-bit-Green has 7 values between 0 to 252. (0, 36, 72, 108, 144, 180, 216, 252)
        -- 2-bit_Blue has 4 values between 0 to 3.
        -- 2-bit-Red * 85 => after conversion, 8-bit-Blue has 4 values between 0 to 255. ( 0, 85, 170, 255)
        o_RGB888(23 downto 16) <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 36), 8) ;
        o_RGB888(15 downto 8)  <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 36), 8) ;
        o_RGB888(7 downto 0)   <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 85), 8) ;

        ----------------------------------------------------------------------------------------------
        --Third Approach: Use less resources than first approaches, but less accurate than first one.
        ----------------------------------------------------------------------------------------------
        --r_Red8   <= shift_left(resize(i_RGB332(7 downto 5), 8) , 5);
        --r_Green8 <= shift_left(resize(i_RGB332(4 downto 2), 8) , 5);
        --r_Blue8  <= shift_left(resize(i_RGB332(1 downto 0), 8) , 6);

        --o_RGB888(23 downto 16) <= r_Red8;
        --o_RGB888(15 downto 8)  <= r_Green8;
        --o_RGB888(7 downto 0)   <= r_Blue8;

        ----------------------------------------------------------------------------------------
        --Forth Approach: Use less resources than others, but less accurate than first approch.
        ----------------------------------------------------------------------------------------
        --o_RGB888(23 downto 16) <= i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6);
        --o_RGB888(15 downto 8)  <= i_RGB332(4 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 3);
        --o_RGB888(7 downto 0)   <= i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0);

    end RTL;