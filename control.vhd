----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:32:15 11/25/2015 
-- Design Name: 
-- Module Name:    control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is
Port(
	clock : in std_logic;
	reset : in std_logic:='0';
	output: out std_logic_vector (7 downto 0)
);
end;

architecture Behavioral of control is
component bram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

	type state_type is (start, initialize, s0, load1, load2, load3, store1, store2, store3, store4, move1, move2, add1, add2, add3, add4, add5, mul1, mul2, jump1, bne1, bne2, bne3, out1, out2, out3, stop);
	signal state : state_type := start;
	
	type register_array is array (15 downto 0) of std_logic_vector(7 downto 0);
	signal reg : register_array;
	signal temp : std_logic_vector (7 downto 0);
	--signal temp1 : std_logic_vector (7 downto 0);
	--signal temp2 : std_logic_vector (7 downto 0);
	
	signal i1: integer:=0;
	signal i2: integer:=0;
	--signal i3: integer:=0;
	
	--signal sgn1: signed (5 downto 0);
	
	signal PC : std_logic_vector(7 downto 0):="00000000";
	signal IR : std_logic_vector(15 downto 0);

	--signal done : std_logic:='1';

	signal address : std_logic_vector (3 downto 0);
	--signal w : std_logic;
	--signal data_in, data_out : std_logic_vector(7 downto 0);

	signal wea : std_logic_vector (0 downto 0):="0";
	signal addra : std_logic_vector(7 downto 0):="11111111";
	signal dina : std_logic_vector(15 downto 0);
	signal douta : std_logic_vector(15 downto 0);

	--signal load : std_logic;

begin

ram: bram port map(clock, wea, addra, dina, douta);

process(clock)
begin
	if clock = '1' and clock'event then
		--if reset = '1' then
		--	state <= start;
		--else
			case state is
				when start => state <= initialize;
				when initialize => state <= s0;			
				when s0 => 
					if IR(15 downto 13) = "000" then
						state <= load1;
					elsif IR(15 downto 13) = "001" then
						state <= store1;
					elsif IR(15 downto 13) = "010" then
						state <= move1;
					elsif IR(15 downto 13) = "011" then
						state <= add1;
					elsif IR(15 downto 13) = "100" then
						state <= mul1;
					elsif IR(15 downto 13) = "101" then
						state <= jump1;
					elsif IR(15 downto 13) = "110" then
						state <= bne1;
					elsif IR(15 downto 13) = "111" then
						state <= stop;
					else
						state <= start;
					end if;
				when load1 => state <= load2;
				when load2 => state <= load3;
				when load3 => state <= out1;
				when store1 => state <= store2;
				when store2 => state <= store3;
				when store3 => state <= store4;
				when store4 => state <= out1;
				when move1 => state <= move2;
				when move2 => state <= out1;
				when add1 => state <= add2;
				when add2 => state <= add3;
				when add3 => state <= out1;
				when mul1 => state <= mul2;
				when mul2 => state <= out1;
				when jump1 => state <= out1;
				when bne1 => state <= bne2;
				when bne2 => state <= out1;
				when out1 => state <= out2;
				when out2 => state <= out3;
				when out3 => state <= s0;
				when stop => state <= stop;
				when others => null;
			end case;
		--end if;
	end if;
end process;
 
process (state)
begin
	case state is
------------------------------------------------------------------------
		when start =>
			PC <= "00000000";
			addra <= "00000000";
			wea <= "0";
		when initialize =>
			null;
		when s0 =>
			wea <= "0";
			--IR <= douta;
			addra <= PC + 1;
			IR <= douta;
			PC <= PC + 1;
------------------------------------------------------------------------			
		when load1 =>
			addra <= reg(conv_integer(IR(8 downto 5)));
			address <= IR(12 downto 9);
		when load2 =>
			addra <= PC;
		when load3 =>
			reg(conv_integer(address)) <= douta (7 downto 0);
			--addra <= PC;
------------------------------------------------------------------------
		when store1 =>
			address <= IR(12 downto 9);
		when store2 =>
			temp <= reg(conv_integer(address));
		when store3 =>
			address <= IR(8 downto 5);
		when store4 =>
			addra <= temp;
			dina (7 downto 0) <= reg(conv_integer(address));
			dina (15 downto 8) <= "00000000";
			wea <= "1";
------------------------------------------------------------------------
		when move1 =>
			address <= IR(12 downto 9);
		when move2 =>
			reg(conv_integer(address)) <= IR(8 downto 1);
------------------------------------------------------------------------
		when mul1 => --doubt in multiplication
			i1 <= conv_integer(reg(conv_integer(IR(8 downto 5))));
			i2 <= conv_integer(reg(conv_integer(IR(4 downto 1))));
			address <= IR(12 downto 9);
		when mul2 =>
			reg(conv_integer(address)) <= std_logic_vector(to_unsigned(i1*i2,8));
------------------------------------------------------------------------
		when add1 =>
			i1 <= conv_integer(reg(conv_integer(IR(8 downto 5))));
			i2 <= conv_integer(reg(conv_integer(IR(4 downto 1))));
			address <= IR(12 downto 9);
			--i1 <= to_integer(unsigned(temp1));
		when add2 =>
			temp <= std_logic_vector(to_unsigned(i1+i2,8));
		when add3 =>
			reg(conv_integer(address)) <= temp;
------------------------------------------------------------------------
		when jump1 =>
			PC <= IR(12 downto 5) - 1;
			addra <= IR(12 downto 5) - 1;
------------------------------------------------------------------------
		when bne1 =>
			if reg(conv_integer(IR(12 downto 9))) = reg(conv_integer(IR(8 downto 5))) then
				--PC <= PC;
				temp <= "00000001";
			else
				if IR(4) = '0' then
					temp(3 downto 0) <= IR(3 downto 0);
					temp(7 downto 4) <= "0000";
				else
					temp(3 downto 0) <= (IR(3 downto 0) xor "1111") + 1;
					temp(7 downto 4) <= "0000";					
				end if;
			end if;
		when bne2 => 
			if reg(conv_integer(IR(12 downto 9))) = reg(conv_integer(IR(8 downto 5))) then
				PC <= PC + temp - 1;
				addra <= PC + temp -1;
			else
				if IR(4) = '0' then
					PC <= PC + temp - 1;
					addra <= PC + temp -1;
				else
					PC <= PC - temp - 1;
					addra <= PC - temp -1;
				end if;
			end if;
------------------------------------------------------------------------
		when out1 =>
			addra <= "11111111";
			--output <= douta (7 downto 0);
			--addra <= PC;
		when out2 =>
			--output <= douta (7 downto 0);
			addra <= PC;
		when out3 =>
			output <= douta (7 downto 0);
		when others => null;
		end case;
end process;

end Behavioral;

