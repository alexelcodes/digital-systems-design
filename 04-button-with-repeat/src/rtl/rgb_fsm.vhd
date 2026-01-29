-- RGB FSM
-- Cycles through R -> G -> B on each input pulse.
-- Asynchronous active-low reset puts the FSM into RED state.

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity rgb_fsm is
  port (
    clk      : in  std_logic; -- slow clock for FSM (e.g., 1 kHz from clk_divider)
    n_Reset  : in  std_logic; -- async reset, active-low
    pulse_in : in  std_logic; -- 1-clock pulse from button_pulser

    sel_r    : out std_logic; -- select Red
    sel_g    : out std_logic; -- select Green
    sel_b    : out std_logic  -- select Blue
  );
end entity;

architecture rtl of rgb_fsm is
  --------------------------------------------------------------------
  -- FSM state register and edge protection signals
  --------------------------------------------------------------------
  type t_state is (S_RED, S_GREEN, S_BLUE);
  signal state : t_state := S_RED; -- current state (starts RED)

begin
  --------------------------------------------------------------------
  -- Output logic: enable one LED based on current FSM state
  --------------------------------------------------------------------
  sel_r <= '1' when state = S_RED else '0';
  sel_g <= '1' when state = S_GREEN else '0';
  sel_b <= '1' when state = S_BLUE else '0';

  --------------------------------------------------------------------
  -- Main FSM: change color on each one-clock 'step'

  --------------------------------------------------------------------
  process (clk, n_Reset) -- runs on clock edges or reset
  begin
    if n_Reset = '0' then
      state <= S_RED; -- reset to RED state

    elsif rising_edge(clk) then -- on clock rising edge 0→1
      if pulse_in = '1' then
        case state is
          -- "when ... =>" means: if current state matches, do this action
          when S_RED => state <= S_GREEN; -- switch from red to green
          when S_GREEN => state <= S_BLUE; -- switch from green to blue
          when S_BLUE => state <= S_RED; -- switch from blue back to red
        end case;
      end if;
    end if;
  end process;
end architecture;
