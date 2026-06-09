library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_rom is
    port (
        i_clk50         :   in      STD_LOGIC;
        i_select_effect :   in      unsigned(4 downto 0);
        i_x             :   in      unsigned(9 downto 0);
        i_y             :   in      unsigned(9 downto 0);
		o_rom_video     :   out     STD_LOGIC_VECTOR(7 downto 0)
    );
end read_rom;

architecture RTL of read_rom is
    --Image specifications
    constant c_IMG_WIDTH        :   integer     :=640;
    constant c_IMG_HEIGHT       :   integer     :=480;
    constant c_IMG_SIZE         :   integer     :=c_IMG_WIDTH * c_IMG_HEIGHT; --307200 pixels
    constant c_ADDR_BIT_WIDTH   :   integer     :=19; --Number of bits required to represent pixels from 0 to 307200
    constant c_RGB_BIT_WIDTH    :   integer     :=8;
    

	 
    signal r_addr_int           :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_rom_addr           :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');   
	signal r_real_addr_int      :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_real_rom_addr      :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal r_mirror_addr_int    :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_mirror_rom_addr    :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');
    signal r_pixelize_addr_int  :   integer range 0 to c_IMG_SIZE-1                 :=0;
    signal r_pixelize_rom_addr  :   STD_LOGIC_VECTOR(c_ADDR_BIT_WIDTH -1 downto 0)  :=(others=>'0');

    begin

        -----------------------------------------
        --Computing the Address line of the ROM
        -----------------------------------------
        --Pixel Cordinate (x, y) |  ROM address
        --______________________________________
        --      (0, 0)           |      0
        --      (1, 0)           |      1
        --      (2, 0)           |      2
        --      . . . .          |      .
        --     (639, 0)          |      639
        --      (0, 1)           |      640
        --      (1, 1)           |      641
        --      (2, 1)           |      642
        --      . . .            |       .
        --     (639, 479)        |      307199

        r_real_addr_int <= to_integer(i_y)* c_IMG_WIDTH + to_integer(i_x);
        r_real_rom_addr <= STD_LOGIC_VECTOR(to_unsigned(r_real_addr_int, r_real_rom_addr'length));

        ----------------------------------------------------------
        --Computing the Address line of the ROM in Flipping Order
        ----------------------------------------------------------
        --Mirror Pixel Cordinate (x, y) |  ROM address
        --_______________________________________________
        --      (0, 0)                  |      639
        --      (1, 0)                  |      638
        --      (2, 0)                  |      637
        --      . . . .                 |      .
        --     (639, 0)                 |      0
        --      (0, 1)                  |      1279
        --      (1, 1)                  |      1278
        --      (2, 1)                  |      1277
        --      . . .                   |       .
        --      (639, 1)                |       640

        r_mirror_addr_int <= to_integer(i_y)* c_IMG_WIDTH + to_integer(639 - i_x);
        r_mirror_rom_addr <= STD_LOGIC_VECTOR(to_unsigned(r_mirror_addr_int, r_mirror_rom_addr'length));

        -----------------------------------------------------------------------
        --Manipulating the Address line of the ROM to get a Pixelize rendering
        -----------------------------------------------------------------------
        --Pixel Cordinate (x, y) |  ROM address
        --______________________________________
        --      (0, 0)           |      0
        --      (1, 0)           |      0
        --      (2, 0)           |      0
        --      (3, 0)           |      0
        --      (4, 0)           |      4
        --      (5, 0)           |      4
        --      (6, 0)           |      4
        --      (7, 0)           |      4
        --      . . . .          |      .
        --     (639, 0)          |      640
        --      (0, 1)           |      0
        --      (1, 1)           |      0
        --      (2, 1)           |      0
        --      (3, 1)           |      0
        --      (4, 1)           |      4
        --      (5, 1)           |      4
        --      (6, 1)           |      4
        --      (7, 1)           |      4
        --      . . .            |       .
        --     (639, 479)        |      307199

        r_pixelize_addr_int <= to_integer(i_y(i_y'left downto 2) & "00")* c_IMG_WIDTH + to_integer(i_x(i_x'left downto 2) & "00");
        r_pixelize_rom_addr <= STD_LOGIC_VECTOR(to_unsigned(r_pixelize_addr_int, r_pixelize_rom_addr'length));

		r_rom_addr <= r_mirror_rom_addr when i_select_effect = "10110" else
						r_pixelize_rom_addr when i_select_effect = "10111" else
						r_real_rom_addr;

        -----------------------
        --ROM Instantiation
        -----------------------
        rom_instantce: entity work.img_rom
        port map (
            address	=> r_rom_addr,
            clock => i_clk50,
            q => o_rom_video
        );

    end RTL;