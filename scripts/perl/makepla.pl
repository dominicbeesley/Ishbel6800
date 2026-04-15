#!/usr/bin/env perl

use strict;
use Data::Dumper;


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
						vhdl => "i_next_state <= $1;"
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

close $fh_out;
