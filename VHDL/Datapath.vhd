-- Noah White
-- rst comes from button_input(1) so it's not in port. Might need to add a rst to alu_control

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Datapath is
    generic(WIDTH : positive := 32);
    port (
        clk                 : in std_logic;
        --PC_input            : in std_logic_vector(WIDTH-1 downto 0);
        PC_ctrl             : in std_logic;
        IorD_ctrl           : in std_logic;
        MemRead_ctrl        : in std_logic;
        MemWrite_ctrl       : in std_logic;
        MemToReg_ctrl       : in std_logic;
        IRWrite_ctrl        : in std_logic;
        RegDst_ctrl         : in std_logic;
        RegWrite_ctrl       : in std_logic;
        JumpAndLink_ctrl    : in std_logic;
        IsSigned_ctrl       : in std_logic;
        ALUSrcA_ctrl        : in std_logic;
        ALUSrcB_ctrl        : in std_logic_vector(1 downto 0);
        ALUOp_ctrl          : in std_logic_vector(5 downto 0);              -- Sets INST type (goes to alu_control)
        PCSource_ctrl       : in std_logic_vector(1 downto 0);
        button_input        : in std_logic_vector(1 downto 0);
        switch_input        : in std_logic_vector(9 downto 0);
        IR31to26            : out std_logic_vector(5 downto 0);
        IR5to0              : out std_logic_vector(5 downto 0);
        --PC_source           : out std_logic_vector(WIDTH-1 downto 0);
        branch_taken        : out std_logic;
        outport_data        : out std_logic_vector(WIDTH-1 downto 0)

    );
end Datapath;

architecture structural of Datapath is
    
    -- Components
    COMPONENT PC    -- Replaced PC with a reg below (idk if keeping this here could cause issues)
    PORT(
        clk             : in  std_logic;
        rst             : in  std_logic;
        input           : in std_logic_vector(WIDTH-1 downto 0);
        ctrl            : in std_logic;
        addr            : out std_logic_vector(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT mux2to1
    generic(WIDTH : positive	:= 32);
    PORT(
        d0, d1			: IN  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        s				: IN  std_logic;
        mux_out         : OUT STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT mux4to1
    PORT(
        d0, d1, d2, d3 : IN  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        s              : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        mux_out        : OUT STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT Memory_top_level
    PORT(
        addr                : in std_logic_vector(WIDTH-1 downto 0);
        wrData              : in std_logic_vector(WIDTH-1 downto 0);
        inport0_in          : in std_logic_vector(8 downto 0);
        inport1_in          : in std_logic_vector(8 downto 0);
        inport0_en          : in std_logic;
        inport1_en          : in std_logic;
        wr_en               : in std_logic;
        rd_en               : in std_logic;
        clk                 : in std_logic;
        rst                 : in std_logic;
        rd_data             : out std_logic_vector(WIDTH-1 downto 0);
        outport_data        : out std_logic_vector(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT reg
    PORT(
        clk    : in  std_logic;
        rst    : in  std_logic;
        en     : in std_logic;
        input  : in  std_logic_vector(WIDTH-1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT registerfile
    PORT(
        clk : in std_logic;
        rst : in std_logic;
		  
        rd_addr0 : in std_logic_vector(4 downto 0); --read reg 1
        rd_addr1 : in std_logic_vector(4 downto 0); --read reg 2
		  
        wr_addr : in std_logic_vector(4 downto 0); --write register
        wr_en : in std_logic;
        wr_data : in std_logic_vector(31 downto 0); --write data
		  
        rd_data0 : out std_logic_vector(31 downto 0); --read data 1
        rd_data1 : out std_logic_vector(31 downto 0); --read data 2
	
	    --JAL	
	    JumpAndLink : in std_logic
    );
    END COMPONENT;

    COMPONENT alu
    PORT(
        inputA		    : in std_logic_vector(WIDTH-1 downto 0);
		inputB		    : in std_logic_vector(WIDTH-1 downto 0);
		OpSel		    : in std_logic_vector(7 downto 0);
        shift           : in std_logic_vector(4 downto 0);
        branch_taken    : out std_logic;
		result		    : out std_logic_vector(WIDTH-1 downto 0);
        result_hi       : out std_logic_vector(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT alu_control
    PORT(
        IR_5to0             : in std_logic_vector(5 downto 0);
        ALUOp               : in std_logic_vector(5 downto 0);                     -- Might be a vector and change later
        OpSel               : out std_logic_vector(7 downto 0);
        HI_en               : out std_logic;
        LO_en               : out std_logic;
        ALU_LO_HI           : out std_logic_vector(1 downto 0)
    );
    END COMPONENT;

    COMPONENT sign_extend
    PORT (
        input               : in std_logic_vector(15 downto 0);
        IsSigned            : in std_logic;
        output              : out std_logic_vector(31 downto 0)
    );
    END COMPONENT;

    -- Signals and other stuff
    signal rst                      : std_logic;
    signal PC_output                : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_Out_r                : std_logic_vector(WIDTH-1 downto 0);
    signal MemAddr                  : std_logic_vector(WIDTH-1 downto 0);
    signal RegA                     : std_logic_vector(WIDTH-1 downto 0);
    signal RegB                     : std_logic_vector(WIDTH-1 downto 0);
    signal MemOut                   : std_logic_vector(WIDTH-1 downto 0);
    signal inport0_en               : std_logic;
    signal inport1_en               : std_logic;
    signal PC_source                : std_logic_vector(WIDTH-1 downto 0);
    signal IROut                    : std_logic_vector(WIDTH-1 downto 0);
    signal MemData_r                : std_logic_vector(WIDTH-1 downto 0);
    signal RegFile_wr_addr          : std_logic_vector(4 downto 0);
    signal RegFile_wr_data          : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_LO_HI_MUX            : std_logic_vector(WIDTH-1 downto 0);
    signal sign_extend_out          : std_logic_vector(WIDTH-1 downto 0);
    signal sign_extend_shifted      : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_srcA                 : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_srcB                 : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_OpSel                : std_logic_vector(7 downto 0);         -- CHANGE WIDTH LATER (MAYBE)
    signal ALU_Result               : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_Result_Hi            : std_logic_vector(WIDTH-1 downto 0);
    signal LO_en                    : std_logic;
    signal HI_en                    : std_logic;
    signal LO_r                     : std_logic_vector(WIDTH-1 downto 0);
    signal HI_r                     : std_logic_vector(WIDTH-1 downto 0);
    signal IR25to0_shifted          : std_logic_vector(WIDTH-1 downto 0);
    signal ALU_LO_HI                : std_logic_vector(1 downto 0);


begin
    inport0_en <= '1' when (button_input(0) = '1' and switch_input(9) = '0') else '0';
    inport1_en <= '1' when (button_input(0) = '1' and switch_input(9) = '1') else '0';
    IR31to26 <= IROut(31 downto 26);
    IR5to0   <= IROut(5 downto 0);
    rst <= button_input(1);
    
    -- PORT mapping and other stuff and whatnot (lhs is component, rhs is local)
    U_PC : reg port map(
        clk             => clk,
        rst             => rst,
        en              => PC_ctrl,
        input           => PC_source,     
        output          => PC_output
    );
    
    U_MemAddr_MUX : mux2to1 port map(
        d0              => PC_output,
        d1              => ALU_Out_r,            -- REPLACE THIS WITH APPROPRIATE THING LATER
        s               => IorD_ctrl,
        mux_out         => MemAddr
    );

    U_Memory : Memory_top_level port map(
        addr                => MemAddr,
        wrData              => RegB,            -- Reg B of reg file I believe
        inport0_in          => switch_input(8 downto 0),
        inport1_in          => switch_input(8 downto 0),
        inport0_en          => inport0_en,
        inport1_en          => inport1_en,     
        wr_en               => MemWrite_ctrl,
        rd_en               => MemRead_ctrl,
        clk                 => clk,        
        rst                 => rst,
        rd_data             => MemOut,
        outport_data        => outport_data
    );

    U_IR : reg port map(
        clk                 => clk,
        rst                 => rst,
        en                  => IRWrite_ctrl,
        input               => MemOut,
        output              => IROut
    );

    U_MemData_r : reg port map(
        clk                 => clk,
        rst                 => rst,
        en                  => '1',
        input               => MemOut,
        output              => MemData_r

    );

    U_RegFile_IN_MUX0 : mux2to1
    generic map(
        WIDTH => 5
    ) 
    port map(
        d0                  => IROut(20 downto 16),
        d1                  => IROut(15 downto 11),
        s                   => RegDst_ctrl,
        mux_out             => RegFile_wr_addr
    );

    U_RegFile_IN_MUX1 : mux2to1
    port map(
        d0                  => ALU_LO_HI_MUX,
        d1                  => MemData_r,
        s                   => MemToReg_ctrl,
        mux_out             => RegFile_wr_data
    );

    U_RegFile : registerfile
    port map(
        clk                 => clk,
        rst                 => rst,
        rd_addr0            => IROut(25 downto 21),
        rd_addr1            => IROut(20 downto 16),
        wr_addr             => RegFile_wr_addr,
        wr_en               => RegWrite_ctrl,
        wr_data             => RegFile_wr_data,
        rd_data0            => RegA,
        rd_data1            => RegB,
        JumpAndLink         => JumpAndLink_ctrl
    );

    U_sign_extend : sign_extend
    port map(
        input               => IROut(15 downto 0),
        IsSigned            => IsSigned_ctrl,
        output              => sign_extend_out
    );

    -- Shift sign_extend_out left by two to put into the next MUX (Do this inside sign_extend or maybe not)
    sign_extend_shifted <= 
        std_logic_vector(shift_left(unsigned(sign_extend_out), 2)) when IsSigned_ctrl = '0' else
        std_logic_vector(shift_left(signed(sign_extend_out), 2));
        
    U_ALU_IN_MUX0 : mux2to1
    port map(
        d0                  => PC_output,
        d1                  => RegA,
        s                   => ALUSrcA_ctrl,
        mux_out             => ALU_srcA
    );

    U_ALU_IN_MUX1 : mux4to1
    port map(
        d0                  => RegB,
        d1                  => X"00000004",
        d2                  => sign_extend_out,
        d3                  => sign_extend_shifted,
        s                   => ALUSrcB_ctrl,
        mux_out             => ALU_srcB
    );

    U_ALU : alu
    port map(
        inputA		        => ALU_srcA,
		inputB		        => ALU_srcB,
		OpSel		        => ALU_OpSel,
        shift               => IROut(10 downto 6),
        branch_taken        => branch_taken,
        result              => ALU_Result,
        result_hi           => ALU_Result_Hi
    );

    U_ALU_Out : reg
    port map(
        clk                 => clk,
        rst                 => rst,
        en                  => '1',
        input               => ALU_Result,
        output              => ALU_Out_r
    );
    
    U_LO : reg
    port map(
        clk                 => clk,
        rst                 => rst,
        en                  => LO_en,
        input               => ALU_Result,
        output              => LO_r
    );

    U_HI : reg
    port map(
        clk                 => clk,
        rst                 => rst,
        en                  => HI_en,
        input               => ALU_Result_Hi,
        output              => HI_r
    );

    IR25to0_shifted <= PC_output(31 downto 28) & IROut(25 downto 0) & "00";
    U_MUX_PCSource : mux4to1
    port map(
        d0                  => ALU_Result,
        d1                  => ALU_Out_r,
        d2                  => IR25to0_shifted,
        d3                  => (others => '0'),
        s                   => PCSource_ctrl,
        mux_out             => PC_source
    );

    U_ALU_CTRL : alu_control
    port map(
        IR_5to0             => IROut(5 downto 0),
        ALUOp               => ALUOp_ctrl,
        OpSel               => ALU_OpSel,
        HI_en               => HI_en,
        LO_en               => LO_en,
        ALU_LO_HI           => ALU_LO_HI
    );
    
    U_MUX_ALU_LO_HI : mux4to1
    port map(
        d0                  => ALU_Out_r,
        d1                  => LO_r,
        d2                  => HI_r,
        d3                  => (others => '0'),
        s                   => ALU_LO_HI,
        mux_out             => ALU_LO_HI_MUX
    );

    
end architecture structural;