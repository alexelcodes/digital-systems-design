-- Testbench for lab4_top (end-to-end integration)
-- Verifies:
--  * clk_divider -> button_pulser -> rgb_fsm chain
--  * Board clock = 125 MHz
--  * btn(0) = reset (active-high on board)
--  * btn(1) = user button: SHORT press → single step RED→GREEN

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity tb_lab4_top is
  -- No ports in a testbench
end entity;

architecture Behavioral of tb_lab4_top is
  --------------------------------------------------------------------
  -- Board clock and buttons (simulation signals)
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 8 ns; -- 125 MHz clock period
  signal sysclk : std_logic                    := '0';             -- simulated board clock
  signal btn    : std_logic_vector(1 downto 0) := (others => '0'); -- btn(0)=reset, btn(1)=user

  --------------------------------------------------------------------
  -- Observed LED outputs
  --------------------------------------------------------------------
  signal led5_r : std_logic;
  signal led5_g : std_logic;
  signal led5_b : std_logic;

begin
  --------------------------------------------------------------------
  -- 125 MHz clock generator (toggles every half period)
  --------------------------------------------------------------------
  sysclk <= not sysclk after (SYSCLK_PERIOD / 2);

  --------------------------------------------------------------------
  -- Stimulus sequence:
  --  1) Press board reset (btn(0)='1'), then release (btn(0)='0')
  --  2) Wait a few ms so the 1 kHz domain starts ticking
  --  3) SHORT press on btn(1) for a few ms → expect one step RED→GREEN
  --------------------------------------------------------------------
  stim_p: process
  begin
    -- 1) Assert reset (active-high on board button 0)
    btn(0) <= '1'; -- press reset
    wait for 1 us; -- plenty of 125 MHz cycles in reset
    btn(0) <= '0'; -- release reset

    -- 2) Guard time (allow slow 1 kHz logic to tick)
    wait for 5 ms; -- ≈5 slow ticks @1 kHz

    -- 3) SHORT press on btn(1)
    btn(1) <= '1'; -- press user button
    wait for 3 ms; -- >1 slow tick so pulser will detect it
    btn(1) <= '0'; -- release (single step expected)

    -- Observe LEDs for a while
    wait for 5 ms;

    wait; -- stop this process (simulation continues passively)
  end process;

  --------------------------------------------------------------------
  -- DUT: lab4_top (connect testbench signals to top-level)
  --------------------------------------------------------------------
  dut: entity work.lab4_top
    port map (
      sysclk => sysclk,
      btn    => btn,
      led5_r => led5_r,
      led5_g => led5_g,
      led5_b => led5_b
    );

  --------------------------------------------------------------------
  -- Simple monitor: print which color is active at each sysclk edge
  -- (helps to see the RED→GREEN change in the console)
  --------------------------------------------------------------------
  monitor_p: process
  begin
    wait until rising_edge(sysclk);
    if led5_r = '1' then
      report "LED5 = RED";
    elsif led5_g = '1' then
      report "LED5 = GREEN";
    elsif led5_b = '1' then
      report "LED5 = BLUE";
    end if;
  end process;

  --------------------------------------------------------------------
  -- What to check on the waveform/console:
  --  * After reset release (btn(0)=0): expect RED → led5_r='1', led5_g='0', led5_b='0'
  --  * During/after the short press on btn(1): exactly one step to GREEN
  --    (no auto-repeat here because top-level uses 2 s / 0.5 s, and we press only ~3 ms)
  --------------------------------------------------------------------
end architecture;
