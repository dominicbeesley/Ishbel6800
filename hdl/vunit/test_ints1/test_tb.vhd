library vunit_lib;
context vunit_lib.vunit_context;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;

entity test_tb is
   generic (
      runner_cfg : string
      );
end test_tb;

architecture rtl of test_tb is

   signal   i_cpu_clk_phi2:      std_logic;
   signal   i_cpu_clk_phi1:      std_logic;
   signal   i_cpu_clk_phi0:      std_logic;

   signal   i_sys_nRES:          std_logic;
   signal   i_cpu_nHALT:         std_logic;
   signal   i_cpu_nIRQ:          std_logic;

   signal   i_cpu_D:             std_logic_vector(7 downto 0);
   signal   i_cpu_A:             std_logic_vector(15 downto 0);
   signal   i_cpu_RnW:           std_logic;
   signal   i_cpu_BA:            std_logic;
   signal   i_cpu_VMA:           std_logic;

   signal   i_nCS_ROM:           std_logic;
   signal   i_RAM0_nCS:          std_logic;

   signal   i_RAM0_nWE:          std_logic;

begin



   p_clk_phi0:process
   begin
      i_cpu_clk_phi0 <= '0';
      wait for 250 ns;
      i_cpu_clk_phi0 <= '1';
      wait for 250 ns;
   end process;

   i_cpu_clk_phi2 <= transport i_cpu_clk_phi0 after 30 ns;

   i_cpu_clk_phi1 <= transport (not i_cpu_clk_phi2) and (not i_cpu_clk_phi0) after 10 ns;

   p_reset:process
   begin
      i_sys_nRES <= '0';
      wait for 10 us;
      i_sys_nRES <= '1';
      wait;
   end process;




   p_main:process
   variable I:integer;
   begin

      test_runner_setup(runner, runner_cfg);


      while test_suite loop


         if run("test") then

            
            wait for 200 us;


         end if;

      end loop;

      wait for 20 us;

      test_runner_cleanup(runner); -- Simulation ends here
   end process;

   i_cpu_d <= (others => 'Z');

   
   e_cpu:entity work.real_6800_tb
   port map (   
      PHI1        => i_cpu_clk_phi1,
      PHI2        => i_cpu_clk_phi2,
      A           => i_cpu_A,
      D           => i_cpu_D,
      nRESET      => i_sys_nRES,
      TSC         => '1',
      DBE         => i_cpu_clk_phi2,
      nHALT       => i_cpu_nHALT,
      nIRQ        => i_cpu_nIRQ,
      nNMI        => '1',
      VMA         => i_cpu_VMA,
      RnW         => i_cpu_RnW,
      BA          => i_cpu_ba
      );


   i_nCS_ROM <= '0' when i_cpu_A(15 downto 8) = x"FF" and i_cpu_VMA = '1' else '1';

   e_rom:entity work.ROM_tb 
   generic map (
      romfile => "../../asm/build/test.rom",
      size => 256
   )
   port map (
      A           => i_cpu_A(7 downto 0),
      D           => i_cpu_d,
      nCS         => i_nCS_ROM,
      nOE         => not i_cpu_clk_phi2
   );

   i_RAM0_nCS <= '0' when i_cpu_A(15 downto 14) = "00" and i_cpu_VMA = '1' else '1';
   i_RAM0_nWE <= '0' when i_cpu_RnW = '0' and i_cpu_clk_phi2 = '1' else '1';


   e_ram:entity work.RAM_tb 
   generic map (
      size => 16384
   )
   port map (
      A           => i_cpu_A(13 downto 0),
      D           => i_cpu_D,
      nCS         => i_RAM0_nCS,
      nOE         => not i_cpu_clk_phi2,
      nWE         => i_RAM0_nWE
   );


   p_halt:process(i_cpu_clk_phi2, i_sys_nRES)
   constant x_halt : std_logic_vector(24 downto 0) := "1111111111111111111111111";
   variable v_halt : std_logic_vector(x_halt'range);
   begin
      if i_sys_nRES = '0' then
         v_halt := x_halt;
      elsif falling_edge(i_cpu_clk_phi2) then
         v_halt := v_halt(v_halt'high - 1 downto 0) & v_halt(0);
      end if;
      i_cpu_nHALT <= v_halt(v_halt'high);
   end process;
  
   p_irq:process(i_cpu_clk_phi2, i_sys_nRES)
   constant x_irq : std_logic_vector(24 downto 0) := "1111111111111000000000000";
   variable v_irq : std_logic_vector(x_irq'range);
   begin
      if i_sys_nRES = '0' then
         v_irq := x_irq;
      elsif falling_edge(i_cpu_clk_phi2) then
         v_irq := v_irq(v_irq'high - 1 downto 0) & v_irq(0);
      end if;
      i_cpu_nIRQ <= v_irq(v_irq'high);
   end process;

   p_bus_hold:process
   variable v_pre_D:std_logic_vector(7 downto 0) := (others => 'Z');
   variable i:natural;
   begin
      i_cpu_D <= (others => 'Z');
      wait for 0 us;
      for i in 7 downto 0 loop
         if not is_x(i_cpu_D(I)) then
            v_pre_D(I) := i_cpu_D(I);
         end if;
         if is_X(v_pre_D(I)) then
            v_pre_D(I) := 'Z';
         end if;
      end loop;
      i_cpu_D <= v_pre_D;
      wait for 0 us;
      wait on i_cpu_D;

   end process;


      
end rtl;
