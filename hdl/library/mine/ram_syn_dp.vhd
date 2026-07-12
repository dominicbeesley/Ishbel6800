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
-- Module Name:    	RAM_SYN_dp
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		Synthesizable clocked RAM - dual port, same clock
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

entity RAM_syn_dp is
	generic (
		size		: integer := 1024
	);
	port (
		CLK_I			: in		std_logic;

		A_CLKEN_I	: in		std_logic;
		A_A_I			: in		std_logic_vector(numbits(size)-1 downto 0);
		A_D_I			: in		std_logic_vector(7 downto 0);
		A_D_O			: out		std_logic_vector(7 downto 0);
		A_WE_I		: in		std_logic;

		B_CLKEN_I	: in		std_logic;
		B_A_I			: in		std_logic_vector(numbits(size)-1 downto 0);
		B_D_I			: in		std_logic_vector(7 downto 0);
		B_D_O			: out		std_logic_vector(7 downto 0);
		B_WE_I		: in		std_logic			
	);
		
end RAM_syn_dp;

architecture rtl of RAM_syn_dp is

	type		ram_type	is array (0 to size - 1) of std_logic_vector(7 downto 0);	
	signal	ram		: ram_type;
begin



	p_A:process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if A_CLKEN_I = '1' and A_WE_I = '1' then
				ram(to_integer(unsigned(A_A_i))) <= A_D_i;
			end if;

			A_D_o <= ram(to_integer(unsigned(A_A_I)));
		end if;
	end process;

	p_B:process(CLK_I)
	begin
		if rising_edge(CLK_I) then
			if B_CLKEN_I = '1' and B_WE_I = '1' then
				ram(to_integer(unsigned(B_A_i))) <= B_D_i;
			end if;

			B_D_o <= ram(to_integer(unsigned(B_A_I)));
		end if;
	end process;

		
end rtl;

