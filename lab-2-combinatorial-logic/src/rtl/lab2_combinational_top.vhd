-- Lab 2: Combinational Logic
-- Board: PYNQ-Z2
--   2-to-4 decoder and basic logic gates
--   Mode selected by switches
--   RGB LED4 from buttons
--   RGB LED5 with master override

library IEEE; -- include standard IEEE library
  use IEEE.STD_LOGIC_1164.all; -- import logic types (std_logic, std_logic_vector)

  -- top-level entity and port I/O declaration

entity lab2_combinational_top is
  port (
    btn    : in  std_logic_vector(1 downto 0); -- 2 push buttons
    sw     : in  std_logic_vector(1 downto 0); -- 2 switches
    led    : out std_logic_vector(3 downto 0); -- 4 green LEDs
    led4_r : out std_logic;                    -- RGB LED4 red
    led4_g : out std_logic;                    -- RGB LED4 green
    led4_b : out std_logic;                    -- RGB LED4 blue
    led5_r : out std_logic;                    -- RGB LED5 red
    led5_g : out std_logic;                    -- RGB LED5 green
    led5_b : out std_logic                     -- RGB LED5 blue
  );
end entity;

-- architecture declaration section (signals, constants, types, components etc.)

architecture Behavioral of lab2_combinational_top is

  -- RGB colour codes reference
  -- | Code | R | G | B | Color  |
  -- |------|---|---|---|--------|
  -- | 100  | 1 | 0 | 0 | Red    |
  -- | 010  | 0 | 1 | 0 | Green  |
  -- | 001  | 0 | 0 | 1 | Blue   |
  -- | 000  | 0 | 0 | 0 | Off    |

  -- internal RGB signals, active-high (2=R,1=G,0=B; 100=red,010=green,001=blue)
  signal RGB_Led_4 : std_logic_vector(2 downto 0);
  signal RGB_Led_5 : std_logic_vector(2 downto 0);

  -- LED buses for two modes: decoder vs logic-gates
  signal dec_led  : std_logic_vector(3 downto 0);
  signal gate_led : std_logic_vector(3 downto 0);

begin -- architecture body (begin ... end)

  ------------------------------------------------------------------------------
  -- 2 to 4 decoder + RGB4 color
  --
  -- | btn1 | btn0 | led3 led2 led1 led0 |
  -- |------|------|---------------------|
  -- |   0  |   0  |     0  0  0  1      |
  -- |   0  |   1  |     0  0  1  0      |
  -- |   1  |   0  |     0  1  0  0      |
  -- |   1  |   1  |     1  0  0  0      |
  ------------------------------------------------------------------------------
  -- When switch 1 is off, LEDs 0-3 acts one-hot, 2-to-4 decoder
  -- When switch 1 is on, LEDs 0-3 acts as in table below:
  -- 
  -- | btn1 | btn0 | led3 led2 led1 led0 |
  -- |------|------|---------------------|
  -- |  0   |  0   |   1    0    0    0  |
  -- |  0   |  1   |   1    1    1    0  |
  -- |  1   |  0   |   1    1    1    0  |
  -- |  1   |  1   |   0    1    0    1  |
  ------------------------------------------------------------------------------

  -- 2 to 4 decoder for led(3:0)
  with btn(1 downto 0) select
    dec_led <= "0001" when "00", -- led(0) ON
               "0010" when "01", -- led(1) ON
               "0100" when "10", -- led(2) ON
               "1000" when others; -- led(3) ON ("11")

  -- Logic-gates mode output
  gate_led(3) <= not(btn(1) and btn(0)); -- NAND → 1 1 1 0
  gate_led(2) <= (btn(1) or btn(0));     -- OR   → 0 1 1 1
  gate_led(1) <= (btn(1) xor btn(0));    -- XOR  → 0 1 1 0
  gate_led(0) <= (btn(1) and btn(0));    -- AND  → 0 0 0 1

  -- Mode selector for LEDs, sw1='0' → decoder, sw1='1' → logic
  led <= dec_led when sw(1) = '0' else gate_led;

  ------------------------------------------------------------------------------
  -- RGB4 color from buttons (2=R,1=G,0=B; active-high internal coding)
  -- | btn1 btn0 | RGB4 |
  -- |   0   0   | 000  (off)
  -- |   0   1   | 100  (red)
  -- |   1   0   | 010  (green)
  -- |   1   1   | 001  (blue)
  ------------------------------------------------------------------------------

  --- RGB4 color selection
  with btn(1 downto 0) select
    RGB_Led_4 <= "000" when "00", -- off
                 "100" when "01", -- red
                 "010" when "10", -- green
                 "001" when others; -- blue ("11")

  -- RGB4 mapping to physical pins
  led4_r <= RGB_Led_4(2);
  led4_g <= RGB_Led_4(1);
  led4_b <= RGB_Led_4(0);

  ------------------------------------------------------------------------------
  -- Master switch (output mux) for RGB5:

  -- | sw1 | sw0 | RGB5 output | Meaning          |
  -- |-----|-----|-------------|------------------|
  -- |  0  |  0  | 000         | off              |
  -- |  0  |  1  | RGB4        | copy RGB4        |
  -- |  1  |  0  | 111         | white (override) |
  -- |  1  |  1  | 111         | white (override) |

  -- When switch 0 (sw0) is off, RGB-led 5 remains off.
  -- When switch 0 (sw0) is on, RGB-led 5 acts as RGB-led 4.
  -- When switch 1 (sw1) is on, it overrides everything so that all channels of RGB-led 5 are on (it turns white).
  ------------------------------------------------------------------------------

  -- RGB5 color selection with master switch
  RGB_Led_5 <= (others => '1') when sw(1) = '1' else -- white (override)
              RGB_Led_4        when sw(0) = '1' else -- mirror RGB4
                (others => '0'); -- off

  -- RGB5 mapping to physical pins
  led5_r <= RGB_Led_5(2);
  led5_g <= RGB_Led_5(1);
  led5_b <= RGB_Led_5(0);

end architecture;
