-- Created by Noah White
-- Last Edit: Noah White on 8/6/25
--
-- Description: 
--      Top level entity for the MIPS. Essentially just combining the controller and datapath.
--
-- Methodology (from Stitt):
--      Design the circuit, then write the code.
--
-- NOTES:
--      - 1 cycle for MemRead to be asserted. When next cycle hits, read data is seen on RAM output. That is the RAM timing
--      - Only need Quartus to acquire the RAM IP file as far as I can tell. Also need Quartus for full synthesis
--
-- NEXT STEPS (Updated 8/6/25):
--      - Attempt to use the memory viewer thing in ModelSim (don't need to do yet, prob just do when needed)
--      - GENERAL: Continue watching Stitt video and figuring out how to do controller based on resources and whatever else
--


LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    generic(WIDTH : positive := 32);
    port (
        clk                 : in std_logic;
        button_input        : in std_logic_vector(1 downto 0);      -- button_input(1) is rst
        switch_input        : in std_logic_vector(9 downto 0);
        outport_data        : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity top_level;



-- Here in lies the architecture lol. May need some arch signals we'll see
architecture structural of top_level is

    -- Controller (and Datapath) signals
    signal IR31to26         : std_logic_vector(5 downto 0);
    signal PCWriteCond      : std_logic;
    signal PCWrite          : std_logic;
    signal IorD             : std_logic;
    signal MemRead          : std_logic;
    signal MemWrite         : std_logic;
    signal MemToReg         : std_logic;
    signal IRWrite          : std_logic;
    signal RegDst           : std_logic;
    signal RegWrite         : std_logic;
    signal JumpAndLink      : std_logic;
    signal IsSigned         : std_logic;
    signal ALUSrcA          : std_logic;
    signal ALUSrcB          : std_logic_vector(1 downto 0);
    signal ALUOp            : std_logic_vector(2 downto 0);
    signal PCSource         : std_logic_vector(1 downto 0);

    -- Datapath only signals
    signal PC_ctrl          : std_logic;
    signal branch_taken     : std_logic;

begin
    PC_ctrl <= PCWrite OR (PCWriteCond AND branch_taken);

    U_Controller : entity work.Controller
        port map(
            clk             => clk,       
            rst             => button_input(1),       
            IR31to26        => IR31to26,        -- The OP Code I believe
            PCWriteCond     => PCWriteCond,     -- Goes into a gate outside of controller     
            PCWrite         => PCWrite,         -- Goes into a gate outside of controller
            IorD            => IorD,       
            MemRead         => MemRead,       
            MemWrite        => MemWrite,       
            MemToReg        => MemToReg,       
            IRWrite         => IRWrite,       
            RegDst          => RegDst,       
            RegWrite        => RegWrite,       
            JumpAndLink     => JumpAndLink,     
            IsSigned        => IsSigned,      
            ALUSrcA         => ALUSrcA,       
            ALUSrcB         => ALUSrcB,     
            ALUOp           => ALUOp,           -- May need to change width later
            PCSource        => PCSource       
        );
    
    U_Datapath : entity work.Datapath
        port map(
            clk                 => clk,
            PC_ctrl             => PC_ctrl,
            IorD_ctrl           => IorD,
            MemRead_ctrl        => MemRead,
            MemWrite_ctrl       => MemWrite,
            MemToReg_ctrl       => MemToReg,
            IRWrite_ctrl        => IRWrite,
            RegDst_ctrl         => RegDst,
            RegWrite_ctrl       => RegWrite,
            JumpAndLink_ctrl    => JumpAndLink,
            IsSigned_ctrl       => IsSigned,
            ALUSrcA_ctrl        => ALUSrcA,
            ALUSrcB_ctrl        => ALUSrcB,
            ALUOp_ctrl          => ALUOp,           -- Might be a vector and change later
            PCSource_ctrl       => PCSource,
            button_input        => button_input,
            switch_input        => switch_input,
            IR31to26            => IR31to26,
            branch_taken        => branch_taken,    -- Goes into a gate outside of controller
            outport_data        => outport_data
        );
    
    
end architecture structural;
