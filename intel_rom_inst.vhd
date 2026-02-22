library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity intel_rom_inst is
  port (
    address : in std_logic_vector(7 downto 0);
    clock   : in std_logic;
    q       : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of intel_rom_inst is
  
  component intel_rom
    port (
      address : in std_logic_vector(7 downto 0);
      clock   : in std_logic;
      q       : out std_logic_vector(15 downto 0)
    );
  end component;

begin
  rom_inst : intel_rom 
    port map (
      address => address,
      clock   => clock,
      q       => q
    );

end architecture;