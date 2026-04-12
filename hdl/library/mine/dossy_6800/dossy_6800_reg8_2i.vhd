----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	12/4/2025 
-- Design Name: 
-- Module Name:    	dossy_6800_reg8_2i
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		8 bit register with two write ports, first takes precedence
--							need to investigate whether there are undocumented instructions
--							that write both ports and have wired or/and results
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

entity dossy_6800_reg8_2i is
	port (	
		CLK_i:    	in  std_logic;
		WE_0_i:		in  std_logic;
		D_0_i:		in  std_logic_vector(7 downto 0);
		WE_1_i:		in  std_logic;
		D_1_i:		in  std_logic_vector(7 downto 0);
		D_o:			out std_logic_vector(7 downto 0)
		);
end;

architecture rtl of dossy_6800_reg8_2i is
	signal	r_reg8	: std_logic_vector(7 downto 0);
	
begin

	D_o <= r_reg8;

	p_wr:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			if WE_0_i = '1' then
				r_reg8 <= D_0_i;
			elsif WE_1_i = '1' then
				r_reg8 <= D_1_i;
			end if;
		end if;
	end process;

end rtl;