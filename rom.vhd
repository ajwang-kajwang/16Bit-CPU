library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ROM is
  port (
    clk  : in std_logic;  -- Added clock input
    addr : in std_logic_vector(15 downto 0);
    data : out std_logic_vector(15 downto 0)  -- Changed to output only
  );
end entity;

architecture behavioral of ROM is
  type rom_type is array (0 to 255) of std_logic_vector(15 downto 0);
  -- Initialize ROM with a function instead of direct assignment
  function init_rom return rom_type is
    variable rom_data : rom_type;
  begin
    -- Default initialization
    for i in rom_data'range loop
      rom_data(i) := x"FFFF";
    end loop;
    
    -- Specific initializations
    rom_data(0) := x"4000"; -- test jmp, jump to 0x10
    rom_data(1) := x"0080"; -- fetch address in 0x80
    rom_data(16) := x"1000"; -- opcode lda_imm
    rom_data(17) := x"0081"; -- addr 0x81
    rom_data(18) := x"1100"; -- opcode ldb_imm
    rom_data(19) := x"0082"; -- addr 0x82
    rom_data(20) := x"2100"; -- opcode sub
    rom_data(21) := x"1200"; -- opcode sta_imm
    rom_data(22) := x"8000"; -- addr 0x8000
    rom_data(128) := x"0010"; -- jump to addr 0x10
    rom_data(129) := x"F55F"; -- lda_imm f55f
    rom_data(130) := x"5FF5"; -- ldb_imm 5ff5
    
    return rom_data;
  end function;
  
  signal rom : rom_type := init_rom;
  
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if unsigned(addr(15 downto 8)) = 0 then
        data <= rom(to_integer(unsigned(addr(7 downto 0))));
      else
        data <= (others => '1');
      end if;
    end if;
  end process;
end behavioral;