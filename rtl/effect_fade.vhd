library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_fade is
    port (
        i_RGB888    :   in      unsigned(23 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_fade;

architecture RTL of effect_fade is
    begin
        o_pixel(23 downto 16) <= "00" & i_RGB888(23 downto 21) & "000";
        o_pixel(15 downto 8)  <= "00" & i_RGB888(15 downto 13) & "000";
        o_pixel(7 downto 0)   <= "00" & i_RGB888(7 downto 5)   & "000";
										  
    end RTL;

    