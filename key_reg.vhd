library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Bloco que faz a decodificacao dos dados das chaves da placa para a entrada do registrador

-- declaracao de portas de entrada e saida
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
        if rst = '1' then -- se rst acionado, saida vai para 0
            data_out <= (others => '0'); 
        else
            if rising_edge(clk) then
                if (mem_addr_bus = "11111101" and rd = '1') then -- quando no endereco FD e enable de leitura habilitado, na subida do clk a parte baixa da saida recebe a entrada
                    data_out (7 downto 0) <= data_r;
                elsif (mem_addr_bus = "11111110" and rd = '1') then -- quando no endereco FE e enable de leitura habilitado, na subida do clk a parte alta da saida recebe a entrada
                     data_out (15 downto 8) <= data_r;
                end if;
            end if;
        end if;
    end process;
end architecture RTL;
