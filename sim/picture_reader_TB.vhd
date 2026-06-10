library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity picture_reader_TB is
    generic (
        g_DATA_WIDTH    :   integer         :=8 --will be determined based on RGB color format, for example RGB24 has 24 data width
    );
    port (
        clk     :   in  std_logic;
        addrs   :   in  unsigned(18 downto 0);  -- 0..307199
        q       :   out std_logic_vector(g_DATA_WIDTH -1 downto 0)
    );
end entity;

architecture TB of picture_reader_TB is
    --------------------------------------------------------------------
    --Calculating the maximum number of hex digits based on data width
    --------------------------------------------------------------------
    --for example: 24 bits data width will be converted to 6 hex digits ( each hex digit is 4 bits)
    constant c_HEX_LIMIT    :   integer     :=g_DATA_WIDTH/4;

    -------------------------------------------------------------------------
    --A Decoder function to convert one hex digit to its equivalent integer.
    -------------------------------------------------------------------------
    function hex_digit_to_binary(c : character) return STD_LOGIC_VECTOR is
    begin
        case c is
            when '0' => return "0000";
            when '1' => return "0001";
            when '2' => return "0010";
            when '3' => return "0011";
            when '4' => return "0100";
            when '5' => return "0101";
            when '6' => return "0110";
            when '7' => return "0111";
            when '8' => return "1000";
            when '9' => return "1001";
            when 'A' | 'a' => return "1010";
            when 'B' | 'b' => return "1011";
            when 'C' | 'c' => return "1100";
            when 'D' | 'd' => return "1101";
            when 'E' | 'e' => return "1110";
            when 'F' | 'f' => return "1111";
            when others => return "0000";
        end case;
    end function;

    --------------------------------------------------------------------
    -- Convert hex string to STD_LOGIC_VECTOR(7 downto 0)
    --------------------------------------------------------------------
    function hex_2_STD_VECTOR(h : string) return std_logic_vector is
        variable v  : STD_LOGIC_VECTOR(g_DATA_WIDTH-1 DOWNTO 0) :=(OTHERS=>'0');
        type t_binary_array is array (1 to c_HEX_LIMIT) of STD_LOGIC_VECTOR(3 DOWNTO 0);
        variable bi  : t_binary_array;
    begin
        for i in 1 to c_HEX_LIMIT loop
            bi(i) := hex_digit_to_binary(h(i));
        end loop;

			if c_HEX_LIMIT = 6 then		
					v := bi(1) & bi(2) & bi(3) & bi(4) & bi(5) & bi(6);
			elsif c_HEX_LIMIT = 4 then	
					v := bi(1) & bi(2) & bi(3) & bi(4);
			elsif c_HEX_LIMIT = 3 then	
					v := bi(1) & bi(2) & bi(3);
			elsif c_HEX_LIMIT = 2 then	
					v := bi(1) & bi(2);
			end if;
			--v:= (digit(1) * (16**5)) +(digit(2) * (16**4)) + (digit(3) * (16**3)) +(digit(4) * (16**2)) + (digit(5) * (16**1)) + digit(6);
        --Convert Hex string to integer
        --for exmple for 3 hex string:
        --v  := (digit(1) * 16^1) + (digit(0) * 16*0)
        --for i in 1 to c_HEX_LIMIT-1 loop
        --    v:= v + (digit(i) * (16**i));
        --end loop;

        --convert integer to STD_LOGIC_VECTOR
        return v;
    end function;

 
    -- RAM type
    type RAM is array (0 to 307199) of std_logic_vector(g_DATA_WIDTH-1 downto 0);

    ------------------------------
    -- Function to load MIF file
    ------------------------------
    function load_mif(filename : string) return RAM is
        file f              : text open read_mode is filename;
        variable line       : line;
        variable mem        : RAM := (others => (others => '0'));
        variable addr       : integer;
        variable colon      : character;
        variable data_hex   : string(1 to c_HEX_LIMIT);
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

            mem(addr) := hex_2_STD_VECTOR(data_hex);
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
			    picture_rom <= load_mif("/home/ise/ISE/Projects/img_processing/my_picture_RGB24.mif");
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
