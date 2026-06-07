library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_rainbow is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_effect_En :   in      STD_LOGIC;
        i_plus_btn  :   in      STD_LOGIC;
        i_minus_btn :   in      STD_LOGIC;
        i_y         :   in      unsigned(9 downto 0);
        i_Red8      :   out     unsigned(7 downto 0);
        i_Green8    :   out     unsigned(7 downto 0);
        i_Blue8     :   out     unsigned(7 downto 0);
        o_intensity :   out     unsigned(6 downto 0);
        o_Red8      :   out     unsigned(7 downto 0);
        o_Green8    :   out     unsigned(7 downto 0);
        o_Blue8     :   out     unsigned(7 downto 0)
    );
end effect_rainbow;

architecture RTL of effect_rainbow is
    signal r_intensity :       unsigned(7 downto 0)         :="11110000";
    signal r_plus_btn  :       STD_LOGIC                    :='0';
    signal r_minus_btn :       STD_LOGIC                    :='0';
    signal r_y         :       integer                      :=0;

    begin
        i_y <= to_integer(i_y);

        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    if i_reset = '1' then
                        r_intensity <= "11110000";
                    else
                        if i_effect_En = '1' then

                            if r_y < 80 then
                                o_Red8   <= i_Red8;
                                o_Green8 <= i_Green8 and r_intensity;
                                o_Blue8  <= i_blue8 and r_intensity;
                            elsif r_y < 160 then
                                o_Red8   <= i_Red8 and r_intensity;
                                o_Green8 <= i_Green8;
                                o_Blue8  <= i_Blue8 and r_intensity;
                            elsif r_y < 240 then
                                o_Red8   <= i_Red8 and r_intensity;
                                o_Green8 <= i_Green8 and r_intensity;
                                o_Blue8  <= i_Blue8;
                            elsif r_y < 320 then
                                o_Red8   <= i_Red8 and r_intensity;
                                o_Green8 <= i_Green8;
                                o_Blue8  <= i_Blue8;
                            elsif r_y < 400 then
                                o_Red8   <= i_Red8;
                                o_Green8 <= i_Green8 and r_intensity;
                                o_Blue8  <= i_Blue8;
                            else
                                o_Red8   <= i_Red8;
                                o_Green8 <= i_Green8;
                                o_Blue8  <= i_Blue8 and r_intensity;;
                            end if; 

                            if i_plus_btn = '0' and r_plus_btn = '1' then --falling-edge of plus button
                                if r_intensity < "11111111" then
                                    r_intensity <= '1' & r_intensity(7 downto 1);
                                end if;
                            elsif i_minus_btn = '0' and r_minus_btn = '1' then --falling-edge of minus button
                                if r_intensity > "00000000" then
                                    r_intensity <= r_intensity(7 downto 1) & '0';
                                end if;
                            end if;

                        else
                            r_intensity <= "11110000";
                        end if; --if i_effect_En = '1' or else

                    end if; --if i_reset = '1' or else
                end if; --if rising_edge
            end process;
            
            o_intensity <= r_intensity;

    end RTL;