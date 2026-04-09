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

   signal   i_cpu_D:             std_logic_vector(7 downto 0);
   signal   i_cpu_A:             std_logic_vector(15 downto 0);
   signal   i_cpu_RnW:           std_logic;
   signal   i_cpu_BA:            std_logic;
   signal   i_cpu_VMA:           std_logic;

   signal   i_nCS_ROM:           std_logic;
   signal   i_RAM0_nCS:          std_logic;

   signal   i_RAM0_nWE:          std_logic;

   signal   i_fp_btn_stop_n:     std_logic;
   signal   i_fp_btn_run_n:      std_logic;

   signal   i_per_nRD:           std_logic;
   signal   i_bus_jam_rd:        std_logic;
   signal   i_bus_jam_d:         std_logic_vector(7 downto 0);

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

            i_fp_btn_run_n <= '1';
            i_fp_btn_stop_n <= '1';

            
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
      nIRQ        => '1',
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
      nOE         => i_per_nRD
   );

   i_RAM0_nCS <= '0' when i_cpu_A(15 downto 8) = x"00" and i_cpu_VMA = '1' else '1';
   i_RAM0_nWE <= '0' when i_cpu_RnW = '0' and i_cpu_clk_phi2 = '1' else '1';


   e_ram:entity work.RAM_tb 
   generic map (
      size => 256
   )
   port map (
      A           => i_cpu_A(7 downto 0),
      D           => i_cpu_D,
      nCS         => i_RAM0_nCS,
      nOE         => i_per_nRD,
      nWE         => i_RAM0_nWE
   );

   -- bus jam overrides normal reads from devices
   i_per_nRD <=   '1' when i_bus_jam_rd else
                  '0' when not i_cpu_clk_phi2 else
                  '1';

   e_fp:entity work.front_panel_ctl
   port map (

      -- clocks
      cpu_clk_phi2   => i_cpu_clk_phi2,

      -- front panel buttons and switches
      btn_stop_n_i   => i_fp_btn_stop_n,
      btn_run_n_i    => i_fp_btn_run_n,

      -- system control in
      sys_res_n_i    => i_sys_nRES,

      -- cpu control in            
      cpu_ba_i       => i_cpu_ba,
      cpu_vma_i      => i_cpu_VMA,

      -- cpu control out
      cpu_halt_n_o   => i_cpu_nHALT,

      -- bus override out
      bus_jam_d_o    => i_bus_jam_d,
      bus_jam_rd_o   => i_bus_jam_rd

   );

   i_cpu_D <=  i_bus_jam_d when i_bus_jam_rd = '1' and i_cpu_clk_phi2 = '1' else
               (others => 'Z');
      
end rtl;
