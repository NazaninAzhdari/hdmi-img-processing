library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_effects is
    port (
        i_clk50         :   in      STD_LOGIC;
        i_select_effect :   in      unsigned(4 downto 0);
        i_x             :   in      unsigned(9 downto 0);
        i_y             :   in      unsigned(9 downto 0);
        i_RGB332        :   in      unsigned(7 downto 0);
        o_pixel         :   out     unsigned(23 downto 0)
    );
end control_effects;

architecture RTL of control_effects is
    signal w_RGB888                 :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_BBCE_pixel             :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_bright_pixel           :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_BW_pixel               :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_checkerboard_pixel     :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_cool_tint_pixel        :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_CRT_pixel              :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_dark_pixel             :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_DBCE_pixel             :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_fire_pixel             :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_avg_gray_pixel         :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_mix_gray_pixel         :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_inv_avg_gray_pixel     :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_inv_mix_gray_pixel     :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_warm_negative_pixel    :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_negative_pixel         :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_cool_posterize_pixel   :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_warm_posterize_pixel   :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_rainbow_pixel          :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_RGB_cycling_pixel      :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_solarize_pixel         :   unsigned(7 downto 0)    :=(others=>'0');
    signal w_warm_tint_pixel        :   unsigned(7 downto 0)    :=(others=>'0');
        
    begin

        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    case i_select_effect is
                        when "00000" => o_pixel <= w_RGB888;
                        when "00001" => o_pixel <= w_BBCE_pixel;
                        when "00010" => o_pixel <= w_bright_pixel;
                        when "00011" => o_pixel <= w_BW_pixel;
                        when "00100" => o_pixel <= w_checkerboard_pixel;
                        when "00101" => o_pixel <= w_cool_tint_pixel;
                        when "00110" => o_pixel <= w_CRT_pixel;
                        when "00111" => o_pixel <= w_dark_pixel;
                        when "01000" => o_pixel <= w_DBCE_pixel;
                        when "01001" => o_pixel <= w_fire_pixel;
                        when "01010" => o_pixel <= w_avg_gray_pixel;
                        when "01011" => o_pixel <= w_mix_gray_pixel;
                        when "01100" => o_pixel <= w_inv_avg_gray_pixel;
                        when "01101" => o_pixel <= w_inv_mix_gray_pixel;
                        when "01110" => o_pixel <= w_warm_negative_pixel;
                        when "01111" => o_pixel <= w_negative_pixel;
                        when "10000" => o_pixel <= w_cool_posterize_pixel;
                        when "10001" => o_pixel <= w_warm_posterize_pixel;;
                        when "10010" => o_pixel <= w_rainbow_pixel;
                        when "10011" => o_pixel <= w_RGB_cycling_pixel;
                        when "10100" => o_pixel <= w_solarize_pixel;
                        when "10101" => o_pixel <= w_warm_tint_pixel;
                        when "10110" => o_pixel <= 
                        when "10111" => o_pixel <= 
                        when "11000" => o_pixel <= 
                        when "11001" => o_pixel <= 
                        when "11010" => o_pixel <= 
                        when "11011" => o_pixel <= 
                        when "11100" => o_pixel <= 
                        when "11101" => o_pixel <= 
                        when "11110" => o_pixel <=
                        when "11111" => o_pixel <= 
                        when others =>
                    end case;
                end if;
            end process;

        ---------------------------------------
        --Bright‑biased color expansion Effect
        ---------------------------------------
        apply_BBCE_effect: entity work.effect_BBCE
        port map(
            i_RGB332=> i_RGB332,
            o_Pixel => w_BBCE_pixel
        );

        ---------------------------------------
        --Brightness Effect
        ---------------------------------------
        apply_brightness_effect: entity work.effect_bright
        generic map(
        g_BRIGHT => 128
        )
        port map(
        i_RGB332 => i_RGB332,
        o_Pixel => w_bright_pixel
        );
        
        ---------------------------------------
        --Black-White Threshold Effect
        ---------------------------------------
        apply_Black_white_effect: entity work.effect_BW
        generic map(
            g_THRESHOLD => 5
        )
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_BW_pixel
        );

        ---------------------------------------
        --Checker-board Effect
        ---------------------------------------
        apply_Checkerboard_effect: entity work.effect_checkerboard
        port map(
            i_x => i_x,
            i_y => i_y,
            i_RGB332 => i_RGB332,
            o_Pixel => w_checkerboard_pixel
        );

        ---------------------------------------
        --Cool Tint Effect
        ---------------------------------------
        apply_cool_tint_effect: entity work.effect_cool_tint
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => o_cool_tint_pixel
        );

        ---------------------------------------
        --CRT Effect
        ---------------------------------------
        apply_CRT_effect: entity work.effect_CRT
        port map(
            i_y => i_y,
            i_RGB332 => i_x,
            o_Pixel => w_CRT_pixel
        );

        ---------------------------------------
        --Darkness Effect
        ---------------------------------------
        apply_darkness_effect: entity work.effect_dark
        generic map(
            g_DARK => 128
        )
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_dark_pixel
        );

        ---------------------------------------
        --Dark‑biased color expansion Effect
        ---------------------------------------
        apply_DBCE_effect: entity work.effect_DBCE
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_DBCE_pixel
        );

        ---------------------------------------
        --Fire Effect
        ---------------------------------------
        apply_fire_effect: entity work.effect_fire
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_fire_pixel
        );

        ---------------------------------------
        --Averaged Gray-Scale Effect
        ---------------------------------------
        apply_avg_gray_effect: entity work.effect_grayscale_averaged
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_avg_gray_pixel
        );

        ---------------------------------------
        --Channel-Mix Gray-Scale Effect
        ---------------------------------------
        apply_channel_Mix_gray_effect: entity work.effect_grayscale_channelMix
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_mix_gray_pixel
        );

        ------------------------------------------
        --Inversion of Averaged Gray-Scale Effect
        ------------------------------------------
        apply_inv_avg_gray_effect: entity work.effect_invert_gray_averaged
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_inv_avg_gray_pixel
        );

        ---------------------------------------------
        --Inversion of Channel-Mix Gray-Scale Effect
        ---------------------------------------------
        apply_inv_mix_gray_effect: entity work.effect_invert_gray_channelMix
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_inv_mix_gray_pixel
        );

        ---------------------------------------------
        --Warm Negative Effect
        ---------------------------------------------
        apply_warm_negative_effect: entity work.effect_negative_warm
        generic map(
            g_WARM_TINT => 50
        )
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_warm_negative_pixel
        );

        ---------------------------------------------
        --Negative Effect
        ---------------------------------------------
        apply_negative_effect: entity work.effect_negative
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_negtive_pixel
        );

        ---------------------------------------------
        --Cool Posterize Effect
        ---------------------------------------------
        apply_cool_posterize_effect: entity work.effect_posterize_cool
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_cool_posterize_pixel
        );

        ---------------------------------------------
        --Warm Posterize Effect
        ---------------------------------------------
        apply_warm_posterize_effect: entity work.effect_posterize_warm
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_warm_posterize_pixel
        );

        ---------------------------------------------
        --Rainbow Tint Effect
        ---------------------------------------------
        apply_rainbow_effect: entity work.effect_rainbow
        port map(
            i_y => i_y,
            i_RGB332 => i_RGB332,
            o_Pixel => w_rainbow_pixel
        );

        ---------------------------------------------
        --RGB Channel cycling Effect
        ---------------------------------------------
        apply_RGB_cycling_effect: entity work.effect_RGB_cycling
        port map(
            i_y => i_y,
            i_RGB332 => i_RGB332,
            o_Pixel => w_RGB_cycling_pixel
        );

        ---------------------------------------------
        --Solarize Effect
        ---------------------------------------------
        apply_solarize_effect: entity work.effect_solarize
        generic map(
            g_THRESHOLD => 5
        )
        port (
            i_RGB332 => i_RGB332,
            o_Pixel => w_solarize_pixel
        );

        ---------------------------------------------
        --Warm Tint Effect
        ---------------------------------------------
        apply_warm_tint_effect: entity work.effect_warm_tint
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_warm_tint_pixel
        );

        ---------------------------------------------
        --No Effect
        ---------------------------------------------
        no_effect: entity work.no_effect
        port map(
            i_RGB332 => i_RGB332,
            o_Pixel => w_RGB888
        );

    end RTL;