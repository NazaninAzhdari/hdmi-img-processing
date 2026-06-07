library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_color is
    port (
        i_clk50             :   in      STD_LOGIC;
        i_reset             :   in      STD_LOGIC;
        i_effect_En         :   in      STD_LOGIC;
        i_plus_btn          :   in      STD_LOGIC;
        i_minus_btn         :   in      STD_LOGIC;
        i_Red8              :   in      unsigned(7 downto 0);
        i_Green8            :   in      unsigned(7 downto 0);
        i_Blue8             :   in      unsigned(7 downto 0);
        o_red_intensity     :   out     unsigned(7 downto 0);
        o_green_intensity   :   out     unsigned(7 downto 0);
        o_blue_intensity    :   out     unsigned(7 downto 0);
        o_Red8              :   out     unsigned(7 downto 0);
        o_Green8            :   out     unsigned(7 downto 0);
        o_Blue8             :   out     unsigned(7 downto 0)
    );
end effect_color;

architecture RTL of effect_color is
    signal r_red_intensity    :       unsigned(7 downto 0)         :=(others=>'1');
    signal r_green_intensity  :       unsigned(7 downto 0)         :=(others=>'1');
    signal r_blue_intensity   :       unsigned(7 downto 0)         :=(others=>'1');

    signal r_plus_btn  :       STD_LOGIC                    :='0';
    signal r_minus_btn :       STD_LOGIC                    :='0';

    begin
        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    if i_reset = '1' then
                        r_red_intensity <= "11111111";
                        r_green_intensity <= "11111111";
                        r_blue_intensity <= "11111111";
                    else
                        if i_effect_En = '1' then

                            if i_plus_btn = '0' and r_plus_btn = '1' then --falling-edge of plus button
                                if i_red_btn = '1' then
                                    r_red_intensity <= '1' & r_red_intensity(7 downto 1);
                                elsif i_green_btn = '1' then
                                    r_green_intensity <= '1' & r_green_intensity(7 downto 1);
                                elsif i_blue_btn = '1' then
                                    r_blue_intensity <= '1' & r_blue_intensity(7 downto 1);
                                end if;

                            elsif i_minus_btn = '0' and r_minus_btn = '1' then --falling-edge of minus button
                                if i_red_btn = '1' then
                                    r_red_intensity <= r_red_intensity(7 downto 1) & '0';
                                elsif i_green_btn = '1' then
                                    r_green_intensity <= r_green_intensity(7 downto 1) & '0';
                                elsif i_blue_btn = '1' then
                                    r_blue_intensity <= r_blue_intensity(7 downto 1) & '0';
                                end if;
                            end if;

                        else
                            r_red_intensity <= "11111111";
                            r_green_intensity <= "11111111";
                            r_blue_intensity <= "11111111";
                        end if; --if i_effect_En = '1' or else

                    end if; --if i_reset = '1' or else
                end if; --if rising_edge
            end process;
            
            o_Red8 <= i_Red8 and r_red_intensity;
            o_Green8 <= i_Green8 and r_green_intensity;
            o_Blue8 <= i_Blue8 and r_blue_intensity;
            
            o_red_intensity <= r_red_intensity;
            o_green_intensity <= r_green_intensity;
            o_blue_intensity <= r_blue_intensity;
    end RTL;