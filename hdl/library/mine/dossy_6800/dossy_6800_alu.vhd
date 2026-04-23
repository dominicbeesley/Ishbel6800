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
	
		-- TODO make this a regular ADD but jam this stuff onto DB
		procedure daa(
			C_i : in std_logic;
			H_i : in std_logic;
			B_i : in std_logic_vector(7 downto 0);

			C_o : out std_logic;
			V_o : out std_logic;
			R_o : out std_logic_vector(7 downto 0)
			) is
		variable lngt9 : boolean;
		variable corr  : std_logic_vector(7 downto 0) := (others => '0');
		variable C_t	: std_logic;
		variable H_t	: std_logic;
		begin
				lngt9 := unsigned(B_i(3 downto 0)) > 9;

				if H_i = '1' or lngt9 then
					corr(3 downto 0) := x"6";
				end if;

				if C_i = '1' or unsigned(B_i(7 downto 4)) > 9 or 
						(lngt9 and unsigned(B_i(7 downto 4)) > 8) then
					corr(7 downto 4) := x"6";
				end if;

				adc_8('0', corr, B_i, C_t, H_t, V_o, R_o);

				C_o := C_t or C_i;
		end procedure;

	variable v_C_i_masked 	: std_logic;
	variable v_C_o				: std_logic;
	variable v_H_o				: std_logic;
	variable v_V_o				: std_logic;
	variable v_N_o				: std_logic;
	variable v_Z_o				: std_logic;
	variable v_SUM_o			: std_logic_vector(7 downto 0);
	begin

		v_C_i_masked  :=	'0' when	OP_i = alu_add or 
											OP_i = alu_sub or
											OP_i = alu_asl or
											OP_i = alu_lsr or		
											OP_i = alu_dec or
											OP_i = alu_neg else
								'1' when OP_i = alu_inc or
											OP_i = alu_com else									
								C_i;
		v_V_o := V_i;
		v_C_o := C_i;
		v_H_o	:= H_i;

		--TODO: VERIFY: Datasheet and decode6502 say different flags for NEG, 
		--Leventhal and most obvious ALU action say sames as NEG is 0 - A)


		case OP_i is
			when alu_add | alu_adc | alu_inc | alu_dec =>
				adc_8(v_C_i_masked, A_i, B_i, v_C_o, v_H_o, v_V_o, v_SUM_o);
			when alu_sub | alu_sbc | alu_neg | alu_com =>
				sbc_8(v_C_i_masked, A_i, B_i, v_C_o, v_V_o, v_SUM_o); -- ignore H?
			when alu_or =>
				v_V_o := '0';
				v_SUM_o := A_i or B_i;
			when alu_eor =>
				v_V_o := '0';
				v_SUM_o := A_i xor B_i;
			when alu_rol | alu_asl =>
				v_C_o := A_i(7);
				v_SUM_o := A_i(6 downto 0) & v_C_i_masked;				
			when alu_ror | alu_lsr =>
				v_C_o := A_i(0);
				v_SUM_o := v_C_i_masked & A_i(7 downto 1);
			when alu_asr =>
				v_C_o := A_i(0);
				v_SUM_o := A_i(7) & A_i(7 downto 1);
			when alu_daa =>
				daa(C_i, H_i, B_i, v_C_o, v_V_o, v_SUM_o);
			when others => -- AND
				-- AND is default
				v_V_o := '0';
				v_SUM_o := B_i and A_i;
		end case;
		v_N_o := v_SUM_o(7);
		v_Z_o := not or_reduce(v_SUM_o);

		if OP_i = alu_inc or OP_i = alu_dec then
			v_C_o := C_i;
			v_H_o := H_i; -- not necessary?
		end if;

		if OP_i = alu_asl or
			OP_i = alu_asr or
			OP_i = alu_rol or
			OP_i = alu_ror or
			OP_i = alu_lsr then
			v_V_o := v_N_o xor v_C_o;
		end if;


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