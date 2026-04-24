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
-- Module Name:    	RAM_SYN
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		Synthesizable clocked RAM
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

entity RAM_syn is
	generic (
		size		: integer := 1024
	);
	port (
		CLK_I			: in		std_logic;
		CLKEN_I		: in		std_logic;
		A_I			: in		std_logic_vector(numbits(size)-1 downto 0);
		D_I			: in		std_logic_vector(7 downto 0);
		D_O			: out		std_logic_vector(7 downto 0);
		WE_I			: in		std_logic			
	);
		
end RAM_syn;

architecture rtl of RAM_syn is

	type		ram_type	is array (0 to size - 1) of std_logic_vector(7 downto 0);	
	signal	ram		: ram_type;

	signal	r_A		: std_logic_vector(numbits(size)-1 downto 0);
begin

	D_o <= ram(to_integer(unsigned(r_A)));

	p_read:process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				r_A <= A_I;
			end if;
		end if;
	end process;

	p_write:process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' and WE_I = '1' then
				ram(to_integer(unsigned(A_i))) <= D_i;
			end if;
		end if;
	end process;	
		
end rtl;

