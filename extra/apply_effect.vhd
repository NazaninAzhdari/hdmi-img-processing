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
        o_pixel
    );
end apply_effect;

architecture RTL of apply_effect is
    begin
        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    if i_reset= '1' then
                    
                    else
                        case i_select_effect is
                            when "0000" => --Brightness
                                if (to_integer(i_Red8) + r_intensity) < 256 then
                                    r_Red8 <= to_unsigned((to_integer(i_Red8) + r_intensity) , 8);
                                else 
                                    r_Red8 <= (others=>'1');
                                end if;

                                if (to_integer(i_Green8) + r_intensity) < 256 then
                                    r_Green8 <= to_unsigned((to_integer(i_Green8) + r_intensity) , 8);
                                else 
                                    r_Green8 <= (others=>'1');
                                end if;

                                if (to_integer(i_Blue8) + r_intensity) < 256 then
                                    r_Blue8  <= to_unsigned((to_integer(i_Blue8) + r_intensity) , 8);
                                else 
                                    r_Blue8  <=(others=>'1');
                                end if;
                            
                            when "0001" => --Darkness
                                if (to_integer(i_Red8) - r_intensity) > 0 then
                                    r_Red8 <= to_unsigned((to_integer(i_Red8) - r_intensity) , 8);
                                else 
                                    r_Red8 <= (others=>'0');
                                end if;

                                if (to_integer(i_Green8) - r_intensity) > 0 then
                                    r_Green8 <= to_unsigned((to_integer(i_Green8) - r_intensity) , 8);
                                else 
                                    r_Green8 <= (others=>'0');
                                end if;

                                if (to_integer(i_Blue8) - r_intensity) > 0 then
                                    r_Blue8  <= to_unsigned((to_integer(i_Blue8) - r_intensity) , 8);
                                else 
                                    r_Blue8  <=(others=>'0');
                                end if;

                            when "0010" => --BW
                                if (to_integer(i_RGB332) > r_intensity) then
                                    r_Red8   <= (others=>'1');
                                    r_Green8 <= (others=>'1');
                                    r_Blue8  <= (others=>'1'); 
                                else
                                    r_Red8   <= (others=>'0');
                                    r_Green8 <= (others=>'0');
                                    r_Blue8  <= (others=>'0'); 
                                end if;

                            when "0011" => --checkerboard
                                

    end RTL;