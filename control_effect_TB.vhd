library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity control_effect_TB is
end control_effect_TB;

architecture RTL of control_effect_TB is
    component control_effects
        port (
            i_clk50         : in  std_logic;
            i_select_effect : in  unsigned(4 downto 0);
            i_x             : in  unsigned(9 downto 0);
            i_y             : in  unsigned(9 downto 0);
            i_RGB332        : in  unsigned(7 downto 0);
            o_pixel         : out unsigned(23 downto 0)
        );
    end component;

    constant c_CLK50_PERIOD : time := 40 ns;

    signal i_clk50_TB         : std_logic := '0';
    signal r_clk25_TB         : std_logic := '0';
    signal i_select_effect_TB : unsigned(4 downto 0) := (others => '0');
    signal i_x_TB             : unsigned(9 downto 0) := (others => '0');
    signal i_y_TB             : unsigned(9 downto 0) := (others => '0');
    signal r_x_TB             : unsigned(9 downto 0) := (others => '0');
    signal r_y_TB             : unsigned(9 downto 0) := (others => '0');
    signal i_RGB332_TB        : unsigned(7 downto 0) := (others => '0');
    signal o_pixel_TB         : unsigned(23 downto 0) := (others => '0');

    type ram_type is array (0 to 307199) of std_logic_vector(7 downto 0);
    signal image_ram : ram_type;

    file effect_file : text;

    signal pixel_index : integer := 0;
    signal effect_index : unsigned(4 downto 0) := (others => '0');
    signal writing : boolean := false;

    impure function load_image return ram_type is
        variable mem : ram_type := (others => (others => '0'));
    begin
        for idx in mem'range loop
            mem(idx) := std_logic_vector(to_unsigned(idx mod 256, 8));
        end loop;
        return mem;
    end function;

    procedure open_mif_file(
        sel : in unsigned(4 downto 0);
        f   : inout text
    ) is
        variable fname    : string(1 to 12) := "effect00.mif";
        variable effect_n : integer := to_integer(sel);
        variable tens     : character := character'val(character'pos('0') + effect_n / 10);
        variable ones     : character := character'val(character'pos('0') + effect_n mod 10);
        variable L        : line;
    begin
        fname(7) := tens;
        fname(8) := ones;
        file_open(f, fname, write_mode);

        write(L, string'("WIDTH=24;")); writeline(f, L);
        write(L, string'("DEPTH=307200;")); writeline(f, L);
        write(L, string'("ADDRESS_RADIX=DEC;")); writeline(f, L);
        write(L, string'("DATA_RADIX=HEX;")); writeline(f, L);
        write(L, string'("CONTENT BEGIN")); writeline(f, L);
    end procedure;

    procedure write_pixel(
        f     : inout text;
        addr  : in integer;
        pixel : in unsigned(23 downto 0)
    ) is
        variable L : line;
    begin
        write(L, addr);
        write(L, string'(" : "));
        write(L, to_hstring(pixel));
        write(L, string'(";"));
        writeline(f, L);
    end procedure;

    procedure close_mif_file(
        f : inout text
    ) is
        variable L : line;
    begin
        write(L, string'("END;")); writeline(f, L);
        file_close(f);
    end procedure;

begin

    i_x_TB <= r_x_TB;
    i_y_TB <= r_y_TB;

    image_ram <= load_image;

    gen_Clk50: process
    begin
        i_clk50_TB <= '0';
        wait for c_CLK50_PERIOD / 2;
        i_clk50_TB <= '1';
        wait for c_CLK50_PERIOD / 2;
    end process;

    gen_Clk25: process(i_clk50_TB)
    begin
        if rising_edge(i_clk50_TB) then
            r_clk25_TB <= not r_clk25_TB;
        end if;
    end process;

    gen_x_y: process(i_clk25_TB)
    begin
        if rising_edge(i_clk25_TB) then
            if r_y_TB < 479 then
                if r_x_TB < 639 then
                    r_x_TB <= r_x_TB + 1;
                else
                    r_x_TB <= (others => '0');
                    r_y_TB <= r_y_TB + 1;
                end if;
            else
                r_x_TB <= (others => '0');
                r_y_TB <= (others => '0');
            end if;
        end if;
    end process;

    main_process: process(i_clk50_TB)
    begin
        if rising_edge(i_clk50_TB) then
            if writing = false then
                open_mif_file(effect_index, effect_file);
                writing <= true;
                pixel_index <= 0;
            end if;

            i_RGB332_TB <= unsigned(image_ram(pixel_index));
            write_pixel(effect_file, pixel_index, o_pixel_TB);

            if pixel_index = 307199 then
                close_mif_file(effect_file);
                writing <= false;
                if effect_index = "11111" then
                    assert false report "Finished all effects" severity failure;
                else
                    effect_index <= effect_index + 1;
                    i_select_effect_TB <= effect_index + 1;
                end if;
                pixel_index <= 0;
            else
                pixel_index <= pixel_index + 1;
            end if;
        end if;
    end process;

    UUT: control_effects
        port map (
            i_clk50 => i_clk50_TB,
            i_select_effect => i_select_effect_TB,
            i_x => i_x_TB,
            i_y => i_y_TB,
            i_RGB332 => i_RGB332_TB,
            o_pixel => o_pixel_TB
        );

end RTL;
