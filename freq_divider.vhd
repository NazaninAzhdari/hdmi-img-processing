library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freq_divider is
    generic (
        g_HALF_PERIOD_CLK_CYCLES    :   integer     :=4 --how many clock cycles of input clock we have to put together 
                                                        --to get the half period of the desired clock
                                                        -- g_HALF_PERIOD_CLK_CYCLES = input frequency / (2 * output frequency)
    );
    port (
        i_clk   :   in      STD_LOGIC;
        o_clk   :   out     STD_LOGIC
    );
end freq_divider;

architecture RTL of freq_divider is
    signal r_counter    :   integer range 0 to g_HALF_PERIOD_CLK_CYCLES-1 :=0;
    signal r_clk        :   STD_LOGIC                                     :='0';
    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    if r_counter < g_HALF_PERIOD_CLK_CYCLES -1 then
                        r_counter <= r_counter + 1;
                    else
                        r_counter <= 0;
                        r_clk <= not r_clk;
                    end if;
                end if;
            end process;
        o_clk <= r_clk;

    end RTL;

    