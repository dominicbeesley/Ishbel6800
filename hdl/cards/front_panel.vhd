library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity front_panel_ctl is
   port (

      -- clocks
      cpu_clk_phi2   : in  std_logic;

      -- front panel buttons and switches
      btn_stop_n_i   : in  std_logic;
      btn_run_n_i    : in  std_logic;

      -- system control in
      sys_res_n_i    : in  std_logic;

      -- cpu control in            
      cpu_ba_i       : in  std_logic;
      cpu_vma_i      : in  std_logic;

      -- cpu control out
      cpu_halt_n_o   : out std_logic;

      -- bus override out
      bus_jam_d_o    : out std_logic_vector(7 downto 0);
      bus_jam_rd_o   : out std_logic

   );
end front_panel_ctl;

architecture rtl of front_panel_ctl is
   
   type t_state is (transit, run, halted);

   signal   state    : t_state;

   type t_jam_rom_ent is record
      bus_jam_rd     : std_logic;
      bus_jam_d      : std_logic_vector(7 downto 0);
      nhalt          : std_logic;
      next_state     : t_state;
   end record;

   type t_jam_rom_arr is array(natural range <>) of t_jam_rom_ent;

   constant jam_rom : t_jam_rom_arr(0 to 15) := (
      0 => ('1', x"00", '1', transit),    -- vector fetch
      1 => ('1', x"00", '1', transit),    -- vector fetch
      2 => ('1', x"3F", '0', halted),     -- SWI instruction, start halt
      others => ('1', x"00", '0', halted)
      );

   signal   jam_rom_ptr : unsigned(3 downto 0);
   signal   jam_cur     : t_jam_rom_ent;

begin

   jam_cur <= jam_rom(to_integer(jam_rom_ptr));

   bus_jam_d_o <= jam_cur.bus_jam_d;
   bus_jam_rd_o <=   '1' when jam_cur.bus_jam_rd = '1' and state = transit else
                     '0';
   cpu_halt_n_o <= jam_cur.nhalt;


   p_state:process(cpu_clk_phi2)
   begin
      if sys_res_n_i = '0' then
         state <= transit;
         jam_rom_ptr <= to_unsigned(0, jam_rom_ptr'length);
      elsif falling_edge(cpu_clk_phi2) then
         
         if state = transit then
            state <= jam_cur.next_state;
         end if;

         if jam_cur.next_state = transit and cpu_vma_i = '1' then
            jam_rom_ptr <= jam_rom_ptr + 1;
         end if;

      end if;

   end process;


end rtl;