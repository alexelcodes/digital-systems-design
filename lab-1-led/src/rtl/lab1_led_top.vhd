-- Lab 1: LED Controller
-- Board: PYNQ-Z2
-- Combinational design:
--   led(3:0) follows btn(3:0)
--   RGB LED4: red/green/blue for single button press
--   RGB LED5: white (no buttons), off (all buttons)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_thingy_top is
  Port (
    btn :       in  STD_LOGIC_VECTOR(3 downto 0);
    sw :        in  STD_LOGIC_VECTOR(1 downto 0);
    led :       out  STD_LOGIC_VECTOR (3 downto 0);
    led4_r :    out STD_LOGIC;
    led4_g :    out STD_LOGIC;
    led4_b :    out STD_LOGIC;
    led5_r :    out STD_LOGIC;
    led5_g :    out STD_LOGIC;
    led5_b :    out STD_LOGIC
  );
end led_thingy_top;

architecture Behavioral of led_thingy_top is
   
    -- group of RGB led signals
    signal RGB_Led_4: std_logic_vector(0 to 2);
    -- group of RGB led signals
    signal RGB_Led_5: std_logic_vector(0 to 2);


begin

    -- buttons directly mapped to red leds
    led <= btn;
 
    -- Some "housekeeping" first
    -- map signal "RGB_Led_4" to actual output ports
    led4_r <= RGB_Led_4(2);
    led4_g <= RGB_Led_4(1);
    led4_b <= RGB_Led_4(0);
    
    -- map signal "RGB_Led_5" to actual output ports
    led5_r <= RGB_Led_5(2);
    led5_g <= RGB_Led_5(1);
    led5_b <= RGB_Led_5(0);
            
                
    -- Control of RGB LED 4
    with btn(3 downto 0) select
        RGB_Led_4 <=    "001" when "0001", --red
                        "010" when "0010", --green
                        "100" when "0100", --blue
                        "000" when others; --off
                        
    -- Control of RGB LED 5
         with btn(3 downto 0) select
            RGB_Led_5 <=    "111" when "0000", --white
                            "000" when "1111", --off
                            "111" when others; -- -> no spec, let's keep it white                        
           
                        
end Behavioral;