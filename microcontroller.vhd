library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity microcontroller is
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
    --push button input
    btn : in std_logic
  );
end microcontroller;

architecture behavioral of microcontroller is
  -- Component Declarations
  component CPU is
    port (
      clk                  : in std_logic;
      rst                  : in std_logic;
      Mem_Data_Output_Port : in std_logic_vector(15 downto 0);
      Mem_Data_Input_Port  : out std_logic_vector(15 downto 0);
      Memory_Addr_Port     : out std_logic_vector(15 downto 0);
      Memory_Data_WE       : out std_logic;
      Memory_Addr_WE       : out std_logic
    );
  end component;

  component RAM is
    port (
      clk      : in std_logic;
      addr     : in std_logic_vector(15 downto 0);
      data_in  : in std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0);
      we       : in std_logic;
      en       : in std_logic
    );
  end component;

  component intel_rom is
    port (
      clk  : in std_logic;
      addr : in std_logic_vector(15 downto 0);
      data : out std_logic_vector(15 downto 0);  -- Changed to output only
      en   : in std_logic
    );
  end component;

  component seg_output is
    port (
      clk            : in std_logic;
      seg0_out       : out std_logic_vector(7 downto 0);
      seg1_out       : out std_logic_vector(7 downto 0);
      seg2_out       : out std_logic_vector(7 downto 0);
      seg3_out       : out std_logic_vector(7 downto 0);
      seg4_out       : out std_logic_vector(7 downto 0);
      seg5_out       : out std_logic_vector(7 downto 0);
      data           : in std_logic_vector(15 downto 0);
      data_we        : in std_logic;
      rom_addr       : in std_logic_vector(7 downto 0);
      display_enable : in std_logic
    );
  end component;

  -- Clock signals
  signal cpu_clk, sys_clk : std_logic := '0';
  signal cpu_clk_divide_counter, mem_clk_divider_counter : integer range 0 to 4999999 := 0;

  -- Memory interface signals
  signal ram_data_in, ram_data_out : std_logic_vector(15 downto 0);
  signal rom_data : std_logic_vector(15 downto 0);
  signal cpu_data_in, cpu_data_out : std_logic_vector(15 downto 0);
  signal cpu_addr, latched_addr : std_logic_vector(15 downto 0);
  signal ram_addr, rom_addr : std_logic_vector(15 downto 0);
  
  -- Control signals
  signal cpu_data_we, cpu_addr_we : std_logic;
  signal ram_we, rom_enable, ram_enable : std_logic;
  
  -- Display signals
  signal seg_data : std_logic_vector(15 downto 0) := (others => '0');
  signal seg_we, display_enable : std_logic;

begin
  -- CPU Clock Divider
  process(clk_in)
  begin
    if rising_edge(clk_in) then
      if cpu_clk_divide_counter = 4999999 then
        cpu_clk_divide_counter <= 0;
        cpu_clk <= not cpu_clk;
      else
        cpu_clk_divide_counter <= cpu_clk_divide_counter + 1;
      end if;
    end if;
  end process;

  -- System Clock Divider
  process(clk_in)
  begin
    if rising_edge(clk_in) then
      if mem_clk_divider_counter = 2499999 then
        mem_clk_divider_counter <= 0;
        sys_clk <= not sys_clk;
      else
        mem_clk_divider_counter <= mem_clk_divider_counter + 1;
      end if;
    end if;
  end process;

  -- CPU Instance
  CPU_inst : CPU port map (
    clk                  => cpu_clk,
    rst                  => reset,
    Mem_Data_Output_Port => cpu_data_in,
    Mem_Data_Input_Port  => cpu_data_out,
    Memory_Addr_Port     => cpu_addr,
    Memory_Data_WE       => cpu_data_we,
    Memory_Addr_WE       => cpu_addr_we
  );

  -- RAM Instance
  RAM_inst : RAM port map (
    clk      => cpu_clk,
    addr     => ram_addr,
    data_in  => ram_data_in,
    data_out => ram_data_out,
    we       => ram_we,
    en       => ram_enable
  );

  -- ROM Instance
  ROM_inst : intel_rom port map (
    clk  => sys_clk,
    addr => rom_addr,
    data => rom_data,
    en   => rom_enable
  );

  -- Seven-Segment Display Instance
  seg_output_inst : seg_output port map (
    clk            => sys_clk,
    seg0_out       => seg0_out,
    seg1_out       => seg1_out,
    seg2_out       => seg2_out,
    seg3_out       => seg3_out,
    seg4_out       => seg4_out,
    seg5_out       => seg5_out,
    data           => seg_data,
    data_we        => seg_we,
    rom_addr       => rom_addr(7 downto 0),
    display_enable => display_enable
  );

  -- Address assignment
  ram_addr <= latched_addr;
  rom_addr <= latched_addr;

  -- In the Memory and Display Control Process section, modify the comparison logic:
  process(sys_clk, reset)
  begin
    if reset = '0' then
      -- Reset state
      cpu_data_in <= (others => '0');
      ram_data_in <= (others => '0');
      latched_addr <= (others => '0');
      ram_we <= '0';
      seg_we <= '0';
      rom_enable <= '0';
      ram_enable <= '0';
      display_enable <= '0';
      
    elsif rising_edge(sys_clk) then
      -- Default signal states
      seg_we <= '0';
      ram_we <= '0';
      
      -- Address latching
      if cpu_addr_we = '1' then
        latched_addr <= cpu_addr;
      end if;

      -- Memory enable control
      rom_enable <= '1' when latched_addr(15 downto 12) = "0000" else '0';
      ram_enable <= '1' when latched_addr(15 downto 12) = "1000" else '0';

      -- Memory access control
      if latched_addr(15 downto 12) = "0000" then  -- ROM access
        if cpu_data_we = '0' then
          cpu_data_in <= rom_data;
        end if;
        
      elsif latched_addr(15 downto 12) = "1000" then  -- RAM access
        if cpu_data_we = '1' then
          ram_we <= '1';
          ram_data_in <= cpu_data_out;
        else
          cpu_data_in <= ram_data_out;
        end if;
        
      elsif latched_addr(15 downto 12) = "0001" then  -- Display access
        if cpu_data_we = '1' then
          seg_we <= '1';
          display_enable <= latched_addr(8);
          seg_data <= cpu_data_out;
        end if;
      end if;
    end if;
  end process;