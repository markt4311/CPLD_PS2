--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RC2014_ps2interface is
	port(
	-- RC2014 standard bus slave
		A	: in std_logic_vector(15 downto 0);
		D	: inout std_logic_vector(7 downto 0) := (others => 'Z');
		
		n_M1 : in std_logic;
		n_Reset: in std_logic;
		Clock: in std_logic;
		n_Int: in std_logic;
		n_Mreq: in std_logic;
		n_Wr : in std_logic;
		n_Rd : in std_logic;
		n_Iorq : in std_logic;

		-- PS2 keyboard interface
		ps2clk	: in std_logic;
		ps2data	: in std_logic
	);
end RC2014_ps2interface;

architecture rtl of RC2014_ps2interface is

	signal Dout : std_logic_vector(7 downto 0);

	signal enableDout : std_logic := '0';
	
	signal ps2codenew : std_logic;
	signal ps2code: std_logic_vector(7 downto 0);
	
	signal matrix : std_logic_vector(63 downto 0);		--	8 x 8 key matrix
	
	signal ps2keypressed 		: std_logic;
	
	--declare debounce component for debouncing PS2 input signals
	--https://www.digikey.com/eewiki/pages/viewpage.action?pageId=28278929
  COMPONENT ps2_keyboard IS
    GENERIC(
		clk_freq              : INTEGER := 50_000_000; --system clock frequency in Hz
		debounce_counter_size : INTEGER := 8);         --set such that (2^size)/clk_freq = 5us (size = 8 for 50MHz)
    PORT(
      clk          : IN  STD_LOGIC;                     --system clock
		ps2_clk      : IN  STD_LOGIC;                     --clock signal from PS/2 keyboard
		ps2_data     : IN  STD_LOGIC;                     --data signal from PS/2 keyboard
		ps2_code_new : OUT STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
		ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --code received from PS/2
  END COMPONENT;

	begin
	
	ps2: ps2_keyboard
    GENERIC MAP(
		clk_freq => 10000000,
		debounce_counter_size => 8		--	8 is for 50MHz clock
		)
    PORT MAP(
		clk => Clock,
		ps2_clk => ps2clk,
		ps2_data => ps2data,
		ps2_code_new => ps2codenew,
		ps2_code => ps2code
		);
	
	enableDout <= not (n_Rd or n_Iorq or not n_M1 
					or A(7) or A(6) or A(5) or A(4) or A(3));
	
	process (enableDout, Dout) is
	begin
		if enableDout = '1' then
			D(7 downto 0) <= Dout(7 downto 0);
		else
			D(7 downto 0) <= (others => 'Z');
		end if;
	end process;
	
	-- ps2 keyboard interface
	-- http://vhdlguru.blogspot.com/2010/09/example-d-flip-flop-with-asynchronous.html
	process (Clock, ps2codenew, n_Reset, ps2code) is
	begin
		if n_Reset = '0' then
			ps2keypressed <= '1';
			matrix(63 downto 0) <= (others => '0');
		else
			if rising_edge(ps2codenew) then
			
				if ps2code = "11110000" then
					ps2keypressed <= '0';
				else
					ps2keypressed <= '1';
				end if;
				
					-- map the keyboard code to the switch matrix
					-- https://www.digikey.com/eewiki/pages/viewpage.action?pageId=28279002
					case ps2code is
						when x"45" =>  --0
							matrix(0) <= ps2keypressed;
                  when x"16" =>  --1
							matrix(1) <= ps2keypressed;
                  when x"1E" =>  --2
							matrix(2) <= ps2keypressed;
                  when x"26" =>  --3
							matrix(3) <= ps2keypressed;
                  when x"25" =>  --4
							matrix(4) <= ps2keypressed;
                  when x"2E" =>  --5
							matrix(5) <= ps2keypressed;
                  when x"36" =>  --6
							matrix(6) <= ps2keypressed;
                  when x"3D" =>  --7
							matrix(7) <= ps2keypressed;
                  when x"3E" =>  --8
							matrix(8) <= ps2keypressed;
                  when x"46" =>  --9
							matrix(9) <= ps2keypressed;
                  when x"52" =>  --'
							matrix(10) <= ps2keypressed;
                  when x"41" =>  --,
							matrix(11) <= ps2keypressed;
                  when x"4E" =>  ---
							matrix(12) <= ps2keypressed;
                  when x"49" =>  --.
							matrix(13) <= ps2keypressed;
                  when x"4A" =>  --/
							matrix(14) <= ps2keypressed;
                  when x"4C" =>  --;
							matrix(15) <= ps2keypressed;
                  when x"55" =>  --=
							matrix(16) <= ps2keypressed;
                  when x"54" =>  --[
							matrix(17) <= ps2keypressed;
                  when x"5D" =>  --\
							matrix(18) <= ps2keypressed;
                  when x"5B" =>  --]
							matrix(19) <= ps2keypressed;
                  when x"0E" =>  --`
							matrix(20) <= ps2keypressed;
						when x"1C" =>  --a
							matrix(21) <= ps2keypressed;
                  when x"32" =>  --b
							matrix(22) <= ps2keypressed;
                  when x"21" =>  --c
							matrix(23) <= ps2keypressed;
                  when x"23" =>  --d
							matrix(24) <= ps2keypressed;
                  when x"24" =>  --e
							matrix(25) <= ps2keypressed;
                  when x"2B" =>  --f
							matrix(26) <= ps2keypressed;
                  when x"34" =>  --g
							matrix(27) <= ps2keypressed;
                  when x"33" =>  --h
							matrix(28) <= ps2keypressed;
                  when x"43" =>  --i
							matrix(29) <= ps2keypressed;
                  when x"3B" =>  --j
							matrix(30) <= ps2keypressed;
                  when x"42" =>  --k
							matrix(31) <= ps2keypressed;
                  when x"4B" =>  --l
							matrix(32) <= ps2keypressed;
                  when x"3A" =>  --m
							matrix(33) <= ps2keypressed;
                  when x"31" =>  --n
							matrix(34) <= ps2keypressed;
                  when x"44" =>  --o
							matrix(35) <= ps2keypressed;
                  when x"4D" =>  --p
							matrix(36) <= ps2keypressed;
                  when x"15" =>  --q
							matrix(37) <= ps2keypressed;
                  when x"2D" =>  --r
							matrix(38) <= ps2keypressed;
                  when x"1B" =>  --s
							matrix(39) <= ps2keypressed;
                  when x"2C" =>  --t
							matrix(40) <= ps2keypressed;
                  when x"3C" =>  --u
							matrix(41) <= ps2keypressed;
                  when x"2A" =>  --v
							matrix(42) <= ps2keypressed;
                  when x"1D" =>  --w
							matrix(43) <= ps2keypressed;
                  when x"22" =>  --x
							matrix(44) <= ps2keypressed;
                  when x"35" =>  --y
							matrix(45) <= ps2keypressed;
                  when x"1A" =>  --z
							matrix(46) <= ps2keypressed;
						when x"29" =>  --space
							matrix(47) <= ps2keypressed;
						when x"66" =>  --backspace (BS control code)
							matrix(48) <= ps2keypressed;
						when x"0D" =>  --tab (HT control code)
							matrix(49) <= ps2keypressed;
						when x"5A" =>  --enter (CR control code)
							matrix(50) <= ps2keypressed;
						when x"76" =>  --escape (ESC control code)
							matrix(51) <= ps2keypressed;
							
						when x"58" =>                   --caps lock code
							matrix(52) <= ps2keypressed;
						when x"14" =>                   --code for the control keys
							matrix(53) <= ps2keypressed;
						when x"12" =>                   --left shift code
							matrix(54) <= ps2keypressed;
						when x"59" =>                   --right shift code
							matrix(55) <= ps2keypressed;
					 
						when others =>
							
					end case;
				
			end if;
		end if;
	end process;
	
	-- key matrix interface to processor as 8 addresses of 8 bits
	process (A, matrix) is
	begin
		case A(2 downto 0) is
		when "000" => 
				Dout(7 downto 0) <= matrix(7 downto 0);
		when "001" => 
				Dout(7 downto 0) <= matrix(15 downto 8);
		when "010" => 
				Dout(7 downto 0) <= matrix(23 downto 16);
		when "011" => 
				Dout(7 downto 0) <= matrix(31 downto 24);
		when "100" => 
				Dout(7 downto 0) <= matrix(39 downto 32);
		when "101" => 
				Dout(7 downto 0) <= matrix(47 downto 40);
		when "110" => 
				Dout(7 downto 0) <= matrix(55 downto 48);
		when "111" => 
				Dout(7 downto 0) <= matrix(63 downto 56);
		end case;
	end process;
end;