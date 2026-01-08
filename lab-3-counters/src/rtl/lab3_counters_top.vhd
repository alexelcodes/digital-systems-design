-- Lab 3: Counters
-- Board: PYNQ-Z2
--   int_a: free-running counter -> JA(7:0)
--   int_b: wraps at 25 -> JB(7:0)
--   Reset synchronized from btn(0)

library IEEE;
  use IEEE.STD_LOGIC_1164.all; -- standard logic types
  use IEEE.NUMERIC_STD.all; -- conversions (integer <-> unsigned)

  -- Top-level module and I/O ports

entity lab3_counters_top is
  port (
    sysclk : in  std_logic;                    -- 125 MHz clock
    btn    : in  std_logic_vector(0 downto 0); -- btn(0) = reset button
    ja     : out std_logic_vector(7 downto 0); -- outputs to PMOD JA connector
    jb     : out std_logic_vector(7 downto 0)  -- outputs to PMOD JB connector
  );
end entity;

architecture rtl of lab3_counters_top is
  --------------------------------------------------------------------------
  -- Counters
  -- Start from 0 in simulation, but on real FPGA the reset button is needed
  --------------------------------------------------------------------------
  signal int_a : integer                := 0; -- counter without range limit
  signal int_b : integer range 0 to 255 := 0; -- counter limited to 0..255 (8 bits)

  --------------------------------------------------------------------------
  -- Reset signals
  -- Button is asynchronous → pass it through 2 flip-flops (synchronizer)
  -- After that we get a clean reset signal inside the clock domain
  --------------------------------------------------------------------------
  signal rst_meta : std_logic := '0'; -- first stage of synchronizer
  signal rst_sync : std_logic := '0'; -- second stage, used as reset
begin
  --------------------------------------------------------------------------
  -- Synchronizer for reset button
  -- If btn(0) = '1' → rst_sync becomes '1' after 2 clock cycles
  --------------------------------------------------------------------------
  sync_rst: process (sysclk)
  begin
    if rising_edge(sysclk) then
      rst_meta <= btn(0);
      rst_sync <= rst_meta;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Counter process
  -- Every clock cycle:
  --   if reset = 1 → set counters to 0
  --   else         → increase counters by 1
  --------------------------------------------------------------------------
  counter_p: process (sysclk)
  begin
    if rising_edge(sysclk) then
      if rst_sync = '1' then
        int_a <= 0;
        int_b <= 0;
      else
        int_a <= int_a + 1;

        if int_b = 25 then
          int_b <= 0; -- wrap back to 0
        else
          int_b <= int_b + 1; -- otherwise increment
        end if;

      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Output mapping
  -- Send the last 8 bits (LSB = least significant bits) of each counter to JA and JB
  -- Conversion: integer → unsigned → std_logic_vector
  --------------------------------------------------------------------------
  ja <= std_logic_vector(to_unsigned(int_a, ja'length));
  jb <= std_logic_vector(to_unsigned(int_b, jb'length));
end architecture;
