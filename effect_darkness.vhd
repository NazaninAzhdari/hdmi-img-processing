library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_darkness is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_effect_En :   in      STD_LOGIC;
        i_plus_btn  :   in      STD_LOGIC;
        i_minus_btn :   in      STD_LOGIC;
        i_Red8      :   in      unsigned(7 downto 0);
        i_Green8    :   in      unsigned(7 downto 0);
        i_Blue8     :   in      unsigned(7 downto 0);
        o_intensity :   out     unsigned(6 downto 0);
        o_Red8      :   out     unsigned(7 downto 0);
        o_Green8    :   out     unsigned(7 downto 0);
        o_Blue8     :   out     unsigned(7 downto 0)
    );
end effect_darkness;

architecture RTL of effect_darkness is
    signal r_intensity :       integer range 0 to 100       :=50;
    signal r_plus_btn  :       STD_LOGIC                    :='0';
    signal r_minus_btn :       STD_LOGIC                    :='0';

    begin
        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    if i_reset = '1' then
                        r_intensity <= 50;
                    else
                        if i_effect_En = '1' then

                            if i_plus_btn = '0' and r_plus_btn = '1' then --falling-edge of plus button
                                if r_intensity < 100 then
                                    r_intensity <= r_intensity + 10;
                                end if;
                            elsif i_minus_btn = '0' and r_minus_btn = '1' then --falling-edge of minus button
                                if r_intensity > 0 then
                                    r_intensity <= r_intensity - 10;
                                end if;
                            end if;

                        else
                            r_intensity <= 50;
                        end if; --if i_effect_En = '1' or else

                    end if; --if i_reset = '1' or else
                end if; --if rising_edge
            end process;
            
            ---------------------
            --Control saturation
            ---------------------
            o_Red8   <= to_unsigned((to_integer(i_Red8) - r_intensity) , 8) 
                        when (to_integer(i_Red8) - r_intensity) > 0  
                        else (others=>'0');

            o_Green8 <= to_unsigned((to_integer(i_Green8) - r_intensity) , 8) 
                        when (to_integer(i_Green8) - r_intensity) > 0  
                        else (others=>'0');

            o_Blue8  <= to_unsigned((to_integer(i_Blue8) - r_intensity) , 8) 
                        when (to_integer(i_Blue8) - r_intensity) > 0  
                        else (others=>'0');
            
            o_intensity <= to_unsigned(r_intensity, o_intensity'length);
    end RTL;