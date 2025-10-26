library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerfile is
    port(
        clk : in std_logic;
        rst : in std_logic;
		  
        rd_addr0 : in std_logic_vector(4 downto 0); --read reg 1 (A)
        rd_addr1 : in std_logic_vector(4 downto 0); --read reg 2 (B)
		  
        wr_addr : in std_logic_vector(4 downto 0); --write register
        wr_en : in std_logic;
        wr_data : in std_logic_vector(31 downto 0); --write data
		  
        rd_data0 : out std_logic_vector(31 downto 0); --read data 1 (A) (Register cuz synchronous)
        rd_data1 : out std_logic_vector(31 downto 0); --read data 2 (B) (Register cuz synchronous)
	
	    --JAL	
	    JumpAndLink : in std_logic
        );
end registerfile;


-- The register file can be designed using an asynchronus read or a synchronous read.
-- Please note that you need to remove RegA and RegB from oyur datapath if you use the synchronous read
-- The registers would implicitly be captured by the register file. 

architecture sync_read of registerfile is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array;
    
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then
            if (wr_en = '1') then
                regs(to_integer(unsigned(wr_addr))) <= wr_data; -- Would need to change this so only happens when JAL = '0' for accuracy but doesn't matter here I'd say because wr_addr should be "00000" in our JAL cases. Actually don't need to do this because we are just not going to assert wr_en on JAL cases
					 regs(0) <= (others => '0');
            end if;
            if(JumpAndLink = '1') then
                regs(31) <= wr_data;
            end if;
            rd_data0 <= regs(to_integer(unsigned(rd_addr0)));
            rd_data1 <= regs(to_integer(unsigned(rd_addr1)));
        end if;
    end process;
    
end sync_read;
