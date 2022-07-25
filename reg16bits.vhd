library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- registrador de 16 bits com reset assincrono e enable sincrono com o clock

entity reg16bits is -- declaracao de portas de entrada e saida
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
            reg_out <= (others=>'0'); -- se clear acionado, saida vai para 0
        elsif rising_edge(clk) then
            if w_flag = '1' then -- se enable de escrita acionado, na subida do clock saida igual a entrada
                reg_out <= data_in;
            end if;
        end if;
    end process;
    
end architecture RTL;
