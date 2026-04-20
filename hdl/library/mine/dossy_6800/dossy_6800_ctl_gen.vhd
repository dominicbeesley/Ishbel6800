-- THIS IS A GENERATED FILE - SEE makepla.pl - DO NET EDIT THIS FILE --
-- GENERATED : 2026-04-20T14:14:58Z
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

	IR_DBI_i			: in  std_logic_vector(7 downto 0); -- used for decode * early
	IR_i				: in	std_logic_vector(7 downto 0); -- used for executing instruction
	ALU_CC_i			: in  std_logic_vector(7 downto 0); -- registered ALU output flags

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
	mux_ABH_0_o		: out	std_logic;

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

	ALU_op_o			: out t_alu_op;

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
		variable firstdecode : boolean;	-- A bodge to differentiate between first pass include addressing mode
		begin
			firstdecode := (
				state_i = TSL0 or 
				state_i = TSL0_D02 or 
				state_i = TSL0_D01 or 
				state_i = LDX_TSL0_D02 or
				state_i = INXDEX_TSL0 or
				state_i = GI_TSL0_D01);
			if PMATCH(IR_DBI_i,  "1-11----") and firstdecode then
				return T1_EXT0;
			elsif PMATCH(IR_DBI_i,  "1-01----") and firstdecode then
				return T1_DIR0;
			elsif PMATCH(IR_DBI_i,  "1-10----") and firstdecode then
				return T1_IDX0;
			elsif PMATCH(IR_DBI_i,  "0111----") and firstdecode then
				return T1_EXT0;
			elsif PMATCH(IR_DBI_i,  "0110----") and firstdecode then
				return T1_IDX0;

			elsif PMATCH(IR_DBI_i, "00000001") then
				return NOP_T1_D00;
			elsif PMATCH(IR_DBI_i, "00000110") then
				return TAP_T1_D00;
			elsif PMATCH(IR_DBI_i, "00000111") then
				return TPA_T1_D00;
			elsif PMATCH(IR_DBI_i, "0000100-") then
				return INXDEX_T1_D00;
			elsif PMATCH(IR_DBI_i, "0000101-") or PMATCH(IR_DBI_i, "000011--") then
				return SEx_T1_D00;

			elsif PMATCH(IR_DBI_i, "00110000") then
				return TSX_T1_GP50;
			elsif PMATCH(IR_DBI_i, "00110001") or PMATCH(IR_DBI_i, "00110100") then
				return INSDES_T1_GP50;
			elsif PMATCH(IR_DBI_i, "0011001-") then
				return PULA_T1_GP50;
			elsif PMATCH(IR_DBI_i, "00110101") then
				return TXS_T1_GP50;
			elsif PMATCH(IR_DBI_i, "0011011-") then
				return PSHA_T1_GP50;
			elsif PMATCH(IR_DBI_i, "00111001") then
				return RTS_T1_GP50;
			elsif PMATCH(IR_DBI_i, "00111011") then
				return RTI_T1_GP50;
			elsif PMATCH(IR_DBI_i, "00111111") then
				return SWAI_T1_GP50;

			elsif PMATCH(IR_DBI_i, "011-1110") then
				return TSL0;

			elsif PMATCH(IR_DBI_i, "1---1110") then
				return LDx_T1_D00;
			elsif PMATCH(IR_DBI_i, "1---1111") then
				return STx_T1_D00;
			elsif PMATCH(IR_DBI_i, "1---0111") then
				return GI_STA_T1_D00;
			elsif PMATCH(IR_DBI_i, "1-------") then
				return GI_T1_D00;
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
		mux_ABH_0_o			<= '0';

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

		ALU_op_o				<= alu_and;

		RnW_o					<= '1';
		VMA_o					<= '1';

		case state_i is 
         when DX1 =>
            mux_DB_SUM_o <= '1';
            mux_OBL_DB_o <= '1';
            INC_L_src_o <= db;
            mux_ABH_INCH_o <= '1';
            if ALU_CC_i(CCIX_C) = '1' then
               INC_act_o <= inc_page;
            else
               INC_act_o <= hold;
            end if;
            VMA_o <= '0';
            next_state_o <= DX2;

         when DX2 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            if IR_i(2 downto 0) = "111" then
               -- its a write next
               VMA_o <= '0';
               INC_act_o <= hold;
            end if;
            next_state_o <= DECODE;

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

         when GI_STA_T1_D00 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            if IR_i(6) = '1' then
               mux_DB_ACCB_o <= '1';
            else
               mux_DB_ACCA_o <= '1';
            end if;
            mux_ABLI_FF_o <= '1';
            RnW_o <= '0';
            next_state_o <= GI_STA_TSL0_D01;

         when GI_STA_TSL0_D01 =>
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            CCR_ld_ALU_Z_o <= '1';
            CCR_ld_ALU_N_o <= '1';
            CCR_ld_CLV_o <= '1';
            mux_ABLI_FF_o <= '1';
            next_state_o <= TSL0;

         when GI_T1_D00 =>
            if IR_i(5 downto 4) = "00" then
               -- was immediate, keep pc
               mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            else
               mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
               INC_L_src_o <= abl; INC_H_src_o <= abh;
            end if;
            mux_DB_DBI_o <= '1';
            if PMATCH(IR_i(3 downto 0), "000-") then
               ALU_op_o <= alu_sub;
            elsif PMATCH(IR_i(3 downto 0), "001-") then
               ALU_op_o <= alu_sbc;
            elsif PMATCH(IR_i(3 downto 0), "1000") then
               ALU_op_o <= alu_eor;
            elsif PMATCH(IR_i(3 downto 0), "1001") then
               ALU_op_o <= alu_adc;
            elsif PMATCH(IR_i(3 downto 0), "1010") then
               ALU_op_o <= alu_or;
            elsif PMATCH(IR_i(3 downto 0), "1011") then
               ALU_op_o <= alu_add;
            end if;
            if IR_i(3 downto 0) = "0110" then
               mux_ABLI_FF_o <= '1';
            elsif IR_i(6) = '1' then
               mux_ABLI_ACCB_o <= '1';
            else
               mux_ABLI_ACCA_o <= '1';
            end if;
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            next_state_o <= GI_TSL0_D01;

         when GI_TSL0_D01 =>
            mux_DB_SUM_o <= '1';
            if IR_i(3) = '1' or IR_i(0) = '0' then
               if IR_i(6) = '1' then
                  ACCB_ld_DB_o <= '1';
               else
                  ACCA_ld_DB_o <= '1';
               end if;
            end if;
            CCR_ld_ALU_Z_o <= '1';
            CCR_ld_ALU_N_o <= '1';
            CCR_ld_ALU_C_o <= '1';
            CCR_ld_ALU_H_o <= '1';
            CCR_ld_ALU_V_o <= '1';
            IR_ld_D_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            next_state_o <= DECODE;

         when GP52 =>
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            next_state_o <= TSL0;

         when INSDES_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            if IR_i(0) = '0' then
               INC_act_o <= dec;
            end if;
            VMA_o <= '0';
            next_state_o <= TXS_GP51;

         when INXDEX_D01 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            IXL_ld_ABL_o <= '1'; IXH_ld_ABH_o <= '1';
            mux_ABLI_IXL_o <= '1';
            mux_DB_IXH_o <= '1';
            VMA_o <= '0';
            next_state_o <= INXDEX_D02;

         when INXDEX_D02 =>
            mux_ABLI_IXL_o <= '1';
            mux_DB_IXH_o <= '1';
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            next_state_o <= INXDEX_TSL0;

         when INXDEX_T1_D00 =>
            mux_ABH_IXH_o <= '1';
            INC_H_src_o <= abh;
            mux_ABLI_IXL_o <= '1';
            mux_ABL_ABLI_o <= '1';
            INC_L_src_o <= abl;
            if IR_i(0) = '1' then
               INC_act_o <= dec;
            end if;
            VMA_o <= '0';
            next_state_o <= INXDEX_D01;

         when INXDEX_TSL0 =>
            CCR_ld_ALU_Z_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            IR_ld_D_o <= '1';
            next_state_o <= DECODE;

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
            mux_ABLI_FF_o <= '1';
            CCR_ld_ALU_N_o <= '1';
            CCR_ld_ALU_Z_o <= '1';
            CCR_ld_CLV_o <= '1';
            next_state_o <= LDX_TSL0_D02;

         when LDX_TSL0_D02 =>
            CCR_ld_AND_ALU_Z_o<= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            IR_ld_D_o <= '1';
            next_state_o <= DECODE;

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
            next_state_o <= TSL0_D01;

         when PSHA_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            VMA_o <= '0';
            next_state_o <= GP52;

         when PSHA_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            if IR_i(0) = '1' then
               mux_DB_ACCB_o <= '1';
            else
               mux_DB_ACCA_o <= '1';
            end if;
            RnW_o <= '0';
            INC_act_o <= dec;
            next_state_o <= PSHA_GP51;

         when PULA_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            next_state_o <= PULA_GP52;

         when PULA_GP52 =>
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            mux_DB_DBI_o <= '1';
            if IR_i(0) = '1' then
               ACCB_ld_DB_o <= '1';
            else
               ACCA_ld_DB_o <= '1';
            end if;
            next_state_o <= TSL0;

         when PULA_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            VMA_o <= '0';
            next_state_o <= PULA_GP51;

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

         when RTS_GP51 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            SPL_ld_ABL_o <= '1'; SPH_ld_ABH_o <= '1';
            next_state_o <= RTI_R57;

         when RTS_T1_GP50 =>
            mux_ABL_SPL_o <= '1'; mux_ABH_SPH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            VMA_o <= '0';
            next_state_o <= RTS_GP51;

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
            next_state_o <= TSL0_D01;

         when STx_D01 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            if IR_i(6) = '1' then
               mux_DB_IXL_o <= '1';
            else
               mux_DB_SPL_o <= '1';
            end if;
            RnW_o <= '0';
            CCR_ld_ALU_Z_o <= '1';
            CCR_ld_ALU_N_o <= '1';
            CCR_ld_CLV_o <= '1';
            mux_ABLI_FF_o <= '1';
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
            CCR_ld_AND_ALU_Z_o<= '1';
            mux_ABLI_FF_o <= '1';
            next_state_o <= TSL0;

         when STx_T1_D00 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            if IR_i(6) = '1' then
               mux_DB_IXH_o <= '1';
            else
               mux_DB_SPH_o <= '1';
            end if;
            mux_ABLI_FF_o <= '1';
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

         when T1_DIR0 =>
            mux_DB_DBI_o <= '1';
            mux_OBL_DB_o <= '1';
            INC_L_src_o <= db;
            mux_ABH_0_o <= '1';
            INC_H_src_o <= abh;
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            if IR_i(2 downto 0) = "111" then
               -- its a write next
               VMA_o <= '0';
               INC_act_o <= hold;
            end if;
            next_state_o <= DECODE;

         when T1_EXT0 =>
            mux_DB_DBI_o <= '1';
            T_ld_DB_o <= '1';
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            next_state_o <= EXT1;

         when T1_IDX0 =>
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            INC_act_o <= hold;
            mux_DB_DBI_o <= '1';
            T_ld_DB_o <= '1';
            mux_ABLI_IXL_o <= '1';
            mux_ABL_ABLI_o <= '1';
            mux_ABH_IXH_o <= '1';
            INC_H_src_o <= abh;
            ALU_op_o <= alu_add;
            VMA_o <= '0';
            next_state_o <= DX1;

         when TAP_T1_D00 =>
            mux_DB_ACCA_o <= '1';
            CCR_ld_DB_o <= '1';
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            next_state_o <= TSL0_D01;

         when TPA_T1_D00 =>
            mux_DB_CCR_o <= '1';
            ACCA_ld_DB_o <= '1';
            mux_ABL_PCL_o <= '1'; mux_ABH_PCH_o <= '1';
            INC_L_src_o <= abl; INC_H_src_o <= abh;
            next_state_o <= TSL0_D01;

         when TSL0|TSL0_D02|TSL0_D01 =>
            mux_ABL_INCL_o <= '1'; mux_ABH_INCH_o <= '1';
            PCL_ld_INCL_o <= '1'; PCH_ld_INCH_o <= '1';
            IR_ld_D_o <= '1';
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
