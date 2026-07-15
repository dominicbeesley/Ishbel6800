-- MIT License
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Dominic Beesley https://github.com/dominicbeesley
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- ----------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	13/7/2026
-- Design Name: 
-- Module Name:    	max7219_matrix
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 		Drive a set of max7219 matrix displays, configurable 1..8 rows, N columns
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

-- assume matrix is arranged as 
-- col    0             1                2               .... n
-- row 0  <byte 0> 		<byte 1>         <byte 2>
--     1  <byte COLS>   <byte COLS + 1>  <byte COLS + 2> ...
--
-- SPI CLK will be CLK_I/CLKEN_I divided by 4
-- after initialisation refresh rate will CLK_I/CLKEN_I / ((COLS * 16) + 1) * ROWS)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package max7219_matrix_pack is
	type t_max7219_matrix_data is array(integer range <>) of std_logic_vector(7 downto 0);
end package max7219_matrix_pack;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.max7219_matrix_pack.all;

use work.common.all;

entity max7219_matrix is
	Generic (
		ROWS						: natural range 1 to 8 := 8;
		COLS						: positive := 4
	);
	port (
		RST_I			: in		std_logic;

		CLK_I			: in		std_logic;
		CLKEN_I		: in		std_logic;

		DATA_I		: in		t_max7219_matrix_data(0 to ROWS*COLS-1);

		SPI_nCS_o	: out		std_logic;
		SPI_DAT_o	: out		std_logic;
		SPI_CLK_o	: out		std_logic

	);
		
end max7219_matrix;


architecture rtl of max7219_matrix is

	constant MAX7219_CMD_NOP				: std_logic_vector(7 downto 0) := x"00";
	constant MAX7219_CMD_DECODEMODE		: std_logic_vector(7 downto 0) := x"09";
	constant MAX7219_CMD_INTENSITY		: std_logic_vector(7 downto 0) := x"0A";
	constant MAX7219_CMD_SCANLIMIT		: std_logic_vector(7 downto 0) := x"0B";
	constant MAX7219_CMD_SHUTDOWN			: std_logic_vector(7 downto 0) := x"0C";
	constant MAX7219_CMD_TEST				: std_logic_vector(7 downto 0) := x"0F";

	type t_state is (reset1, reset2, reset3, init, run);
	type t_row_state is (start, shifting);
	type t_bit_state is (phase0, phase1, phase2, phase3);

	signal	r_bit_state	: t_bit_state;
	signal	r_row_state	: t_row_state;
	signal	r_state		: t_state;


	signal	sr			: std_logic_vector(15 downto 0);
	signal	col_ix	: unsigned(numbits(COLS-1) - 1 downto 0);
	signal   row_ix   : unsigned(3 downto 0); 		-- note goes from 1..ROWS not 0..ROWS-1 !
	signal	dat_ix	: unsigned(numbits(ROWS*COLS-1)-1 downto 0);
	signal   bit_ix   : unsigned(3 downto 0);

begin

	p_row:process(RST_I, CLK_I, CLKEN_I)
	variable v_load : boolean;
	begin
		
		if RST_I = '1' then
			col_ix <= (others => '0');
			row_ix <= to_unsigned(1, row_ix'length);
			dat_ix <= (others => '0');
			bit_ix <= (others => '1');
			r_row_state <= start;
			r_state <= reset1;
			sr <= (others => '0');
		elsif rising_edge(CLK_I) then
			if CLKEN_I = '1' then

				v_load := false;

				if r_bit_state = phase1 then
					case r_row_state is
						when start =>
							col_ix <= (others => '0');
							bit_ix <= (others => '0');
							if row_ix = ROWS then
								row_ix <= to_unsigned(1, row_ix'length);
								dat_ix <= (others => '0');
								if r_state = reset1 then
									r_state <= reset2;
								elsif r_state = reset2 then
									r_state <= reset3;
								elsif r_state = reset3 then
									r_state <= init;
								else
									r_state <= run;
								end if;
							else
								row_ix <= row_ix + 1;
							end if;
						when others => null;
					end case;
				end if;

				if r_bit_state = phase2 then
					if r_row_state = shifting then
						if bit_ix = 15 then
							if col_ix = to_unsigned(COLS-1, col_ix'length) then
								r_row_state <= start;
								col_ix <= (others => '0');
							else
								v_load := true;
								bit_ix <= (others => '0');
								col_ix <= col_ix + 1;
							end if;
						else
							sr <= sr(14 downto 0) & sr(15);
							bit_ix <= bit_ix + 1;
						end if;
					else
						v_load := true;
						bit_ix <= (others => '0');
						r_row_state <= shifting;
					end if;
				end if;


				if v_load then
					if r_state = reset1 or r_state = reset2 or r_state = reset3 then
						sr <= (others => '0');
					elsif r_state = init then
						case to_integer(row_ix) is 
							when 2 | 7 =>
								sr <= MAX7219_CMD_TEST & "00000000";
							when 1 | 3 =>
								sr <= MAX7219_CMD_SHUTDOWN & "00000001";
							when 4 =>
								sr <= MAX7219_CMD_INTENSITY & "00000001";
							when 5 =>
								sr <= MAX7219_CMD_SCANLIMIT & std_logic_vector(to_unsigned(ROWS - 1, 8));
							when 6 =>
								sr <= MAX7219_CMD_DECODEMODE & "00000000";
							when others =>
								sr <= (others => '0');
						end case;
					else
						sr <= "0000" & std_logic_vector(row_ix) & DATA_I(to_integer(dat_ix));
						dat_ix <= dat_ix + 1;
					end if;
				end if;

			end if;

		end if;
	end process;
		
	p_clk:process(CLK_I, CLKEN_I)
	begin
		if rising_edge(CLK_I) then
			if CLKEN_I = '1' then				
				case r_bit_state is
					when phase0 =>
						SPI_CLK_o <= '0';
						r_bit_state <= phase1;
					when phase1 =>
						r_bit_state <= phase2;
					when phase2 =>
						r_bit_state <= phase3;
						SPI_CLK_o <= '1';
					when phase3 =>
						r_bit_state <= phase0;
					when others => 
						r_bit_state <= phase3;
				end case;
			end if;
		end if;

	end process;

	
	p_bits:process(RST_I, CLK_I, CLKEN_I)
	begin
		if RST_I = '1' then
			SPI_nCS_o <= '1';
			SPI_DAT_o <= '1';
		elsif rising_edge(CLK_I) then
			if CLKEN_I = '1' then
				
				if r_bit_state = phase0 then
					if r_state = init or r_state = run then
						if r_row_state = start then
							SPI_nCS_o <= '1';
						else
							SPI_nCS_o <= '0';
						end if;
						SPI_DAT_o <= sr(sr'high);
					end if;
				end if;
			end if;
		end if;

	end process;
	

end rtl;