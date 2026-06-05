library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adju_color_scale is
    port (

    );
end adju_color_scale;

architecture RTL of adju_color_scale is
    begin

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
                        when REPETITION_1 => --scale the colors with repetition
                            o_Red8   <= i_Red3 & i_Red3 & i_Red3(2 downto 1);
                            o_Green8 <= i_Green3 & i_Green3 & i_Green3(2 downto 1);
                            o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= REPETITION_2;
                            end if;  
								
                        when REPETITION_2 => --scale the colors with repetition
                            o_Red8   <= i_Red3 & i_Red3 & i_Red3(1 downto 0);
                            o_Green8 <= i_Green3 & i_Green3 & i_Green3(1 downto 0);
                            o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= REPETITION_3;
                            end if;

                        when REPETITION_3 => --scale the colors with repetition
                            o_Red8   <= i_Red3 & i_Red3(2 downto 1) & i_Red3;
                            o_Green8 <= i_Green3 & i_Green3(2 downto 1) & i_Green3;
                            o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= REPETITION_4;
                            end if;  
								
                        when REPETITION_4 => --scale the colors with repetition
                            o_Red8   <= i_Red3 & i_Red3(1 downto 0) & i_Red3;
                            o_Green8 <= i_Green3 & i_Green3(1 downto 0) & i_Green3;
                            o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= REPETITION_5;
                            end if;

                        when REPETITION_5 => --scale the colors with repetition
                            o_Red8   <= i_Red3(2 downto 1) & i_Red3 & i_Red3;
                            o_Green8 <= i_Green3(2 downto 1) & i_Green3 & i_Green3;
                            o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= REPETITION_6;
                            end if;  
								
                        when REPETITION_6 => --scale the colors with repetition
                            o_Red8   <= i_Red3(1 downto 0) & i_Red3 & i_Red3;
                            o_Green8 <= i_Green3(1 downto 0) & i_Green3 & i_Green3;
                            o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PADDING_1;
                            end if;
									  
						when PADDING_1 => --scale the colors with padding bits
                            o_Red8   <= i_Red3 & "00000";
                            o_Green8 <= i_Green3 & "00000";
                            o_Blue8  <= i_Blue2 & "000000";

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PADDING_2;
                            end if;

                        when PADDING_2 => --scale the colors with padding bits
                            o_Red8   <= i_Red3 & "11111";
                            o_Green8 <= i_Green3 & "11111";
                            o_Blue8  <= i_Blue2 & "111111";

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PADDING_3;
                            end if;

                        when PADDING_3 => --scale the colors with padding bits
                            o_Red8   <= "00" & i_Red3 & "000";
                            o_Green8 <= "00" & i_Green3 & "000";
                            o_Blue8  <= "00" & i_Blue2 & "0000";

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PADDING_4;
                            end if;

                        when PADDING_4 => --scale the colors with padding bits
                            o_Red8   <= "11" & i_Red3 & "111";
                            o_Green8 <= "11" & i_Green3 & "111";
                            o_Blue8  <= "11" & i_Blue2 & "1111";

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PAD_REP_1;
                            end if;

                        when PAD_REP_1 => --scale the colors with padding bits and repetition
                            o_Red8   <= i_Red3 & "00" & i_Red3;
                            o_Green8 <= i_Green3 & "00" & i_Green3 ;
                            o_Blue8  <= i_Blue2 & "00" & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PAD_REP_2;
                            end if;

                        when PAD_REP_2 => --scale the colors with padding bits and repetition
                            o_Red8   <= i_Red3 & "11" & i_Red3;
                            o_Green8 <= i_Green3 & "11" & i_Green3 ;
                            o_Blue8  <= i_Blue2 & "11" & i_Blue2 & i_Blue2;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PAD_REP_3;
                            end if;
						
                        
						when RGB_SCALE =>
                            o_Red8   <= i_Red3 * 255 / 7;
                            o_Green8 <= i_Green3 * 255 / 7 ;
                            o_Blue8  <= i_Blue2 * 255 / 3;

                            if i_button_L = '1' and r_button_L = '0' then
                                r_picture_tone <= PAD_REP_3;
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


    end RTL;