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

end package dossy_6800;

package body dossy_6800 is

end package body dossy_6800;

