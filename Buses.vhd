library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Buses is
  port (
    -- Inputs
    Bus1_In_ALU_Result : in std_logic_vector(15 downto 0);
    Bus1_In_Mem_Data   : in std_logic_vector(15 downto 0);
    Bus1_In_Reg_A      : in std_logic_vector(15 downto 0);
    Bus1_In_Reg_B      : in std_logic_vector(15 downto 0);
    Bus1_In_PC         : in std_logic_vector(15 downto 0);
    --selection
    Bus1_In_Sel        : in std_logic_vector(2 downto 0);
    Bus1_Out_Sel       : in std_logic_vector(2 downto 0);
    -- Outputs
    Bus1_Out_PC        : out std_logic_vector(15 downto 0);
    Bus1_Out_Mem_Addr  : out std_logic_vector(15 downto 0);
    Bus1_Out_Mem_Data  : out std_logic_vector(15 downto 0);
    Bus1_Out_IR        : out std_logic_vector(15 downto 0);
    Bus1_Out_Reg_A     : out std_logic_vector(15 downto 0);
    Bus1_Out_Reg_B     : out std_logic_vector(15 downto 0)
  );
end Buses;

architecture Behavioral of Buses is

  -- Bus Output selection constants
  constant Bus1_Out_Sel_PC       : std_logic_vector(2 downto 0) := "000";
  constant Bus1_Out_Sel_Mem_Addr : std_logic_vector(2 downto 0) := "001";
  constant Bus1_Out_Sel_Mem_Data : std_logic_vector(2 downto 0) := "010";
  constant Bus1_Out_Sel_IR       : std_logic_vector(2 downto 0) := "011";
  constant Bus1_Out_Sel_Reg_A    : std_logic_vector(2 downto 0) := "100";
  constant Bus1_Out_Sel_Reg_B    : std_logic_vector(2 downto 0) := "101";

begin

  process (Bus1_In_Sel, Bus1_Out_Sel, Bus1_In_ALU_Result, Bus1_In_Mem_Data, Bus1_In_Reg_A, Bus1_In_Reg_B, Bus1_In_PC)
  begin
    -- Default assignments to prevent latches
    Bus1_Out_PC       <= (others => '0');
    Bus1_Out_Mem_Addr <= (others => '0');
    Bus1_Out_Mem_Data <= (others => '0');
    Bus1_Out_IR       <= (others => '0');
    Bus1_Out_Reg_A    <= (others => '0');
    Bus1_Out_Reg_B    <= (others => '0');

    case Bus1_In_Sel is
      when "000" =>  -- ALU Result
        case Bus1_Out_Sel is
          when Bus1_Out_Sel_PC =>
            Bus1_Out_PC <= Bus1_In_ALU_Result;
          when Bus1_Out_Sel_Mem_Addr =>
            Bus1_Out_Mem_Addr <= Bus1_In_ALU_Result;
          when Bus1_Out_Sel_Mem_Data =>
            Bus1_Out_Mem_Data <= Bus1_In_ALU_Result;
          when Bus1_Out_Sel_IR =>
            Bus1_Out_IR <= Bus1_In_ALU_Result;
          when Bus1_Out_Sel_Reg_A =>
            Bus1_Out_Reg_A <= Bus1_In_ALU_Result;
          when Bus1_Out_Sel_Reg_B =>
            Bus1_Out_Reg_B <= Bus1_In_ALU_Result;
          when others =>
            null;
        end case;

      when "001" =>  -- Memory Data
        case Bus1_Out_Sel is
          when Bus1_Out_Sel_PC =>
            Bus1_Out_PC <= Bus1_In_Mem_Data;
          when Bus1_Out_Sel_Mem_Addr =>
            Bus1_Out_Mem_Addr <= Bus1_In_Mem_Data;
          when Bus1_Out_Sel_Mem_Data =>
            Bus1_Out_Mem_Data <= Bus1_In_Mem_Data;
          when Bus1_Out_Sel_IR =>
            Bus1_Out_IR <= Bus1_In_Mem_Data;
          when Bus1_Out_Sel_Reg_A =>
            Bus1_Out_Reg_A <= Bus1_In_Mem_Data;
          when Bus1_Out_Sel_Reg_B =>
            Bus1_Out_Reg_B <= Bus1_In_Mem_Data;
          when others =>
            null;
        end case;

      when "010" =>  -- Register A
        case Bus1_Out_Sel is
          when Bus1_Out_Sel_PC =>
            Bus1_Out_PC <= Bus1_In_Reg_A;
          when Bus1_Out_Sel_Mem_Addr =>
            Bus1_Out_Mem_Addr <= Bus1_In_Reg_A;
          when Bus1_Out_Sel_Mem_Data =>
            Bus1_Out_Mem_Data <= Bus1_In_Reg_A;
          when Bus1_Out_Sel_IR =>
            Bus1_Out_IR <= Bus1_In_Reg_A;
          when Bus1_Out_Sel_Reg_A =>
            Bus1_Out_Reg_A <= Bus1_In_Reg_A;
          when Bus1_Out_Sel_Reg_B =>
            Bus1_Out_Reg_B <= Bus1_In_Reg_A;
          when others =>
            null;
        end case;

      when "011" =>  -- Register B
        case Bus1_Out_Sel is
          when Bus1_Out_Sel_PC =>
            Bus1_Out_PC <= Bus1_In_Reg_B;
          when Bus1_Out_Sel_Mem_Addr =>
            Bus1_Out_Mem_Addr <= Bus1_In_Reg_B;
          when Bus1_Out_Sel_Mem_Data =>
            Bus1_Out_Mem_Data <= Bus1_In_Reg_B;
          when Bus1_Out_Sel_IR =>
            Bus1_Out_IR <= Bus1_In_Reg_B;
          when Bus1_Out_Sel_Reg_A =>
            Bus1_Out_Reg_A <= Bus1_In_Reg_B;
          when Bus1_Out_Sel_Reg_B =>
            Bus1_Out_Reg_B <= Bus1_In_Reg_B;
          when others =>
            null;
        end case;

      when "100" =>  -- Program Counter (PC)
        case Bus1_Out_Sel is
          when Bus1_Out_Sel_PC =>
            Bus1_Out_PC <= Bus1_In_PC;
          when Bus1_Out_Sel_Mem_Addr =>
            Bus1_Out_Mem_Addr <= Bus1_In_PC;
          when Bus1_Out_Sel_Mem_Data =>
            Bus1_Out_Mem_Data <= Bus1_In_PC;
          when Bus1_Out_Sel_IR =>
            Bus1_Out_IR <= Bus1_In_PC;
          when Bus1_Out_Sel_Reg_A =>
            Bus1_Out_Reg_A <= Bus1_In_PC;
          when Bus1_Out_Sel_Reg_B =>
            Bus1_Out_Reg_B <= Bus1_In_PC;
          when others =>
            null;
        end case;

      when others =>
        null;  -- Handle unexpected Bus1_In_Sel values
    end case;
  end process;

end Behavioral;
