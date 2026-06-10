library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity picture_reader_TB is
    port (
        clk     :   in  std_logic;
        addrs   :   in  unsigned(18 downto 0);  -- 0..307199
        q       :   out std_logic_vector(7 downto 0)
    );
end entity;

architecture TB of picture_reader_TB is

    -------------------------------------------------------------------------
    --A Decoder function to convert one hex digit to its equivalent integer.
    -------------------------------------------------------------------------
    function hex_digit_to_int(c : character) return integer is
    begin
        case c is
            when '0' => return 0;
            when '1' => return 1;
            when '2' => return 2;
            when '3' => return 3;
            when '4' => return 4;
            when '5' => return 5;
            when '6' => return 6;
            when '7' => return 7;
            when '8' => return 8;
            when '9' => return 9;
            when 'A' | 'a' => return 10;
            when 'B' | 'b' => return 11;
            when 'C' | 'c' => return 12;
            when 'D' | 'd' => return 13;
            when 'E' | 'e' => return 14;
            when 'F' | 'f' => return 15;
            when others => return 0;
        end case;
    end function;

    --------------------------------------------------------------------
    -- Convert 2‑digit hex string to STD_LOGIC_VECTOR(7 downto 0)
    --------------------------------------------------------------------
    function hex2slv(h : string) return std_logic_vector is
        variable v              : integer := 0;
        variable d1, d2         : integer;
    begin
        --for RGB8 we have two hex
        --assign two corrospond digits
        d1 := hex_digit_to_int(h(1));
        d2 := hex_digit_to_int(h(2));

        v  := d1 * 16 + d2;
        return std_logic_vector(to_unsigned(v, 8));
    end function;


    -- RAM type
    type RAM is array (0 to 307199) of std_logic_vector(7 downto 0);

    ------------------------------
    -- Function to load MIF file
    ------------------------------
    function load_mif(filename : string) return RAM is
        file f              : text open read_mode is filename;
        variable line       : line;
        variable mem        : RAM := (others => (others => '0'));
        variable addr       : integer;
        variable colon      : character;
        variable data_hex   : string(1 to 2);
        variable semicolon  : character;
        variable space      : character;
    begin
        -- DEBUG: Check if file opened
        assert false report "Opening MIF file..." severity note;

        --------------------------------------------------------------------
        -- Skip until "CONTENT BEGIN"
        --------------------------------------------------------------------
        while not endfile(f) loop
            readline(f, line);
            if line'length >= 12 then
                if line(1 to 13) = "CONTENT BEGIN" then
                    -- DEBUG: Check if file reach the CONTENT Begin part
                    assert false report "reach the CONTENT BEGIN part." severity note;
                    exit;
                end if;
            end if;
        end loop;
            
        -----------------------------------
        -- Read: <addrress> : <hex-data>;
        -----------------------------------
        while not endfile(f) loop
            readline(f, line);

            -- Stop at END;
            if line'length >= 3 then
                if line(1 to 3) = "END" then
                    exit;
                end if;
            end if;

            -- Parse: 123 : 6C;
            read(line, addr);
            read(line, space);
            read(line, colon);
            read(line, space);
            read(line, data_hex);
            read(line, semicolon);

            mem(addr) := hex2slv(data_hex);
        end loop;

        return mem;
    end function;

    ----------------------
    --ROM signal
    ----------------------
    signal picture_rom      : RAM   := (others => (others => '0'));
    

    begin
	 
        ---------------------------
        --Initializing the rom
        ---------------------------
	    initialization_ROM : process
		    begin
			    picture_rom <= load_mif("/home/ise/ISE/Projects/img_processing/my_picture.mif");
			    wait;
		    end process;

        --------------------------------------
        -- Synchronous read from rom
        --------------------------------------
        process(clk)
            begin
                if rising_edge(clk) then
                    q <= picture_rom(to_integer(addrs));
                end if;
            end process;

    end TB;
