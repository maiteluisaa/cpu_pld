library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- registrador de instrucoes com reset assincrono e enable sincrono com o clock

entity ir is
    port( -- declaracao de portas de entrada e saida
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
        if reset = '1' then -- se rst acionado, saida vai para 0
            opcode <= (others=>'0'); 
            immediate <= (others=>'0');
            mem_addr <= (others=>'0');
        elsif rising_edge(clk) then
            if en = '1' then -- se enable acionado, na subida do clk decodifica a entrada
                opcode <= data (15 downto 8);
                immediate <= data (7 downto 0);
                mem_addr <= unsigned(data (7 downto 0));
            end if;
        end if;
    end process;
    

end architecture RTL;
