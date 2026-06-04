library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity img_processing_top is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset_L   :   in      STD_LOGIC;
        i_button_L  :   in      STD_LOGIC;

		o_hdmi_CLK 	:	out     STD_LOGIC;
        o_hdmi_DE   :   out     STD_LOGIC;
        o_hdmi_VS   :   out     STD_LOGIC;
        o_hdmi_HS   :   out     STD_LOGIC;
        o_hdmi_video:   out     STD_LOGIC_VECTOR(23 downto 0)
    );
end img_processing_top;

architecture RTL of img_processing_top is
    --Image specifications
    constant c_IMG_WIDTH        :   integer     :=640;
    constant c_IMG_HEIGHT       :   integer     :=480;
    constant c_IMG_SIZE         :   integer     :=c_IMG_WIDTH * c_IMG_HEIGHT; --307200 pixels
    constant c_ADDR_BIT_WIDTH   :   integer     :=19; --Number of bits required to represent pixels from 0 to 307200
    constant c_RGB_BIT_WIDTH    :   integer     :=8;

    signal w_clk25      :   STD_LOGIC                               :='0';
    signal w_X, w_y     :   unsigned(9 downto 0)                    :=(others=>'0');
    signal r_addr_int   :   integer range 0 to c_IMG_SIZE-1         :=0;
    signal r_rom_addr   :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal w_rom_video  :   STD_LOGIC_VECTOR(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0');
	 
	 signal r_adju_high  :   unsigned(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0');
	 signal r_adju_low  :   unsigned(c_RGB_BIT_WIDTH-1 downto 0)    :=(others=>'0');
	 
	 signal r_Red, r_Green, r_Blue  :  STD_LOGIC_VECTOR(7 downto 0)  :=(others=>'0');
	 signal w_DE : STD_LOGIC  :='0';
	 
	 type color_machine is (GRAY_TONE, RED_TONE, GREEN_TONE, BLUE_TONE, SEA_GREEN_TONE, YELLOW_TONE, PURPLE_TONE, WARM_TINT, COOL_TINT);
     signal r_picture_tone : color_machine  :=GRAY_TONE;
	  signal r_button_L : STD_LOGIC :='0';
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


				
			r_adju_high <= resize( (unsigned(w_rom_video) * 3 / 4) , r_adju_high'length);
			r_adju_low <= unsigned(w_rom_video) / 2;

        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
						r_button_L <= i_button_L;
						
                    case r_picture_tone is
                        when GRAY_TONE => --Gray Tone
                            r_Red   <= w_rom_video;
                            r_Green <= w_rom_video;
                            r_Blue  <= w_rom_video;
										
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= RED_TONE;
									  end if; 
                        
                        when RED_TONE => --Red Tone
                            r_Red   <= w_rom_video;
                            r_Green <= (others=>'0');
                            r_Blue  <= (others=>'0');
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= GREEN_TONE;
									  end if;

                        when GREEN_TONE => --Green Tone
                            r_Red   <= (others=>'0');
                            r_Green <= w_rom_video;
                            r_Blue  <= (others=>'0');
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= BLUE_TONE;
									  end if;

                        when BLUE_TONE => --Blue Tone
                            r_Red   <= (others=>'0');
                            r_Green <= (others=>'0');
                            r_Blue  <= w_rom_video;
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= SEA_GREEN_TONE;
									  end if;

                        when SEA_GREEN_TONE => --Sea-Green Tone
                            r_Red   <= (others=>'0');
                            r_Green <= w_rom_video;
                            r_Blue  <= w_rom_video;
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= PURPLE_TONE;
									  end if;

                        when PURPLE_TONE => --Purple Tone
                            r_Red   <= w_rom_video;
                            r_Green <= (others=>'0');
                            r_Blue  <= w_rom_video;
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= YELLOW_TONE;
									  end if;

                        when YELLOW_TONE => --Yellow Tone
                            r_Red   <= w_rom_video;
                            r_Green <= w_rom_video;
                            r_Blue  <= (others=>'0');
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= WARM_TINT;
									  end if;

                        when WARM_TINT => --Warm Tint
                            r_Red   <= w_rom_video;
                            r_Green <= STD_LOGIC_VECTOR(r_adju_high);
                            r_Blue  <= STD_LOGIC_VECTOR(r_adju_low);
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= COOL_TINT;
									  end if;

                        when COOL_TINT => --Coll Tint
                            r_Red   <= STD_LOGIC_VECTOR(r_adju_low);
                            r_Green <= STD_LOGIC_VECTOR(r_adju_high);
                            r_Blue  <= w_rom_video;
									 
									 if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= GRAY_TONE;
									  end if;

                        when others =>
                            r_picture_tone <= GRAY_TONE;
                    end case;  
                end if;
            end process;

        o_hdmi_video <= r_Red & r_Green & r_Blue when w_DE = '1' else (others=>'0');
		o_hdmi_De <= w_DE;
		o_hdmi_clk <= w_clk25;

    end RTL;