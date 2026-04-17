-- THIS IS A GENERATED FILE - SEE makepla.pl - DO NET EDIT THIS FILE --
-- GENERATED : 2026-04-17T13:28:09Z
-- THIS IS A GENERATED FILE - SEE makepla.pl - DO NET EDIT THIS FILE --
-- 
----------------------------------------------------------------------------------
-- Company:				Dossytronics
-- Engineer:			Dominic Beesley
-- 
-- Create Date:		12/4/2025 
-- Design Name: 
-- Module Name:		dossy_6800_ctl_gen
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:		cpu control - generated file
--
-- Dependencies: 
--
-- Revision: 			GENERATED FILE
-- Additional Comments: 
--
-- Licence: MIT - see file LICENCE.txt
----------------------------------------------------------------------------------


library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library dossy_6800;
use dossy_6800.dossy_6800.all;

entity dossy_6800_ctl_gen is
port
(
	state_i			: in	t_cpu_state;

	IR_i				: in	std_logic_vector(7 downto 0);

	next_state_o	: out t_cpu_state;

	mux_ABL_INCL_o	: out	std_logic;
	mux_ABL_PCL_o	: out	std_logic;
	mux_ABL_SPL_o	: out	std_logic;
	mux_ABL_ABLI_o	: out	std_logic;
	mux_OBL_DB_o	: out	std_logic;
	mux_ABLI_ABL_o	: out	std_logic;
	mux_ABLI_IXL_o	: out	std_logic;
	mux_ABLI_ACCA_o: out	std_logic;
	mux_ABLI_ACCB_o: out	std_logic;
	mux_ABLI_IXH_o	: out	std_logic;
	mux_ABLI_FF_o	: out	std_logic;
	mux_DB_T_o		: out	std_logic;
	mux_DB_PCH_o	: out	std_logic;
	mux_DB_SPH_o	: out	std_logic;
	mux_DB_IXH_o	: out	std_logic;
	mux_DB_PCL_o	: out	std_logic;
	mux_DB_SPL_o	: out	std_logic;
	mux_DB_IXL_o	: out	std_logic;
	mux_DB_ACCA_o	: out	std_logic;
	mux_DB_ACCB_o	: out	std_logic;
	mux_DB_CCR_o	: out	std_logic;
	mux_DB_SUM_o	: out	std_logic;
	mux_DB_DBI_o	: out	std_logic;
	mux_DB_RESV_o	: out	std_logic;
	mux_DB_NMIV_o	: out	std_logic;
	mux_DB_SWIV_o	: out	std_logic;
	mux_DB_IRQV_o	: out	std_logic;
	mux_ABH_T_o		: out	std_logic;
	mux_ABH_INCH_o	: out	std_logic;
	mux_ABH_PCH_o	: out	std_logic;
	mux_ABH_SPH_o	: out	std_logic;
	mux_ABH_IXH_o	: out	std_logic;
	mux_ABH_FF_o	: out	std_logic;

	PCL_ld_INCL_o	: out	std_logic;
	SPL_ld_ABL_o	: out	std_logic;
	SPL_ld_DB_o		: out	std_logic;
	IXL_ld_ABL_o	: out	std_logic;
	IXL_ld_DB_o		: out	std_logic;
	ACCB_ld_ABLI_o	: out	std_logic;
	ACCB_ld_DB_o	: out	std_logic;
	ACCA_ld_ABLI_o	: out	std_logic;
	ACCA_ld_DB_o	: out	std_logic;
	T_ld_DB_o		: out	std_logic;
	T_ld_ABH_o		: out	std_logic;
	PCH_ld_INCH_o	: out	std_logic;
	SPH_ld_DB_o		: out	std_logic;
	SPH_ld_ABH_o	: out	std_logic;
	IXH_ld_DB_o		: out	std_logic;
	IXH_ld_ABH_o	: out	std_logic;
	CCR_ld_DB_o 	: out std_logic;
	CCR_ld_ALU_Z_o : out std_logic;
	CCR_ld_AND_ALU_Z_o : out std_logic;
	CCR_ld_ALU_N_o : out std_logic;
	CCR_ld_ALU_V_o : out std_logic;
	CCR_ld_ALU_C_o : out std_logic;
	CCR_ld_ALU_H_o : out std_logic;
	CCR_ld_SEV_o 	: out std_logic;
	CCR_ld_SEC_o 	: out std_logic;
	CCR_ld_SEI_o 	: out std_logic;
	CCR_ld_CLV_o 	: out std_logic;
	CCR_ld_CLC_o 	: out std_logic;
	CCR_ld_CLI_o 	: out std_logic;
	IR_ld_D_o		: out	std_logic;

	INC_L_src_o		: out	t_inc_l_src;
	INC_H_src_o		: out	t_inc_h_src;
	INC_act_o		: out	t_inc_act;

	RnW_o				: out std_logic;
	VMA_o				: out std_logic

);
end;

architecture rtl of dossy_6800_ctl_gen is
begin

	p_control:process(all)
		function PMATCH(V: in std_logic_vector; M: in std_logic_vector) return boolean is
		begin
			if V ?= M then
				return true;
			else
				return false;
			end if;			
		end function;

		impure function DECODE return t_cpu_state is
		begin
			if PMATCH(IR_i,  "1-11----") and (state_i = TSL0 or state_i = TSL0_D02 or state_i = TSL0_D01) then
				return T1_EXT0;
			elsif PMATCH(IR_i, "0000101-") or PMATCH(IR_i, "000011--") then
				return SEx_T1_D00;
			elsif PMATCH(IR_i, "00000001") then
				return NOP_T1_D00;
			elsif PMATCH(IR_i, "00110101") then
				return TXS_T1_GP50;
			elsif PMATCH(IR_i, "00110000") then
				return TSX_T1_GP50;
			elsif PMATCH(IR_i, "00111111") then
				return SWAI_T1_GP50;
			elsif PMATCH(IR_i, "00111011") then
				return RTI_T1_GP50;
			elsif PMATCH(IR_i, "1---1110") then
				return LDx_T1_D00;
			elsif PMATCH(IR_i, "1---1111") then
				return STx_T1_D00;
			else
				return DIEBAD;
			end if;
		end function;
	begin
		next_state_o <= DIEBAD;

		mux_ABL_INCL_o		<= '0';
		mux_ABL_PCL_o		<= '0';
		mux_ABL_SPL_o		<= '0';
		mux_ABL_ABLI_o		<= '0';
		mux_OBL_DB_o		<= '0';
		mux_ABLI_ABL_o		<= '0';
		mux_ABLI_IXL_o		<= '0';
		mux_ABLI_ACCA_o	<= '0';
		mux_ABLI_ACCB_o	<= '0';
		mux_ABLI_IXH_o		<= '0';
		mux_ABLI_FF_o		<= '0';
		mux_DB_T_o			<= '0';
		mux_DB_PCH_o		<= '0';
		mux_DB_SPH_o		<= '0';
		mux_DB_IXH_o		<= '0';
		mux_DB_PCL_o		<= '0';
		mux_DB_SPL_o		<= '0';
		mux_DB_IXL_o		<= '0';
		mux_DB_ACCA_o		<= '0';
		mux_DB_ACCB_o		<= '0';
		mux_DB_CCR_o		<= '0';
		mux_DB_SUM_o		<= '0';
		mux_DB_DBI_o		<= '0';
		mux_DB_RESV_o		<= '0';
		mux_DB_NMIV_o		<= '0';
		mux_DB_SWIV_o		<= '0';
		mux_DB_IRQV_o		<= '0';
		mux_ABH_T_o			<= '0';
		mux_ABH_INCH_o		<= '0';
		mux_ABH_PCH_o		<= '0';
		mux_ABH_SPH_o		<= '0';
		mux_ABH_IXH_o		<= '0';
		mux_ABH_FF_o		<= '0';

		PCL_ld_INCL_o		<= '0';
		SPL_ld_ABL_o		<= '0';
		SPL_ld_DB_o			<= '0';
		IXL_ld_ABL_o		<= '0';
		IXL_ld_DB_o			<= '0';
		ACCB_ld_ABLI_o		<= '0';
		ACCB_ld_DB_o		<= '0';
		ACCA_ld_ABLI_o		<= '0';
		ACCA_ld_DB_o		<= '0';
		T_ld_DB_o			<= '0';
		T_ld_ABH_o			<= '0';
		PCH_ld_INCH_o		<= '0';
		SPH_ld_DB_o			<= '0';
		SPH_ld_ABH_o		<= '0';
		IXH_ld_DB_o			<= '0';
		IXH_ld_ABH_o		<= '0';

		CCR_ld_DB_o				<= '0';
		CCR_ld_ALU_Z_o			<= '0';
		CCR_ld_AND_ALU_Z_o	<= '0';
		CCR_ld_ALU_N_o			<= '0';
		CCR_ld_ALU_V_o			<= '0';
		CCR_ld_ALU_C_o			<= '0';
		CCR_ld_ALU_H_o			<= '0';
		CCR_ld_SEV_o			<= '0';
		CCR_ld_SEC_o			<= '0';
		CCR_ld_SEI_o			<= '0';
		CCR_ld_CLV_o			<= '0';
		CCR_ld_CLC_o			<= '0';
		CCR_ld_CLI_o			<= '0';


		IR_ld_D_o			<= '0';

		INC_L_src_o			<= inc;
		INC_H_src_o			<= inc;
		INC_act_o			<= inc;

		RnW_o					<= '1';
		VMA_o					<= '1';

		case state_i is 
         when EXT1 =>
            mux_ABH_T_o <= '1';
            INC_H_src_o <= abh;
            mux_DB_DBI_o <= '1';
            mux_OBL_DB_o <= '1';
            INC_L_src_o <= db;
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            if IR_i(2 downto 0) = "111" then
               -- its a write next
               VMA_o <= '0';
               INC_act_o <= hold;
            end if;
            next_state_o <= DECODE;

         when GP52 =>
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            IR_ld_D_o <= '1';
            next_state_o <= TSL0;

         when LDX_D01 =>
            if IR_i(5 downto 4) = "00" then
               -- was immediate, keep pc
               mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            else
               mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
               INC_L_src_o <= abl; INC_H_src_o <= abh;
            end if;
            mux_DB_DBI_o <= '1';
            if IR_i(6) = '1' then
               IXL_ld_DB_o <= '1';
            else
               SPL_ld_DB_o <= '1';
            end if;
            IR_ld_D_o <= '1';
            mux_ABLI_FF_o <= '1';
            next_state_o <= TSL0_D02;

         when LDx_T1_D00 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_DBI_o <= '1';
            if IR_i(6) = '1' then
               IXH_ld_DB_o <= '1';
            else
               SPH_ld_DB_o <= '1';
            end if;
            mux_ABLI_FF_o <= '1';
            next_state_o <= LDX_D01;

         when NOP_T1_D00 =>
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            IR_ld_D_o <= '1';
            next_state_o <= TSL0_D01;

         when R57 =>
            mux_DB_DBI_o <= '1';
            T_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= R58;

         when R58 =>
            mux_DB_DBI_o <= '1';
            mux_OBL_DB_o <= '1';
            INC_L_src_o <= db;
            mux_ABH_T_o <= '1';
            INC_H_src_o <= abh;
            IR_ld_D_o <= '1';
            next_state_o <= TSL0;

         when RESET|GP58 =>
            if IR_i = x"3F" then
               mux_DB_SWIV_o <= '1';
            else
               mux_DB_RESV_o <= '1';
            end if;
            mux_ABH_FF_o <= '1';
            INC_H_src_o <= abh;
            CCR_ld_SEI_o <= '1';
            mux_OBL_DB_o <= '1';
            INC_L_src_o <= db;
            if state_i = RESET then
               next_state_o <= GP58;
            else
               next_state_o <= R57;
            end if;

         when RTI_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            next_state_o <= RTI_GP52;

         when RTI_GP52 =>
            mux_DB_DBI_o <= '1';
            CCR_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= RTI_R53;

         when RTI_R53 =>
            mux_DB_DBI_o <= '1';
            ACCB_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= RTI_R54;

         when RTI_R54 =>
            mux_DB_DBI_o <= '1';
            ACCA_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= RTI_R55;

         when RTI_R55 =>
            mux_DB_DBI_o <= '1';
            IXH_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= RTI_R56;

         when RTI_R56 =>
            mux_DB_DBI_o <= '1';
            IXL_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= RTI_R57;

         when RTI_R57 =>
            mux_DB_DBI_o <= '1';
            T_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            next_state_o <= R58;

         when RTI_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            VMA_o <= '0';
            next_state_o <= RTI_GP51;

         when SEx_T1_D00 =>
            --TODO: decode this stuff and encode flags from IR direct?
            if IR_i(2 downto 0) = "010" then
               CCR_ld_CLV_o <= '1';
            elsif IR_i(2 downto 0) = "011" then
               CCR_ld_SEV_o <= '1';
            elsif IR_i(2 downto 0) = "100" then
               CCR_ld_CLC_o <= '1';
            elsif IR_i(2 downto 0) = "101" then
               CCR_ld_SEC_o <= '1';
            elsif IR_i(2 downto 0) = "110" then
               CCR_ld_CLI_o <= '1';
            elsif IR_i(2 downto 0) = "111" then
               CCR_ld_SEI_o <= '1';
            end if;
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            IR_ld_D_o <= '1';
            next_state_o <= TSL0_D01;

         when STx_D01 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            if IR_i(6) = '1' then
               mux_DB_IXL_o <= '1';
            else
               mux_DB_SPL_o <= '1';
            end if;
            RnW_o <= '0';
            next_state_o <= STx_D02;

         when STx_D02 =>
            -- TODO: this whole cycle had to be added - I think we need to move writes back a cycle somehow!
            if IR_i(5 downto 4) = "00" then
               -- was immediate, keep pc
               mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            else
               mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
               INC_L_src_o <= abl; INC_H_src_o <= abh;
            end if;
            mux_DB_DBI_o <= '1';
            if IR_i(6) = '1' then
               IXL_ld_DB_o <= '1';
            else
               SPL_ld_DB_o <= '1';
            end if;
            IR_ld_D_o <= '1';
            mux_ABLI_FF_o <= '1';
            next_state_o <= TSL0;

         when STx_T1_D00 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            if IR_i(6) = '1' then
               mux_DB_IXH_o <= '1';
            else
               mux_DB_SPH_o <= '1';
            end if;
            RnW_o <= '0';
            next_state_o <= STx_D01;

         when SWAI_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_PCH_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP52;

         when SWAI_GP52 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_IXL_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP53;

         when SWAI_GP53 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_IXH_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP54;

         when SWAI_GP54 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_ACCA_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP55;

         when SWAI_GP55 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_ACCB_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP56;

         when SWAI_GP56 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            mux_DB_CCR_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP57;

         when SWAI_GP57 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            INC_act_o <= dec;
            VMA_o <= '0';
            if IR_i /= x"3E" then -- TODO: better check here!
               next_state_o <= GP58;
            else
               next_state_o <= WAIT_INTER;
            end if;

         when SWAI_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            mux_DB_PCL_o <= '1';
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= SWAI_GP51;

         when T1_EXT0 =>
            mux_DB_DBI_o <= '1';
            T_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= EXT1;

         when TSL0|TSL0_D02|TSL0_D01 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            next_state_o <= DECODE;

         when TSX_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            IXL_ld_ABL_o <= '1'; IXH_ld_ABH_o <= '1';
            VMA_o <= '0';
            next_state_o <= GP52;

         when TSX_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            VMA_o <= '0';
            next_state_o <= TSX_GP51;

         when TXS_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            VMA_o <= '0';
            next_state_o <= GP52;

         when TXS_T1_GP50 =>
            mux_ABLI_IXL_o <= '1';
            mux_ABL_ABLI_o <= '1';
            mux_ABH_IXH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            INC_act_o <= dec;
            VMA_o <= '0';
            next_state_o <= TXS_GP51;

         when WAIT_INTER =>
            --TODO: this is WAIT's WAIT state...what to do here, BA?
            next_state_o <= WAIT_INTER;

			when others => null;
		end case;
	end process;

end rtl;
