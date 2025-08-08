-- Created by Noah White on 8/6/25
-- Last Edit: Noah White on 8/6/25
--
-- Description: 
--      Testbench for top_level.vhd   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_top_level IS
END tb_top_level;

architecture behavior of tb_top_level is

    CONSTANT WIDTH : positive := 32;

    -- Component under test
    COMPONENT top_level 
        GENERIC(WIDTH : positive := 32);
        PORT(
            clk                 : in std_logic;
            button_input        : in std_logic_vector(1 downto 0);      -- button_input(1) is rst
            switch_input        : in std_logic_vector(9 downto 0);
            outport_data        : out std_logic_vector(WIDTH-1 downto 0)
        );
    END COMPONENT;
    
    -- Signals (same as in port above)
    signal clk          : std_logic;
    signal button_input : std_logic_vector(1 downto 0);
    signal switch_input : std_logic_vector(9 downto 0);
    signal outport_data : std_logic_vector(WIDTH-1 downto 0);

begin
    UUT : top_level
        PORT MAP(
            clk             => clk,
            button_input    => button_input,
            switch_input    => switch_input,
            outport_data    => outport_data
        );
    
     -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Init (button_input(1) is rst)
        button_input(1) <= '1';
        wait for 20 ns;
        button_input(1) <= '0';

        -- I think that's pretty much it tbh because the rst should set everything in motion but we'll see


        wait;
    END PROCESS;
    
end architecture behavior;
