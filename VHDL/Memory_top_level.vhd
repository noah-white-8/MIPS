-- Noah White
-- Section #: 11088

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory_top_level is
    generic(WIDTH : positive := 32);
    port (
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
        outport_data        : out std_logic_vector(WIDTH-1 downto 0)       -- temporary prob
    );
end entity Memory_top_level;


architecture structural of Memory_top_level is
    
    -- Components
    COMPONENT RAM 
    PORT(
        address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
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

    COMPONENT mux4to1
    PORT(
        d0, d1, d2, d3 : IN  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        s              : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        mux_out        : OUT STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
    END COMPONENT;

    COMPONENT enable_logic
    PORT(
        addr            : in std_logic_vector(WIDTH-1 downto 0);
        wr_en           : in std_logic;
        outport_wr_en   : out std_logic;
        RAM_wr_en       : out std_logic;
        mux_sel         : out std_logic_vector(1 downto 0)
    );
    END COMPONENT;

    -- Signals, etc.
    type reg_array_t is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);
    signal RAM_out      : std_logic_vector(WIDTH-1 downto 0);
    signal mux_inputs   : reg_array_t(0 to 3);
    signal inport0_in_full  : std_logic_vector(WIDTH-1 downto 0);
    signal inport1_in_full  : std_logic_vector(WIDTH-1 downto 0);
    signal outport_wr_en    : std_logic;
    signal RAM_wr_en        : std_logic;
    signal mux_sel          : std_logic_vector(1 downto 0);

begin
    
    U_enable_logic: enable_logic port map(
        addr                => addr,
        wr_en               => wr_en,
        outport_wr_en       => outport_wr_en,
        RAM_wr_en           => RAM_wr_en,
        mux_sel             => mux_sel
    );

    U_RAM: RAM port map(
        address             => addr(7 downto 0),
        clock               => clk,
        data                => wrData,
        rden                => rd_en,
        wren                => RAM_wr_en,                       
        q                   => mux_inputs(2)
    );

    inport0_in_full <= (31 downto 9 => '0') & inport0_in;
    U_INPORT0: reg port map(
        clk                 => clk,
        rst                 => '0',
        en                  => inport0_en,
        input               => inport0_in_full,
        output              => mux_inputs(0)              
    );

    inport1_in_full <= (31 downto 9 => '0') & inport1_in;
    U_INPORT1: reg port map(
        clk                 => clk,
        rst                 => '0',
        en                  => inport1_en,
        input               => inport1_in_full,
        output              => mux_inputs(1)              
    );

    U_OUTPORT: reg port map(
        clk                 => clk,
        rst                 => rst,
        en                  => outport_wr_en,          
        input               => wrData,
        output              => outport_data              
    );

    mux_inputs(3) <= (others => '0');
    U_MUX: mux4to1 port map(
        d0                  => mux_inputs(0),
        d1                  => mux_inputs(1),
        d2                  => mux_inputs(2),
        d3                  => mux_inputs(3),
        s                   => mux_sel,
        mux_out             => rd_data                      -- Primary output of the system
    );
    
    
end architecture structural;
