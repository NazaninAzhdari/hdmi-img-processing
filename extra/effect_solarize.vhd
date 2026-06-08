library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_solarize is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_effect_En :   in      STD_LOGIC;
        i_plus_btn  :   in      STD_LOGIC;
        i_minus_btn :   in      STD_LOGIC;
        i_RGB332    :   in      unsigned(7 downto 0);
        o_intensity :   out     unsigned(6 downto 0);
        o_Red8      :   out     unsigned(7 downto 0);
        o_Green8    :   out     unsigned(7 downto 0);
        o_Blue8     :   out     unsigned(7 downto 0)
    );
end effect_solarize;

architecture RTL of effect_solarize is
    signal r_intensity :       integer range 0 to 256       :=128;
    signal r_plus_btn  :       STD_LOGIC                    :='0';
    signal r_minus_btn :       STD_LOGIC                    :='0';

    begin
        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    if i_reset = '1' then
                        r_intensity <= 128;
                    else
                        if i_effect_En = '1' then

                            if i_plus_btn = '0' and r_plus_btn = '1' then --falling-edge of plus button
                                if r_intensity < 256 then
                                    r_intensity <= r_intensity + 16;
                                end if;
                            elsif i_minus_btn = '0' and r_minus_btn = '1' then --falling-edge of minus button
                                if r_intensity > 0 then
                                    r_intensity <= r_intensity - 16;
                                end if;
                            end if;

                        else
                            r_intensity <= 128;
                        end if; --if i_effect_En = '1' or else

                    end if; --if i_reset = '1' or else
                end if; --if rising_edge
            end process;
            
            ---------------------
            --Control saturation
            ---------------------
            o_Red8   <= not (i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6)) 
                        when (to_integer(i_RGB332) > r_intensity) 
                        else (i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6));

            o_Green8 <= not (i_RGB332(4 downto 2) & i_RGB332(4 downto 2) & i_RGB332(4 downto 2)) 
                        when (to_integer(i_RGB332) > r_intensity) 
                        else (i_RGB332(7 downto 5) & i_RGB332(7 downto 5) & i_RGB332(7 downto 6));

            o_Blue8  <= not (i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0)) 
                        when (to_integer(i_RGB332) > r_intensity) 
                        else (i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0) & i_RGB332(1 downto 0));
            --i_RGB332 can be a number between 0 to 255 
            --r_intensity can be a number between 0 to 256      
            
            o_intensity <= to_unsigned(r_intensity, o_intensity'length);


    end RTL;