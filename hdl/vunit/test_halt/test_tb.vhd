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

   signal   i_cpu_din:           std_logic_vector(7 downto 0);
   signal   i_cpu_A:             std_logic_vector(15 downto 0);

   signal   i_nCS_ROM:           std_logic;

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


            wait for 150 us;

         end if;

      end loop;

      wait for 20 us;

      test_runner_cleanup(runner); -- Simulation ends here
   end process;

   i_cpu_din <= (others => 'Z');

   
   e_cpu:entity work.cpu68_dom
   port map (   
      clk         => i_cpu_clk_phi2,
      rst         => not i_cpu_nRES,
      rw          => open,
      vma         => open,
      address     => i_cpu_A,
      data_in     => i_cpu_din,
      data_out    => open,
      hold        => '0',
      halt        => not i_cpu_nHALT,
      irq         => '0',
      nmi         => '0',
      test_alu    => open,
      test_cc     => open
      );


   i_nCS_ROM <= '0' when i_cpu_A(15 downto 8) = x"FF" else '1';

   e_rom:entity work.ROM_tb 
   generic map (
      romfile => "../../asm/build/test.rom",
      size => 256
   )
   port map (
      A           => i_cpu_A(7 downto 0),
      D           => i_cpu_din,
      nCS         => i_nCS_ROM,
      nOE         => not i_cpu_clk_phi2
   );
      
end rtl;
