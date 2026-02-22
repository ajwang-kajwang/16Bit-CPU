--testbench
library IEEE;
use IEEE.std_logic_1164.all;

entity microcontroller_tb is
end entity;

architecture test of microcontroller_tb is

  -- Signals to drive the DUT
  signal clk_in : std_logic := '0';
  signal reset  : std_logic := '1';
  signal btn    : std_logic := '1';
  -- Clock period definition for 50 MHz clock
  constant clk_period : time := 10ns;

  -- Component declaration for Microcontroller
  component microcontroller is
    port (
      clk_in : in std_logic;
      reset  : in std_logic;
      --led output
      led_out : out std_logic_vector(9 downto 0);
      --7 seg output
      seg0_out : out std_logic_vector(7 downto 0);
      seg1_out : out std_logic_vector(7 downto 0);
      seg2_out : out std_logic_vector(7 downto 0);
      seg3_out : out std_logic_vector(7 downto 0);
      seg4_out : out std_logic_vector(7 downto 0);
      seg5_out : out std_logic_vector(7 downto 0);
      --switch input
      --sw : in std_logic_vector(9 downto 0);
      --push button input
      btn : in std_logic
    );
  end component;

begin

  -- Instantiate the Microcontroller DUT
  DUT : microcontroller
  port map
  (
    clk_in => clk_in,
    reset  => reset,
    btn    => btn
  );

  -- Clock Generation Process
  clk_process : process
  begin
    while True loop
      clk_in <= '1';
      wait for clk_period ;
      clk_in <= '0';
      wait for clk_period ;
    end loop;
    wait;
  end process clk_process;

  -- Reset Generation Process
  reset_process : process
  begin
    -- Assert Reset
    reset <= '0';
    wait for 100 ns; -- Hold reset for 100 ns

    -- De-assert Reset
    reset <= '1';
    wait;
  end process reset_process;

  -- Simulation Termination Process
  terminate_sim : process
  begin
    -- Wait for a sufficient amount of time to observe behavior
    wait for 20000 ns;
    -- Terminate simulation
    assert False report "Simulation Completed Successfully" severity failure;
  end process terminate_sim;

end architecture;