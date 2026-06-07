library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_effects is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_sel_effect:   in      unsigned(2 downto 0);
        i_plus_btn
        i_minus_btn

        i_x         :   in      unsigned(9 downto 0);
        i_y         :   in      unsigned(9 downto 0);
        i_Red3      :   in      unsigned(2 downto 0);
        i_Green3    :   in      unsigned(2 downto 0);
        i_Blue2     :   in      unsigned(1 downto 0);
        o_pixel
    );
end control_effects;

architecture RTL of control_effects is
    begin
        r_brightness_En <= '1' when i_sel_effect = "000" else '0';
        r_darkness_En <= '1' when i_sel_effect = "001" else '0';
        r_BW_En <= '1' when i_sel_effect = "010" else '0';
        r_checkerboard_En <= '1' when i_sel_effect = "011" else '0';
        r_color_En <= '1' when i_sel_effect = "100" else '0';
        r_CRT_En <= '1' when i_sel_effect = "101" else '0';
        r_rainbow_En <= '1' when i_sel_effect = "110" else '0';
        r_solarize_En <= '1' when i_sel_effect = "111" else '0';

        -------------------------------
        --Aplly brightness effect
        ------------------------------
        brightness_effect: entity work.effect_brightness
        port map(
            i_clk50 => i_clk50,
            i_reset => i_reset,
            i_effect_En => r_brightness_En,
            i_plus_btn => i_plus_btn,
            i_minus_btn => i_minus_btn,
            i_Red8 => r_Red8,
            i_Green8 => r_Green8,
            i_Blue8 => r_Blue8,
            o_intensity 
            o_Red8      :   out     unsigned(7 downto 0);
            o_Green8    :   out     unsigned(7 downto 0);
            o_Blue8     :   out     unsigned(7 downto 0)
        );
end effect_brightness;


    end RTL;