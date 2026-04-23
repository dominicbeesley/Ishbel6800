#!/usr/bin/env perl

use strict;
use Data::Dumper;
use DateTime;

sub usage($$) {
	my ($fh, $msg) = @_;

	print "makepla.pl <input file> <output vhdl>\n";
	
	$msg && die $msg;
}

my $fn_in = shift or usage(*STDERR, "Missing input file argument");
my $fn_out = shift or usage(*STDERR, "Missing output file argument");

open(my $fh_in, "<", $fn_in) or usage(*STDERR, "Cannot open \"$fn_in\" for input : $!");


 ###                  #           #          ##   #           #           #
 #  #                 #           #         #                       #
 #  #   ##    ###   ###         ###   ##    #    ##    ###   ##    ####  ##     ##   ###    ###
 ###   #  #  #  #  #  #        #  #  #  #  ###    #    #  #   #     #     #    #  #  #  #  #
 # #   ####  #  #  #  #        #  #  ####   #     #    #  #   #     #     #    #  #  #  #   ##
 #  #  #     # ##  #  #        #  #  #      #     #    #  #   #     #     #    #  #  #  #     #
 #  #   ##    # #   ###         ###   ##    #    ###   #  #  ###     ##  ###    ##   #  #  ###

my %xfers = ();
my %statements = ();
my %states = ();

use POSIX qw(strftime);
my $now = time();
my $nowstr = strftime('%FT%TZ', gmtime($now));

use constant {
	STATE_XFERS => 0,
	STATE_STATEMENTS => 1,
	STATE_STATES => 2
};

my $in_state = 0;
my $cur_xfer;
my $cur_state;

while (<$fh_in>) {
	
	my $l = $_;
	$l =~ s/#.*//;
	$l =~ s/^\s+//;
	$l =~ s/[\s\r\n]+$//;


	if ($l ne "") {
		if ($l =~ /=+\s*(\w+(\s\w+)*)\s*=+/) {
			my $sec = uc($1);
			print "SECTION $sec\n";
			if ($sec eq "TRANSFERS") {
				$in_state = STATE_XFERS;
			} elsif ($sec eq "STATEMENTS") {
				$in_state = STATE_STATEMENTS;
			} elsif ($sec eq "STATES") {

				print Dumper(%xfers);

				$in_state = STATE_STATES;
			} else {
				die "Unrecognised section $sec";
			}
		} else {
			if ($in_state == STATE_XFERS) {
				if ($l =~ /^\[\s*(REG|MUX)\s+(\w+)\s*(!(\w+(\s*,\s*\w+)*))?\s*\]$/) {
					my ($t, $k, $excl) = ($1, $2, $4);
					exists $xfers{$k} and die "Duplicate TRANSFER def \"$k\"";				

					$cur_xfer = {
						key => $k,
						typ => $t,
						excl => [ map {s/^\s+|\s+$//g; $_}
  									 split(/,/, $excl) ],
  						defs => {}
					};

					$xfers{$k} = $cur_xfer;
				} elsif ($l =~ /(\w+)\s+{\s*(.*?)\s*}/) {
					$cur_xfer or die "Transfer defined before destination";
					$cur_xfer->{defs}->{$1} = $2;
				} else {
					die "Unrecognised line in transfers [$cur_xfer->{key}] \"$l\"";
				}
			} elsif ($in_state == STATE_STATEMENTS) {
				if ($l =~ /(\w+)\s+{\s*(.*?)\s*}/) {
					my ($k, $vhdl) = ($1, $2);
					exists $statements{$k} and die "Duplicate STATEMENT def \"$k\"";				

					$statements{$k} = $vhdl;
				} else {
					die "Unrecognised line in statements \"$l\"";
				}
			} elsif ($in_state == STATE_STATES) {
				if ($l =~ /^\[\s*(\w+)\s*(,\s*(\w+(\s*,\s*\w+)*))?\s*\]$/) {
					my ($k, $alias) = ($1, $3);
					my @aliases = ();
					foreach my $ka (map {s/^\s+|\s+$//g; $_}
  									 split(/,/, $alias)) {
						if ($ka) {
							exists($states{$ka}) and die "State alias \"$ka\" already defined";

							$states{$ka} = {
								key => $ka,
								type => "alias",
								alias => $k
							};

							push @aliases, $ka;
						}
  					}

					exists($states{$k}) and die "State \"$k\" already defined";
					$cur_state = {
						key => $k,
						type => "state",
						lines => [],
						aliases => join("|", @aliases)
					};
					$states{$k} = $cur_state;
				
				} elsif ($l =~ /^{\s*(.*?)\s*}$/) {
					$cur_state or die "State content without state definition";

					push @{$cur_state->{lines}}, {
						type => "vhdl",
						vhdl => $1
					};
				} elsif ($l =~ /\s*(\w+)(\s*->\s*(\w+)\s*(,\s*(\w+(\s*,\s*\w+)*))?)+/) {
						
					my @parts = ();

					foreach my $pp (map {s/^\s+|\s+$//g; $_}
  									 split(/->/, $l)) {
											
						push @parts, [ map {s/^\s+|\s+$//g; $_}
  									 split(/,/, $pp) ];
  					}
  					my $l = scalar @parts;
  					for (my $i = 0 ; $i < $l - 1; $i++) {

						scalar @{@parts[$i]} == 1 or die "Source of data transfer must be a singleton";
						my $src = @{@parts[$i]}[0];

						foreach my $dest (@{@parts[$i+1]}) {
							exists($xfers{$dest}) or die "No destination \"$dest\"";
							my $xf = $xfers{$dest};

							exists($xf->{defs}->{$src}) or die "No definition for $src->$dest";
							my $vhdl = $xf->{defs}->{$src};

							push @{$cur_state->{lines}}, {
								type => "xfer",
								xfer => $dest,
								vhdl => $vhdl
							};	
						}
  					}
				} elsif ($l =~ /NEXT\s*=\s*(\w+)/) {
					push @{$cur_state->{lines}}, {
						type => "next",
						vhdl => "next_state_o <= $1;"
					};				
				} else {
					# look for a statement
					exists $statements{$l} or die "Unrecognised line in states \"$l\"";
					push @{$cur_state->{lines}}, {
						type => "statement",
						vhdl => $statements{$l}
					};	
				}
			} else {
				die "Unhandled state";
			}
		}
	}
}

close $fh_in;

print Dumper(%states);

open(my $fh_out, ">", $fn_out) or usage(*STDERR, "Cannot open \"$fn_out\" for output : $!");


print $fh_out <<'ENDVHDL';
-- THIS IS A GENERATED FILE - SEE makepla.pl - DO NET EDIT THIS FILE --
ENDVHDL
print $fh_out "-- GENERATED : $nowstr\n";
print $fh_out <<'ENDVHDL';
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
	CCR_i				: in  std_logic_vector(7 downto 0); -- registered CPU status flags
	T_Q_i				: in  std_logic_vector(7 downto 0); -- used for branch page carries : TODO: think of cheaper way

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
	mux_ABLI_00_o	: out	std_logic;
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
				state_i = CPX_TSL0_D02 or
				state_i = INXDEX_TSL0 or
				state_i = GI_TSL0_D01 or
				state_i = GII_ACC_TSL0_D01 or
				state_i = xBA_TSL0_D01 or
				state_i = Txx_TSL0_D01 or
				state_i = DAA_TSL0_D01
			);
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

			elsif PMATCH(IR_DBI_i, "0001000-") then
				return xBA_T1_D00;
			elsif PMATCH(IR_DBI_i, "0001011-") then
				return Txx_T1_D00;
			elsif PMATCH(IR_DBI_i, "00011001") then
				return DAA_T1_D00;
			elsif PMATCH(IR_DBI_i, "00011011") then
				return xBA_T1_D00;

			elsif PMATCH(IR_DBI_i, "0010----") then
				return BRA_T1_IDX0;

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

			-- NOTE: FOR GII JMP is caught at end of EXT/IDX addressing mode
			elsif PMATCH(IR_DBI_i, "010-----") then
				return GII_ACC_T1_D00;
			elsif PMATCH(IR_DBI_i, "011-----") then
				return GII_MEM_T1_D00;

			elsif PMATCH(IR_DBI_i, "10--1100") then
				return CPX_T1_D00;
			elsif PMATCH(IR_DBI_i, "1---1110") then
				return LDx_T1_D00;
			elsif PMATCH(IR_DBI_i, "1---1111") then
				return STx_T1_D00;
			elsif PMATCH(IR_DBI_i, "1---0111") then
				return GI_STA_T1_D00;
			elsif PMATCH(IR_DBI_i, "100011-1") then
				return BSR_T1_IDX0;
			-- JSR is special case at end of EXT/IDX modes
			--elsif PMATCH(IR_DBI_i, "101-11-1") then
			--	return JBSR_T1_GP50;
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
		mux_ABLI_00_o		<= '0';
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
ENDVHDL

my $indent;

foreach my $ks (sort keys %states) {
	$indent = 3;
	my $state = $states{$ks};

	if ($state->{type} eq "state") {
		print $fh_out ("   " x $indent) . "when $ks" . ($state->{aliases}?"|":"") . $state->{aliases} . " =>\n";
		
		$indent++;

		foreach my $l (@{$state->{lines}}) {
			my $vhdl = $l->{vhdl};

			$vhdl =~ s/\s+/ /g;

			if ($vhdl =~ /^(end\s+if|else|elsif)\b/) {
				$indent--;
			}
			print $fh_out ("   " x $indent) . $vhdl . "\n";
			if ($vhdl =~ /^(if|else|elsif)\b/) {
				$indent++;
			}
		}

		print $fh_out "\n";
	}
}

print $fh_out <<'ENDVHDL';
			when others => null;
		end case;
	end process;

end rtl;
ENDVHDL

close $fh_out;
