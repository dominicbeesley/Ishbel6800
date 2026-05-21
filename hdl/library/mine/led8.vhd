
-- MIT License
-- -----------------------------------------------------------------------------
-- Copyright (c) 2022 Dominic Beesley https://github.com/dominicbeesley
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- -----------------------------------------------------------------------------


-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	5/5/2026
-- Design Name: 
-- Module Name:    	
-- Project Name:		led8
-- Target Devices: 
-- Tool versions: 
-- Description: 		Combinatorial 7 segment + dot driver, hex symbols
-- Dependencies: 
--
-- Revision: 
-- Additional Comments: 
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led8 is
	port(
		D_i		: in	std_logic_vector(3 downto 0);
		DOT_i		: in  std_logic;

		SEG_o		: out std_logic_vector(7 downto 0)
	);
end led8;

architecture rtl of led8 is

begin

	process(all)
	begin
		case to_integer(unsigned(D_i)) is
			when 16#0# => SEG_o(6 downto 0) <= not("1111110");
			when 16#1# => SEG_o(6 downto 0) <= not("0110000");
			when 16#2# => SEG_o(6 downto 0) <= not("1101101");
			when 16#3# => SEG_o(6 downto 0) <= not("1111001");
			when 16#4# => SEG_o(6 downto 0) <= not("0110011");
			when 16#5# => SEG_o(6 downto 0) <= not("1011011");
			when 16#6# => SEG_o(6 downto 0) <= not("1011111");
			when 16#7# => SEG_o(6 downto 0) <= not("1110000");
			when 16#8# => SEG_o(6 downto 0) <= not("1111111");
			when 16#9# => SEG_o(6 downto 0) <= not("1111011");
			when 16#A# => SEG_o(6 downto 0) <= not("1110111");
			when 16#B# => SEG_o(6 downto 0) <= not("0011111");
			when 16#C# => SEG_o(6 downto 0) <= not("1001110");
			when 16#D# => SEG_o(6 downto 0) <= not("0111101");
			when 16#E# => SEG_o(6 downto 0) <= not("1001111");
			when 16#F# => SEG_o(6 downto 0) <= not("1000111");
			when others => SEG_o(6 downto 0) <= "0100010";
		end case;
	end process;

	SEG_o(7) <= not DOT_i;

end rtl;