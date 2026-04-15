library vunit_lib;
context vunit_lib.vunit_context;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;

entity test_tb is
   generic (
      runner_cfg : string;
      dump_file_name : string := "./decoder.bin"
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

   signal   sim_stop:            boolean := false;

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

   

   p_main:process
   variable I:integer;
   begin

      test_runner_setup(runner, runner_cfg);


      while test_suite loop


         if run("test") then

            i_cpu_nHALT <= '1';
            i_sys_nRES <= '0';
            wait for 10 us;
            wait until falling_edge(i_cpu_clk_phi1);
            i_sys_nRES <= '1';

            wait for 100 us;

            sim_stop <= true;

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


   i_nCS_ROM <= '0' when i_cpu_A(15 downto 12) = x"F" and i_cpu_VMA = '1' else '1';

   e_rom:entity work.ROM_tb 
   generic map (
      romfile => "../../asm/build/test.rom",
      size => 4096
   )
   port map (
      A           => i_cpu_A(11 downto 0),
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
   i_per_nRD <=   '0' when i_cpu_clk_phi2 = '1' and i_cpu_RnW = '1' else
                  '1';

   p_dumper:process
      type dump_file_type is file of character;
      file dump_file : dump_file_type;
      variable v_flags : std_logic_vector(7 downto 0);
   begin
      file_open(dump_file, dump_file_name, write_mode);

      while not sim_stop  loop
         wait until falling_edge(i_cpu_clk_phi2);

            v_flags := (
               0 => i_cpu_RnW,
               1 => i_cpu_VMA,
               2 => i_cpu_ba,
               6 => i_sys_nRES,
               others => '0'
               );

            write(dump_file, character'val(to_integer(unsigned(i_cpu_D))));
            write(dump_file, character'val(to_integer(unsigned(v_flags))));
      end loop;
      wait;

   end process;

      
end rtl;
