library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity img_processing_top is
    port (
        i_clk50         :   in      STD_LOGIC;
        i_reset_L       :   in      STD_LOGIC;
        i_select        :   in      unsigned(4 downto 0);
        o_LEDs          :   out     unsigned(4 downto 0);
		o_hdmi_CLK 	    :	out     STD_LOGIC;
        o_hdmi_DE       :   out     STD_LOGIC;
        o_hdmi_VS       :   out     STD_LOGIC;
        o_hdmi_HS       :   out     STD_LOGIC;
        o_hdmi_video    :   out     unsigned(23 downto 0)
    );
end img_processing_top;

architecture RTL of img_processing_top is
    signal w_clk25              :   STD_LOGIC                                       :='0';
    signal w_X, w_y             :   unsigned(9 downto 0)                            :=(others=>'0');
    signal w_rom_video          :   STD_LOGIC_VECTOR(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0');  
	signal w_DE                 :   STD_LOGIC                                       :='0';
    signal w_effected_pixel     :   unsigned(23 downto 0)                           :=(others=>'0');
    signal w_select_effect      :   unsigned(4 downto 0)                            :=(others=>'0');

    begin
        ----------------------------------
        --Dividing the frequency of clock
        ----------------------------------
        dividing_frequency: entity work.freq_divider
        generic map(
            g_HALF_PERIOD_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk50, --50MHz
            o_clk => w_clk25  --25MHz
        );

        ----------------------------
        --Debouncing the switch 0
        ----------------------------
        debounce_switch_0: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT => c_DEBOUNCE_LIMIT
        )
        port map(
            i_clk => i_clk50,
            i_bouncy => i_select(0),
            o_debounced => w_select_effect(0)
        );

        ---------------------------
        --Debouncing the switch 1
        ---------------------------
        debounce_switch_1: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT => c_DEBOUNCE_LIMIT
        )
        port map(
            i_clk => i_clk50,
            i_bouncy => i_select(1),
            o_debounced => w_select_effect(1)
        );

        ----------------------------
        --Debouncing the switch 2
        ----------------------------
        debounce_switch_2: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT => c_DEBOUNCE_LIMIT
        )
        port map(
            i_clk => i_clk50,
            i_bouncy => i_select(2),
            o_debounced => w_select_effect(2)
        );

        ---------------------------
        --Debouncing the switch 3
        ---------------------------
        debounce_switch_3: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT => c_DEBOUNCE_LIMIT
        )
        port map(
            i_clk => i_clk50,
            i_bouncy => i_select(3),
            o_debounced => w_select_effect(3)
        );

        ----------------------------
        --Debouncing the switch 4
        ----------------------------
        debounce_switch_4: entity work.debounce_filter
        generic map(
            g_DEBOUNCE_LIMIT => c_DEBOUNCE_LIMIT
        )
        port map(
            i_clk => i_clk50,
            i_bouncy => i_select(4),
            o_debounced => w_select_effect(4)
        );

        ----------------------
        --VGA synchronization
        ----------------------
        vga_sync: entity work.VGAsync
        port map(
            i_clk25 => w_clk25,
            i_reset => not i_reset_L,
            o_X => w_X,
            o_Y => w_Y,
            o_DE => w_DE,
            o_HS => o_hdmi_HS,
            o_VS => o_hdmi_VS
        );

        -----------------------------------------
        --Read the Pixel from BRAM
        -----------------------------------------
        read_pixel_from_BRAM: entity work.read_rom
        port map(
            i_clk50 => i_clk50,
            i_select_effect => w_select_effect,
            i_x => w_x,
            i_y => w_y,
            o_rom_video => w_rom_video
        );

        ---------------------------
        --Apply Effect on Image 
        ---------------------------
        applying_effect: entity work.control_effects
        port map(
            i_clk50  => i_clk50,
            i_select_effect => w_select_effect,
            i_x => w_x,
            i_y => w_y,
            i_RGB332 => unsigned(w_rom_video),
            o_pixel => w_effected_pixel
        );

        o_hdmi_video <= w_effected_pixel when w_DE = '1' else (others=>'0');
		o_hdmi_De <= w_DE;
		o_hdmi_clk <= w_clk25;
        o_LEDs <= w_select_effect;

    end RTL;