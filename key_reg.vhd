library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key_reg is
    port(
        clk : in std_logic;
        rst : in std_logic;
        mem_addr_bus: in std_logic_vector(7 downto 0);
        data_r : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector (15 downto 0);
        rd : in std_logic     
    );
end entity key_reg;

architecture RTL of key_reg is
    
begin
    process(clk, rst)
    begin       
        if rst = '1' then
            data_out <= (others => '0'); 
        else
            if rising_edge(clk) then
                if (mem_addr_bus = "11111101" and rd = '1') then -- FD
                    data_out (7 downto 0) <= data_r;
                elsif (mem_addr_bus = "11111110" and rd = '1') then -- FE
                     data_out (15 downto 8) <= data_r;
                end if;
            end if;
        end if;
    end process;
end architecture RTL;
