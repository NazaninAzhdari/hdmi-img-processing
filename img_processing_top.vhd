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
	 
	 type color_machine is (NO_EFFECT_1, NO_EFFECT_2, NO_EFFECT_3, NO_EFFECT_4, NO_EFFECT_5, NO_EFFECT_6, 
	 NO_EFFECT_7, NO_EFFECT_8, NO_EFFECT_9, NO_EFFECT_10, 
	 NO_EFFECT_11, NO_EFFECT_12, NO_EFFECT_13, NO_EFFECT_14, NO_EFFECT_15, NO_EFFECT_16,
	 INVERT_TONE, BW_TONE, GRAY_TONE, RED_TONE, GREEN_TONE, BLUE_TONE, SEA_GREEN_TONE, YELLOW_TONE, PURPLE_TONE, WARM_TINT, COOL_TINT);
     signal r_picture_tone : color_machine  :=NO_EFFECT_1;
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

                    if i_reset_L = '0' then 
                        r_picture_tone <= NO_EFFECT_1;

                    else
						
                    case r_picture_tone is
                        when NO_EFFECT_1 =>
                            r_Red   <= w_rom_video( 7 downto 5) & w_rom_video( 7 downto 5) & w_rom_video( 7 downto 6);
                            r_Green <= w_rom_video(4 downto 2) & w_rom_video( 4 downto 2) & w_rom_video( 4 downto 3);
                            r_Blue  <= w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0);

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_2;
									  end if;  
								
								when NO_EFFECT_2 =>
                            r_Red   <= w_rom_video( 7 downto 5) & w_rom_video( 7 downto 5) & w_rom_video( 6 downto 5);
                            r_Green <= w_rom_video(4 downto 2) & w_rom_video( 4 downto 2) & w_rom_video( 3 downto 2);
                            r_Blue  <= w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0);

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_3;
									  end if;
									  
								when NO_EFFECT_3 =>
                            r_Red   <= w_rom_video( 7 downto 6) & w_rom_video( 7 downto 5) & w_rom_video( 7 downto 5);
                            r_Green <= w_rom_video(4 downto 3) & w_rom_video( 4 downto 2) & w_rom_video( 4 downto 2);
                            r_Blue  <= w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0);

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_4;
									  end if;
									  
								when NO_EFFECT_4 =>
                            r_Red   <= w_rom_video( 6 downto 5) & w_rom_video( 7 downto 5) & w_rom_video( 7 downto 5);
                            r_Green <= w_rom_video(3 downto 2) & w_rom_video( 4 downto 2) & w_rom_video( 4 downto 2);
                            r_Blue  <= w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0);

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_5;
									  end if;
									  
								when NO_EFFECT_5 =>
                            r_Red   <= w_rom_video( 7 downto 5) & "00000";
                            r_Green <= w_rom_video(4 downto 2) & "00000";
                            r_Blue  <= w_rom_video(1 downto 0) & "000000";

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_6;
									  end if;
									  
								when NO_EFFECT_6 =>
                            r_Red   <= w_rom_video( 7 downto 5) & "11111";
                            r_Green <= w_rom_video(4 downto 2) & "11111";
                            r_Blue  <= w_rom_video(1 downto 0) & "111111";

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_7;
									  end if;
									  
								when NO_EFFECT_7 => --black page
                            r_Red   <= "00000" & w_rom_video( 7 downto 5);
                            r_Green <= "00000" & w_rom_video(4 downto 2);
                            r_Blue  <= "000000" & w_rom_video(1 downto 0);

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_8;
									  end if;
									  
								when NO_EFFECT_8 => --white page
                            r_Red   <= "11111" & w_rom_video( 7 downto 5);
                            r_Green <= "11111" & w_rom_video(4 downto 2);
                            r_Blue  <= "111111" & w_rom_video(1 downto 0);

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_9;
									  end if;
									  
								when NO_EFFECT_9 =>
                            r_Red   <= "00" & w_rom_video( 7 downto 5) & "000";
                            r_Green <= "00" & w_rom_video(4 downto 2) & "000";
                            r_Blue  <= "000" & w_rom_video(1 downto 0) & "000";

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_10;
									  end if;
									  
								when NO_EFFECT_10 =>
                            r_Red   <= "11" & w_rom_video( 7 downto 5) & "111";
                            r_Green <= "11" & w_rom_video(4 downto 2) & "111";
                            r_Blue  <= "111" & w_rom_video(1 downto 0) & "111";

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_11;
									  end if;
									  
								when NO_EFFECT_11 =>
                            r_Red   <=  (w_rom_video( 7 downto 5) & "00" & w_rom_video( 7 downto 5));
                            r_Green <= (w_rom_video(4 downto 2) & "00" & w_rom_video( 4 downto 2));
                            r_Blue  <=  (w_rom_video(1 downto 0) & "00" & w_rom_video(1 downto 0) & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_12;
									  end if;
									  
								when NO_EFFECT_12 =>
                            r_Red   <=  (w_rom_video( 7 downto 5) & "00" & w_rom_video( 7 downto 5));
                            r_Green <=  (w_rom_video(4 downto 2) & "00" & w_rom_video( 4 downto 2));
                            r_Blue  <=  (w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & "00" & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_13;
									  end if;
									  
								when NO_EFFECT_13 =>
                            r_Red   <=  (w_rom_video( 7 downto 5) & "00" & w_rom_video( 7 downto 5));
                            r_Green <=  (w_rom_video(4 downto 2) & "00" & w_rom_video( 4 downto 2));
                            r_Blue  <=  (w_rom_video(1 downto 0) & "0000" & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_14;
									  end if;
									  
								when NO_EFFECT_14 =>
                            r_Red   <=  (w_rom_video( 7 downto 5) & "11" & w_rom_video( 7 downto 5));
                            r_Green <=  (w_rom_video(4 downto 2) & "11" & w_rom_video( 4 downto 2));
                            r_Blue  <=  (w_rom_video(1 downto 0) & "11" & w_rom_video(1 downto 0) & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_15;
									  end if;
									  
								when NO_EFFECT_15 =>
                            r_Red   <=  (w_rom_video( 7 downto 5) & "11" & w_rom_video( 7 downto 5));
                            r_Green <=  (w_rom_video(4 downto 2) & "11" & w_rom_video( 4 downto 2));
                            r_Blue  <=  (w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & "11" & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= NO_EFFECT_16;
									  end if;
									  
								when NO_EFFECT_16 =>
                            r_Red   <= (w_rom_video( 7 downto 5) & "11" & w_rom_video( 7 downto 5));
                            r_Green <= (w_rom_video(4 downto 2) & "11" & w_rom_video( 4 downto 2));
                            r_Blue  <=  (w_rom_video(1 downto 0) & "1111" & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= INVERT_TONE;
									  end if;
						
                        when INVERT_TONE =>
                            r_Red   <= not (w_rom_video( 7 downto 5) & w_rom_video( 7 downto 5) & w_rom_video( 7 downto 6));
                            r_Green <= not (w_rom_video(4 downto 2) & w_rom_video( 4 downto 2) & w_rom_video( 4 downto 3));
                            r_Blue  <= not (w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0) & w_rom_video(1 downto 0));

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= BW_TONE;
									  end if; 

                        when BW_TONE => --Gray Tone
                            if to_integer(unsigned(w_rom_video)) > 15 then
                                r_Red   <= (others=>'1');
                                r_Green <= (others=>'1');
                                r_Blue  <= (others=>'1');
                            else
                                r_Red   <= (others=>'0');
                                r_Green <= (others=>'0');
                                r_Blue  <= (others=>'0');
                            end if;

                            if i_button_L = '1' and r_button_L = '0' then
											r_picture_tone <= GRAY_TONE;
									  end if; 

                        when GRAY_TONE =>
                            if to_integer(unsigned(w_rom_video)) > 63 then
                                r_Red   <= "00111111";
                                r_Green <= "00111111";
                                r_Blue  <= "00111111";

                            elsif to_integer(unsigned(w_rom_video)) > 15 then
                                r_Red   <= "00001111";
                                r_Green <= "00001111";
                                r_Blue  <= "00001111";
                            
                            elsif to_integer(unsigned(w_rom_video)) > 3 then
                                r_Red   <= "00000011";
                                r_Green <= "00000011";
                                r_Blue  <= "00000011";
                                
                            else
                                r_Red   <= (others=>'0');
                                r_Green <= (others=>'0');
                                r_Blue  <= (others=>'0');
                            end if;

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
											r_picture_tone <= NO_EFFECT_1;
									  end if;

                        when others =>
                            r_picture_tone <= NO_EFFECT_1;
                    end case;
						end if;  
                end if;
            end process;

        o_hdmi_video <= r_Red & r_Green & r_Blue when w_DE = '1' else (others=>'0');
		o_hdmi_De <= w_DE;
		o_hdmi_clk <= w_clk25;

    end RTL;