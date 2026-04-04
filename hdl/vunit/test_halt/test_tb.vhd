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
   signal   i_cpu_nRES:          std_logic;
   signal   i_cpu_nHALT:         std_logic;

begin



   p_clk_phi2:process
   begin
      i_cpu_clk_phi2 <= '0';
      wait for 250 ns;
      i_cpu_clk_phi2 <= '1';
      wait for 250 ns;
   end process;

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
            wait for 1 us;
            wait until i_cpu_nRES = '1';

            for i in 0 to 10 loop
               wait until falling_edge(i_cpu_clk_phi2);
            end loop;

            i_cpu_nHALT <= '0';


         end if;

      end loop;

      wait for 3 us;

      test_runner_cleanup(runner); -- Simulation ends here
   end process;

   
   e_cpu:entity work.cpu68
   port map (   
      clk         => i_cpu_clk_phi2,
      rst         => not i_cpu_nRES,
      rw          => open,
      vma         => open,
      address     => open,
      data_in     => x"3F",
      data_out    => open,
      hold        => '0',
      halt        => not i_cpu_nHALT,
      irq         => '0',
      nmi         => '0',
      test_alu    => open,
      test_cc     => open
      );

end rtl;
