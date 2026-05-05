
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
-- Project Name:		led8_N
-- Target Devices: 
-- Tool versions: 
-- Description: 		N sets of 7 segment LEDS (and dots)
-- Dependencies: 
--
-- Revision: 
-- Additional Comments: 
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led8_N is
	generic (
		SIZE		: natural := 4
	);
	port(
		RST_i		: in	std_logic;
		CLK_i		: in	std_logic;
		CLKEN_i	: in  std_logic;

		D_i		: in	std_logic_vector(4 * SIZE - 1 downto 0);
		DOT_i		: in  std_logic_vector(SIZE-1 downto 0);

		SEG_o		: out std_logic_vector(7 downto 0);
		SEL_o		: out std_logic_vector(SIZE-1 downto 0)
	);
end led8_N;

architecture rtl of led8_N is
	
	signal	r_sel	:	std_logic_vector(SIZE-1 downto 0) := (0 => '1', others => '0');

	signal	i_D_act : std_logic_vector(3 downto 0);
	signal	i_Dot_act : std_logic;

begin

	SEL_o	<= r_sel;

	p_sel:process(RST_i, CLK_i)
	begin
		if RST_i = '1' then
			r_sel	<= (0 => '1', others => '0');
		elsif rising_edge(CLK_i) then
			if CLKEN_i = '1' then
				r_sel <= r_sel(SIZE-2 downto 0) & r_sel(SIZE-1);
			end if;
		end if;		
	end process;

	p_mux:process(all)
	begin

		i_Dot_act <= '0';
		i_D_act <= x"A";
		for I in 0 to SIZE-1 loop
			if r_sel(I) = '1' then
				i_Dot_act <= DOT_i(I);
				i_D_act <= D_i(I*4 + 3 downto I*4);
			end if;
		end loop;
	end process;

	e_led8:entity work.led8
	port map (
		D_i		=> i_D_act,
		DOT_i		=> i_Dot_act,

		SEG_o		=> SEG_o
	);


end rtl;