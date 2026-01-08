-- Testbench for rgb_fsm
-- Verifies:
--  * After reset -> RED is active
--  * Each pulse steps colors: RED → GREEN → BLUE → RED
--  * Continuous pulses (like long press) keep cycling colors

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity tb_rgb_fsm is
  -- No ports in a testbench
end entity;

architecture Behavioral of tb_rgb_fsm is
  --------------------------------------------------------------------
  -- Clock and reset signals for simulation
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 100 ns; -- 10 MHz clock period
  signal clk     : std_logic := '0'; -- simulated FSM clock (starts at '0')
  signal n_Reset : std_logic := '0'; -- active-low reset (starts active)

  --------------------------------------------------------------------
  -- Stimulus and DUT I/O
  --------------------------------------------------------------------
  signal pulse_in : std_logic := '0'; -- input pulse from button_pulser
  signal sel_r    : std_logic;        -- output: Red channel
  signal sel_g    : std_logic;        -- output: Green channel
  signal sel_b    : std_logic;        -- output: Blue channel

  --------------------------------------------------------------------
  -- Helper: wait N rising edges of clk (for compact delays)
  --------------------------------------------------------------------
  procedure wait_cycles(n : natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

begin
  --------------------------------------------------------------------
  -- Clock generator (toggles every half period) -> 10 MHz square wave
  --------------------------------------------------------------------
  clk <= not clk after (SYSCLK_PERIOD / 2.0);

  --------------------------------------------------------------------
  -- Stimulus sequence:
  --  1) Hold reset low for 10 cycles, then release
  --  2) Send single pulses → expect R→G→B→R transitions
  --  3) Send a burst of pulses → continuous color cycling
  --------------------------------------------------------------------
  stimulus_p: process
  begin
    -- 1) Keep reset active-low for 10 cycles
    wait_cycles(10);
    n_Reset <= '1'; -- release reset (FSM starts in RED)
    wait_cycles(5); -- small guard time

    -- 2) Single-step pulses
    pulse_in <= '1';
    wait until rising_edge(clk); -- change color (RED→GREEN)
    pulse_in <= '0';
    wait_cycles(3); -- stay GREEN
    pulse_in <= '1';
    wait until rising_edge(clk); -- change color (GREEN→BLUE)
    pulse_in <= '0';
    wait_cycles(3); -- stay BLUE
    pulse_in <= '1';
    wait until rising_edge(clk); -- change color (BLUE→RED)
    pulse_in <= '0';
    wait_cycles(5); -- stay RED

    -- 3) Burst of pulses (simulate long press → auto-repeat)
    for k in 1 to 6 loop
      pulse_in <= '1';
      wait until rising_edge(clk);
      pulse_in <= '0';
      wait_cycles(4); -- spacing between pulses
    end loop;

    wait; -- stop this process (simulation continues passively)
  end process;

  --------------------------------------------------------------------
  -- DUT: rgb_fsm
  -- Connects the testbench signals to the FSM under test.
  -- The FSM changes LED color (R→G→B→R) on each input pulse.
  --------------------------------------------------------------------
  dut: entity work.rgb_fsm
    port map (
      clk      => clk,
      n_Reset  => n_Reset,
      pulse_in => pulse_in,
      sel_r    => sel_r,
      sel_g    => sel_g,
      sel_b    => sel_b
    );

  --------------------------------------------------------------------
  -- Simple monitor: print which color is active at each rising edge
  --------------------------------------------------------------------
  monitor_p: process
  begin
    wait until rising_edge(clk);
    if sel_r = '1' then
      report "Color = RED";
    elsif sel_g = '1' then
      report "Color = GREEN";
    elsif sel_b = '1' then
      report "Color = BLUE";
    end if;
  end process;

end architecture;
