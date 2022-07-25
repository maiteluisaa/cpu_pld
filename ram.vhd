library ieee;   
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram is
    
    Generic (
            constant size_mem: integer := 256;
                     size_bits: integer := 16
    
    );
    
	 -- modelo retirado do guia "VHDL Coding Styles" 
	 -- declaracao de portas de entrada e saida
    port (
        clk : in std_logic;
        addr: in unsigned(7 downto 0);
        -- Must exist to infer RAM.
        we : in std_logic;  
        data_in : in std_logic_vector((size_bits - 1) downto 0);
        q : out std_logic_vector((size_bits - 1) downto 0)
    );
end entity;

architecture rtl of ram is

    type mem is array (0 to (size_mem - 1)) of std_logic_vector((size_bits - 1) downto 0);
    signal ram_block: mem;
    
begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if we = '1' then -- se enable de escrita ativado, na subida do clk ram(addr) recebe a entrada
                ram_block(to_integer(addr)) <= data_in;
            end if;
            q <= ram_block(to_integer(addr)); -- na subida do clk, saida recebe ram(addr)
        end if;
    end process;    
end rtl;