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
-- Create Date:    	4/4/2019
-- Design Name: 
-- Module Name:    	dip 40 blitter - mk2 product board
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		PoC blitter and 6502/6809/Z80/68008 cpu board with 2M RAM, 256k ROM
-- Dependencies: 
--
-- Revision: 
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.mk1board_types.all;

library work;
use work.common.all;


entity tr_halt is
	port(
		-- crystal osc 50Mhz - on WS board
		CLK_50M_i							: in		std_logic;
		EXT_nRESET_i						: in		std_logic;								-- WS button

		PHI0_o								: out		std_logic;
		PHI1_o								: out		std_logic;
		PHI2_o								: out		std_logic;
	
		CPU_VMA_i							: in		std_logic;
		CPU_BA_i								: in		std_logic;
		CPU_RnW_i							: in		std_logic;

		CPU_nRES_o							: out		std_logic;
		CPU_nHALT_o							: out    std_logic;

		CPU_D_io								: inout	std_logic_vector(7 downto 0)

	);
end tr_halt;

architecture rtl of tr_halt is

	constant DIV_50_1 : natural := (50/2)-1;

	signal	r_clkdiv_50_1				: unsigned(numbits(DIV_50_1) downto 0) := to_unsigned(DIV_50_1, numbits(DIV_50_1) + 1); -- 1 bit larger, overflow resets

	signal	r_phi							: std_logic_vector(2 downto 0) := (others => '0');

	signal	i_phi1						: std_logic;
	signal	i_phi2						: std_logic;

begin

	i_phi1 <= not (r_phi(2) or r_phi(1));
	i_phi2 <= r_phi(2) and r_phi(1);

	PHI0_o <= r_phi(0);
	PHI1_o <= i_phi1;
	PHI2_o <= i_phi2;

	p_clk_div:process(CLK_50M_i)
	begin
		if rising_edge(CLK_50M_i) then
			if r_clkdiv_50_1(r_clkdiv_50_1'high) = '1' then
				r_clkdiv_50_1 <= to_unsigned(DIV_50_1, r_clkdiv_50_1'length);
				r_phi(0) <= not r_phi(0);
			else
				r_clkdiv_50_1 <= r_clkdiv_50_1 - 1;
			end if;
			r_phi(r_phi'high downto 1) <= r_phi(r_phi'high-1 downto 0);
		end if;
	end process;


	b_res:block is
		signal r_res_ctr : unsigned(5 downto 0) := (others => '0');
	begin
		p_test_res:process(EXT_nRESET_i, i_phi1)
		begin
			if EXT_nRESET_i = '0' then
				r_res_ctr <= (others => '0');
			elsif falling_edge(i_phi1) then
				if r_res_ctr(r_res_ctr'high) = '0' then
					r_res_ctr <= r_res_ctr + 1;
				end if;
			end if;
		end process;
		CPU_nRES_o <= r_res_ctr(r_res_ctr'high);
	end block;


	b_halt:block is
		signal r_h_ctr : unsigned(5 downto 0);		
		signal r_waiting : std_logic;
	begin
		p_halt:process(CPU_nRES_o, i_phi2)
		begin
			if CPU_nRES_o = '0' then
				CPU_nHALT_o <= '0';			
				r_h_ctr <= (others => '0');
				r_waiting <= '0';
			elsif falling_edge(i_phi2) then
				CPU_nHALT_o <= '0';
				if CPU_BA_i = '1' then
					if r_h_ctr(r_h_ctr'high) = '1' and r_waiting = '0' then
						CPU_nHALT_o <= '1';
						r_h_ctr <= (others => '0');
						r_waiting <= '1';
					else
						r_h_ctr <= r_h_ctr + 1;
					end if;
				else
					r_waiting <= '0';
				end if;
			end if;
		end process;
	end block;


	CPU_D_io <= x"01" when CPU_RnW_i = '1' else (others => 'H');
end rtl;
