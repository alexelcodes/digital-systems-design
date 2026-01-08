-- Lab 5 Top-Level: RGB Dimmer
-- Combines clk_divider, button_pulser, rgb_controller, and three PWM modules.
-- Board: PYNQ-Z2

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity lab5_top is
  port (
    sysclk : in  std_logic;                    -- 125 MHz system clock
    btn    : in  std_logic_vector(3 downto 0); -- btn0=Reset, btn1=Select, btn2=Up, btn3=Down
    led5_r : out std_logic;                    -- PWM output (Red)
    led5_g : out std_logic;                    -- PWM output (Green)
    led5_b : out std_logic;                    -- PWM output (Blue)
    led4_r : out std_logic;                    -- show active channel
    led4_g : out std_logic;
    led4_b : out std_logic
  );
end entity;

architecture rtl of lab5_top is

  --------------------------------------------------------------------
  -- Internal signals
  --------------------------------------------------------------------
  signal n_Reset : std_logic := '0';

  signal clk_1k  : std_logic := '0'; -- slow clock (1 kHz) for buttons + controller
  signal clk_pwm : std_logic := '0'; -- fast clock (1 MHz) for PWM modules

  -- Button pulser outputs
  signal pulse_sel  : std_logic := '0';
  signal pulse_up   : std_logic := '0';
  signal pulse_down : std_logic := '0';

  -- RGB values (8-bit each)
  signal red_val   : std_logic_vector(7 downto 0);
  signal green_val : std_logic_vector(7 downto 0);
  signal blue_val  : std_logic_vector(7 downto 0);

  -- Channel selection indicators
  signal sel_r, sel_g, sel_b : std_logic;

begin
  --------------------------------------------------------------------
  -- Reset: btn0 (active-high on board) → internal active-low
  --------------------------------------------------------------------
  n_Reset <= not btn(0);

  --------------------------------------------------------------------
  -- Clock divider #1: 125 MHz → 1 kHz for logic (buttons, controller)
  --------------------------------------------------------------------
  u_clkdiv_slow: entity work.clk_divider
    generic map (
      G_INPUT_HZ => 125_000_000,
      G_OUT_HZ   => 1_000 -- 1 kHz for button_pulser + rgb_controller
    )
    port map (
      clk_in  => sysclk,
      n_Reset => n_Reset,
      clk_out => clk_1k
    );

  --------------------------------------------------------------------
  -- Clock divider #2: 125 MHz → 1 MHz for PWM
  -- 1 MHz with 8-bit PWM gives ~3.9 kHz PWM frequency (1e6 / 256),
  -- which is smooth for the eye and uses less power than 125 MHz.
  --------------------------------------------------------------------
  u_clkdiv_pwm: entity work.clk_divider
    generic map (
      G_INPUT_HZ => 125_000_000,
      G_OUT_HZ   => 1_000_000 -- 1 MHz for PWM
    )
    port map (
      clk_in  => sysclk,
      n_Reset => n_Reset,
      clk_out => clk_pwm
    );

  --------------------------------------------------------------------
  -- Button pulser instances for Select, Up, Down
  --------------------------------------------------------------------
  u_pulser_sel: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 2000, -- ≈2 s before start repeat
      G_REPEAT_PERIOD_CYCLES => 500 -- ≈0.5 s between repeats
    )
    port map (
      clk       => clk_1k,
      n_Reset   => n_Reset,
      btn_in    => btn(1),
      pulse_out => pulse_sel
    );

  u_pulser_up: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 1000,
      G_REPEAT_PERIOD_CYCLES => 50
    )
    port map (
      clk       => clk_1k,
      n_Reset   => n_Reset,
      btn_in    => btn(2),
      pulse_out => pulse_up
    );

  u_pulser_down: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 1000,
      G_REPEAT_PERIOD_CYCLES => 50
    )
    port map (
      clk       => clk_1k,
      n_Reset   => n_Reset,
      btn_in    => btn(3),
      pulse_out => pulse_down
    );

  --------------------------------------------------------------------
  -- RGB Controller: handles color selection and brightness
  --------------------------------------------------------------------
  u_ctrl: entity work.rgb_controller
    port map (
      clk        => clk_1k,
      n_Reset    => n_Reset,
      pulse_sel  => pulse_sel,
      pulse_up   => pulse_up,
      pulse_down => pulse_down,
      red_val    => red_val,
      green_val  => green_val,
      blue_val   => blue_val,
      sel_r      => sel_r,
      sel_g      => sel_g,
      sel_b      => sel_b
    );

  --------------------------------------------------------------------
  -- Three PWM modules: control LED brightness
  -- Now they use clk_pwm (1 MHz) instead of sysclk (125 MHz).
  --------------------------------------------------------------------
  u_pwm_r: entity work.pwm
    port map (
      clk     => clk_pwm,
      n_Reset => n_Reset,
      pwm_val => red_val,
      pwm_out => led5_r
    );

  u_pwm_g: entity work.pwm
    port map (
      clk     => clk_pwm,
      n_Reset => n_Reset,
      pwm_val => green_val,
      pwm_out => led5_g
    );

  u_pwm_b: entity work.pwm
    port map (
      clk     => clk_pwm,
      n_Reset => n_Reset,
      pwm_val => blue_val,
      pwm_out => led5_b
    );

  --------------------------------------------------------------------
  -- Show active channel on LED4
  --------------------------------------------------------------------
  led4_r <= sel_r;
  led4_g <= sel_g;
  led4_b <= sel_b;

end architecture;
