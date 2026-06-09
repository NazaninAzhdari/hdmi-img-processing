library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_TV_noise is
    port (
        i_clk50     :   in      STD_LOGIC;
        i_RGB332    :   in      unsigned(7 downto 0);
        o_Pixel     :   out     unsigned(23 downto 0)
    );
end effect_TV_noise;

architecture RTL of effect_TV_noise is
    signal r_Red8     :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Green8   :   unsigned(7 downto 0)    :=(others=>'0');
    signal r_Blue8    :   unsigned(7 downto 0)    :=(others=>'0');

    signal w_LFSR     :   unsigned(7 downto 0)    :=(others=>'0');
    signal R_noise    :   unsigned(7 downto 0)    :=(others=>'0');
    signal G_noise    :   unsigned(7 downto 0)    :=(others=>'0');
    signal B_noise    :   unsigned(7 downto 0)    :=(others=>'0');

    begin
        ---------------------------------------------------
        --Converting a 8-bit RGB image to 24-bit RGB Scale
        ---------------------------------------------------
        r_Red8 <= to_unsigned((to_integer(i_RGB332(7 downto 5)) * 36), 8); 
        r_Green8 <= to_unsigned((to_integer(i_RGB332(4 downto 2)) * 36) , 8);
        r_Blue8 <= to_unsigned((to_integer(i_RGB332(1 downto 0)) * 85) , 8);

        -------------------
        -- Noise scaling
        -------------------
        R_noise <= shift_right(w_LFSR, 2); --Weak Red
        G_noise <= shift_right(w_LFSR, 1); --Medium Green
        B_noise <= w_LFSR;                 --Strong Blue 

        
        o_pixel(23 downto 16) <= to_unsigned((to_integer(r_Red8) + R_noise) , 8) when (to_integer(r_Red8) + R_noise) < 256 else 
                                (others=>'1') when (to_integer(r_Red8) + R_noise) >= 256 else
                                (others=>'0');

        o_pixel(15 downto 8)  <= to_unsigned((to_integer(r_Green8) + G_noise) , 8) when (to_integer(r_Green8) + G_noise) < 256 else 
                                (others=>'1') when (to_integer(r_Green8) + G_noise) >= 256 else
                                (others=>'0');

        o_pixel(7 downto 0)   <= to_unsigned((to_integer(r_Blue8) + B_noise) , 8) when (to_integer(r_Blue8) + B_noise) < 256 else 
                                (others=>'1') when (to_integer(r_Blue8) + B_noise) >= 256 else
                                (others=>'0');

        -----------------------------------
        --Generate Random Number by LFSR-8
        -----------------------------------
        gen_random_num: entity woek.LFSR8
        port map(
            i_clk   => i_clk50,
            i_reset => '0',
            o_LFSR  => w_LFSR
        );
    end RTL;