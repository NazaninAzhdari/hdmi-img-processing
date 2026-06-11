library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity img_processing_TB is
end img_processing_TB;

architecture RTL of img_processing_TB is
    --Constants
    constant c_HALF_CLK50_PERIOD    :   time                    := 10 ns;
    constant c_IMG_WIDTH            :   integer                 :=640;
    constant c_IMG_HEIGHT           :   integer                 :=480;
    constant c_IMG_SIZE             :   integer                 :=c_IMG_WIDTH * c_IMG_HEIGHT; --307200 pixels
    constant c_ADDR_BIT_WIDTH       :   integer                 :=19;
    constant c_DATA_WIDTH           :   integer                 :=24; --determined based on RGB color format, could be 8, 12, 16, 24

    --Input signals
    signal i_clk50_TB               :   std_logic               := '0';
    signal i_select_effect_TB       :   unsigned(4 downto 0)    := (others => '0');
    signal i_reset_TB               :   STD_LOGIC               :='0';

    --Wiring signals and constants
    signal w_clk25_TB               :   std_logic                                   := '0';
    signal w_x_TB                   :   unsigned(9 downto 0)                        := (others => '0');
    signal w_y_TB                   :   unsigned(9 downto 0)                        := (others => '0');
    signal w_DE_TB                  :   STD_LOGIC                                   :='0';
    signal r_rom_addr_TB            :   unsigned(c_ADDR_BIT_WIDTH -1 downto 0)      :=(others=>'0');   
	signal r_real_addr_int_TB       :   integer range 0 to c_IMG_SIZE-1             :=0;
    signal r_real_rom_addr_TB       :   unsigned(c_ADDR_BIT_WIDTH -1 downto 0)      :=(others=>'0');
    signal r_mirror_addr_int_TB     :   integer range 0 to c_IMG_SIZE-1             :=0;
    signal r_mirror_rom_addr_TB     :   unsigned(c_ADDR_BIT_WIDTH -1 downto 0)      :=(others=>'0');
    signal r_pixelize_addr_int_TB   :   integer range 0 to c_IMG_SIZE-1             :=0;
    signal r_pixelize_rom_addr_TB   :   unsigned(c_ADDR_BIT_WIDTH -1 downto 0)      :=(others=>'0');
    signal w_rom_video_TB           :   STD_LOGIC_VECTOR(c_DATA_WIDTH-1 downto 0)   := (others => '0');
    --signal w_rom_video888_TB        :   unsigned(23 downto 0)                       := (others => '0');

    --Output signal
    signal o_effected_pixel_TB      :   unsigned(23 downto 0)                       := (others => '0');

    begin
        --------------------------------
        --Generating 50Mhz Clock
        --------------------------------
        gen_Clk_50MHz: process
        begin
            i_clk50_TB <= '0';
            wait for c_HALF_CLK50_PERIOD;
            i_clk50_TB <= '1';
            wait for c_HALF_CLK50_PERIOD;
        end process;

        ----------------------------------
        --Dividing the frequency of clock
        ----------------------------------
        dividing_frequency: entity work.freq_divider
        generic map(
            g_HALF_PERIOD_CLK_CYCLES => 1
        )
        port map (
            i_clk => i_clk50_TB, --50MHz
            o_clk => w_clk25_TB  --25MHz
        );

        ----------------------
        --VGA synchronization
        ----------------------
        vga_sync: entity work.VGAsync
        port map(
            i_clk25 => w_clk25_TB,
            i_reset => i_reset_TB,
            o_X => w_X_TB,
            o_Y => w_Y_TB,
            o_DE => w_DE_TB,
            o_HS => open,
            o_VS => open
        );

        ---------------------------------------
        --Computing the address of the memory
        ---------------------------------------
        r_real_addr_int_TB <= to_integer(w_y_TB)* c_IMG_WIDTH + to_integer(w_x_TB);
        r_real_rom_addr_TB <= to_unsigned(r_real_addr_int_TB, r_real_rom_addr_TB'length);

        r_mirror_addr_int_TB <= to_integer(w_y_TB)* c_IMG_WIDTH + to_integer(639 - w_x_TB);
        r_mirror_rom_addr_TB <= to_unsigned(r_mirror_addr_int_TB, r_mirror_rom_addr_TB'length);

        r_pixelize_addr_int_TB <= to_integer(w_y_TB(w_y_TB'left downto 2) & "00")* c_IMG_WIDTH + to_integer(w_x_TB(w_x_TB'left downto 2) & "00");
        r_pixelize_rom_addr_TB <= to_unsigned(r_pixelize_addr_int_TB, r_pixelize_rom_addr_TB'length);

		r_rom_addr_TB <= r_mirror_rom_addr_TB when i_select_effect_TB = "00001" else
						r_pixelize_rom_addr_TB when i_select_effect_TB = "00010" else
						r_real_rom_addr_TB;

        ----------------------------
        --Read the Image From ROM
        ----------------------------
        read_the_mif_file: entity work.picture_reader_TB
		  generic map (
				g_DATA_WIDTH => c_DATA_WIDTH
			)
        port map(
            clk => i_clk50_TB,
            addrs => r_rom_addr_TB,
            q  => w_rom_video_TB
        );

        --my FPGA doesn't have enough BRAM, so i didn't able to store my picture with the RGB24 color format.
        --so i convert my picture to RGB8, i did store it into BRAM, and then i used the module below to convert RGB8 to RGB24
        --but for the purpose of simulation, i am going to use RGB24, since there is no limitation.
        --if you want to use RGB8, uncomment this module.
        ------------------------------------------
        --Convert RGB332 to RGB888
        ------------------------------------------
        --convert_RGB332_to_RGB888: entity work.RGB332_to_RGB888
        --port map(
        --    i_RGB332 => unsigned(w_rom_video_TB),
        --    o_RGB888 => w_rom_video888_TB
        --);

        ---------------------------
        --Apply Effect on Image 
        ---------------------------
        applying_effect: entity work.control_effects
        port map(
            i_clk50  => i_clk50_TB,
            i_select_effect => i_select_effect_TB,
            i_x => w_x_TB,
            i_y => w_y_TB,
            i_RGB888 => unsigned(w_rom_video_TB),
            o_pixel => o_effected_pixel_TB
        );

        ----------------------------------------------------------------------------------------
        --Reading the Picture into text file with the format of "R G B", for example: 130 34 78
        ----------------------------------------------------------------------------------------
        reading_into_text_file: process
            file write_file      : text;
            variable file_line   : line;
            variable pixel_count : integer := 0;
            
            alias pixel_r is o_effected_pixel_TB(23 downto 16);
            alias pixel_g is o_effected_pixel_TB(15 downto 8);
            alias pixel_b is o_effected_pixel_TB(7 downto 0);
        begin

            file_open(write_file, "image_26.txt", WRITE_MODE);
            
            i_select_effect_TB <= "11010";
            i_reset_TB <= '1';
            wait for 100 ns;
            i_reset_TB <= '0';

            while pixel_count < 307200 loop 
                wait until rising_edge(w_clk25_TB);

                if w_DE_TB = '1' then

                    write(file_line, to_integer(unsigned(pixel_r)));
                    write(file_line, string'(" "));
                    write(file_line, to_integer(unsigned(pixel_g)));
                    write(file_line, string'(" "));
                    write(file_line, to_integer(unsigned(pixel_b)));
                    
                    writeline(write_file, file_line);
            
                    pixel_count := pixel_count + 1;
                end if;
            end loop;

            file_close(write_file);
            report "Simulation Finished! All pixels saved to image_00.txt";
            wait; 
        end process;

    end RTL;
