--BBCE = bright‑biased color expansion

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_BBCE is
    port (
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_BBCE;

architecture RTL of effect_BBCE is
    begin
        
        --bright‑biased color expansion
        o_pixel(23 downto 16) <= i_RGB332(7 downto 6) & i_RGB332(7 downto 5) & i_RGB332(7 downto 5);
        o_pixel(15 downto 8)  <= i_RGB332(4 downto 3) & i_RGB332(4 downto 2) & i_RGB332(4 downto 2);
        o_pixel(7 downto 0)   <= i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0);

    end RTL;