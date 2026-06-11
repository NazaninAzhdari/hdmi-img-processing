library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce_filter is
    generic (
        g_DEBOUNCE_LIMIT    :   integer     :=4
    );
    port (
        i_clk       :   in      STD_LOGIC;
        i_bouncy    :   in      STD_LOGIC;
        o_debounced :   out     STD_LOGIC
    );
end debounce_filter;

architecture RTL of debounce_filter is
    signal r_debounced  :   STD_LOGIC                               :='0';
    signal r_counter    :   integer range 0 to g_DEBOUNCE_LIMIT-1   :=0;

    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    if i_bouncy /= r_debounced and r_counter < g_DEBOUNCE_LIMIT -1 then
                        r_counter <= r_counter + 1;
                    elsif r_counter = g_DEBOUNCE_LIMIT -1 then
                        r_counter <= 0;
                        r_debounced <= i_bouncy;
                    else
                        r_counter <= 0;
                    end if;
                end if;
            end process;
            o_debounced <= r_debounced;
    end RTL;