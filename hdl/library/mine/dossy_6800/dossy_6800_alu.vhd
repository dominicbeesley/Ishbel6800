----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	17/4/2025 
-- Design Name: 
-- Module Name:    	dossy_6800_alu
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		ALU
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
use IEEE.STD_LOGIC_MISC.ALL;

library dossy_6800;
use dossy_6800.dossy_6800.all;

entity dossy_6800_alu is
	port (	
		CLK_i		: in	std_logic;

		OP_i		: in	t_alu_op;
		C_i		: in	std_logic;
		H_i		: in  std_logic;
		V_i		: in  std_logic;
		A_i		: in	std_logic_vector(7 downto 0);
		B_i		: in	std_logic_vector(7 downto 0);

		C_o		: out	std_logic;
		H_o		: out	std_logic;
		N_o		: out	std_logic;
		V_o		: out	std_logic;
		Z_o		: out	std_logic;
		SUM_o		: out	std_logic_vector(7 downto 0)
	);
end;

architecture rtl of dossy_6800_alu is
begin



	p_ALU:process(all)

		procedure adc_nyb(
			C_i : in	std_logic;
			A_i : in	std_logic_vector(3 downto 0);
			B_I : in	std_logic_vector(3 downto 0);
			
			C_o : out std_logic;
			R_o : out std_logic_vector(3 downto 0)
		) is
		variable v_C : unsigned(4 downto 0);
		variable v_R : unsigned(4 downto 0);
		begin
			v_C := (0 => C_i, others => '0');
			v_R := ("0" & unsigned(B_i)) +
					 ("0" & unsigned(A_i)) +
					 v_C;
			C_o := v_R(4);
			R_o := std_logic_vector(v_R(3 downto 0));
		end procedure;

		procedure sbc_nyb(
			C_i : in	std_logic;
			A_i : in	std_logic_vector(3 downto 0);
			B_I : in	std_logic_vector(3 downto 0);
			
			C_o : out std_logic;
			R_o : out std_logic_vector(3 downto 0)
		) is
		variable v_C : unsigned(4 downto 0);
		variable v_R : unsigned(4 downto 0);
		begin
			v_C := (0 => C_i, others => '0');
			v_R := ("0" & unsigned(B_i)) -
					 (("0" & unsigned(A_i)) +
					 v_C);
			C_o := v_R(4);
			R_o := std_logic_vector(v_R(3 downto 0));
		end procedure;

		procedure adc_8(
			C_i : in std_logic;
			A_i : in std_logic_vector(7 downto 0);
			B_I : in std_logic_vector(7 downto 0);
			
			C_o : out std_logic;
			H_o : out std_logic;
			V_o : out std_logic;
			R_o : out std_logic_vector(7 downto 0)
		) is
		variable v_Rl	: std_logic_vector(3 downto 0);
		variable v_H	: std_logic;
		variable v_Rh	: std_logic_vector(3 downto 0);
		variable v_C	: std_logic;
		begin
			adc_nyb(C_i, A_i(3 downto 0), B_i(3 downto 0), v_H, v_Rl);
			adc_nyb(v_H, A_i(7 downto 4), B_i(7 downto 4), v_C, v_Rh);
			
			C_o := v_C;
			H_o := v_H;
			R_o := v_Rh & v_Rl;
			v_o := (A_i(7) xor v_Rh(3)) and (B_i(7) xor v_Rh(3));

		end procedure;

		procedure sbc_8(
			C_i : in std_logic;
			A_i : in std_logic_vector(7 downto 0);
			B_I : in std_logic_vector(7 downto 0);
			
			C_o : out std_logic;
			V_o : out std_logic;
			R_o : out std_logic_vector(7 downto 0)
		) is
		variable v_Rl	: std_logic_vector(3 downto 0);
		variable v_H	: std_logic;
		variable v_Rh	: std_logic_vector(3 downto 0);
		variable v_C	: std_logic;
		begin
			sbc_nyb(C_i, A_i(3 downto 0), B_i(3 downto 0), v_H, v_Rl);
			sbc_nyb(v_H, A_i(7 downto 4), B_i(7 downto 4), v_C, v_Rh);
			
			C_o := v_C;
			R_o := v_Rh & v_Rl;
			v_o := (not(A_i(7)) xor v_Rh(3)) and (B_i(7) xor v_Rh(3));

		end procedure;


	variable v_C_i_masked 	: std_logic;
	variable v_C_o				: std_logic;
	variable v_H_o				: std_logic;
	variable v_V_o				: std_logic;
	variable v_N_o				: std_logic;
	variable v_Z_o				: std_logic;
	variable v_SUM_o			: std_logic_vector(7 downto 0);
	begin

		v_C_i_masked  := C_i when OP_i = alu_adc or OP_i = alu_sbc else
							'0';
		v_V_o := V_i;
		v_C_o := C_i;
		v_H_o	:= H_i;

		case OP_i is
			when alu_add | alu_adc =>
				adc_8(v_C_i_masked, A_i, B_i, v_C_o, v_H_o, v_V_o, v_SUM_o);
			when alu_sub | alu_sbc =>
				sbc_8(v_C_i_masked, A_i, B_i, v_C_o, v_V_o, v_SUM_o); -- ignore H?
			when alu_or =>
				v_V_o := '0';
				v_SUM_o := A_i or B_i;
			when alu_eor =>
				v_V_o := '0';
				v_SUM_o := A_i xor B_i;
			when others => -- AND
				-- AND is default
				v_V_o := '0';
				v_SUM_o := B_i and A_i;
		end case;
		v_N_o := v_SUM_o(7);
		v_Z_o := not or_reduce(v_SUM_o);


		if rising_edge(CLK_i) then
			SUM_o <= v_SUM_o;

			C_o	<= v_C_o;
			H_o	<= v_H_o;
			V_o	<= v_V_o;
			N_o	<= v_N_o;
			Z_o   <= v_Z_o;
		end if;
	end process;


end rtl;