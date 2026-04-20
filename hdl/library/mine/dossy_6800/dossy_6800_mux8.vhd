----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	12/4/2025 
-- Design Name: 
-- Module Name:    	dossy_6800_mux8
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		8 bit wide mux with multiple inputs, lowest index has 
--							higher priority
-- TODO: 				bus muxes should probably surface combinatorial or 
--							inconsistent behaviour when there are multiple sources 
--							active
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
use dossy_6800.dossy_6800.all;

entity dossy_6800_mux8 is
	generic (
		DEFVAL	: std_logic_vector(7 downto 0) := (others => 'X');
		WIDTH		: positive
	);
	port (	
		SEL_i		: in	std_logic_vector(WIDTH-1 downto 0);
		D_i		: in	t_arr_mux8(WIDTH-1 downto 0);
		D_o		: out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of dossy_6800_mux8 is
	
begin

	p_mux:process(all)
	begin
		D_o <= DEFVAL;
		for i in WIDTH-1 downto 0 loop
			if SEL_i(I) = '1' then
				D_o <= D_i(I);
			end if;
		end loop;
	end process;	

end rtl;