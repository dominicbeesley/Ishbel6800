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

   signal   i_clk_50M:           std_logic;

   signal   i_nTXE:              std_logic;

begin



   p_clk:process
   begin
      i_clk_50M <= '0';
      wait for 10 ns;
      i_clk_50M <= '1';
      wait for 10 ns;
   end process;


   p_main:process
   variable I:integer;
   begin

      test_runner_setup(runner, runner_cfg);


      while test_suite loop


         if run("test") then
         
            wait for 5000 us;

         end if;

      end loop;

      wait for 20 us;

      test_runner_cleanup(runner); -- Simulation ends here
   end process;

   e_dut:entity work.ws_6800_one
   generic map (
      ROOT => "../../../../testrigs/ws_6800_one"
      )
   port map (
      -- crystal osc 50Mhz - on WS board
      CLK_50M_i                     => i_clk_50M,
      EXT_nRESET_i                  => '1',

      LED_o                         => open,

      FT245_nRD_o                   => open,
      FT245_nWR_o                   => open,
      FT245_nRXF_i                  => '1',
      FT245_nTXE_i                  => i_nTXE,
      FT245_PWR_o                   => open,
      FT245_nRST_o                  => open,
      FT245_D_io                    => open,

      lcd32_D_io                    => open,
      lcd32_nCS_o                   => open,
      lcd32_RS_o                    => open,
      lcd32_nWR_o                   => open,
      lcd32_nRD_o                   => open,
      lcd32_nRESET_o                => open,
      
      touch_irq_i                   => '1',
      touch_nCS_o                   => open,
      touch_SCLK_o                  => open,
      touch_MOSI_o                  => open,
      touch_MISO_i                  => '1'


   );

   p_txe:process
   begin
      i_nTXE <= '1';
      wait for 100 us;
      wait until rising_edge(i_clk_50M);
      i_nTXE <= '0';
      wait for 12 us;
   end process;   
      
end rtl;
