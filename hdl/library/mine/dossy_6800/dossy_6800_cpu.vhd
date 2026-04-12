----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	12/4/2025 
-- Design Name: 
-- Module Name:    	dossy_6800_cpu
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		main cpu file
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
		CLK_i:    	in  std_logic;
		RST_i:    	in  std_logic;
		HALT_i:     in  std_logic;
		IRQ_i:      in  std_logic;
		NMI_i:      in  std_logic;
		RnW_o:    	out std_logic;
		VMA_o:	   out std_logic;
		BA_o:       out std_logic;
		A_o:	 		out std_logic_vector(15 downto 0);
	   D_i:	 		in  std_logic_vector(7 downto 0);
	   D_o:	 		out std_logic_vector(7 downto 0)
		);
end;

architecture rtl of dossy_6800_cpu is

	-- internal buses
	signal	ib_DB					: std_logic_vector(7 downto 0);
	signal	ib_ABL				: std_logic_vector(7 downto 0);
	signal	ib_ABLI				: std_logic_vector(7 downto 0);
	signal	ib_ABH				: std_logic_vector(7 downto 0);

	-- internal bus mux controls
	signal	i_mux_ABL_INCL 	: std_logic;
	signal	i_mux_ABL_PCL 		: std_logic;
	signal	i_mux_ABL_SPL	 	: std_logic;
	signal	i_mux_ABL_IXL	 	: std_logic;
	signal	i_mux_ABL_ABLI 	: std_logic;

	signal	i_mux_ABLI_ABL 	: std_logic;
	signal	i_mux_ABLI_IXL		: std_logic;
	signal	i_mux_ABLI_ACCA 	: std_logic;
	signal	i_mux_ABLI_ACCB 	: std_logic;
	signal	i_mux_ABLI_IXH 	: std_logic;

	signal	i_mux_DB_T 			: std_logic;
	signal	i_mux_DB_PCH		: std_logic;
	signal	i_mux_DB_SPH	 	: std_logic;
	signal	i_mux_DB_IXH	 	: std_logic;
	signal	i_mux_DB_CCR	 	: std_logic;
	signal	i_mux_DB_SUM		: std_logic;
	signal	i_mux_DB_DBI		: std_logic;

	signal	i_mux_ABH_T		 	: std_logic;
	signal	i_mux_ABH_INCH		: std_logic;
	signal	i_mux_ABH_PCH	 	: std_logic;
	signal	i_mux_ABH_SPH 		: std_logic;
	signal	i_mux_ABH_IXH	 	: std_logic;

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
	signal	i_INLC_ld_ABL		: std_logic;
	signal	i_INLC_ld_DB		: std_logic;
	
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
	
	signal	i_INCH_ld_ABH		: std_logic;

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
	signal	i_INC_ctl			: t_inc_control;

	-- other inputs to BUS MUXes
	signal	i_SUM_Q				: std_logic_vector(7 downto 0);

begin


--
-- ###                     #  #  #  #  #  #
-- #  #                    ####  #  #  #  #
-- #  #  #  #   ###        ####  #  #   ##    ##    ###
-- ###   #  #  #           #  #  #  #   ##   #  #  #
-- #  #  #  #   ##         #  #  #  #  #  #  ####   ##
-- #  #  #  #     #        #  #  #  #  #  #  #        #
-- ###    ###  ###         #  #   ##   #  #   ##   ###
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


	e_bus_mux_ABLI:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 5
	)
	port map (
		SEL_i		=> (
			0 => i_mux_ABLI_ABL,
			1 => i_mux_ABLI_IXL,
			2 => i_mux_ABLI_ACCA,
			3 => i_mux_ABLI_ACCB,
			4 => i_mux_ABLI_IXH
		),
		D_i		=> (
			0 => ib_ABL,
			1 => i_IXL_Q,
			2 => i_ACCA_Q,
			3 => i_ACCB_Q,
			4 => i_IXH_Q
		),
		D_o		=> ib_ABLI
	);


	e_bus_mux_DB:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 7
	)
	port map (
		SEL_i		=> (
			0 => i_mux_DB_T,
			1 => i_mux_DB_PCH,
			2 => i_mux_DB_SPH,
			3 => i_mux_DB_IXH,
			4 => i_mux_DB_CCR,
			5 => i_mux_DB_SUM,
			6 => i_mux_DB_DBI
		),
		D_i		=> (
			0 => i_T_Q,
			1 => i_PCH_Q,
			2 => i_SPH_Q,
			3 => i_IXH_Q,
			4 => i_CCR_Q,
			5 => i_SUM_Q,
			6 => i_DBI_Q
		),
		D_o		=> ib_DB
	);

	e_bus_mux_ABH:entity dossy_6800.dossy_6800_mux8
	generic map (
		WIDTH => 5
	)
	port map (
		SEL_i		=> (
			0 => i_mux_ABH_T,
			1 => i_mux_ABH_INCH,
			2 => i_mux_ABH_PCH,
			3 => i_mux_ABH_SPH,
			4 => i_mux_ABH_IXH
		),
		D_i		=> (
			0 => i_T_Q,
			1 => i_INCH_Q,
			2 => i_PCH_Q,
			3 => i_SPH_Q,
			4 => i_IXH_Q
		),
		D_o		=> ib_ABH
	);

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
		WE_i			=> i_DBI_ld_D,
		D_i			=> D_i,
		D_o			=> i_DBI_Q
	);

	e_reg_ir:entity dossy_6800.dossy_6800_reg8
	port map (
		CLK_i			=> CLK_i,
		WE_i			=> i_IR_ld_D,
		D_i			=> D_i,
		D_o			=> i_DBI_Q
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
	variable v_int	: std_logic_vector(8 downto 0); -- low order with carry
	begin
		if rising_edge(CLK_i) then
			case i_INC_ctl is
				when vec_res =>
					r_incl <= x"FE";
				when vec_nmi =>
					r_incl <= x"FC";
				when vec_swi =>
					r_incl <= x"FA";
				when vec_irq =>
					r_incl <= x"F8";
				when ld_a =>
					r_incl <= ib_ABL;
				when ld_db_ah =>
					r_incl <= ib_DB;
				when inc => 
					v_int := std_logic_vector("0" & unsigned(r_incl) + 1);
					r_incl <= v_int(7 downto 0);
				when dec	=> 
					v_int := std_logic_vector("0" & unsigned(r_incl) - 1);
					r_incl <= v_int(7 downto 0);
				when others =>
					r_incl <= r_incl;
			end case;

			case i_INC_ctl is
				when vec_res | vec_nmi | vec_swi	| vec_irq =>
					r_inch <= x"FF";
				when ld_a | ld_db_ah =>
					r_inch <= ib_ABH;
				when inc => 
					if v_int(8) = '1' then
						r_inch <= std_logic_vector(unsigned(r_inch) + 1);
					end if;
				when dec =>
					if v_int(8) = '1' then
						r_inch <= std_logic_vector(unsigned(r_inch) - 1);
					end if;
				when inc_page =>
					r_inch <= std_logic_vector(unsigned(r_inch) + 1);
				when others	=>	
					r_inch <= r_inch;
			end case;


		end if;
	end process;


end rtl;