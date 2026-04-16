----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	12/4/2025 
-- Design Name: 
-- Module Name:    	dossy_6800
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		Package file for dossy_6800_cpu
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
-- Licence: MIT - see file LICENCE.txt
----------------------------------------------------------------------------------


library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library dossy_6800;

package dossy_6800 is
	
	type t_arr_mux8 is array (natural range <>) of std_logic_vector(7 downto 0);

	constant CCIX_H	: natural := 5;
	constant CCIX_I	: natural := 4;
	constant CCIX_N	: natural := 3;
	constant CCIX_Z	: natural := 2;
	constant CCIX_V	: natural := 1;
	constant CCIX_C	: natural := 0;

	type t_inc_l_src	is (inc, abl, db);
	type t_inc_h_src	is (inc, abh);
	type t_inc_act		is (inc, dec, inc_page, hold);

	type t_cpu_state is (
		RESET,
		-- prep vector address
		GP58,
		-- load first vector address
		R57,
		-- load second vector address
		R58,
		-- TSL0 fetch
		TSL0,

		-- load X/Y register
		LDx_T1_D00,
		LDx_D01,

		-- store X/Y register
		STx_T1_D00,
		STx_D01,
		STx_D02,

		-- TSX
		TXS_T1_GP50,
		TXS_GP51,

		GP52,

		-- SWI / WAI
		SWAI_T1_GP50,
		SWAI_GP51,
		SWAI_GP52,
		SWAI_GP53,
		SWAI_GP54,
		SWAI_GP55,
		SWAI_GP56,
		SWAI_GP57,

		-- SWI / WAI
		RTI_T1_GP50,
		RTI_GP51, -- SKIPPING THIS FROM Fig.2F seems wrong
		RTI_GP52,
		RTI_R53,
		RTI_R54,
		RTI_R55,
		RTI_R56,
		RTI_R57,
		

		-- generic fetch and set Z?
		TSL0_D02,

		-- EXTENDED addressing
		T1_EXT0,
		EXT1,

		-- DIE
		DIEBAD,
		WAIT_INTER
		);

end package dossy_6800;

package body dossy_6800 is

end package body dossy_6800;

