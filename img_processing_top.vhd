library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity img_processing_top is
    port (
        i_clk50         :   in      STD_LOGIC;
        i_reset_L       :   in      STD_LOGIC;
        i_effect_btn_L  :   in      STD_LOGIC;
        i_plus_btn_L    :   in      STD_LOGIC;
        i_minus_btn_L   :   in      STD_LOGIC;

		o_hdmi_CLK 	:	out     STD_LOGIC;
        o_hdmi_DE   :   out     STD_LOGIC;
        o_hdmi_VS   :   out     STD_LOGIC;
        o_hdmi_HS   :   out     STD_LOGIC;
        o_hdmi_video:   out     unsigned(23 downto 0)
    );
end img_processing_top;

architecture RTL of img_processing_top is
    --Image specifications
    constant c_IMG_WIDTH        :   integer     :=640;
    constant c_IMG_HEIGHT       :   integer     :=480;
    constant c_IMG_SIZE         :   integer     :=c_IMG_WIDTH * c_IMG_HEIGHT; --307200 pixels
    constant c_ADDR_BIT_WIDTH   :   integer     :=19; --Number of bits required to represent pixels from 0 to 307200
    constant c_RGB_BIT_WIDTH    :   integer     :=8;

    signal w_clk25              :   STD_LOGIC                                       :='0';
    signal w_X, w_y             :   unsigned(9 downto 0)                            :=(others=>'0');
    signal r_addr_int           :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_rom_addr           :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal w_rom_video          :   STD_LOGIC_VECTOR(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0'); 
	signal w_effect_Red, w_effect_Green, w_effect_Blue:  unsigned(7 downto 0)                            :=(others=>'0');
	signal w_DE                 :   STD_LOGIC                                       :='0';
    signal w_adju_Red, w_adju_Green, w_adju_Blue:  unsigned(7 downto 0)                            :=(others=>'0');

	 
	 
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
        --     (639, 0)          |      640
        --      (0, 1)           |      641
        --      (1, 1)           |      642
        --      (2, 1)           |      643
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

        ----------------------------------------------------------------------
        --Applying different effects on image by manupulating the color scale
        ----------------------------------------------------------------------
        applying_effect: entity work.apply_effect
        port map (
            i_clk50 => i_clk50,
            i_reset => not i_reset_L,
            i_effect_btn => not i_effect_btn_L,
            i_x => w_x,
            i_y => w_y,
            i_Red3 => unsigned(w_rom_video(7 downto 5)),
            i_Green3 => unsigned(w_rom_video(4 downto 2)),
            i_Blue2 => unsigned(w_rom_video(1 downto 0)),
            o_Red8 => w_effect_Red,
            o_Green8 => w_effect_Green,
            o_Blue8 => w_effect_Blue
        );

        ----------------------------------------------
        --adjusting effects
        --------------------------------------------
        adjusting_effect: entity work.adju_effect
        port map(
            i_clk50 => i_clk50,
            i_reset => not i_reset_L,
            i_effect_btn => not i_effect_btn_L,
            i_plus_btn => not i_plus_btn_L,
            i_minus_btn => not i_minus_btn_L,
            i_Red8 => w_effect_red
            i_Green8 => w_effect_green,
            i_Blue8 => w_effect_blue,
            o_Red8 => w_adju_red,
            o_Green8 => w_adju_green,
            o_Blue8 => w_adju_blue
        );

        

        o_hdmi_video <= w_adju_Red & w_adju_Green & w_adju_Blue when w_DE = '1' else (others=>'0');
		o_hdmi_De <= w_DE;
		o_hdmi_clk <= w_clk25;

    end RTL;