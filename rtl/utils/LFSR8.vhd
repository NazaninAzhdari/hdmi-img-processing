library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR8 is
    port (
        i_clk   :   in      STD_LOGIC;
        i_reset :   in      STD_LOGIC;
        o_LFSR  :   out     unsigned(7 downto 0)
    );
end LFSR8;

architecture RTL of LFSR8 is
    signal r_LFSR   :    unsigned(7 downto 0)     :=(others=>'0');
    signal r_xnor   :    STD_LOGIC                :='0';

    begin
        process(i_clk) is
            begin
                if rising_edge(i_clk) then
                    if i_reset = '1' then
                        r_lfsr <= (others=>'0');
                    else
                        r_lfsr <= r_lfsr(r_lfsr'left- 1 downto 0) & r_xnor;
                    end if;
                end if;
            end process;
            o_LFSR <= r_LFSR;
            r_xnor <= r_lfsr(7) xnor r_lfsr(5) xnor r_lfsr(4) xnor r_lfsr(3);
    end RTL;