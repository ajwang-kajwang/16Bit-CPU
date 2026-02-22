library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ALU is
  port (
    In1, In2 : in std_logic_vector(15 downto 0);
    Op       : in std_logic_vector(3 downto 0);
    Result   : out std_logic_vector(15 downto 0);
    NVZC     : out std_logic_vector(3 downto 0)
  );
end ALU;

architecture Behavioral of ALU is
  signal temp : std_logic_vector(16 downto 0);
begin
  process (Op)
  begin
    case Op is
        -- Addition
      when "0000" => temp <= std_logic_vector(unsigned('0' & In1) + unsigned('0' & In2));
        -- Subtraction
      when "0001" => temp <= std_logic_vector(unsigned('0' & In1) - unsigned('0' & In2));
        -- Multiplication (limited to lower 16 bits)
      when "0010" => temp <= std_logic_vector(resize(unsigned(In1) * unsigned(In2), 17));
        -- Division (limited to lower 16 bits)
      when "0011" =>
        if unsigned(In2) /= 0 then
          temp <= std_logic_vector(resize(unsigned(In1) / unsigned(In2), 17));
        else
          temp <= (others => '0'); -- Division by zero protection, explicitly set to zero
        end if;
        -- Bitwise AND
      when "0100" => temp <= '0' & (In1 and In2);
        -- Bitwise OR
      when "0101" => temp <= '0' & (In1 or In2);
        -- Bitwise XOR
      when "0110" => temp <= '0' & (In1 xor In2);
        -- Bitwise NOR
      when "0111" => temp <= '0' & not (In1 or In2);
        -- Bitwise NAND
      when "1000" => temp <= '0' & not (In1 and In2);
        -- Bitwise XNOR
      when "1001" => temp <= '0' & not (In1 xor In2);
        -- Shift left
      when "1010" => temp <= std_logic_vector(resize(unsigned(In1) sll to_integer(unsigned(In2(3 downto 0))), 17));
        -- Shift right
      when "1011" => temp <= std_logic_vector(resize(unsigned(In1) srl to_integer(unsigned(In2(3 downto 0))), 17));
        -- Default case
      when others => temp <= (others => '0');
    end case;
  end process;

  -- Assign the lower 16 bits of temp to Result
  Result <= temp(15 downto 0);

  -- Set NVZC flags
  NVZC(3) <= temp(15); -- Negative flag (most significant bit of result)
  NVZC(2) <= '1' when temp(15 downto 0) = "0000000000000000" else
  '0'; -- Zero flag

  -- Overflow flag
  NVZC(1) <= '1' when (Op = "0000" and In1(15) = In2(15) and In1(15) /= temp(15)) else
  '1' when (Op = "0001" and In1(15) /= In2(15) and In1(15) /= temp(15)) else
  '0';

  NVZC(0) <= temp(16); -- Carry flag (the 17th bit, which represents carry-out)
end Behavioral;
