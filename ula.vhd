LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- biblioteca para o uso de signed

-- ULA - unidade lógica aritmética contém operações de soma, multiplicação, comparação,
-- lógica E, lógica OU e inversora

entity ula is -- declaração de portas de entrada e saída
    port(
        a : in SIGNED(15 downto 0);
        b : in SIGNED(15 downto 0);
        aluop : in std_logic_vector(2 downto 0); -- chave selecionadora
        result_lsb: out SIGNED(15 downto 0); 
        result_msb: out SIGNED(15 downto 0)
    );
end entity ula;

architecture logic of ula is

    signal mul : SIGNED(31 downto 0);  -- auxilia no processo de multiplicação (sobrecarga de operadores)
    signal boolc : SIGNED(15 downto 0); -- auxilia no processo de comparação (sobrecarga de operadores)
    signal boole : SIGNED(15 downto 0); -- auxilia no processo de comparação (sobrecarga de operadores)

begin

    mul <= a*b;

    boolc <= "0000000000000001" when a<b else "0000000000000000";
    boole <= "0000000000000001" when a=b else "0000000000000000";

    with aluop select -- duas chaves, processos concorrentes
    result_lsb <= a + b when "000",
                  mul (15 downto 0) when "001", -- somente os bits menos significativos
                  a and b when "010",
                  a or b when "011",
                  not a when "100",
                  b when "101",
                  boolc when "110",
                  boole when "111",
                  "0000000000000000" when others;

    with aluop select
    result_msb <= mul (31 downto 16) when "001", -- somente os bits mais significativos
                  a when "101",
                  "0000000000000000" when others; -- quando qualquer estímulo diferente (X, por exemplo) em aluop a saída vai para 0

end architecture logic;
