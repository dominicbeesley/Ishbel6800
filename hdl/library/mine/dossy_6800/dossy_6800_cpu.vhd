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
-- Description:			main cpu file
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
		CLK_i:		in	std_logic;
		RST_i:		in	std_logic;
		HALT_i:		in	std_logic;
		IRQ_i:		in	std_logic;
		NMI_i:		in	std_logic;
		RnW_o:		out std_logic;
		VMA_o:	   out std_logic;
		BA_o:		out std_logic;
		A_o:			out std_logic_vector(15 downto 0);
	   D_i:			in	std_logic_vector(7 downto 0);
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
	signal	i_mux_ABL_INCL	: std_logic;
	signal	i_mux_ABL_PCL		: std_logic;
	signal	i_mux_ABL_SPL		: std_logic;
	signal	i_mux_ABL_ABLI	: std_logic;

	signal	i_mux_OBL_DB		: std_logic;

	signal	i_mux_ABLI_ABL	: std_logic;
	signal	i_mux_ABLI_IXL		: std_logic;
	signal	i_mux_ABLI_ACCA		: std_logic;
	signal	i_mux_ABLI_ACCB		: std_logic;
	signal	i_mux_ABLI_IXH	: std_logic;
	signal	i_mux_ABLI_FF		: std_logic;

	signal	i_mux_DB_T			: std_logic;
	signal	i_mux_DB_PCH		: std_logic;
	signal	i_mux_DB_SPH		: std_logic;
	signal	i_mux_DB_IXH		: std_logic;
	signal	i_mux_DB_PCL		: std_logic;
	signal	i_mux_DB_SPL		: std_logic;
	signal	i_mux_DB_IXL		: std_logic;
	signal	i_mux_DB_ACCA		: std_logic;
	signal	i_mux_DB_ACCB		: std_logic;
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

   signal   i_IR_Q_DBI        : std_logic_vector(7 downto 0); -- this comes from IR unless loading from DBI...TODO: think of a nicer way

	-- alu control and outputs
   signal   i_ALU_op          : t_alu_op;
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

	signal   i_CCR_ld_DB			: std_logic;
	signal	i_CCR_ld_ALU_Z		: std_logic;
	signal	i_CCR_ld_AND_ALU_Z: std_logic;
	signal	i_CCR_ld_ALU_N		: std_logic;
	signal	i_CCR_ld_ALU_V		: std_logic;
	signal	i_CCR_ld_ALU_C		: std_logic;
	signal	i_CCR_ld_ALU_H		: std_logic;
	signal	i_CCR_ld_SEV		: std_logic;
	signal	i_CCR_ld_SEC		: std_logic;
	signal	i_CCR_ld_SEI		: std_logic;
	signal	i_CCR_ld_CLV		: std_logic;
	signal	i_CCR_ld_CLC		: std_logic;
	signal	i_CCR_ld_CLI		: std_logic;

	signal	i_IR_ld_D			: std_logic;

	-- special CCR regs
	signal	r_CCR					: std_logic_vector(5 downto 0);
	signal	r_CCR_IM				: std_logic;

	-- incrementer
	signal	r_incl				: std_logic_vector(7 downto 0);
	signal	r_inch				: std_logic_vector(7 downto 0);
	signal	i_INC_H_src			: t_inc_h_src;
	signal	i_INC_L_src			: t_inc_l_src;
	signal	i_INC_act			: t_inc_act;

	-- other control signals
	signal	i_VMA			: std_logic;
	signal	i_RnW			: std_logic;

	
	signal i_next_state		: t_cpu_state;
	signal r_state			: t_cpu_state;

begin

--
-- ###                     #  #
-- #  #                    ####
-- #  #  #  #   ###        ####  #  #  #  #   ##    ###
-- ###   #  #  #           #  #  #  #  #  #  #  #  #
-- #  #  #  #   ##         #  #  #  #   ##   ####   ##
-- #  #  #  #     #        #  #  #  #  #  #  #        #
-- ###    ###  ###         #  #   ###  #  #   ##   ###
--

-- TODO: bus muxes should probably surface combinatorial or inconsistent 
-- behaviour when there are multiple sources active

	e_bus_mux_ABL:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 4
	)
	port map (
		SEL_i		=> (
			0 => i_mux_ABL_INCL,
			1 => i_mux_ABL_PCL,
			2 => i_mux_ABL_SPL,
			3 => i_mux_ABL_ABLI
		),
		D_i		=> (
			0 => i_INCL_Q,
			1 => i_PCL_Q,
			2 => i_SPL_Q,
			3 => ib_ABLI
		),
		D_o		=> ib_ABL
	);

	ib_OBL <= ib_DB when i_mux_OBL_DB = '1' else
				 ib_ABL;

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
		WIDTH => 16
	)
	port map (
		SEL_i		=> (
			0 => i_mux_DB_T,
			1 => i_mux_DB_PCH,
			2 => i_mux_DB_SPH,
			3 => i_mux_DB_IXH,
			4 => i_mux_DB_PCL,
			5 => i_mux_DB_SPL,
			6 => i_mux_DB_IXL,
			7 => i_mux_DB_ACCA,
			8 => i_mux_DB_ACCB,
			9 => i_mux_DB_CCR,
			10=> i_mux_DB_SUM,
			11=> i_mux_DB_DBI,
			12=> i_mux_DB_RESV,
			13=> i_mux_DB_NMIV,
			14=> i_mux_DB_SWIV,
			15=> i_mux_DB_IRQV
		),
		D_i		=> (
			0 => i_T_Q,
			1 => i_PCH_Q,
			2 => i_SPH_Q,
			3 => i_IXH_Q,
			4 => i_PCL_Q,
			5 => i_SPL_Q,
			6 => i_IXL_Q,
			7 => i_ACCA_Q,
			8 => i_ACCB_Q,
			9 => i_CCR_Q,
			10=> i_ALU_SUM_Q,
			11=> i_DBI_Q,
			12=> x"FE",
			13=> x"FC",
			14=> x"FA",
			15=> x"F8"
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
--  ##   #     #  #
-- #  #  #     #  #
-- #  #  #     #  #
-- ####  #     #  #
-- #  #  #     #  #
-- #  #  #     #  #
-- #  #  ####   ##
--

   e_alu:entity dossy_6800.dossy_6800_alu
   port map (   
      CLK_i    => CLK_i,

      OP_i     => i_ALU_op,
      C_i      => i_CCR_Q(CCIX_C),
      H_i      => i_CCR_Q(CCIX_H),
      V_i      => i_CCR_Q(CCIX_V),
      A_i      => ib_DB,
      B_i      => ib_ABLI,

      C_o      => i_ALU_CCR_Q(CCIX_C),
      H_o      => i_ALU_CCR_Q(CCIX_H),
      N_o      => i_ALU_CCR_Q(CCIX_N),
      V_o      => i_ALU_CCR_Q(CCIX_V),
      Z_o      => i_ALU_CCR_Q(CCIX_Z),
      SUM_o    => i_ALU_SUM_Q
   );

   i_ALU_CCR_Q(CCIX_I) <= '1';
   i_ALU_CCR_Q(7 downto 6) <= "11";


--
-- ###                #                                  ####   #    ##
-- #  #                           #                      #            #
-- #  #   ##    ###  ##     ###  ####   ##   # ##        #     ##     #     ##
-- ###   #  #  #  #   #    #      #    #  #  ##          ###    #     #    #  #
-- # #   ####  #  #   #     ##    #    ####  #           #      #     #    ####
-- #  #  #      ###   #       #   #    #     #           #      #     #    #
-- #  #   ##      #  ###   ###     ##   ##   #           #     ###   ###    ##
--              ##
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


	p_reg_ccr:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			
			if RST_i = '1' then
				-- TODO: this is a frig - discover what real CPU does.
				r_CCR <= "010000";
			else
				if i_CCR_ld_ALU_Z = '1' then
					r_CCR(CCIX_Z) <= i_ALU_CCR_Q(CCIX_Z);
				elsif i_CCR_ld_AND_ALU_Z = '1' then
					r_CCR(CCIX_Z) <= r_CCR(CCIX_Z) and i_ALU_CCR_Q(CCIX_Z);
				elsif i_CCR_ld_DB = '1' then
					r_CCR(CCIX_Z) <= ib_DB(CCIX_Z);
				end if;

				if i_CCR_ld_ALU_N = '1' then
					r_CCR(CCIX_N) <= i_ALU_CCR_Q(CCIX_N);
				elsif i_CCR_ld_DB = '1' then
					r_CCR(CCIX_N) <= ib_DB(CCIX_N);
				end if;

				if i_CCR_ld_ALU_V = '1' then
					r_CCR(CCIX_V) <= i_ALU_CCR_Q(CCIX_V);
				elsif i_CCR_ld_DB = '1' then
					r_CCR(CCIX_V) <= ib_DB(CCIX_V);
				elsif i_CCR_ld_SEV = '1' then
					r_CCR(CCIX_V) <= '1';
				elsif i_CCR_ld_CLV = '1' then
					r_CCR(CCIX_V) <= '0';
				end if;

				if i_CCR_ld_ALU_C = '1' then
					r_CCR(CCIX_C) <= i_ALU_CCR_Q(CCIX_C);
				elsif i_CCR_ld_DB = '1' then
					r_CCR(CCIX_C) <= ib_DB(CCIX_C);
				elsif i_CCR_ld_SEC = '1' then
					r_CCR(CCIX_C) <= '1';
				elsif i_CCR_ld_CLC = '1' then
					r_CCR(CCIX_C) <= '0';
				end if;

				if i_CCR_ld_ALU_H = '1' then
					r_CCR(CCIX_H) <= i_ALU_CCR_Q(CCIX_H);
				elsif i_CCR_ld_DB = '1'  then
					r_CCR(CCIX_H) <= ib_DB(CCIX_H);
				end if;

				if i_CCR_ld_DB then
					r_CCR_IM <= ib_DB(CCIX_I);
					r_CCR(CCIX_I) <= r_CCR(CCIX_I) or ib_DB(CCIX_I) or r_CCR_IM;
				elsif i_CCR_ld_SEI = '1' then
					r_CCR_IM <= '1';
					r_CCR(CCIX_I) <= '1';
				elsif i_CCR_ld_CLI = '1' then
					r_CCR(CCIX_I) <= r_CCR(CCIX_I) or r_CCR_IM;
					r_CCR_IM <= '0';
				else
					r_CCR(CCIX_I) <= r_CCR_IM;
				end if;
			end if;
		end if;
	end process;
	i_CCR_Q <= "11" & r_CCR;

	e_reg_dbi:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> VMA_o,
		D_i			=> D_i,
		D_o			=> i_DBI_Q
	);

   -- TODO: Fig.1 shows this coming from D_i, we have to mux IR with DBI in control
	e_reg_ir:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> i_IR_ld_D,
		D_i			=> i_DBI_Q,
		D_o			=> i_IR_Q
	);

--
-- ###
--  #                                               #
--  #    ###    ###  # ##   ##  ## #    ##   ###   ####   ##   # ##
--  #    #  #  #     ##    #  # # # #  #  #  #  #   #    #  #  ##
--  #    #  #  #     #     #### # # #  ####  #  #   #    ####  #
--  #    #  #  #     #     #    # # #  #     #  #   #    #     #
-- ###   #  #   ###  #      ##  #   #   ##   #  #    ##   ##   #
--

	-- this assumes a 16bit increment can be carried out in one cycle?
	p_inc:process(CLK_i)
	variable v_src_l : std_logic_vector(7 downto 0);
	variable v_src_h : std_logic_vector(7 downto 0);
	variable v_int	: std_logic_vector(8 downto 0); -- low order with carry
	begin
		if rising_edge(CLK_i) then

			case i_INC_L_src is 
				when abl =>
					v_src_l := ib_ABL;
				when db =>
					v_src_l := ib_DB;
				when others =>
					v_src_l := i_INCL_Q;
			end case;

			case i_INC_H_src is 
				when abh =>
					v_src_h := ib_ABH;
				when others =>
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
				when others =>	
					r_inch <= v_src_h;
			end case;


		end if;
	end process;

	i_INCH_Q <= r_inch;
	i_INCL_Q <= r_incl;

--
--  ##                                                   #      #
-- #  #   #           #                                  #
-- #     ####   ###  ####   ##        ## #    ###   ###  ###   ##    ###    ##
--  ##    #    #  #   #    #  #       # # #  #  #  #     #  #   #    #  #  #  #
--    #   #    #  #   #    ####       # # #  #  #  #     #  #   #    #  #  ####
-- #  #   #    # ##   #    #          # # #  # ##  #     #  #   #    #  #  #
--  ##     ##   # #    ##   ##        #   #   # #   ###  #  #  ###   #  #   ##
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

   i_IR_Q_DBI <= i_DBI_Q when i_IR_ld_D = '1' else i_IR_Q;

	e_ctl_gen:entity dossy_6800.dossy_6800_ctl_gen
	port map (
		state_i			=> r_state,
      IR_DBI_i       => i_IR_Q_DBI,
		IR_i				=> i_IR_Q,
		
		next_state_o	=> i_next_state,

		mux_ABL_INCL_o	=> i_mux_ABL_INCL,
		mux_ABL_PCL_o	=> i_mux_ABL_PCL,
		mux_ABL_SPL_o	=> i_mux_ABL_SPL,
		mux_ABL_ABLI_o	=> i_mux_ABL_ABLI,
		mux_OBL_DB_o	=> i_mux_OBL_DB,
		mux_ABLI_ABL_o	=> i_mux_ABLI_ABL,
		mux_ABLI_IXL_o	=> i_mux_ABLI_IXL,
		mux_ABLI_ACCA_o=> i_mux_ABLI_ACCA,
		mux_ABLI_ACCB_o=> i_mux_ABLI_ACCB,
		mux_ABLI_IXH_o	=> i_mux_ABLI_IXH,
		mux_ABLI_FF_o	=> i_mux_ABLI_FF,
		mux_DB_T_o		=> i_mux_DB_T,
		mux_DB_PCH_o	=> i_mux_DB_PCH,
		mux_DB_SPH_o	=> i_mux_DB_SPH,
		mux_DB_IXH_o	=> i_mux_DB_IXH,
		mux_DB_PCL_o	=> i_mux_DB_PCL,
		mux_DB_SPL_o	=> i_mux_DB_SPL,
		mux_DB_IXL_o	=> i_mux_DB_IXL,
		mux_DB_ACCA_o	=> i_mux_DB_ACCA,
		mux_DB_ACCB_o	=> i_mux_DB_ACCB,
		mux_DB_CCR_o	=> i_mux_DB_CCR,
		mux_DB_SUM_o	=> i_mux_DB_SUM,
		mux_DB_DBI_o	=> i_mux_DB_DBI,
		mux_DB_RESV_o	=> i_mux_DB_RESV,
		mux_DB_NMIV_o	=> i_mux_DB_NMIV,
		mux_DB_SWIV_o	=> i_mux_DB_SWIV,
		mux_DB_IRQV_o	=> i_mux_DB_IRQV,
		mux_ABH_T_o		=> i_mux_ABH_T,
		mux_ABH_INCH_o	=> i_mux_ABH_INCH,
		mux_ABH_PCH_o	=> i_mux_ABH_PCH,
		mux_ABH_SPH_o	=> i_mux_ABH_SPH,
		mux_ABH_IXH_o	=> i_mux_ABH_IXH,
		mux_ABH_FF_o	=> i_mux_ABH_FF,

		PCL_ld_INCL_o	=> i_PCL_ld_INCL,
		SPL_ld_ABL_o	=> i_SPL_ld_ABL,
		SPL_ld_DB_o		=> i_SPL_ld_DB,
		IXL_ld_ABL_o	=> i_IXL_ld_ABL,
		IXL_ld_DB_o		=> i_IXL_ld_DB,
		ACCB_ld_ABLI_o	=> i_ACCB_ld_ABLI,
		ACCB_ld_DB_o	=> i_ACCB_ld_DB,
		ACCA_ld_ABLI_o	=> i_ACCA_ld_ABLI,
		ACCA_ld_DB_o	=> i_ACCA_ld_DB,
		T_ld_DB_o		=> i_T_ld_DB,
		T_ld_ABH_o		=> i_T_ld_ABH,
		PCH_ld_INCH_o	=> i_PCH_ld_INCH,
		SPH_ld_DB_o		=> i_SPH_ld_DB,
		SPH_ld_ABH_o	=> i_SPH_ld_ABH,
		IXH_ld_DB_o		=> i_IXH_ld_DB,
		IXH_ld_ABH_o	=> i_IXH_ld_ABH,
		
		CCR_ld_DB_o			=> i_CCR_ld_DB,
		CCR_ld_ALU_Z_o		=> i_CCR_ld_ALU_Z,
		CCR_ld_AND_ALU_Z_o=> i_CCR_ld_AND_ALU_Z,
		CCR_ld_ALU_N_o		=> i_CCR_ld_ALU_N,
		CCR_ld_ALU_V_o		=> i_CCR_ld_ALU_V,
		CCR_ld_ALU_C_o		=> i_CCR_ld_ALU_C,
		CCR_ld_ALU_H_o		=> i_CCR_ld_ALU_H,
		CCR_ld_SEV_o		=> i_CCR_ld_SEV,
		CCR_ld_SEC_o		=> i_CCR_ld_SEC,
		CCR_ld_SEI_o		=> i_CCR_ld_SEI,
		CCR_ld_CLV_o		=> i_CCR_ld_CLV,
		CCR_ld_CLC_o		=> i_CCR_ld_CLC,
		CCR_ld_CLI_o		=> i_CCR_ld_CLI,

		IR_ld_D_o		=> i_IR_ld_D,

		INC_L_src_o		=> i_INC_L_src,
		INC_H_src_o		=> i_INC_H_src,
		INC_act_o		=> i_INC_act,

      ALU_op_o       => i_ALU_op,

		RnW_o				=> i_RnW,
		VMA_o				=> i_VMA

	);

	p_A:process(all)
	begin
		A_o <= ib_ABH & ib_OBL;
		VMA_o <= i_VMA;
		RnW_o <= i_RnW;
	end process;

	BA_o <= '0';
	D_o <= ib_DB;

end rtl;