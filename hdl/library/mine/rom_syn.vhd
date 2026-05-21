-- MIT License
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Dominic Beesley https://github.com/dominicbeesley
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
-- ----------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	24/4/2026
-- Design Name: 
-- Module Name:    	ROM_syn 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		Synthesizable clocked ROM
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
use IEEE.NUMERIC_STD.ALL;

use work.common.all;

entity ROM_syn is
	Generic (
		romfile					: string;
		size						: natural	:= 4096
	);
	port (
		CLK_I			: in		std_logic;
		CLKEN_I		: in		std_logic;
		A_I			: in		std_logic_vector(numbits(size)-1 downto 0);
		D_O			: out		std_logic_vector(7 downto 0)
	);
		
end ROM_syn;

architecture rtl of ROM_syn is

	type		romtype			is array(0 to size-1) of std_logic_vector(7 downto 0);
	signal	rom				: romtype;

	signal	r_A				: std_logic_vector(numbits(size)-1 downto 0);
begin

	p_init:process
		type char_file_t is file of character;
		file char_file : char_file_t;
		variable char_v : character;
		subtype byte_t is natural range 0 to 255;
		variable byte_v : byte_t;
		variable i : integer;
	begin
		i := 0;
		file_open(char_file, romfile );
		while not endfile(char_file) and i < size loop
			read(char_file, char_v);
			byte_v := character'pos(char_v);
			rom(i) <= std_logic_vector(to_unsigned(byte_v, 8));
			i := i + 1;
--			report "Char: " & " #" & integer'image(byte_v);
		end loop;
		file_close(char_file);
		
		wait;
	end process;
	
	D_o <= rom(to_integer(unsigned(r_A)));

	p_read:process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				r_A <= A_I;
			end if;
		end if;
	end process;

		
end rtl;

