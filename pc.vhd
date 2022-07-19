library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- contador de programa (mantem a posição atual da sequência de execução das instruções do programa do processado)
-- contém um registrador de 16 bits síncrono com o clk e reset assíncrono

entity pc is --declaração de portas de entrada e saída
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
        if reset = '1' then
            data <= (others=>'0'); --- para parametrização de código
        elsif rising_edge(clk) then
            if load = '1' then -- load tem prioridade sobre up
                data <= data_in;
            elsif up = '1' then
                data <= data + "0001"; -- data é in/out para fazer a conversão para signed
            end if;
        end if;
    end process;

end architecture RTL;
