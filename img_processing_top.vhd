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
    --Image specifications
    constant c_IMG_WIDTH        :   integer     :=640;
    constant c_IMG_HEIGHT       :   integer     :=480;
    constant c_IMG_SIZE         :   integer     :=c_IMG_WIDTH * c_IMG_HEIGHT; --307200 pixels
    constant c_ADDR_BIT_WIDTH   :   integer     :=19; --Number of bits required to represent pixels from 0 to 307200
    constant c_RGB_BIT_WIDTH    :   integer     :=8;
    constant c_DEBOUNCE_LIMIT   :   integer     :=5000000; --0.1 Sec. with 50MHz Clock

    signal w_clk25              :   STD_LOGIC                                       :='0';
    signal w_X, w_y             :   unsigned(9 downto 0)                            :=(others=>'0');
    signal r_addr_int           :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_rom_addr           :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal w_rom_video          :   STD_LOGIC_VECTOR(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0'); 
    signal r_mirror_addr_int           :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_mirror_rom_addr           :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal w_mirror_rom_video          :   STD_LOGIC_VECTOR(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0'); 
    signal r_pixelize_addr_int           :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_pixelize_rom_addr           :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal w_pixelize_rom_video          :   STD_LOGIC_VECTOR(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0'); 
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
        --Computing the Address line of the ROM
        -----------------------------------------
        --Pixel Cordinate (x, y) |  ROM address
        --______________________________________
        --      (0, 0)           |      0
        --      (1, 0)           |      1
        --      (2, 0)           |      2
        --      . . . .          |      .
        --     (639, 0)          |      639
        --      (0, 1)           |      640
        --      (1, 1)           |      641
        --      (2, 1)           |      642
        --      . . .            |       .
        --     (639, 479)        |      307199

        r_addr_int <= to_integer(w_y)* c_IMG_WIDTH + to_integer(w_x);
        r_rom_addr <= STD_LOGIC_VECTOR(to_unsigned(r_addr_int, r_rom_addr'length));

        -----------------------
        --ROM Instantiation
        -----------------------
        rom_instantce: entity work.img_rom
        port map (
            address	=> r_rom_addr,
            clock => i_clk50,
            q => w_rom_video
        );

        ----------------------------------------------------------
        --Computing the Address line of the ROM in Flipping Order
        ----------------------------------------------------------
        --Mirror Pixel Cordinate (x, y) |  ROM address
        --_______________________________________________
        --      (0, 0)                  |      639
        --      (1, 0)                  |      638
        --      (2, 0)                  |      637
        --      . . . .                 |      .
        --     (639, 0)                 |      0
        --      (0, 1)                  |      1279
        --      (1, 1)                  |      1278
        --      (2, 1)                  |      1277
        --      . . .                   |       .
        --      (639, 1)                |       640

        r_mirror_addr_int <= to_integer(w_y)* c_IMG_WIDTH + to_integer(639 - w_x);
        r_mirror_rom_addr <= STD_LOGIC_VECTOR(to_unsigned(r_mirror_addr_int, r_mirror_rom_addr'length));

        -----------------------
        --ROM Instantiation
        -----------------------
        rom_instantce: entity work.img_rom
        port map (
            address	=> r_mirror_rom_addr,
            clock => i_clk50,
            q => w_mirror_rom_video
        );

        -----------------------------------------------------------------------
        --Manipulating the Address line of the ROM to get a Pixelize rendering
        -----------------------------------------------------------------------
        --Pixel Cordinate (x, y) |  ROM address
        --______________________________________
        --      (0, 0)           |      0
        --      (1, 0)           |      0
        --      (2, 0)           |      0
        --      (3, 0)           |      0
        --      (4, 0)           |      4
        --      (5, 0)           |      4
        --      (6, 0)           |      4
        --      (7, 0)           |      4
        --      . . . .          |      .
        --     (639, 0)          |      640
        --      (0, 1)           |      0
        --      (1, 1)           |      0
        --      (2, 1)           |      0
        --      (3, 1)           |      0
        --      (4, 1)           |      4
        --      (5, 1)           |      4
        --      (6, 1)           |      4
        --      (7, 1)           |      4
        --      . . .            |       .
        --     (639, 479)        |      307199

        r_pixelize_addr_int <= to_integer(w_y(w_y'left downto 2))* c_IMG_WIDTH + to_integer(w_x(w_x'left downto 2));
        r_pixelize_rom_addr <= STD_LOGIC_VECTOR(to_unsigned(r_pixelize_addr_int, r_pixelize_rom_addr'length));

        -----------------------
        --ROM Instantiation
        -----------------------
        rom_instantce: entity work.img_rom
        port map (
            address	=> r_pixelize_rom_addr,
            clock => i_clk50,
            q => w_pixelize_rom_video
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
            i_RGB332 => unsigned(w_Rom_video),
            i_mirror_RGB332 => unsigned(w_mirror_Rom_video),
            i_pixelize_RGB332 => unsigned(w_pixelize_Rom_video),
            o_pixel => w_effected_pixel
        );

        o_hdmi_video <= w_effected_pixel when w_DE = '1' else (others=>'0');
		o_hdmi_De <= w_DE;
		o_hdmi_clk <= w_clk25;
        o_LEDs <= w_select_effect;

    end RTL;