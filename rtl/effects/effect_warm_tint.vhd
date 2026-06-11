library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_warm_tint is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_warm_tint;

architecture RTL of effect_warm_tint is
    signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');
	signal r_Rx3      :   unsigned(15 downto 0)   :=(others=>'0');
    signal r_Bx3      :   unsigned(15 downto 0)   :=(others=>'0');
	 
    begin
        -----------------------------------------------------
        --Assign RGB888 to corrosponding color channels
        -----------------------------------------------------
        r_Red8 <= i_RGB888(23 downto 16);
        r_Green8 <= i_RGB888(15 downto 8);
        r_Blue8 <= i_RGB888(7 downto 0);

        --------------
        --Warm Tint
        --------------
        --To get this effect:
        --o_Red8   <= (i_Red8 * 3 / 2)       Red Become more stronger *1.5  (approx)
        --o_Green8 <= i_Green8               Green stays strong *1
        --o_Blue8  <= (i_Blue8 * 3 / 4)      Blue becomes weak *0.75 (approx)

		r_Rx3 <= r_Red8 * 3;
		r_Bx3 <= r_Blue8 * 3;

        o_pixel(23 downto 16) <= resize( shift_right(r_Rx3 , 1) , 8) 
                            when resize( shift_right(r_Rx3 , 1) , 8) < 256 
                            else (others=>'1');
									 
        o_pixel(15 downto 8)  <= r_Green8;

        o_pixel(7 downto 0)   <= resize(shift_right(r_Bx3 , 2) , 8)
                            when resize(shift_right(r_Bx3 , 2) , 8) > 0 
                            else (others=>'0');
    end RTL;