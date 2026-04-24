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
-- Create Date:    	28/12/2018
-- Design Name: 
-- Module Name:    	simulation file for the bus behaviour of a "real" 6800
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		
--
-- Dependencies: 	Uses the John Kent 6800 core
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------


-- CAVEATS:
-- TSC ignored!
-- HALT not tested 


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library dossy_6800;
use dossy_6800.dossy_6800.all;

ENTITY real_6800_tb IS
	GENERIC (
			-- these times are from datasheet for 68B00
			dly_addr  : time := 135 ns; 
			dly_dhold : time := 10 ns; -- this is minimum
			dly_tddw  : time := 160 ns;
			dly_tba	 : time := 100 ns;
			dly_tpcs	 : time := 110 ns
		);
	PORT (
		PHI1				: IN		STD_LOGIC;
		PHI2				: IN		STD_LOGIC;
		A					: OUT 		STD_LOGIC_VECTOR(15 downto 0);
		D					: INOUT 	STD_LOGIC_VECTOR(7 downto 0);
		nRESET			: IN		STD_LOGIC;
		TSC				: IN		STD_LOGIC;
		DBE				: IN		STD_LOGIC;
		nHALT				: IN		STD_LOGIC;
		nIRQ				: IN		STD_LOGIC;
		nNMI				: IN		STD_LOGIC;

		VMA				: OUT		STD_LOGIC;
		RnW				: OUT		STD_LOGIC;
		BA					: OUT		STD_LOGIC

		);
END real_6800_tb;

ARCHITECTURE Behavioral OF real_6800_tb IS

	SIGNAL	i_cpu_clk			: STD_LOGIC;

	SIGNAL  	i_RnW					: STD_LOGIC;
	SIGNAL	i_cpu_A				: STD_LOGIC_VECTOR(15 downto 0);

	SIGNAL	i_cpu_D_out			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL	i_cpu_D_out_hold	: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL	i_cpu_D_in			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL	i_RnW_hold			: STD_LOGIC;

	SIGNAL	i_RnW_dly			: STD_LOGIC;
	SIGNAL	i_A_dly				: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL	i_ba_dly				: STD_LOGIC;

	SIGNAL	i_irq					: STD_LOGIC;
	SIGNAL	i_nmi					: STD_LOGIC;
	SIGNAL	i_vma					: STD_LOGIC;
	SIGNAL	i_halt				: STD_LOGIC;

	SIGNAL	i_RESET				: STD_LOGIC;	
	SIGNAL	i_ba					: STD_LOGIC;
	SIGNAL	i_ba2					: STD_LOGIC; -- reclock on phi2 rise

	SIGNAL   i_dbe_ddw			: STD_LOGIC;
	SIGNAL	i_dbe_dh				: STD_LOGIC;

BEGIN



	i_irq <= not(nIRQ);

	i_nmi <= not(nNMI);

	i_reset <= not(nRESET);

	i_cpu_clk <= not PHI2;							

	i_RnW_dly <= transport i_RnW AFTER dly_addr;
	i_A_dly <= transport i_cpu_A AFTER dly_addr;
	i_ba_dly <= transport i_ba AFTER dly_addr;

	p_phi2_ba:process(PHI2, BA)
	begin
		if rising_edge(PHI2) then
			i_ba2 <= i_ba;
		end if;
	end process;

	BA <= transport i_ba2 after dly_Tba;				

	RnW <= i_RnW_dly when i_ba_dly = '0' else 'Z';
	A <= i_A_dly when i_ba_dly = '0' else (others => 'Z');

	VMA <= i_VMA;

	p_cpu_do:process(phi1)
	begin
		if falling_edge(phi1) then
			i_RnW_hold <= i_RnW;
			i_cpu_D_out_hold <= i_cpu_D_out;
		end if;
	end process;

	p_halt:process(PHI1)
	begin
		if falling_edge(PHI1) then
			i_halt <= not nHALT;
		end if;
	end process;

	p_hlt_stb:process(PHI1)
	begin
		if falling_edge(PHI1) then
			if nRESET = '1' and not(nHALT'stable(dly_tpcs)) then
				report "Setup violation on nHALT"
				severity warning;				
			end if;
		end if;
	end process;


	i_dbe_dh <= transport DBE after dly_dhold;
	i_dbe_ddw <= transport DBE after dly_tddw;

	D <= i_cpu_D_out_hold when i_RnW_hold = '0' and i_dbe_dh = '1' and i_dbe_ddw = '1' and BA = '0' else
		 (others => 'Z');

	i_cpu_D_in <= D;

	e_cpu: entity dossy_6800.dossy_6800_cpu port map (
		CLKEN_i		=> '1',
		CLK_i			=> i_cpu_clk,
		RST_i			=> i_RESET,
		HALT_i		=> i_halt,
		IRQ_i			=> i_irq,
		NMI_i			=> i_nmi,

		RnW_o			=> i_RnW,
		VMA_o			=> i_vma,
		BA_o			=> i_ba,
		A_o			=> i_cpu_A,
		D_o			=> i_cpu_D_out,
		D_i			=> i_cpu_D_in
		
	);

END Behavioral;
