-- MIT License
-- -----------------------------------------------------------------------------
-- Copyright (c) 2022 Dominic Beesley https://github.com/dominicbeesley
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
-- -----------------------------------------------------------------------------


-- Company: 			Dossytronics
-- Engineer: 			Dominic Beesley
-- 
-- Create Date:    	24/4/2026
-- Design Name: 
-- Module Name:    	
-- Project Name:		ws_6800_one
-- Target Devices: 
-- Tool versions: 
-- Description: 		A project to exercise the dossy_6800 core
-- Dependencies: 
--
-- Revision: 
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.mk1board_types.all;

library work;
use work.common.all;

library dossy_6800;
use dossy_6800.dossy_6800.all;

entity ws_6800_one is
	generic (
		ROOT									: string := "."
		);
	port(
		-- crystal osc 50Mhz - on WS board
		CLK_50M_i							: in		std_logic;
		EXT_nRESET_i						: in		std_logic;								-- WS button

		LED_o									: out		std_logic_vector(3 downto 0);

		FT245_nRD_o							: out		std_logic;
		FT245_nWR_o							: out		std_logic;
		FT245_nRXF_i						: in		std_logic;
		FT245_nTXE_i						: in		std_logic;
		FT245_PWR_o							: out		std_logic;
		FT245_nRST_o						: out		std_logic;
		FT245_D_io							: inout	std_logic_vector(7 downto 0);

		lcd32_D_io							: inout	std_logic_vector(15 downto 0);
		lcd32_nCS_o							: out		std_logic;
		lcd32_RS_o							: out		std_logic;
		lcd32_nWR_o							: out		std_logic;
		lcd32_nRD_o							: out		std_logic;
		lcd32_nRESET_o						: out		std_logic;
		
		touch_irq_i							: in		std_logic;
		touch_nCS_o							: out		std_logic;
		touch_SCLK_o						: out		std_logic;
		touch_MOSI_o						: out		std_logic;
		touch_MISO_i						: in		std_logic;

		LCD12864_N_o						: out		std_logic;
		LCD12864_RST_o						: out		std_logic;
		LCD12864_PSB_o						: out		std_logic;
		LCD12864_P_o						: out		std_logic;
		LCD12864_RS_o						: out		std_logic;
		LCD12864_RnW_o						: out		std_logic;
		LCD12864_E_o						: out		std_logic;
		LCD12864_D_io						: inout	std_logic_vector(7 downto 0);

		-- seven segment LED matrix on 16I/Os_2
		disp0_seg_o							: out		std_logic_vector(7 downto 0);
		disp0_sel_o							: out		std_logic_vector(3 downto 0)

	);
end ws_6800_one;

architecture rtl of ws_6800_one is

	constant CLOCK_SPEED		: natural := 48;

	signal	i_clk_pll		: std_logic;
	signal	i_rst				: std_logic;

	signal	r_clken_ring	: std_logic_vector(3 downto 0) := (0 => '1', others => '0');

	signal	i_clken_addr	: std_logic;
	signal	i_clken_mems	: std_logic; -- memory transfer start
	signal	i_clken_cpu 	: std_logic;

	signal	i_RDen			: std_logic;
	signal	i_WRen			: std_logic;

	signal	i_CS_RAM			: std_logic;
	signal	i_CS_ROM			: std_logic;
	signal	i_CS_FT245_D	: std_logic;	-- data
	signal	i_CS_FT245_S	: std_logic;	-- status
	signal	i_CS_LCD32		: std_logic;
	signal   i_CS_LCD12864	: std_logic;
	signal   i_CS_VIA			: std_logic;
	signal   i_CS_1M			: std_logic;

	signal	i_cpu_RnW		: std_logic;
	signal	i_cpu_VMA		: std_logic;
	signal	i_cpu_A			: std_logic_vector(15 downto 0);
	signal	i_cpu_D_i		: std_logic_vector(7 downto 0);
	signal	i_cpu_D_o		: std_logic_vector(7 downto 0);

	signal	i_ram_we			: std_logic;
	signal	i_ram_D_o		: std_logic_vector(7 downto 0);
	signal	i_rom_D_o		: std_logic_vector(7 downto 0);
	signal   i_via_D_o		: std_logic_vector(7 downto 0);

	signal	i_via_nIRQ		: std_logic;

	signal	r_lcd_lat		: std_logic_vector(7 downto 0); -- latches 16 bit data see

	constant CLK_4_DIV		: natural := CLOCK_SPEED / 4;
	signal 	r_via_1MHzE		: std_logic;
	signal	r_via_clkdiv	: unsigned(numbits(CLK_4_DIV-1)-1 downto 0) 
											:= to_unsigned(CLK_4_DIV - 1, numbits(CLK_4_DIV-1));
	signal	r_via_phase		: unsigned(1 downto 0) := "00";
	signal	r_via_ena4		: std_logic;

begin

	
	e_main_pll:entity work.main_pll
	port map
	(
		areset	=>	'0',
		inclk0	=>	CLK_50M_i,
		c0			=>	i_clk_pll,
		locked	=>	open
	);

	LED_o(0) <= i_via_nIRQ;
	LED_o(1) <= i_cpu_A(0);
	LED_o(2) <= i_cpu_A(14);
	LED_o(3) <= i_cpu_A(15);

	p_reset:process(i_clk_pll, EXT_nRESET_i)
	variable v_ctr : unsigned(8 downto 0) := (others => '0');
	begin
		
		if rising_edge(i_clk_pll) then
			if EXT_nRESET_i = '0' then
				v_ctr := (others => '0');
			elsif v_ctr(v_ctr'high) = '0' then
				v_ctr := v_ctr + 1;
			end if;

			i_rst <= not(v_ctr(v_ctr'high));
		end if;
	end process;


	--TODO: the clock stretching is very basic - it could be improved

	p_clken:process(i_clk_pll, i_rst)
	variable v_stretch : boolean;
	begin
		if rising_edge(i_clk_pll) then
			v_stretch := false;
			if i_CS_1M = '1' then
				if r_clken_ring(1) = '1' and r_via_phase /= "00" then
					v_stretch := true;
				elsif r_clken_ring(3) = '1' and (r_via_phase /= "11" or r_via_ena4 = '0') then
					v_stretch := true;
				end if;
			end if;

			if not v_stretch then
				r_clken_ring <= r_clken_ring(r_clken_ring'high-1 downto 0) & r_clken_ring(r_clken_ring'high);
			end if;
		end if;
	end process;

	p_1MHz_VIA:process(i_clk_pll)
	begin
		if rising_edge(i_clk_pll) then
			r_via_ena4 <= '0';
			if r_via_clkdiv = 0 then
				r_via_clkdiv <= to_unsigned(CLK_4_DIV - 1, numbits(CLK_4_DIV-1));
				r_via_ena4 <= '1';
			else
				r_via_clkdiv <= r_via_clkdiv - 1;
			end if;
		end if;
	end process;

	p_VIA_phase:process(i_clk_pll)
	begin
		if rising_edge(i_clk_pll) then
			r_via_1MHzE <= std_logic(r_via_phase(1)); -- need this to be 1 cycle late for reads
			if r_via_ena4 = '1' then
				r_via_phase <= r_via_phase + 1;
			end if;
		end if;
	end process;


	i_clken_addr <= r_clken_ring(1);
	i_clken_mems <= r_clken_ring(2);
	i_clken_cpu  <= r_clken_ring(0);
	i_RDen		 <= r_clken_ring(2) or r_clken_ring(3);
	i_WRen		 <= r_clken_ring(2) or r_clken_ring(3);

	p_cs:process(all)
	begin
		if i_rst = '1' then
			i_CS_RAM <= '0';
			i_CS_ROM <= '0';
			i_CS_FT245_D <= '0';
			i_CS_FT245_S <= '0';
			i_CS_LCD32 <= '0';
			i_CS_LCD12864 <= '0';
			i_CS_VIA <= '0';
			i_CS_1M <= '0';
		else
			i_CS_RAM <= '0';
			i_CS_ROM <= '0';
			i_CS_FT245_D <= '0';
			i_CS_FT245_S <= '0';
			i_CS_LCD32 <= '0';
			i_CS_LCD12864 <= '0';
			i_CS_VIA <= '0';
			i_CS_1M <= '0';

			if i_cpu_VMA = '1' then

				if i_cpu_A(15 downto 13) = "111" then
					i_CS_ROM <= '1';
				elsif i_cpu_A(15 downto 8) = x"80" then
					if i_cpu_A(0) = '1' then
						i_CS_FT245_D <= '1';
					else
						i_CS_FT245_S <= '1';
					end if;
				elsif i_cpu_A(15 downto 8) = x"81" then
					i_CS_1M <= '1';
					i_CS_LCD32 <= '1';
				elsif i_cpu_A(15 downto 8) = x"82" then
					i_CS_1M <= '1';
					i_CS_LCD12864 <= '1';
				elsif i_cpu_A(15 downto 8) = x"83" then
					i_CS_1M <= '1';
					i_CS_VIA <= '1';
				elsif i_cpu_A(15) = '0' then
					i_CS_RAM <= '1';
				end if;
			end if;
		end if;
	end process;

	e_cpu:entity dossy_6800.dossy_6800_cpu
	port map (	
		CLK_i		=> i_clk_pll,
		CLKEN_i	=> i_clken_cpu,
		RST_i		=> i_rst,
		HALT_i	=> '0',
		IRQ_i		=>	not i_via_nIRQ,
		NMI_i		=>	'0',
		RnW_o		=>	i_cpu_RnW,
		VMA_o		=>	i_cpu_VMA,
		BA_o		=>	open,
		A_o		=> i_cpu_A,
	   D_i		=>	i_cpu_D_i,
	   D_o		=> i_cpu_D_o
	);

	i_cpu_D_i <= i_ram_D_o 		when i_CS_RAM = '1' else
					 i_rom_D_o 		when i_CS_ROM = '1' else
					 FT245_D_io 	when i_CS_FT245_D = '1' else
					 (0 => FT245_nRXF_i, 1 => FT245_nTXE_i, others => '0') 
					 					when i_CS_FT245_S = '1' else
					 lcd32_D_io(15 downto 8) when i_CS_LCD32 = '1' and i_cpu_A(0) = '0' else
					 r_lcd_lat when i_CS_LCD32 = '1' and i_cpu_A(0) = '1' else
					 LCD12864_D_io when i_CS_LCD12864 = '1' else
					 i_via_D_o when i_CS_VIA = '1' else
					 x"FF";

	e_ram:entity work.RAM_syn
	generic map (
		size		=> 32768
	)
	port map (
		CLK_I			=> i_clk_pll,
		CLKEN_I		=> '1',
		A_I			=> i_cpu_A(14 downto 0),
		D_I			=> i_cpu_D_o,
		D_O			=> i_ram_D_o,
		WE_I			=> i_ram_we
	);

	i_ram_we <= '1' when i_WRen = '1' and i_cpu_RnW = '0' and i_CS_RAM = '1' else
					'0';


	e_rom: ENTITY work.rom
	generic map (
		MIF => ROOT & "/asm/NoIce/build/mon6800.hex"
		--MIF => ROOT & "/asm/smithbug/build/V2_Ishbel.mif"
	)
	port map
	(
		address		=> i_cpu_A(12 downto 0),
		clock			=>	i_clk_pll,
		rden			=> i_clken_addr,
		q				=> i_rom_D_o
	);

	FT245_nRST_o <= '1'; --not i_rst;
	FT245_PWR_o <= '1';
	FT245_nRD_o <= '0' when i_RDen = '1' and i_cpu_RnW = '1' and i_CS_FT245_D = '1' else
						'1';
	FT245_nWR_o <= '0' when i_WRen = '1' and i_cpu_RnW = '0'  and i_CS_FT245_D = '1' else
						'1';

	FT245_D_io <= 	i_cpu_D_o when i_cpu_RnW = '0'  and i_CS_FT245_D = '1' else
						(others => 'Z');

	lcd32_nRESET_o <= not i_rst;

	p_lcd_ctl:process(i_clk_pll, i_rst)
	begin
		
		if i_rst = '1' then
			lcd32_nCS_o <= '1';
			lcd32_RS_o <= '1';
			lcd32_nRD_o <= '1';
			lcd32_nWR_o <= '1';
			r_lcd_lat <= (others => '0');
			lcd32_D_io <= (others => 'Z');
		elsif rising_edge(i_clk_pll) then
			if i_clken_addr = '1' then
					lcd32_nCS_o <= '1';
					lcd32_RS_o <= '1';
					lcd32_nRD_o <= '1';
					lcd32_nWR_o <= '1';
					lcd32_D_io <= (others => 'Z');
				if i_CS_LCD32 = '1' then
					if i_cpu_RnW = '0' then
						if i_cpu_A(0) = '0' then
							-- MSB writes - latch
							r_lcd_lat <= i_cpu_D_o;
						else
							-- LSB write - write both
							lcd32_D_io <= r_lcd_lat & i_cpu_D_o;
							lcd32_RS_o <= i_cpu_A(1);
							lcd32_nCS_o <= '0';
						end if;
					else -- reads
						if i_cpu_A(0) = '0' then
							lcd32_RS_o <= i_cpu_A(1);
							lcd32_nCS_o <= '0';
						end if;
					end if;
				end if;
			elsif i_clken_mems = '1' then
				if i_CS_LCD32 = '1' then
					if i_cpu_RnW = '0' and i_cpu_A(0) = '1' then
						lcd32_nWR_o <= '0'; -- initiate write
					elsif i_cpu_RnW = '1' and i_cpu_A(0) = '0' then
						lcd32_nRD_o <= '0'; -- initiate read
					end if;
				end if;
			elsif i_clken_cpu = '1' then
				lcd32_nWR_o <= '1'; -- end write
				if i_CS_LCD32 = '1' then
					if i_cpu_RnW = '1' and i_cpu_A(0) = '0' then
						r_lcd_lat <= lcd32_D_io(7 downto 0); -- do read, nRD will deassert later
					end if;
				end if;				
			end if;
		end if;
	end process;


	LCD12864_N_o 	<= '0';
	LCD12864_P_o 	<= '1';
	LCD12864_PSB_o <= '1';
	LCD12864_RST_o <= not i_rst;
	LCD12864_D_io 	<= i_cpu_D_o when i_cpu_RnW = '0' and i_CS_LCD12864 = '1' else
							(others => 'Z');
	LCD12864_RnW_o <= i_cpu_RnW;
	LCD12864_RS_o 	<= i_cpu_A(0);
	LCD12864_E_o 	<= '1' when i_CS_LCD12864 = '1' and i_RDen = '1' and i_cpu_RnW = '1' else
							'1' when i_CS_LCD12864 = '1' and i_WRen = '1' and i_cpu_RnW = '0' else
							'0';
	
	b_led:block	
		signal	r_led_clken	: std_logic;	
	begin
		p_led_clkdiv:process(i_clk_pll)
		variable v_div : unsigned(15 downto 0);
		begin
			if rising_edge(i_clk_pll) then
				r_led_clken <= '0';
				v_div := v_div - 1;
				if v_div = 0 then
					r_led_clken <= '1';
				end if;
			end if;
		end process;

		e_led8_4:entity work.led8_N
		generic map (
			SIZE		=> 4
		)
		port map (
			RST_i		=> '0',
			CLK_i		=> i_clk_pll,
			CLKEN_i	=> r_led_clken,

			D_i		=> i_cpu_A,
			DOT_i		=> i_cpu_RnW & i_cpu_VMA & "00",

			SEG_o		=> disp0_seg_o,
			SEL_o		=> disp0_sel_o
		);
	end block;

	e_VIA:entity work.M6522
   port map (
      I_RS                  => i_cpu_A(3 downto 0),
      I_DATA                => i_cpu_D_o,
      O_DATA                => i_via_D_o,
      O_DATA_OE_L           => open,

      I_RW_L                => i_cpu_RnW,
      I_CS1                 => i_CS_VIA,
      I_CS2_L               => '0',

      O_IRQ_L               => i_via_nIRQ,

      -- port a
      I_CA1                 => '1',
      I_CA2                 => '1',
      O_CA2                 => open,
      O_CA2_OE_L            => open,

      I_PA                  => (others => '1'),
      O_PA                  => open,
      O_PA_OE_L             => open,

      -- port b
      I_CB1                 => '1',
      O_CB1                 => open,
      O_CB1_OE_L            => open,

      I_CB2                 => '1',
      O_CB2                 => open,
      O_CB2_OE_L            => open,

      I_PB                  => (others => '1'),
      O_PB                  => open,
      O_PB_OE_L             => open,

      I_P2_H                => r_via_1MHzE,
      RESET_L               => not i_rst,
      ENA_4                 => r_via_ena4,
      CLK                   => i_clk_pll
   );


end rtl;
