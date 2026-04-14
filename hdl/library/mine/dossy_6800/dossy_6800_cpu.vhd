----------------------------------------------------------------------------------
-- Company:				Dossytronics
-- Engineer:			Dominic Beesley
-- 
-- Create Date:		12/4/2025 
-- Design Name: 
-- Module Name:		dossy_6800_cpu
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:		main cpu file
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
use dossy_6800.dossy_6800.all;

entity dossy_6800_cpu is
	port (	
		CLK_i:		in	 std_logic;
		RST_i:		in	 std_logic;
		HALT_i:		in	 std_logic;
		IRQ_i:		in	 std_logic;
		NMI_i:		in	 std_logic;
		RnW_o:		out std_logic;
		VMA_o:		out std_logic;
		BA_o:			out std_logic;
		A_o:			out std_logic_vector(15 downto 0);
		D_i:			in	 std_logic_vector(7 downto 0);
		D_o:			out std_logic_vector(7 downto 0)
		);
end;

architecture rtl of dossy_6800_cpu is

	-- internal buses
	signal	ib_DB					: std_logic_vector(7 downto 0);
	signal	ib_ABL				: std_logic_vector(7 downto 0);
	signal	ib_ABLI				: std_logic_vector(7 downto 0);
	signal	ib_ABH				: std_logic_vector(7 downto 0);
	signal	ib_OBL				: std_logic_vector(7 downto 0);

	-- internal bus mux controls
	signal	i_mux_ABL_INCL		: std_logic;
	signal	i_mux_ABL_PCL		: std_logic;
	signal	i_mux_ABL_SPL		: std_logic;
	signal	i_mux_ABL_IXL		: std_logic;
	signal	i_mux_ABL_ABLI		: std_logic;

	signal	i_mux_OBL_ABL		: std_logic;
	signal	i_mux_OBL_DB		: std_logic;

	signal	i_mux_ABLI_ABL		: std_logic;
	signal	i_mux_ABLI_IXL		: std_logic;
	signal	i_mux_ABLI_ACCA	: std_logic;
	signal	i_mux_ABLI_ACCB	: std_logic;
	signal	i_mux_ABLI_IXH		: std_logic;
	signal	i_mux_ABLI_FF		: std_logic;

	signal	i_mux_DB_T			: std_logic;
	signal	i_mux_DB_PCH		: std_logic;
	signal	i_mux_DB_SPH		: std_logic;
	signal	i_mux_DB_IXH		: std_logic;
	signal	i_mux_DB_CCR		: std_logic;
	signal	i_mux_DB_SUM		: std_logic;
	signal	i_mux_DB_DBI		: std_logic;
	signal	i_mux_DB_RESV		: std_logic;
	signal	i_mux_DB_NMIV		: std_logic;
	signal	i_mux_DB_SWIV		: std_logic;
	signal	i_mux_DB_IRQV		: std_logic;

	signal	i_mux_ABH_T			: std_logic;
	signal	i_mux_ABH_INCH		: std_logic;
	signal	i_mux_ABH_PCH		: std_logic;
	signal	i_mux_ABH_SPH		: std_logic;
	signal	i_mux_ABH_IXH		: std_logic;
	signal	i_mux_ABH_FF		: std_logic;

	-- register file register values
	signal	i_INCL_Q				: std_logic_vector(7 downto 0);
	signal	i_PCL_Q				: std_logic_vector(7 downto 0);
	signal	i_SPL_Q				: std_logic_vector(7 downto 0);
	signal	i_IXL_Q				: std_logic_vector(7 downto 0);
	signal	i_ACCA_Q				: std_logic_vector(7 downto 0);
	signal	i_ACCB_Q				: std_logic_vector(7 downto 0);

	signal	i_T_Q					: std_logic_vector(7 downto 0);
	signal	i_INCH_Q				: std_logic_vector(7 downto 0);
	signal	i_PCH_Q				: std_logic_vector(7 downto 0);
	signal	i_SPH_Q				: std_logic_vector(7 downto 0);
	signal	i_IXH_Q				: std_logic_vector(7 downto 0);
	signal	i_CCR_Q				: std_logic_vector(7 downto 0);
	signal	i_DBI_Q				: std_logic_vector(7 downto 0);
	signal	i_IR_Q				: std_logic_vector(7 downto 0);

	-- alu outputs
	signal	i_ALU_SUM_Q			: std_logic_vector(7 downto 0);
	signal	i_ALU_CCR_Q			: std_logic_vector(7 downto 0);

	-- register file control
	signal	i_PCL_ld_INCL		: std_logic;
	
	signal	i_SPL_ld_ABL		: std_logic;
	signal	i_SPL_ld_DB			: std_logic;
	
	signal	i_IXL_ld_ABL		: std_logic;
	signal	i_IXL_ld_DB			: std_logic;
	
	signal	i_ACCB_ld_ABLI		: std_logic;
	signal	i_ACCB_ld_DB		: std_logic;
	
	signal	i_ACCA_ld_ABLI		: std_logic;
	signal	i_ACCA_ld_DB		: std_logic;

	signal	i_T_ld_DB			: std_logic;
	signal	i_T_ld_ABH			: std_logic;
	
	signal	i_PCH_ld_INCH		: std_logic;

	signal	i_SPH_ld_DB			: std_logic;
	signal	i_SPH_ld_ABH		: std_logic;

	signal	i_IXH_ld_DB			: std_logic;
	signal	i_IXH_ld_ABH		: std_logic;

	signal	i_CCR_ld_DB			: std_logic;
	signal	i_CCR_ld_ALU		: std_logic;

	signal	i_DBI_ld_D			: std_logic;

	signal	i_IR_ld_D			: std_logic;

	-- incrementer
	signal	r_incl				: std_logic_vector(7 downto 0);
	signal	r_inch				: std_logic_vector(7 downto 0);
	signal	i_INC_src			: t_inc_source;
	signal	i_INC_act			: t_inc_act;

	-- other inputs to BUS MUXes
	signal	i_SUM_Q				: std_logic_vector(7 downto 0);

	-- other control signals
	signal	i_VMA			: std_logic;
	signal	r_VMA					: std_logic;

	-- state machine
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

		-- generic fetch and set Z?
		TSL0_D02,

		-- EXTENDED addressing
		T1_EXT0,
		EXT1,

		-- DIE
		DIEBAD
		);
	signal i_next_state	: t_cpu_state;
	signal r_state			: t_cpu_state;

begin


--
-- ###							#	#	#	#	#	#
-- #	#							####	#	#	#	#
-- #	#	#	#	 ###			####	#	#	 ##	 ##	 ###
-- ###	#	#	#				#	#	#	#	 ##	#	#	#
-- #	#	#	#	 ##			#	#	#	#	#	#	####	 ##
-- #	#	#	#		#			#	#	#	#	#	#	#			#
-- ###	 ###	###			#	#	 ##	#	#	 ##	###
--

-- TODO: bus muxes should probably surface combinatorial or inconsistent 
-- behaviour when there are multiple sources active

	e_bus_mux_ABL:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 5
	)
	port map (
		SEL_i		=> (
			0 => i_mux_ABL_INCL,
			1 => i_mux_ABL_PCL,
			2 => i_mux_ABL_SPL,
			3 => i_mux_ABL_IXL,
			4 => i_mux_ABL_ABLI
		),
		D_i		=> (
			0 => i_INCL_Q,
			1 => i_PCL_Q,
			2 => i_SPL_Q,
			3 => i_IXL_Q,
			4 => ib_ABLI
		),
		D_o		=> ib_ABL
	);

	e_bus_mux_OBL:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 2
	)
	port map (
		SEL_i		=> (
			0 => i_mux_OBL_ABL,
			1 => i_mux_OBL_DB
		),
		D_i		=> (
			0 => ib_ABL,
			1 => ib_DB
		),
		D_o		=> ib_OBL
	);


	e_bus_mux_ABLI:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 6
	)
	port map (
		SEL_i		=> (
			0 => i_mux_ABLI_ABL,
			1 => i_mux_ABLI_IXL,
			2 => i_mux_ABLI_ACCA,
			3 => i_mux_ABLI_ACCB,
			4 => i_mux_ABLI_IXH,
			5 => i_mux_ABLI_FF
		),
		D_i		=> (
			0 => ib_ABL,
			1 => i_IXL_Q,
			2 => i_ACCA_Q,
			3 => i_ACCB_Q,
			4 => i_IXH_Q,
			5 => x"FF"
		),
		D_o		=> ib_ABLI
	);


	e_bus_mux_DB:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 11
	)
	port map (
		SEL_i		=> (
			0 => i_mux_DB_T,
			1 => i_mux_DB_PCH,
			2 => i_mux_DB_SPH,
			3 => i_mux_DB_IXH,
			4 => i_mux_DB_CCR,
			5 => i_mux_DB_SUM,
			6 => i_mux_DB_DBI,
			7 => i_mux_DB_RESV,
			8 => i_mux_DB_NMIV,
			9 => i_mux_DB_SWIV,
			10=> i_mux_DB_IRQV
		),
		D_i		=> (
			0 => i_T_Q,
			1 => i_PCH_Q,
			2 => i_SPH_Q,
			3 => i_IXH_Q,
			4 => i_CCR_Q,
			5 => i_SUM_Q,
			6 => i_DBI_Q,
			7 => x"FE",
			8 => x"FC",
			9 => x"FA",
			10=> x"F8"
		),
		D_o		=> ib_DB
	);

	e_bus_mux_ABH:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 6
	)
	port map (
		SEL_i		=> (
			0 => i_mux_ABH_T,
			1 => i_mux_ABH_INCH,
			2 => i_mux_ABH_PCH,
			3 => i_mux_ABH_SPH,
			4 => i_mux_ABH_IXH,
			5 => i_mux_ABH_FF
		),
		D_i		=> (
			0 => i_T_Q,
			1 => i_INCH_Q,
			2 => i_PCH_Q,
			3 => i_SPH_Q,
			4 => i_IXH_Q,
			5 => x"FF"
		),
		D_o		=> ib_ABH
	);

--
-- ###					 #												####	 #		##
-- #	#									 #								#				 #
-- #	#	 ##	 ###	##		 ###	####	 ##	# ##			#		##		 #		 ##
-- ###	#	#	#	#	 #		#		 #		#	#	##				###	 #		 #		#	#
-- # #	####	#	#	 #		 ##	 #		####	#				#		 #		 #		####
-- #	#	#		 ###	 #			#	 #		#		#				#		 #		 #		#
-- #	#	 ##		#	###	###	  ##	 ##	#				#		###	###	 ##
--					 ##	
--

	e_reg_pcl:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> i_PCL_ld_INCL,
		D_i			=> i_INCL_Q,
		D_o			=> i_PCL_Q
	);

	e_reg_spl:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_SPL_ld_ABL,
		D_0_i			=> ib_ABL,
		WE_1_i		=> i_SPL_ld_DB,
		D_1_i			=> ib_DB,
		D_o			=> i_SPL_Q
	);

	e_reg_ixl:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_IXL_ld_ABL,
		D_0_i			=> ib_ABL,
		WE_1_i		=> i_IXL_ld_DB,
		D_1_i			=> ib_DB,
		D_o			=> i_IXL_Q
	);

	e_reg_acc_a:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_ACCA_ld_DB,
		D_0_i			=> ib_DB,
		WE_1_i		=> i_ACCA_ld_ABLI,
		D_1_i			=> ib_ABLI,
		D_o			=> i_ACCA_Q
	);

	e_reg_acc_b:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_ACCB_ld_DB,
		D_0_i			=> ib_DB,
		WE_1_i		=> i_ACCB_ld_ABLI,
		D_1_i			=> ib_ABLI,
		D_o			=> i_ACCB_Q
	);

	e_reg_t_b:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> i_T_ld_DB,
		D_i			=> ib_DB,
		D_o			=> i_T_Q
	);

	e_reg_pch:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> i_PCH_ld_INCH,
		D_i			=> i_INCH_Q,
		D_o			=> i_PCH_Q
	);

	e_reg_sph:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_SPH_ld_ABH,
		D_0_i			=> ib_ABH,
		WE_1_i		=> i_SPH_ld_DB,
		D_1_i			=> ib_DB,
		D_o			=> i_SPH_Q
	);

	e_reg_ixh:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_IXH_ld_ABH,
		D_0_i			=> ib_ABH,
		WE_1_i		=> i_IXH_ld_DB,
		D_1_i			=> ib_DB,
		D_o			=> i_IXH_Q
	);

	e_reg_ccr:entity dossy_6800.dossy_6800_reg8_2i
	port map (
		CLK_i			=> CLK_i,
		WE_0_i		=> i_CCR_ld_DB,
		D_0_i			=> ib_DB,
		WE_1_i		=> i_CCR_ld_ALU,
		D_1_i			=> i_ALU_CCR_Q,
		D_o			=> i_ACCB_Q
	);

	e_reg_dbi:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> VMA_o,
		D_i			=> D_i,
		D_o			=> i_DBI_Q
	);

	e_reg_ir:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> i_IR_ld_D,
		D_i			=> D_i,
		D_o			=> i_IR_Q
	);

--
-- ###
--	 #																 #
--	 #		###	 ###	# ##	 ##  ## #	 ##	###	####	 ##	# ##
--	 #		#	#	#		##		#	# # # #	#	#	#	#	 #		#	#	##
--	 #		#	#	#		#		#### # # #	####	#	#	 #		####	#
--	 #		#	#	#		#		#	  # # #	#		#	#	 #		#		#
-- ###	#	#	 ###	#		 ##  #	#	 ##	#	#	  ##	 ##	#
--

	-- this assumes a 16bit increment can be carried out in one cycle?
	p_inc:process(CLK_i)
	variable v_src_l : std_logic_vector(7 downto 0);
	variable v_src_h : std_logic_vector(7 downto 0);
	variable v_int	: std_logic_vector(8 downto 0); -- low order with carry
	begin
		if rising_edge(CLK_i) then

			case i_INC_src is 
				when al_ah =>
					v_src_l := ib_ABL;
					v_src_h := ib_ABH;
				when db_ah =>
					v_src_l := ib_DB;
					v_src_h := ib_ABH;
				when others =>
					v_src_l := i_INCL_Q;
					v_src_h := i_INCH_Q;
			end case;

			case i_INC_act is
				when inc => 
					v_int := std_logic_vector("0" & unsigned(v_src_l) + 1);
					r_incl <= v_int(7 downto 0);
				when dec	=> 
					v_int := std_logic_vector("0" & unsigned(v_src_l) - 1);
					r_incl <= v_int(7 downto 0);
				when others =>
					r_incl <= v_src_l;
			end case;

			case i_INC_act is
				when inc => 
					if v_int(8) = '1' then
						r_inch <= std_logic_vector(unsigned(v_src_h) + 1);
					else
						r_inch <= v_src_h;
					end if;
				when dec =>
					if v_int(8) = '1' then
						r_inch <= std_logic_vector(unsigned(v_src_h) - 1);
					else
						r_inch <= v_src_h;
					end if;
				when inc_page =>
					r_inch <= std_logic_vector(unsigned(v_src_h) + 1);
				when others	=>	
					r_inch <= v_src_h;
			end case;


		end if;
	end process;

	i_INCH_Q <= r_inch;
	i_INCL_Q <= r_incl;


--
--	 ##											#	#					#		 #
-- #	#	 #				 #						####					#
-- #		####	 ###	####	 ##			####	 ###	 ###	###	##		###	 ##
--	 ##	 #		#	#	 #		#	#			#	#	#	#	#		#	#	 #		#	#	#	#
--		#	 #		#	#	 #		####			#	#	#	#	#		#	#	 #		#	#	####
-- #	#	 #		# ##	 #		#				#	#	# ##	#		#	#	 #		#	#	#
--	 ##	  ##	 # #	  ##	 ##			#	#	 # #	 ###	#	#	###	#	#	 ##
--

	p_state_machine:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			if RST_i = '1' then
				r_state <= RESET;
			else
				r_state <= i_next_state;
			end if;
		end if;
	end process;

	p_state_next:process(all) 
		function PMATCH(V: in std_logic_vector; M: in std_logic_vector) return boolean is
		begin
			if V ?= M then
				return true;
			else
				return false;
			end if;			
		end function;

	begin
		case r_state is
			when RESET =>
				i_next_state <= GP58;
			when GP58 => 
				i_next_state <= R57;
			when R57 =>
				i_next_state <= R58;
			when R58 =>
				i_next_state <= TSL0;
			when TSL0 | TSL0_D02 | EXT1 =>
				if PMATCH(i_IR_Q,	 "1-11----") and (r_state = TSL0 or r_state = TSL0_D02) then
					i_next_state <= T1_EXT0;
				elsif PMATCH(i_IR_Q, "1---111-") then
					i_next_state <= LDx_T1_D00;
				else
					i_next_state <= DIEBAD;
				end if;
			when LDx_T1_D00 =>
				i_next_state <= LDX_D01;
			when LDX_D01 =>
				i_next_state <= TSL0_D02;
			when T1_EXT0 =>
				i_next_state <= EXT1;				
			when others =>
				i_next_state <= DIEBAD;
		end case;
	end process;

	p_control:process(all)
	begin
		i_mux_ABL_INCL		<= '0';
		i_mux_ABL_PCL		<= '0';
		i_mux_ABL_SPL		<= '0';
		i_mux_ABL_IXL		<= '0';
		i_mux_ABL_ABLI		<= '0';
		i_mux_OBL_ABL		<= '0';
		i_mux_OBL_DB		<= '0';
		i_mux_ABLI_ABL		<= '0';
		i_mux_ABLI_IXL		<= '0';
		i_mux_ABLI_ACCA	<= '0';
		i_mux_ABLI_ACCB	<= '0';
		i_mux_ABLI_IXH		<= '0';
		i_mux_ABLI_FF		<= '0';
		i_mux_DB_T			<= '0';
		i_mux_DB_PCH		<= '0';
		i_mux_DB_SPH		<= '0';
		i_mux_DB_IXH		<= '0';
		i_mux_DB_CCR		<= '0';
		i_mux_DB_SUM		<= '0';
		i_mux_DB_DBI		<= '0';
		i_mux_DB_RESV		<= '0';
		i_mux_DB_NMIV		<= '0';
		i_mux_DB_SWIV		<= '0';
		i_mux_DB_IRQV		<= '0';
		i_mux_ABH_T			<= '0';
		i_mux_ABH_INCH		<= '0';
		i_mux_ABH_PCH		<= '0';
		i_mux_ABH_SPH		<= '0';
		i_mux_ABH_IXH		<= '0';
		i_mux_ABH_FF		<= '0';

		i_PCL_ld_INCL		<= '0';
		i_SPL_ld_ABL		<= '0';
		i_SPL_ld_DB			<= '0';
		i_IXL_ld_ABL		<= '0';
		i_IXL_ld_DB			<= '0';
		i_ACCB_ld_ABLI		<= '0';
		i_ACCB_ld_DB		<= '0';
		i_ACCA_ld_ABLI		<= '0';
		i_ACCA_ld_DB		<= '0';
		i_T_ld_DB			<= '0';
		i_T_ld_ABH			<= '0';
		i_PCH_ld_INCH		<= '0';
		i_SPH_ld_DB			<= '0';
		i_SPH_ld_ABH		<= '0';
		i_IXH_ld_DB			<= '0';
		i_IXH_ld_ABH		<= '0';
		i_CCR_ld_DB			<= '0';
		i_CCR_ld_ALU		<= '0';
		i_DBI_ld_D			<= '0';
		i_IR_ld_D			<= '0';

		i_INC_src			<= inc;
		i_INC_act			<= inc;

		case r_state is 
			when GP58 | RESET =>
				--always reset, TODO: other interrupts
				i_mux_DB_RESV <= '1';
				i_mux_OBL_DB <= '1';
				i_mux_ABH_FF <= '1';
				-- TODO: set IM
				if r_state /= RESET then
					i_VMA <= '1';
				end if;
				i_INC_src <= db_ah;
			when R57 =>
				i_mux_DB_DBI <= '1';
				i_T_ld_DB <= '1';
				i_mux_ABH_INCH <= '1';
				i_mux_ABL_INCL <= '1';
				i_mux_OBL_ABL <= '1';
				i_VMA <= '1';
			when R58 =>
				i_mux_DB_DBI <= '1';
				i_INC_src <= db_ah;
				i_mux_ABH_T <= '1';
				i_mux_OBL_DB <= '1';
				i_VMA <= '1';
				i_IR_ld_D <= '1';
			when TSL0 | TSL0_D02 =>
				i_mux_ABL_INCL <= '1';
				i_mux_ABH_INCH <= '1';
				i_mux_OBL_ABL <= '1';
				i_PCL_ld_INCL <= '1';
				i_PCH_ld_INCH <= '1';
				i_VMA <= '1';

			when LDx_T1_D00 =>
				i_mux_ABL_INCL <= '1';
				i_mux_ABH_INCH <= '1';
				i_mux_OBL_ABL <= '1';
				i_VMA <= '1';
				i_mux_DB_DBI <= '1';
				if i_IR_Q(6) = '1' then
					i_IXH_ld_DB <= '1';
				else
					i_SPH_ld_DB <= '1';
				end if;
				i_mux_ABLI_FF <= '1';
				-- TODO ALU stuff

			when LDx_D01 =>
				if i_IR_Q(5 downto 4) = "00" then
					-- was immediate, keep pc
					i_mux_ABL_INCL <= '1';
					i_mux_ABH_INCH <= '1';
					i_INC_src <= inc;
				else
					i_mux_ABL_PCL <= '1';
					i_mux_ABH_PCH <= '1';
					i_INC_src <= al_ah;
				end if;
				i_mux_OBL_ABL <= '1';
				i_VMA <= '1';
				i_IR_ld_D <= '1';
				i_mux_DB_DBI <= '1';
				if i_IR_Q(6) = '1' then
					i_IXL_ld_DB <= '1';
				else
					i_SPL_ld_DB <= '1';
				end if;
				i_mux_ABLI_FF <= '1';


			when T1_EXT0 =>
				i_mux_DB_DBI <= '1';
				i_T_ld_DB <= '1';
				i_mux_ABL_INCL <= '1';
				i_mux_ABH_INCH <= '1';
				i_mux_OBL_ABL <= '1';
				i_VMA <= '1';
			when EXT1 =>
				i_mux_ABH_T <= '1';
				i_mux_OBL_DB <= '1';
				i_mux_ABL_INCL <= '1';
				i_mux_DB_DBI <= '1';
				i_INC_src <= db_ah;
				i_PCH_ld_INCH <= '1';
				i_PCL_ld_INCL <= '1';
				i_VMA <= '1';



			when others => 
				null;

		end case;

	end process;




	p_A:process(all)
	begin
		A_o <= ib_ABH & ib_OBL;
		VMA_o <= i_VMA;
	end process;

	BA_o <= '0';
	RnW_o	 <= '1';

end rtl;