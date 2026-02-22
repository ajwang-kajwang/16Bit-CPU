library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity pc_unit is
  port (
    clk    : in std_logic;
    rst    : in std_logic;
    PC     : out std_logic_vector(15 downto 0);
    PC_set : in std_logic;
    PC_in  : in std_logic_vector(15 downto 0);
    PC_inc : in std_logic
  );
end entity;

architecture behavioral of pc_unit is
  signal PC_tmp : std_logic_vector(15 downto 0) := x"0000";
begin
  -- Single process for reset, PC increment, and PC set
  process (clk, rst)
  begin
    if rst = '0' then
      PC_tmp <= (others => '0');
    elsif rising_edge(clk) then
      if PC_set = '1' then
        PC_tmp <= PC_in;
      elsif PC_inc = '1' then
        PC_tmp <= std_logic_vector(unsigned(PC_tmp) + 1);
      end if;
    end if;
  end process;

  -- Assign output PC
  PC <= PC_tmp;

end architecture behavioral;
