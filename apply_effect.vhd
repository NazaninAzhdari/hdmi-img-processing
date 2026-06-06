library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity apply_effect is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_effect_btn:   in      STD_LOGIC;
        i_x         :   in      unsigned(9 downto 0);
        i_y         :   in      unsigned(9 downto 0);
        i_Red3      :   in      unsigned(2 downto 0);
        i_Green3    :   in      unsigned(2 downto 0);
        i_Blue2     :   in      unsigned(1 downto 0);
        o_Red8      :   out     unsigned(7 downto 0);
        o_Green8    :   out     unsigned(7 downto 0);
        o_Blue8     :   out     unsigned(7 downto 0)
    );
end apply_effect;

architecture RTL of apply_effect is
    type t_color_machine is (REP_1, REP_3, REP_4, PAD_1, PAD_2, PAD_3, PAD_4,
                            RED, GREEN, BLUE,SEA_GREEN, PURPLE, YELLOW,
                            RGB_SCALE, GRAY_SCALE_1 , GRAY_SCALE_2, INVERT_RGB, INVERT_GRAY_1, INVERT_GRAY_2,
                            SOLARIZE, BW_THRESHOLD, SOLARIZE_2, BW_THRESHOLD_2, CHECKERBOARD_MASK, RAINBOW, CRT, INVERT_TINT, FIRE_EFFECT,
                            WARM_TINT, COOL_TINT
                            );
    signal r_picture_tone   :   t_color_machine     :=REP_1;
    signal r_effect_btn     :   STD_LOGIC           :='0';
    signal r_gray           :   unsigned(2 downto 0) :=(others=>'0');
    signal r_brightness     :   unsigned(4 downto 0)  :=(others=>'0'); --big enough to hold the result
    signal r_y              :   integer range 0 to 479      :=0;
	 signal sum_RGB 			:	integer  :=0;
signal r255, g255, b255 : unsigned(11 downto 0)  :=(others=>'0');
    begin

		sum_RGB <= to_integer(i_Red3) + to_integer(i_Green3) + to_integer(i_Blue2);
        r_gray <= to_unsigned((Sum_RGB / 3)  , r_gray'length);
        r_brightness <= to_unsigned(sum_RGB, 5);
        r_y <= to_integer(i_y);
		  

        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
					r_effect_btn <= i_effect_btn;
                    if i_reset = '1' then 
                        r_picture_tone <= REP_1;
                    else

                        case r_picture_tone is
                            when REP_1 => --scale the colors with repetition
                                o_Red8   <= i_Red3 & i_Red3 & i_Red3(2 downto 1);
                                o_Green8 <= i_Green3 & i_Green3 & i_Green3(2 downto 1);
                                o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= REP_3;
                                end if;  
                                    
                            when REP_3 => --scale the colors with repetition
                                o_Red8   <= i_Red3(2 downto 1) & i_Red3 & i_Red3;
                                o_Green8 <= i_Green3(2 downto 1) & i_Green3 & i_Green3;
                                o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= REP_4;
                                end if;  
                                    
                            when REP_4 => --scale the colors with repetition
                                o_Red8   <= i_Red3(1 downto 0) & i_Red3 & i_Red3;
                                o_Green8 <= i_Green3(1 downto 0) & i_Green3 & i_Green3;
                                o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= PAD_1;
                                end if;
                                        
                            when PAD_1 => --scale the colors with padding bits 20 --posterize warm
                                o_Red8   <= i_Red3 & "00000";
                                o_Green8 <= i_Green3 & "00000";
                                o_Blue8  <= i_Blue2 & "000000";

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= PAD_2;
                                end if;

                            when PAD_2 => --scale the colors with padding bits -- posterize cool
                                o_Red8   <= i_Red3 & "11111";
                                o_Green8 <= i_Green3 & "11111"; 
                                o_Blue8  <= i_Blue2 & "111111";

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= PAD_3;
                                end if;

                            when PAD_3 => --scale the colors with padding bits --too dark
                                o_Red8   <= "0" & i_Red3 & "0000";
                                o_Green8 <= "0" & i_Green3 & "0000";
                                o_Blue8  <= "0" & i_Blue2 & "00000";

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= PAD_4;
                                end if;

                            when PAD_4 => --scale the colors with padding bits --too bight
                                o_Red8   <= "1" & i_Red3 & "1111";
                                o_Green8 <= "1" & i_Green3 & "1111";
                                o_Blue8  <= "1" & i_Blue2 & "11111";

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= RGB_SCALE;
                                end if;

                            
                            when RGB_SCALE => --nothing on screen
											
                                o_Red8   <= to_unsigned((to_integer(i_Red3) * 255 / 7),  8) ;
                                o_Green8 <= to_unsigned((to_integer(i_green3) * 255 / 7), 8) ;
                                o_Blue8  <= to_unsigned((to_integer(i_blue2) * 255 / 3) , 8) ;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= INVERT_RGB;
                                end if;
                                
                            when INVERT_RGB =>
                                o_Red8   <= not (i_Red3 & i_Red3 & i_Red3(2 downto 1));
                                o_Green8 <= not (i_Green3 & i_Green3 & i_Green3(2 downto 1));
                                o_Blue8  <= not (i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2);

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= GRAY_SCALE_1;
                                end if;

                            when GRAY_SCALE_1 =>
                                --r_gray <= resize( ((i_Red3 + i_Green3 + i_Blue2) / 3)  , 3);
                                o_Red8 <= r_gray & r_gray & r_gray(2 downto 1);
                                o_Green8 <= r_gray & r_gray & r_gray(2 downto 1);
                                o_Blue8 <= r_gray & r_gray & r_gray(2 downto 1);

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= GRAY_SCALE_2;
                                end if;

                            when GRAY_SCALE_2 =>
                                o_Red8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Blue8 <= i_Red3 & i_Green3 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= INVERT_GRAY_1;
                                end if;
										  
							when INVERT_GRAY_1 =>
                                --r_gray <= resize( ((i_Red3 + i_Green3 + i_Blue2) / 3)  , 3);
                                o_Red8 <= not (r_gray & r_gray & r_gray(2 downto 1));
                                o_Green8 <= not (r_gray & r_gray & r_gray(2 downto 1));
                                o_Blue8 <= not (r_gray & r_gray & r_gray(2 downto 1));

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= INVERT_GRAY_2;
                                end if;
                            
                            when INVERT_GRAY_2 =>
                                o_Red8 <= not (i_Red3 & i_Green3 & i_Blue2);
                                o_Green8 <= not (i_Red3 & i_Green3 & i_Blue2);
                                o_Blue8 <= not (i_Red3 & i_Green3 & i_Blue2);	

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= RED;
                                end if;

                                
                            when RED =>
                                o_Red8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Green8 <= (others=>'0');
                                o_Blue8 <= (others=>'0');

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= GREEN;
                                end if;

                            when GREEN =>
                                o_Red8 <= (others=>'0');
                                o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Blue8 <= (others=>'0');

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= BLUE;
                                end if;
                                
                            when BLUE =>
                                o_Red8 <= (others=>'0');
                                o_Green8 <= (others=>'0');
                                o_Blue8 <= i_Red3 & i_Green3 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= SEA_GREEN;
                                end if;

                            when SEA_GREEN =>
                                o_Red8 <= (others=>'0');
                                o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Blue8 <= i_Red3 & i_Green3 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= PURPLE;
                                end if;

                            when PURPLE =>
                                o_Red8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Green8 <= (others=>'0');
                                o_Blue8 <= i_Red3 & i_Green3 & i_Blue2;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= YELLOW;
                                end if;

                            when YELLOW =>
                                o_Red8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                o_Blue8 <= (others=>'0');

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= SOLARIZE;
                                end if;
                            
                            when SOLARIZE =>
                                --r_brightness <= i_Red3 + i_Green3 + i_Blue2; --not really change(RGB)
                                if r_brightness > 10 then
                                    o_Red8   <= not (i_Red3 & i_Red3 & i_Red3(2 downto 1));
                                    o_Green8 <= not (i_Green3 & i_Green3 & i_Green3(2 downto 1));
                                    o_Blue8  <= not (i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2);
                                else
                                    o_Red8   <= i_Red3 & i_Red3 & i_Red3(2 downto 1);
                                    o_Green8 <= i_Green3 & i_Green3 & i_Green3(2 downto 1);
                                    o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= SOLARIZE_2;
                                end if;
										  
							when SOLARIZE_2 =>
                                --r_brightness <= i_Red3 + i_Green3 + i_Blue2; --not really change(RGB)
                                if r_brightness > 5 then
                                    o_Red8   <= not (i_Red3 & i_Red3 & i_Red3(2 downto 1));
                                    o_Green8 <= not (i_Green3 & i_Green3 & i_Green3(2 downto 1));
                                    o_Blue8  <= not (i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2);
                                else
                                    o_Red8   <= i_Red3 & i_Red3 & i_Red3(2 downto 1);
                                    o_Green8 <= i_Green3 & i_Green3 & i_Green3(2 downto 1);
                                    o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= BW_THRESHOLD;
                                end if;

                            when BW_THRESHOLD => --black picture nothing on screen
                                --r_brightness <= i_Red3 + i_Green3 + i_Blue2;
                                if r_brightness > 10 then
                                    o_Red8   <= (others=>'1');
                                    o_Green8 <= (others=>'1');
                                    o_Blue8  <= (others=>'1');
                                else
                                    o_Red8   <= (others=>'0');
                                    o_Green8 <= (others=>'0');
                                    o_Blue8  <= (others=>'0');
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= BW_THRESHOLD_2;
                                end if;
										  
							when BW_THRESHOLD_2 => --black picture nothing on screen
                                --r_brightness <= i_Red3 + i_Green3 + i_Blue2;
                                if r_brightness > 5 then
                                    o_Red8   <= (others=>'1');
                                    o_Green8 <= (others=>'1');
                                    o_Blue8  <= (others=>'1');
                                else
                                    o_Red8   <= (others=>'0');
                                    o_Green8 <= (others=>'0');
                                    o_Blue8  <= (others=>'0');
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= CHECKERBOARD_MASK;
                                end if;

                            when CHECKERBOARD_MASK =>
                                if (i_x(4) xor i_y(4)) = '1' then
                                    o_Red8   <= to_unsigned((to_integer((i_Red3 & i_Red3 & i_Red3(2 downto 1))) / 2), 8);
                                    o_Green8 <= to_unsigned((to_integer((i_Green3 & i_Green3 & i_Green3(2 downto 1))) / 2), 8);
                                    o_Blue8  <= to_unsigned((to_integer((i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2)) / 2), 8);
                                else
                                    o_Red8   <= i_Red3 & i_Red3 & i_Red3(2 downto 1);
                                    o_Green8 <= i_Green3 & i_Green3 & i_Green3(2 downto 1);
                                    o_Blue8  <= i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2;
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= RAINBOW;
                                end if;

                            when RAINBOW =>
                                if r_y < 80 then
                                    o_Red8   <= i_Red3 & i_Green3 & i_Blue2;
                                    o_Green8 <= (others=>'0');
                                    o_Blue8  <= (others=>'0');
                                elsif r_y < 160 then
                                    o_Red8   <= (others=>'0');
                                    o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                    o_Blue8  <= (others=>'0');
                                elsif r_y < 240 then
                                    o_Red8   <= (others=>'0');
                                    o_Green8 <= (others=>'0');
                                    o_Blue8  <= i_Red3 & i_Green3 & i_Blue2;
                                elsif r_y < 320 then
                                    o_Red8   <= (others=>'0');
                                    o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                    o_Blue8  <= i_Red3 & i_Green3 & i_Blue2;
                                elsif r_y < 400 then
                                    o_Red8   <= i_Red3 & i_Green3 & i_Blue2;
                                    o_Green8 <= (others=>'0');
                                    o_Blue8  <= i_Red3 & i_Green3 & i_Blue2;
                                else
                                    o_Red8   <= i_Red3 & i_Green3 & i_Blue2;
                                    o_Green8 <= i_Red3 & i_Green3 & i_Blue2;
                                    o_Blue8  <= (others=>'0');
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= CRT;
                                end if;

                            when CRT =>
                                if i_y(0) = '1' then
                                    o_Red8   <= (i_Red3 & i_Red3 & i_Red3(2 downto 1)) / 2;
                                    o_Green8 <= (i_Green3 & i_Green3 & i_Green3(2 downto 1)) / 2;
                                    o_Blue8  <= (i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2) / 2;
                                end if;

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= INVERT_TINT;
                                end if;
                            
                            when INVERT_TINT =>
                                --o_Red8   <= resize( ((not (i_Red3 & i_Red3 & i_Red3(2 downto 1))) + 40) , o_Red8'length);
								o_Red8   <= (not (i_Red3 & i_Red3 & i_Red3(2 downto 1))) + 40;
                                o_Green8 <= not (i_Green3 & i_Green3 & i_Green3(2 downto 1));
                                o_Blue8  <= not (i_Blue2 & i_Blue2 & i_Blue2 & i_Blue2);

                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= FIRE_EFFECT;
                                end if;
                            
                            when FIRE_EFFECT => --nothing on screen
                                --r_brightness <= i_Red3 + i_Green3 + i_Blue2;
                                
                                o_Red8   <= to_unsigned((sum_RGB * 20), 8);
                                o_Green8 <= to_unsigned((sum_RGB * 10), 8);
                                o_Blue8  <= to_unsigned((sum_RGB / 4), 8);
										  
								if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= WARM_TINT;
                                end if;
                        

                            when WARM_TINT => --Warm Tint purple yellow
                                o_Red8   <= i_Red3 & i_Green3 & i_Blue2;
                                o_Green8 <= to_unsigned( (to_integer(i_Red3 & i_Green3 & i_Blue2) * 3 / 4) , o_Green8'length);
                                o_Blue8  <= to_unsigned( (to_integer(i_Red3 & i_Green3 & i_Blue2) * 3 / 2) , o_Blue8'length);
                                        
                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= COOL_TINT;
                                end if;

                            when COOL_TINT => --Coll Tint
                                o_Red8   <= to_unsigned( (to_integer(i_Red3 & i_Green3 & i_Blue2) * 3 / 2) , o_Blue8'length);
                                o_Green8 <= to_unsigned( (to_integer(i_Red3 & i_Green3 & i_Blue2) * 3 / 4) , o_Green8'length);
                                o_Blue8  <= i_Red3 & i_Green3 & i_Blue2;
                                        
                                if i_effect_btn = '0' and r_effect_btn = '1' then
                                    r_picture_tone <= REP_1;
                                end if;

                            when others =>
                                r_picture_tone <= REP_1;
                        end case;
					end if;  
                end if;
            end process;

        end RTL;