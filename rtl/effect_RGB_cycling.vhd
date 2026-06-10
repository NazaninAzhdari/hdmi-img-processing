library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_RGB_cycling is
    port (
        i_y         :   in      unsigned(9 downto 0);
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_RGB_cycling;

architecture RTL of effect_RGB_cycling is
    signal r_y              :   integer range 0 to 480      :=0;
    signal r_RGB332         :   unsigned(7 downto 0)        :=(others=>'0');
    begin
        r_y <= to_integer(i_y);

        r_RGB332 <= i_RGB888(23 downto 21) & i_RGB888(15 downto 13) & i_RGB888(7 downto 6);
        ------------------------------------------------------------------------------------
        --Moving the same pixel value into different color channels depending on Y‑position. 
        ------------------------------------------------------------------------------------
        --  0 < r_y < 80    :   Move the r_RGB332 to Red channel
        -- 80 < r_y < 160   :   Move the r_RGB332 to Green channel
        --160 < r_y < 240   :   Move the r_RGB332 to Blue channel
        --240 < r_y < 320   :   Move the r_RGB332 to Green and Blue channels (Sea-Green)
        --320 < r_y < 400   :   Move the r_RGB332 to Red and Blue channels (Purple)
        --400 < r_y < 480   :   Move the r_RGB332 to Red and Green channels (Yellow)

        o_pixel(23 downto 16) <= r_RGB332 when (r_y >= 0 and r_y < 80 ) 
                                        or (r_y >= 320 and r_y < 400) 
                                        else (others=>'0');

        o_pixel(15 downto 8)  <= r_RGB332 when (r_y >= 80 and r_y < 160 ) 
                                        or (r_y >= 240 and r_y < 320) 
                                        or (r_y >= 400 and r_y < 480) 
                                        else (others=>'0');

        o_pixel(7 downto 0)   <= r_RGB332 when (r_y >= 160 and r_y < 400 ) 
                                        else (others=>'0');

    end RTL;