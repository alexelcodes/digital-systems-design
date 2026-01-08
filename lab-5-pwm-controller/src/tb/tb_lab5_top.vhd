-- Testbench for lab5_top (Lab 5 RGB Dimmer)
-- Verifies end-to-end:
--  * clk_divider -> button_pulser -> rgb_controller -> PWM -> LEDs
--  * btn0 : reset
--  * btn1 : select R/G/B channel
--  * btn3 : brightness up
--  * btn2 : brightness down

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity tb_lab5_top is
  -- No ports in a testbench
end entity;

architecture Behavioral of tb_lab5_top is

  --------------------------------------------------------------------
  -- Board clock and buttons (simulation signals)
  --------------------------------------------------------------------
  constant SYSCLK_PERIOD : time := 8 ns; -- 125 MHz clock period

  signal sysclk : std_logic                    := '0';             -- simulated board clock
  signal btn    : std_logic_vector(3 downto 0) := (others => '0'); -- btn0..btn3

  --------------------------------------------------------------------
  -- Observed LED outputs
  --------------------------------------------------------------------
  signal led5_r : std_logic;
  signal led5_g : std_logic;
  signal led5_b : std_logic;

  signal led4_r : std_logic;
  signal led4_g : std_logic;
  signal led4_b : std_logic;

begin

  --------------------------------------------------------------------
  -- 125 MHz clock generator
  --------------------------------------------------------------------
  sysclk <= not sysclk after (SYSCLK_PERIOD / 2);

  --------------------------------------------------------------------
  -- Stimulus:
  --  1) Reset via btn0
  --  2) Short press btn3 (UP) on RED channel
  --  3) Short press btn1 (SELECT) -> switch to GREEN
  --  4) Short press btn3 (UP) on GREEN
  --  5) Short press btn2 (DOWN) on GREEN
  --------------------------------------------------------------------
  stim_p: process
  begin
    ----------------------------------------------------------------
    -- 1) Assert reset (btn0 = '1'), then release
    ----------------------------------------------------------------
    btn <= (others => '0');
    btn(0) <= '1'; -- press reset
    wait for 1 us; -- plenty of 125 MHz cycles
    btn(0) <= '0'; -- release reset

    -- wait some ms so 1 kHz slow clock is running
    wait for 5 ms;

    ----------------------------------------------------------------
    -- 2) Short press UP (btn3) on RED channel
    --    Expect: red brightness increases a bit (PWM on led5_r)
    ----------------------------------------------------------------
    btn(3) <= '1'; -- press UP
    wait for 5 ms; -- > 1 tick @1 kHz, pulser sees it as short press
    btn(3) <= '0'; -- release

    wait for 5 ms;

    ----------------------------------------------------------------
    -- 3) Short press SELECT (btn1) -> switch to GREEN channel
    ----------------------------------------------------------------
    btn(1) <= '1'; -- press SELECT
    wait for 5 ms;
    btn(1) <= '0'; -- release

    wait for 5 ms;

    ----------------------------------------------------------------
    -- 4) Short press UP (btn3) on GREEN channel
    ----------------------------------------------------------------
    btn(3) <= '1';
    wait for 5 ms;
    btn(3) <= '0';

    wait for 5 ms;

    ----------------------------------------------------------------
    -- 5) Short press DOWN (btn2) on GREEN channel
    ----------------------------------------------------------------
    btn(2) <= '1';
    wait for 5 ms;
    btn(2) <= '0';

    -- Observe LEDs for a while
    wait for 20 ms;

    wait; -- stop this process (simulation continues passively)
  end process;

  --------------------------------------------------------------------
  -- DUT: lab5_top
  --------------------------------------------------------------------
  dut: entity work.lab5_top
    port map (
      sysclk => sysclk,
      btn    => btn,
      led5_r => led5_r,
      led5_g => led5_g,
      led5_b => led5_b,
      led4_r => led4_r,
      led4_g => led4_g,
      led4_b => led4_b
    );

end architecture;
