set_time_format -unit ns -decimal_places 3


create_clock -name CLOCK_50M -period 20 [get_ports {CLK_50M_i}]

create_generated_clock -name clk_main -source [get_ports {CLK_50M_i}] -divide_by 5 -multiply_by 1 [get_nets {e_main_pll|altpll_component|auto_generated|wire_pll1_clk[0]}]

derive_clock_uncertainty
