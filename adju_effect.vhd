library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adju_effect is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        i_effect_btn:   in      STD_LOGIC;
        i_plus_btn  :   in      STD_LOGIC;
        i_minus_btn :   in      STD_LOGIC;
        i_Red8      :   in      unsigned(7 downto 0);
        i_Green8    :   in      unsigned(7 downto 0);
        i_Blue8     :   in      unsigned(7 downto 0);
        o_Red8      :   out     unsigned(7 downto 0);
        o_Green8    :   out     unsigned(7 downto 0);
        o_Blue8     :   out     unsigned(7 downto 0)
    );
end adju_effect;

architecture RTL of adju_effect is
    signal r_effect_btn   :     STD_LOGIC                   :='0';
    signal r_plus_btn     :     STD_LOGIC                   :='0';
    signal r_minus_btn    :     STD_LOGIC                   :='0';
    signal r_user_adju    :     integer range -100 to 100   :=0;
    
    begin

        process(i_clk50) is
            begin
                if rising_edge(i_clk50) then
                    r_effect_btn <= i_effect_btn;
                    r_plus_btn <= i_plus_btn;
                    r_minus_btn <= i_minus_btn;
                    if i_reset = '1' then
                        r_user_adju <= 0;
                    else

                        if i_effect_btn = '0' and r_effect_btn = '1' then
                            r_user_adju <= 0;

                        elsif i_plus_btn = '0' and r_plus_btn = '1' then
                            if r_user_adju < 100 then
                                r_user_adju <= r_user_adju + 10;
                            end if;

                        elsif i_minus_btn = '0' and r_minus_btn = '1' then
                            if r_user_adju > -100 then
                                r_user_adju <= r_user_adju - 10;
                            end if;

                        else
                            r_user_adju <= r_user_adju;
                        end if;
                    end if;
                end if;
            end process;

            o_Red8 <= to_unsigned( (to_integer(i_Red8) + r_user_adju)  ,  o_Red8'length) when (to_integer(i_Red8) + r_user_adju) < 256  
				else (others=>'1');
            o_Green8 <= to_unsigned( (to_integer(i_Green8) + r_user_adju)  ,  o_Green8'length) when (to_integer(i_Green8) + r_user_adju) < 256  else (others=>'1');
            o_Blue8 <= to_unsigned( (to_integer(i_Blue8) + r_user_adju)  ,  o_Blue8'length) when (to_integer(i_Blue8) + r_user_adju) < 256  else (others=>'1');

    end RTL;