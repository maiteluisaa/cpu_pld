library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- contador de programa (mantem a posicao atual da sequencia de execucao das instrucoes do programa do processador)
-- contem um registrador de 8 bits sincrono com o clk e reset assincrono

entity pc is --declaracao de portas de entrada e saida
    port(
        clk: in std_logic;
        load: in std_logic;
        reset: in std_logic;
        up: in std_logic;
        data_in: in unsigned (7 downto 0);
        data: buffer unsigned (7 downto 0)       
    );
end entity pc;

architecture RTL of pc is
    
begin
    process (clk, reset)
    begin
        if reset = '1' then -- se rst acionado, saida vai para 0
            data <= (others=>'0'); 
        elsif rising_edge(clk) then
            if load = '1' then -- load tem prioridade sobre up
                data <= data_in; -- se load acionado, saida igual a entrada
            elsif up = '1' then
                data <= data + "0001"; -- se up acionado, saida igual a saida + 1
            end if;
        end if;
    end process;

end architecture RTL;
