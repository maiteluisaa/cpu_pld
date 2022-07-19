library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- registrador de instruções com reset assíncrono e enable síncrono com o clock

entity ir is
    port( -- declaração de portas de entrada e saída
        clk: in std_logic;
        en: in std_logic;
        reset: in std_logic;
        data: in std_logic_vector(15 downto 0);
        opcode: out std_logic_vector(7 downto 0);
        immediate: out std_logic_vector(7 downto 0);
        mem_addr: out unsigned(7 downto 0)
    );
end entity ir;

architecture RTL of ir is
    
begin
    process (clk, reset)
    begin
        if reset = '1' then
            opcode <= (others=>'0'); --- para parametrização de código
            immediate <= (others=>'0');
            mem_addr <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then
                opcode <= data (15 downto 8);
                immediate <= data (7 downto 0);
                mem_addr <= unsigned(data (7 downto 0));
            end if;
        end if;
    end process;
    

end architecture RTL;
