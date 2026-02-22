library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; -- Use NUMERIC_STD for arithmetic operations

entity CPU is
  port (
    clk : in std_logic;
    rst : in std_logic;
    --no luck with IO port
    --Memory_Data_Port : inout std_logic_vector(15 downto 0);
    Mem_Data_Output_Port : in std_logic_vector(15 downto 0);
    Mem_Data_Input_Port  : out std_logic_vector(15 downto 0);
    Memory_Addr_Port     : out std_logic_vector(15 downto 0);
    Memory_Data_WE       : out std_logic;
    Memory_Addr_WE       : out std_logic
  );
end CPU;

architecture Behavioral of CPU is

  -- Component Declarations
  component ALU
    port (
      In1, In2 : in std_logic_vector(15 downto 0);
      Op       : in std_logic_vector(3 downto 0);
      Result   : out std_logic_vector(15 downto 0);
      NVZC     : out std_logic_vector(3 downto 0)
    );
  end component;

  component Register_file is
    port (
      clk                : in std_logic;
      Reg_A_Out          : out std_logic_vector(15 downto 0);
      Reg_B_Out          : out std_logic_vector(15 downto 0);
      Reg_A_Write_Enable : in std_logic;
      Reg_A_In           : in std_logic_vector(15 downto 0);
      Reg_B_Write_Enable : in std_logic;
      Reg_B_In           : in std_logic_vector(15 downto 0)
    );
  end component;

  component Buses is
    port (
      Bus1_In_ALU_Result : in std_logic_vector(15 downto 0);
      Bus1_In_Mem_Data   : in std_logic_vector(15 downto 0);
      Bus1_In_Reg_A      : in std_logic_vector(15 downto 0);
      Bus1_In_Reg_B      : in std_logic_vector(15 downto 0);
      Bus1_In_PC         : in std_logic_vector(15 downto 0);
      Bus1_Out_PC        : out std_logic_vector(15 downto 0);
      Bus1_Out_Mem_Addr  : out std_logic_vector(15 downto 0);
      Bus1_Out_Mem_Data  : out std_logic_vector(15 downto 0);
      Bus1_Out_IR        : out std_logic_vector(15 downto 0);
      Bus1_Out_Reg_A     : out std_logic_vector(15 downto 0);
      Bus1_Out_Reg_B     : out std_logic_vector(15 downto 0);
      Bus1_In_Sel        : in std_logic_vector(2 downto 0);
      Bus1_Out_Sel       : in std_logic_vector(2 downto 0)
    );
  end component;

  component pc_unit is
    port (
      clk    : in std_logic;
      rst    : in std_logic;
      PC     : out std_logic_vector(15 downto 0);
      PC_set : in std_logic;
      PC_in  : in std_logic_vector(15 downto 0);
      PC_inc : in std_logic
    );
  end component;

  component ctrl_unit is
    port (
      clk                   : in std_logic;
      rst                   : in std_logic;
      IR_In                 : in std_logic_vector(15 downto 0);
      Mem_Addr_Write_Enable : out std_logic;
      Mem_Data_Write_Enable : out std_logic;
      Bus1_In_Sel           : out std_logic_vector(2 downto 0);
      Bus1_Out_Sel          : out std_logic_vector(2 downto 0);
      Reg_A_Write_Enable    : out std_logic;
      Reg_B_Write_Enable    : out std_logic;
      PC_Increment          : out std_logic;
      PC_Set                : out std_logic;
      ALU_NVZC_flags        : in std_logic_vector(3 downto 0);
      ALU_Op                : out std_logic_vector(3 downto 0)
    );
  end component;

  -- Signals for Interconnection
  signal Reg_A, Reg_B         : std_logic_vector(15 downto 0);
  signal Reg_A_In, Reg_B_In   : std_logic_vector(15 downto 0);
  signal ALU_Result           : std_logic_vector(15 downto 0);
  signal NVZC_flag            : std_logic_vector(3 downto 0);
  signal ALU_Op               : std_logic_vector(3 downto 0);
  signal Bus1_Out_PC          : std_logic_vector(15 downto 0);
  signal Bus1_Out_IR          : std_logic_vector(15 downto 0);
  signal PC                   : std_logic_vector(15 downto 0);
  signal PC_Increment, PC_Set : std_logic;
  signal Bus1_In_Sel          : std_logic_vector(2 downto 0);
  signal Bus1_Out_Sel         : std_logic_vector(2 downto 0);
  signal Reg_A_Write_Enable   : std_logic;
  signal Reg_B_Write_Enable   : std_logic;
begin

  -- Register File Instantiation
  cpu_register_file : Register_file
  port map
  (
    clk                => clk,
    Reg_A_Out          => Reg_A,
    Reg_B_Out          => Reg_B,
    Reg_A_Write_Enable => Reg_A_Write_Enable,
    Reg_A_In           => Reg_A_In,
    Reg_B_Write_Enable => Reg_B_Write_Enable,
    Reg_B_In           => Reg_B_In
  );

  -- ALU Instantiation
  cpu_alu : ALU
  port map
  (
    In1    => Reg_A,
    In2    => Reg_B,
    Op     => ALU_Op(3 downto 0),
    Result => ALU_Result,
    NVZC   => NVZC_flag
  );

  -- Buses Instantiation
  cpu_bus : Buses
  port map
  (
    Bus1_In_ALU_Result => ALU_Result,
    Bus1_In_Mem_Data   => Mem_Data_Output_Port,
    Bus1_In_Reg_A      => Reg_A,
    Bus1_In_Reg_B      => Reg_B,
    Bus1_In_PC         => PC,
    Bus1_Out_PC        => Bus1_Out_PC,
    Bus1_Out_Mem_Addr  => Memory_Addr_Port,
    Bus1_Out_Mem_Data  => Mem_Data_Input_Port,
    Bus1_Out_IR        => Bus1_Out_IR,
    Bus1_Out_Reg_A     => Reg_A_In,
    Bus1_Out_Reg_B     => Reg_B_In,
    Bus1_In_Sel        => Bus1_In_Sel,
    Bus1_Out_Sel       => Bus1_Out_Sel
  );

  -- Program Counter (PC) Unit Instantiation
  pc_inst : pc_unit
  port map
  (
    clk    => clk,
    rst    => rst,
    PC     => PC,
    PC_set => PC_Set,
    PC_in  => Bus1_Out_PC,
    PC_inc => PC_Increment
  );

  -- Control Unit Instantiation
  control_unit_inst : ctrl_unit
  port map
  (
    clk                   => clk,
    rst                   => rst,
    IR_In                 => Bus1_Out_IR,
    Mem_Addr_Write_Enable => Memory_Addr_WE,
    Mem_Data_Write_Enable => Memory_Data_WE,
    Bus1_In_Sel           => Bus1_In_Sel,
    Bus1_Out_Sel          => Bus1_Out_Sel,
    Reg_A_Write_Enable    => Reg_A_Write_Enable,
    Reg_B_Write_Enable    => Reg_B_Write_Enable,
    PC_Increment          => PC_Increment,
    PC_Set                => PC_Set,
    ALU_NVZC_flags        => NVZC_flag,
    ALU_Op                => ALU_Op
  );

end Behavioral;
