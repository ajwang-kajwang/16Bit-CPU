library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ctrl_unit is
  port (
    clk                                          : in std_logic;
    rst                                          : in std_logic;
    IR_In                                        : in std_logic_vector(15 downto 0);
    Mem_Addr_Write_Enable, Mem_Data_Write_Enable : out std_logic;
    Bus1_In_Sel                                 : out std_logic_vector(2 downto 0);
    Bus1_Out_Sel                                 : out std_logic_vector(2 downto 0);
    Reg_A_Write_Enable, Reg_B_Write_Enable       : out std_logic;
    PC_Increment, PC_Set                         : out std_logic;
    ALU_NVZC_flags                               : in std_logic_vector(3 downto 0);
    ALU_Op                                       : out std_logic_vector(3 downto 0)
  );
end ctrl_unit;

--define instruction set

architecture behavioral of ctrl_unit is
  type state_type is (S_FETCH_0, S_FETCH_1, S_FETCH_2,
    S_DECODE_0,
    S_LS_Op_0, S_LS_Op_1, S_LS_Op_2, S_LS_Op_3, S_LS_Op_4, S_LS_Op_5,S_LS_Op_6,
    S_ALU_Op_0,
    S_JMP_Op_0, S_JMP_Op_1, S_JMP_Op_2, S_JMP_Op_3,
    S_HALT);
  signal curr_state, next_state : state_type;
  signal IR                     : std_logic_vector(15 downto 0);
  -- Bus Input sel mux constant
  constant Bus1_In_Sel_ALU_Result : std_logic_vector(2 downto 0) := "000";
  constant Bus1_In_Sel_Mem        : std_logic_vector(2 downto 0) := "001";
  constant Bus1_In_Sel_Reg_A      : std_logic_vector(2 downto 0) := "010";
  constant Bus1_In_Sel_Reg_B      : std_logic_vector(2 downto 0) := "011";
  constant Bus1_In_Sel_PC         : std_logic_vector(2 downto 0) := "100";
  -- Bus Output sel mux constant
  constant Bus1_Out_Sel_PC       : std_logic_vector(2 downto 0) := "000";
  constant Bus1_Out_Sel_Mem_Addr : std_logic_vector(2 downto 0) := "001";
  constant Bus1_Out_Sel_Mem_Data : std_logic_vector(2 downto 0) := "010";
  constant Bus1_Out_Sel_IR       : std_logic_vector(2 downto 0) := "011";
  constant Bus1_Out_Sel_Reg_A    : std_logic_vector(2 downto 0) := "100";
  constant Bus1_Out_Sel_Reg_B    : std_logic_vector(2 downto 0) := "101";

  signal bus1_in_sel_buf,bus1_out_sel_buf : std_logic_vector(2 downto 0) := "000";
  signal mem_data_we: std_logic := '0';



begin

  
  -- Process for resetting
  process (clk, rst)
  begin
    if rst = '0' then
      curr_state <= S_FETCH_0;
      IR         <= (others => '0'); -- Reset IR to 0
    elsif rising_edge(clk) then
      curr_state <= next_state;
      --put the IR_in in the IR signal when clock is updated
      if curr_state = S_FETCH_2 then
        IR <= IR_In;
      end if;
    end if;
  end process;
  --FSM
  process (curr_state, IR, ALU_NVZC_flags)
  begin
    PC_Increment          <= '0';
    PC_Set                <= '0';
    Reg_A_Write_Enable    <= '0';
    Reg_B_Write_Enable    <= '0';
    Mem_Addr_Write_Enable <= '0';
    Mem_Data_Write_Enable <= '0';
bus1_in_sel_buf  <= bus1_in_sel_buf;  -- Retain previous value unless changed
    bus1_out_sel_buf <= bus1_out_sel_buf; -- Retain previous value unless changed
    case curr_state is
        -- Fetch instruction
      when S_FETCH_0 =>
        --bus transfer from PC to Mem ctrl to fetch instruction
        bus1_in_sel_buf           <= Bus1_In_Sel_PC;
        bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
        Mem_Addr_Write_Enable <= '1';
        next_state            <= S_FETCH_1;
      when S_FETCH_1 =>
        --increment PC while mem ctrl is reading
        PC_Increment <= '1';
        next_state   <= S_FETCH_2;
      when S_FETCH_2 =>
        --bus mux selected to transfer from Mem ctrl to IR which is here
        bus1_in_sel_buf  <= Bus1_In_Sel_Mem;
        bus1_out_sel_buf <= Bus1_Out_Sel_IR;
        next_state   <= S_DECODE_0;
        --IR will be latched in the IR signal after 1 clock cycle
        -- Decode instruction
      when S_DECODE_0 =>
        --decode the instruction
        case IR(15 downto 12) is
          when "0000" => --NOP
            next_state <= S_FETCH_0;
          when "0001" => --Load and Store Op
            next_state <= S_LS_Op_0;
          when "0010" => --ALU Op
            next_state <= S_ALU_Op_0;
          when "0100" => --JMP Op
            next_state <= S_JMP_Op_0;
          when others =>
            next_state <= S_HALT;
        end case;
        -- Load and Store Op
      when S_LS_Op_0 =>
        --select mem addr from pc for fetching target mem addr
        bus1_in_sel_buf           <= Bus1_In_Sel_PC;
        bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
        Mem_Addr_Write_Enable <= '1';
        next_state            <= S_LS_Op_1;
      when S_LS_Op_1 =>
        --increment PC
        PC_Increment <= '1';
        next_state   <= S_LS_Op_2;
      when S_LS_Op_2 =>
        if IR(9) = '0' then
          --fetch the mem addr from mem addr
          bus1_in_sel_buf           <= Bus1_In_Sel_Mem;
          bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
          Mem_Addr_Write_Enable <= '1';
        else --store instruction
          --store address read from PC address to reg b
          --as bus data will be changed in next cycle
          bus1_in_sel_buf        <= Bus1_In_Sel_Mem;
          bus1_out_sel_buf       <= Bus1_Out_Sel_Reg_B;
          Reg_B_Write_Enable <= '1';
        end if;
        next_state <= S_LS_Op_3;
      when S_LS_Op_3 =>
        --address is set
        --10: address mode, 9: load/store, 8: reg select
        if IR(10) = '0' then --immediate mode
          if IR(9) = '0' then --load mem data to reg
            if IR(8) = '0' then --load to reg A
              bus1_in_sel_buf        <= Bus1_In_Sel_Mem;
              bus1_out_sel_buf       <= Bus1_Out_Sel_Reg_A;
              Reg_A_Write_Enable <= '1';
            else --load to reg B
              bus1_in_sel_buf        <= Bus1_In_Sel_Mem;
              bus1_out_sel_buf       <= Bus1_Out_Sel_Reg_B;
              Reg_B_Write_Enable <= '1';
            end if;
            next_state <= S_FETCH_0;
          else --store reg data to mem
            --write 
            bus1_in_sel_buf           <= Bus1_In_Sel_Reg_B;
            bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
            Mem_Addr_Write_Enable <= '1';
            next_state            <= S_LS_Op_4;
          end if;
        else
          --direct mode
          --load mem data to mem addr reg
          bus1_in_sel_buf           <= Bus1_In_Sel_Mem;
          bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
          Mem_Addr_Write_Enable <= '1';
          next_state            <= S_LS_Op_4;
        end if;
      when S_LS_Op_4 =>
        --wait for mem addr to be set
        if IR(9) = '1' then
          --switch the bus right now,not latching the data
          bus1_out_sel_buf <= Bus1_Out_Sel_Mem_Data;
          bus1_in_sel_buf <= Bus1_In_Sel_Reg_A;
          Mem_Data_Write_Enable <= '1';
          next_state            <= S_FETCH_0;
        end if;
        next_state <= S_LS_Op_5;
      when S_LS_Op_5 =>
        if IR(9) = '0' then
          --load mem data to reg0
          if IR(8) = '0' then
            bus1_in_sel_buf        <= Bus1_In_Sel_Mem;
            bus1_out_sel_buf       <= Bus1_Out_Sel_Reg_A;
            Reg_A_Write_Enable <= '1';
          else
            bus1_in_sel_buf        <= Bus1_In_Sel_Mem;
            bus1_out_sel_buf       <= Bus1_Out_Sel_Reg_B;
            Reg_B_Write_Enable <= '1';
          end if;
          next_state <= S_FETCH_0;
        else
          bus1_out_sel_buf <= Bus1_Out_Sel_Mem_Data;
          bus1_in_sel_buf <= Bus1_In_Sel_Reg_A;
          --store reg data to mem
          --Mem_Data_Write_Enable <= '1';
        end if;
        next_state            <= S_LS_Op_6;
      when S_LS_Op_6 =>
      next_state            <= S_FETCH_0;
        -- ALU Op
      when S_ALU_Op_0 =>
        --ALU already connected to the Reg A and Reg B
        --Write ALU Op from IR to ALU
        ALU_Op             <= IR(11 downto 8);
        bus1_in_sel_buf        <= Bus1_In_Sel_ALU_Result;
        bus1_out_sel_buf       <= Bus1_Out_Sel_Reg_A;
        Reg_A_Write_Enable <= '1';
        next_state         <= S_FETCH_0;
      when S_JMP_Op_0 =>
        --fetch the target address
        bus1_in_sel_buf           <= Bus1_In_Sel_PC;
        bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
        Mem_Addr_Write_Enable <= '1';
        next_state            <= S_JMP_Op_1;
      when S_JMP_Op_1 =>
        --do nothing, wait for the mem addr to be set     
        next_state <= S_JMP_Op_2;
      when S_JMP_Op_2 =>
        --what in the instruction address is the target address,need to fetch from the address
        bus1_in_sel_buf           <= Bus1_In_Sel_Mem;
        bus1_out_sel_buf          <= Bus1_Out_Sel_Mem_Addr;
        Mem_Addr_Write_Enable <= '1';
        next_state            <= S_JMP_Op_3;
      when S_JMP_Op_3 =>
        bus1_in_sel_buf  <= Bus1_In_Sel_Mem;
        bus1_out_sel_buf <= Bus1_Out_Sel_PC;
        case IR(11 downto 8) is
          when "0000" =>
            --jump unconditionally
            PC_Set <= '1';
          when "0001" =>
            --jump if zero
            if ALU_NVZC_flags(1) = '1' then
              PC_Set <= '1';
            end if;
          when "0010" =>
            --jump if not zero
            if ALU_NVZC_flags(1) = '0' then
              PC_Set <= '1';
            end if;
          when others =>
            null;
        end case;
        next_state <= S_FETCH_0;
      when S_HALT =>
        --do nothing
        next_state <= S_HALT;
      when others =>
        next_state <= S_HALT;
    end case;

  end process;
	 Bus1_In_Sel <= bus1_in_sel_buf;
  Bus1_Out_Sel <= bus1_out_sel_buf;


end behavioral;