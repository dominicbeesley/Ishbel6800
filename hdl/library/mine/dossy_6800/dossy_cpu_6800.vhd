library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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

	signal	i_PC_temp	: unsigned(15 downto 0);
	signal	i_PC_inc		: unsigned(0 downto 0);
	signal   r_PC			: unsigned(15 downto 0);

	signal	i_DI_mux		: std_logic_vector(7 downto 0);
	signal   ir_alu		: std_logic_vector(7 downto 0); -- latched ALU result

	signal	r_IR			: std_logic_vector(7 downto 0);

	signal	r_SP			: std_logic_vector(15 downto 0);
	signal	r_X			: std_logic_vector(15 downto 0);

begin

	p_PC_temp:process(all)
	begin
		case r_state is
			when s_jmp1 =>
				i_PC_temp <= unsigned(ir_alu & i_DI_mux);
			when others =>
				i_PC_temp <= r_PC;
		end case;
	end process;

	p_PC_inc:process(all)
	begin
		case r_state is 
			when s_jmp0 | s_fetch | s_ldix_imm =>
				i_PC_inc <= "1";
			when s_decode =>
				case r_IR(7 downto 4) is
					when x"0"|x"1"|x"3"|x"4"|x"5"|x"6"|x"A"|x"E" =>
						i_PC_inc <= "0";
					when x"2"|x"7"|x"8"|x"9"|x"B"|x"C"|x"D"|x"F" =>
						i_PC_inc <= "1";
					when others => 
						i_PC_inc <= "0";
				end case;
			when others => 
				i_PC_inc <= "0";
		end case;
	end process;

	p_PC:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			if RST_i = '1' then
				r_PC <= x"FFFE";
			else
				r_PC <= i_PC_temp + i_PC_inc;
			end if;
		end if;
	end process;

	-- TODO: address bus mux

	p_ADDR:process(all)
	begin
		case r_state is 
			when s_txs0 =>
				A_o	<= r_X;
				VMA_o <= '0';
			when s_txs1 =>
				A_o	<= r_SP;
				VMA_o <= '0';
			when others => 
				A_o 	<= std_logic_vector(r_PC);
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

			when s_txs0 =>		i_next_state <= s_txs1;
			when s_txs1 =>		i_next_state <= s_fetch;
			when s_tsx0 =>		i_next_state <= s_tsx1;
			when s_tsx1 =>		i_next_state <= s_fetch;

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


	-- REGISTER FILE -- maybe simplify this
	p_X:process(CLK_i)
	begin
		if rising_edge(CLK_i) then
			-- TODO: reset?
			if r_state = s_ldix_imm then
				if r_IR(6) = '0' then
					r_SP <= ir_alu & i_DI_mux;
				else
					r_X <= ir_alu & i_DI_mux;
				end if;
			elsif r_state = s_txs0 then
				r_SP <= r_X;
			elsif r_state = s_tsx0 then
				r_X <= r_SP;
			end if;
		end if;
	end process;

end rtl;