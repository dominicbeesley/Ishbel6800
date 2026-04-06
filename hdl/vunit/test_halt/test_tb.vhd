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

   signal   i_cpu_nRES:          std_logic;
   signal   i_cpu_nHALT:         std_logic;

   signal   i_cpu_D:             std_logic_vector(7 downto 0);
   signal   i_cpu_A:             std_logic_vector(15 downto 0);
   signal   i_cpu_rnw:           std_logic;

   signal   i_nCS_ROM:           std_logic;
   signal   i_nCS_RAM0:          std_logic;

   signal   i_RAM_nWE:           std_logic;

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
      i_cpu_nRES <= '0';
      wait for 10 us;
      i_cpu_nRES <= '1';
      wait;
   end process;




   p_main:process
   variable I:integer;
   begin

      test_runner_setup(runner, runner_cfg);


      while test_suite loop


         if run("test") then

            i_cpu_nHALT <= '1';

            wait for 25 us;

            i_cpu_nHALT <= '0';

            wait for 20 us;

            i_cpu_nHALT <= '1';

            wait for 100 us;


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
      nRESET      => i_cpu_nRES,
      TSC         => '1',
      DBE         => i_cpu_clk_phi2,
      nHALT       => i_cpu_nHALT,
      nIRQ        => '1',
      nNMI        => '1',
      VMA         => open,
      RnW         => i_cpu_rnw,
      BA          => open
      );


   i_nCS_ROM <= '0' when i_cpu_A(15 downto 8) = x"FF" else '1';

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

   i_nCS_RAM0 <= '0' when i_cpu_A(15 downto 8) = x"00" else '1';

   i_ram_nWE <= '0' when i_cpu_rnw = '0' and i_cpu_clk_phi2 = '1' else '1';


   e_ram:entity work.RAM_tb 
   generic map (
      size => 256
   )
   port map (
      A           => i_cpu_A(7 downto 0),
      D           => i_cpu_D,
      nCS         => i_nCS_RAM0,
      nOE         => not i_cpu_clk_phi2,
      nWE         => i_ram_nWE
   );

      
end rtl;
