library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGAsync is
    port (
        i_clk25     :   in      STD_LOGIC;
        i_reset     :   in      STD_LOGIC;
        o_X         :   out     unsigned(9 downto 0); --10-bits is needed to represent the pixel numbers from 0 to 799
        o_Y         :   out     unsigned(9 downto 0); --10-bits is needed to represent the pixel numbers from 0 to 521
        o_DE        :   out     STD_LOGIC;            --Data Enable signal
        o_HS        :   out     STD_LOGIC;            --Herizontal Sync signal
        o_VS        :   out     STD_LOGIC             --Vertical Sync signal
    );
end VGAsync;

architecture RTL of VGAsync is
    --------------------------
    --640*480  @ 60Hz timing
    --------------------------
    --Herizontal sync constants
    constant c_H_ACTIVE   :   integer     :=640;
    constant c_H_FP       :   integer     :=16;
    constant c_H_PULSE    :   integer     :=96;
    constant c_H_BP       :   integer     :=48;
    constant c_H_TOTAL    :   integer     :=c_H_ACTIVE + c_H_FP + c_H_PULSE + c_H_BP; --800 pixels
    --Vertical sync constants
    constant c_V_ACTIVE   :   integer     :=480;
    constant c_V_FP       :   integer     :=10;
    constant c_V_PULSE    :   integer     :=2;
    constant c_V_BP       :   integer     :=33;
    constant c_V_TOTAL    :   integer     :=c_V_ACTIVE + c_V_FP + c_V_PULSE + c_V_BP; --525 pixels

    --Counter signals to determine the pixel
    signal r_x    :   integer range 0 to c_H_TOTAL-1    :=0;
    signal r_y    :   integer range 0 to c_V_TOTAL-1    :=0;

    begin
        process(i_clk25) is
            begin
                if rising_edge(i_clk25) then
                    if i_reset = '1' then
                        r_x <= '0';
                        r_y <= '0';
                    else
                        if r_y < c_V_TOTAL -1 then
                            if r_x < c_H_TOTAL -1 then
                                r_x <= r_x + 1;
                            else
                                r_x <= 0;
                                r_y <= r_y + 1;
                            end if;
                        else
                            r_y <= 0;
                        end if;
                    end if;
                end if;
            end process;

            o_DE <= '1' when (r_x <= c_H_ACTIVE -1) and (r_y <= c_V_ACTIVE -1) else '0';
            o_HS <= '0' when (r_x >= c_H_ACTIVE + c_H_FP) and (r_x < c_H_TOTAL - c_H_BP) else '1';
            o_VS <= '0' when (r_y >= c_V_ACTIVE + c_V_FP) and (r_y < c_V_TOTAL - c_V_BP) else '1';
            o_X <= to_unsigned(r_x, o_x'length);
            o_Y <= to_unsigned(r_y, o_y'length);
    end RTL;