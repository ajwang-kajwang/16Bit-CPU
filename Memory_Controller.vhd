library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--well, instead of calling the controller, maybe arbitrator is a better name
entity Mem_Controller is
  port (
    clk                      : in std_logic;
    rst                      : in std_logic;
    Memory_Addr              : in std_logic_vector(15 downto 0);
    Memory_Addr_Write_Enable : in std_logic;
    Memory_Data              : inout std_logic_vector(15 downto 0);
    Memory_Data_Write_Enable : in std_logic
  );
end Mem_Controller;

architecture Behavioral of Mem_Controller is

begin

end architecture;
