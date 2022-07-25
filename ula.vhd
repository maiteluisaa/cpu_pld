LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- biblioteca para o uso de signed

-- ULA - unidade logica aritmetica contem operacoes de soma, multiplicacao, comparacao,
-- logica E, logica OU e inversora

entity ula is -- declaracao de portas de entrada e saida
    port(
        a : in SIGNED(15 downto 0);
        b : in SIGNED(15 downto 0);
        aluop : in std_logic_vector(2 downto 0); -- chave selecionadora
        result_lsb: out SIGNED(15 downto 0); 
        result_msb: out SIGNED(15 downto 0)
    );
end entity ula;

architecture logic of ula is

    signal mul : SIGNED(31 downto 0);  -- auxilia no processo de multiplicacao (sobrecarga de operadores)
    signal boolc : SIGNED(15 downto 0); -- auxilia no processo de comparacao (sobrecarga de operadores)
    signal boole : SIGNED(15 downto 0); -- auxilia no processo de comparacao (sobrecarga de operadores)

begin

    mul <= a*b;

    boolc <= "0000000000000001" when a<b else "0000000000000000";
    boole <= "0000000000000001" when a=b else "0000000000000000";

    with aluop select -- duas chaves, processos concorrentes
    result_lsb <= a + b when "000", -- soma
                  mul (15 downto 0) when "001", -- multiplicacao
                  a and b when "010", -- AND
                  a or b when "011", -- OR
                  not a when "100", -- NOT
                  b when "101", -- SWAP
                  boolc when "110", -- comparacao
                  boole when "111", -- comparacao
                  "0000000000000000" when others;

    with aluop select
    result_msb <= mul (31 downto 16) when "001", -- multiplicacao
                  a when "101", -- swap
                  "0000000000000000" when others; 

end architecture logic;
