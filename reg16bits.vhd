library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- registrador de 16 bits com reset ass�ncrono e enable s�ncrono com o clock

entity reg16bits is -- declara��o de portas de entrada e sa�da
    port(
        clk : in std_logic;
        clear : in std_logic;
        w_flag: in std_logic;
        data_in: in signed(15 downto 0);
        reg_out: out signed(15 downto 0)
    );
end entity reg16bits;

architecture RTL of reg16bits is   
begin
    process (clk, clear)
    begin
        if clear = '1' then -- clear tem maior prioridade
            reg_out <= (others=>'0'); --- para parametriza��o de c�digo
        elsif rising_edge(clk) then
            if w_flag = '1' then 
                reg_out <= data_in;
            end if;
        end if;
    end process;
    
end architecture RTL;
