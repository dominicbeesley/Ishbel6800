library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dossy_cpu_6800 is
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

architecture rtl of dossy_cpu_6800 is

	type t_state is (
			s_reset,
			s_jmp0,
			s_jmp1,
			s_decode,
			s_fetch,
			s_ldix_imm,

			s_tsx0,
			s_tsx1,
			s_txs0,
			s_txs1,

			s_TESTBAD
		);

	signal   r_state		: t_state;
	signal	i_next_state: t_state;



	signal	i_DI_mux		: std_logic_vector(7 downto 0);
	signal   ir_alu		: std_logic_vector(7 downto 0); -- latched ALU result

	signal	r_IR			: std_logic_vector(7 downto 0);

	-- 16 bit registers
	signal   i_A_next		: std_logic_vector(15 downto 0);
	signal	r_A			: std_logic_vector(15 downto 0);
	signal   r_PC			: std_logic_vector(15 downto 0);
	signal	r_SP			: std_logic_vector(15 downto 0);
	signal	r_X			: std_logic_vector(15 downto 0);

	-- 16 bit register control
	type		t_A_ld is (keep, PC, SP, X, ALU, inc, dec);
	signal	i_A_ld 		: t_A_ld;
	type		i_IX_ld is (keep, A);
	signal   i_PC_ld		: i_IX_ld;
	signal   i_X_ld		: i_IX_ld;
	signal   i_SP_ld		: i_IX_ld;

begin

	p_PC_ld:process(all)
	begin
		case r_state is 
			when s_fetch =>
				i_PC_ld <= A;
			when others =>
				case i_next_state is
					when s_ldix_imm =>
						i_PC_ld <= A;
					when others =>
						i_PC_ld <= keep;	
				end case;
		end case;
	end process;

	p_A_ld:process(all)
	begin
		case r_state is
			when s_reset =>
				i_A_ld <= keep;
			when s_jmp1 =>
				i_A_ld <= ALU;
			when others =>
				case i_next_state is 
					when s_fetch =>
						i_A_ld <= PC;
					when s_tsx0 =>
						i_A_ld <= SP;
					when s_txs0 =>
						i_A_ld <= X;
					when others =>
						i_A_ld <= inc;
				end case;
		end case;
	end process;

	p_X_ld:process(all)
	begin
		case i_next_state is 
			when s_tsx0 =>
				i_X_ld <= A;
			when others =>
				i_X_ld <= keep;	
		end case;
	end process;

	p_SP_ld:process(all)
	begin
		case i_next_state is 
			when s_txs1 =>
				i_SP_ld <= A;
			when others =>
				i_SP_ld <= keep;	
		end case;
	end process;

	p_r_A_next:process(all)
	begin
		case i_A_ld is
			when PC => i_A_next <= r_PC;
			when SP => i_A_next <= r_SP;
			when X =>  i_A_next <= r_X;
			when inc => i_A_next <= std_logic_vector(unsigned(r_A) + 1);
			when dec => i_A_next <= std_logic_vector(unsigned(r_A) + 1);
			when ALU => i_A_next <= ir_alu & i_DI_mux;
			when others => i_A_next <= r_A;
		end case;
	end process;

	p_r_A:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			if RST_i = '1' then
				r_A <= x"FFFE";
			else
				r_A <= i_A_next;
			end if;
		end if;
	end process;

	p_r_PC:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			case i_PC_ld is
				when A =>
					r_PC <= i_A_next;
				when others =>
					r_PC <= r_PC;
			end case;				
		end if;
	end process;

	p_r_X:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			case i_X_ld is
				when A =>
					r_X <= i_A_next;
				when others =>
					r_X <= r_X;
			end case;				
		end if;
	end process;

	p_r_SP:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			case i_SP_ld is
				when A =>
					r_SP <= i_A_next;
				when others =>
					r_SP <= r_SP;
			end case;				
		end if;
	end process;

	A_o <= r_A;

	
	p_VMA:process(all)
	begin
		case r_state is 
			when s_txs0 =>
				VMA_o <= '0';
			when s_txs1 =>
				VMA_o <= '0';
			when others => 
				VMA_o <= '1';				
		end case;
	end process;

	p_next_state:process(all)
	begin
		case r_state is
			when s_reset => 		i_next_state <= s_jmp0;
			when s_jmp0  =>		i_next_state <= s_jmp1;
			when s_jmp1  =>		i_next_state <= s_fetch;
			when s_fetch =>		i_next_state <= s_decode;

			when s_txs0 =>			i_next_state <= s_txs1;
			when s_txs1 =>			i_next_state <= s_fetch;
			when s_tsx0 =>			i_next_state <= s_tsx1;
			when s_tsx1 =>			i_next_state <= s_fetch;

			when s_decode=>		
				case r_IR is
					when x"CE"|x"8E" =>
						i_next_state <= s_ldix_imm;
					when x"35" =>
						i_next_state <= s_txs0;
					when x"30" =>
						i_next_state <= s_tsx0;
					when others => 
						i_next_state <= s_fetch;
				end case;

			when s_ldix_imm =>
				i_next_state <= s_fetch;

			when others	 =>
				i_next_state <= s_TESTBAD;					
		end case;
	end process;

	p_state:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			if RST_i = '1' then
				r_state <= s_reset;
			else
				r_state <= i_next_state;
			end if;
		end if;
	end process;

	p_IR:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			if RST_i then
				r_IR <= x"01"; -- NOP - does this matter, probably not
			else
				if r_state = s_fetch then
					r_IR <= i_DI_mux;
				end if;
			end if;
		end if;
	end process;

	BA_o <= '0';
	RnW_o <= '1';
	D_o <= (others => '0');

	i_DI_mux <= D_i;
	p_t:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			ir_alu <= i_DI_mux;
		end if;
	end process;



end rtl;