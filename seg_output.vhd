library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity seg_output is
  port (
    clk : in std_logic;
    --7 seg output
    seg0_out : out std_logic_vector(7 downto 0);
    seg1_out : out std_logic_vector(7 downto 0);
    seg2_out : out std_logic_vector(7 downto 0);
    seg3_out : out std_logic_vector(7 downto 0);
    seg4_out : out std_logic_vector(7 downto 0);
    seg5_out : out std_logic_vector(7 downto 0);
    -- data input
    data    : in std_logic_vector(15 downto 0);
    data_we : in std_logic;
    --rom addr input for hex 4,5
    rom_addr : in std_logic_vector(7 downto 0);
    --on/off
    display_enable : in std_logic
  );
end seg_output;

architecture Behavioral of seg_output is

  -- Signal Declarations
  signal seg0, seg1, seg2, seg3, seg4, seg5 : std_logic_vector(7 downto 0) := "00000000";

  --decode function (we are not using dp here)
  function hex_to_7seg (hex_val : std_logic_vector(3 downto 0)) return std_logic_vector is
  begin
    case hex_val is
      when "0000" => return "11000000"; -- 0
      when "0001" => return "11111001"; -- 1
      when "0010" => return "10100100"; -- 2
      when "0011" => return "10110000"; -- 3
      when "0100" => return "10011001"; -- 4
      when "0101" => return "10010010"; -- 5
      when "0110" => return "10000010"; -- 6
      when "0111" => return "11111000"; -- 7
      when "1000" => return "10000000"; -- 8
      when "1001" => return "10010000"; -- 9
      when "1010" => return "10001000"; -- A
      when "1011" => return "10000011"; -- B
      when "1100" => return "11000110"; -- C
      when "1101" => return "10100001"; -- D
      when "1110" => return "10000110"; -- E
      when "1111" => return "10001110"; -- F
      when others => return "11111111"; -- All off
    end case;
  end function;

  signal data_buf : std_logic_vector(15 downto 0) := "0000000000000000";
begin

  process (rom_addr)
  begin
    seg4_out <= hex_to_7seg(rom_addr(3 downto 0)); -- ROM address nibble (lower)
    seg5_out <= hex_to_7seg(rom_addr(7 downto 4)); -- ROM address nibble (upper)
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      if data_we = '1' then
        data_buf <= data;
      end if;
      if display_enable = '1'then
        -- Assign decoded 7-segment values for each data segment
        seg0 <= hex_to_7seg(data_buf(3 downto 0)); -- Least significant nibble
        seg1 <= hex_to_7seg(data_buf(7 downto 4)); -- Next nibble
        seg2 <= hex_to_7seg(data_buf(11 downto 8)); -- Next nibble
        seg3 <= hex_to_7seg(data_buf(15 downto 12));-- Most significant nibble
      elsif display_enable = '0' then
        -- Turn off all segments when display is disabled
        seg0 <= "11111111"; -- All segments off
        seg1 <= "11111111";
        seg2 <= "11111111";
        seg3 <= "11111111";
      end if;
      -- Output the segment values to the respective 7-segment displays
    end if;
  end process;

  seg0_out <= seg0;
  seg1_out <= seg1;
  seg2_out <= seg2;
  seg3_out <= seg3;

end Behavioral;
