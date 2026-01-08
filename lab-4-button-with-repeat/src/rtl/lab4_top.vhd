-- Top-level: wires up clk_divider, button_pulser, and rgb_fsm
-- Board: PYNQ-Z2
--  * sysclk = 125 MHz from board
--  * btn(0) = Reset (active-high on board) → internal n_Reset (active-low)
--  * btn(1) = User button → pulses to step RGB
--  * LED5 = RGB outputs

library IEEE;
  use IEEE.STD_LOGIC_1164.all;

entity lab4_top is
  port (
    sysclk : in  std_logic;                    -- 125 MHz board clock
    btn    : in  std_logic_vector(1 downto 0); -- btn(0)=Reset, btn(1)=User
    led5_r : out std_logic;
    led5_g : out std_logic;
    led5_b : out std_logic
  );
end entity;

architecture rtl of lab4_top is
  signal n_Reset : std_logic := '0'; -- final internal reset (active-low)
  signal clk_1k  : std_logic := '0'; -- divided clock (~1 kHz)
  signal pulse_s : std_logic := '0'; -- internal connection (button_pulser → rgb_fsm)

begin

  -- Convert active-high reset from board to internal active-low reset.
  n_Reset <= not btn(0); -- internal reset = '0' means "reset active"

  --------------------------------------------------------------------
  -- Instantiate clock divider unit:
  -- Takes 125 MHz board clock (sysclk) and produces a 1 kHz slow clock (clk_1k)
  -- Used by the button pulser and RGB FSM for stable timing.
  --------------------------------------------------------------------
  u_clk_div: entity work.clk_divider
    generic map (
      G_INPUT_HZ => 125_000_000, -- input frequency (125 MHz)
      G_OUT_HZ   => 1_000 -- desired output frequency (1 kHz)
    )
    port map (
      clk_in  => sysclk,  -- connect system clock from board
      n_Reset => n_Reset, -- connect internal active-low reset
      clk_out => clk_1k -- output: slow 1 kHz clock
    );

  --------------------------------------------------------------------
  -- Instantiate button pulser unit:
  -- Converts btn1 presses into clean pulses.
  --  * short press → single 1-clock pulse
  --  * long press  → starts auto-repeat after ~2 s, then 1 pulse every ~0.5 s
  --------------------------------------------------------------------
  u_pulser: entity work.button_pulser
    generic map (
      G_START_DELAY_CYCLES   => 2000, -- ≈2 s at 1 kHz clock
      G_REPEAT_PERIOD_CYCLES => 500 -- ≈0.5 s at 1 kHz clock
    )
    port map (
      clk       => clk_1k,  -- use slow 1 kHz clock
      n_Reset   => n_Reset, -- internal active-low reset
      btn_in    => btn(1),  -- user button input
      pulse_out => pulse_s -- generated pulse signal
    );

  --------------------------------------------------------------------
  -- Instantiate RGB FSM unit:
  -- On each pulse, cycles LED colors in sequence R → G → B → R …
  --------------------------------------------------------------------
  u_fsm: entity work.rgb_fsm
    port map (
      clk      => clk_1k,  -- driven by same 1 kHz clock
      n_Reset  => n_Reset, -- internal active-low reset
      pulse_in => pulse_s, -- pulse signal from button pulser
      sel_r    => led5_r,  -- drive red LED channel
      sel_g    => led5_g,  -- drive green LED channel
      sel_b    => led5_b -- drive blue LED channel
    );

end architecture;
