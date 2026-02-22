library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--Not use IO here as output will be attached to the ALU
entity Register_file is
  port (
    clk                : in std_logic;
    Reg_A_Out          : out std_logic_vector(15 downto 0);
    Reg_B_Out          : out std_logic_vector(15 downto 0);
    Reg_A_Write_Enable : in std_logic;
    Reg_A_In           : in std_logic_vector(15 downto 0);
    Reg_B_Write_Enable : in std_logic;
    Reg_B_In           : in std_logic_vector(15 downto 0)
  );
end Register_file;

architecture Behavioral of Register_file is
  --don't do the reg array as this is a simple cpu
  signal Reg_A : std_logic_vector(15 downto 0);
  signal Reg_B : std_logic_vector(15 downto 0);
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if Reg_A_Write_Enable = '1' then
        Reg_A <= Reg_A_In;
      end if;
      if Reg_B_Write_Enable = '1' then
        Reg_B <= Reg_B_In;
      end if;
    end if;
  end process;
  Reg_A_Out <= Reg_A;
  Reg_B_Out <= Reg_B;
end Behavioral;
