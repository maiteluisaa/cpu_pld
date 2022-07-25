library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- máquina de estados de uma cpu

entity fsm is
    port(
        clk : in std_logic; -- clock
        opcode: in std_logic_vector(7 downto 0); -- tipo de operacao
        w_flaga: out std_logic; -- enable de escrita no registrador A
        w_flagb: out std_logic; -- enable de escrita no registrador B
        we: out std_logic; -- auxilia com enable de escrita para ram e displays 7seg
        wr: out std_logic; -- auxilia com enable de leitura para chaves
        up: out std_logic; -- incrementa para o proximo endereco da ROM
        load: out std_logic; -- carrega um endereco da ROM
        rst : in std_logic; -- reset assincrono
        ula_out : in std_logic; -- auxilia com comparacao para as operacoes blt e beq
        aluop: out std_logic_vector (2 downto 0); -- sinal de controle da ula
        sel_rom: out std_logic -- auxilia na diferenciacao de desvio ou pc + 1
    );
end entity fsm;

architecture RTL of fsm is -- declaracao dos estados
    type state_type is (state0, fetch, decode, ld_imed, swap_mul, w_back, ula, read_mem, write_mem, jmp, halt, bs1);
    signal state : state_type := state0;

begin

    process(clk, rst) is
    begin
        if rst = '1' then
            state <= state0;
        elsif rising_edge(clk) then
            case state is
                when state0 =>
                    if rst = '0' then
                        state <= fetch;
                    end if;
                when fetch =>
                    state <= decode;
                when decode => -- desvio de estados conforme opcode
                    if opcode = x"60" then -- load immediate
                        state <= ld_imed;
                    elsif opcode = x"70" or opcode = x"20" then -- swap e mul
                        state <= swap_mul;
                    elsif opcode = x"10" or opcode = x"30" or opcode = x"40" or opcode = x"50" then -- restante de operacoes da ula
                        state <= ula;
                    elsif opcode = x"01" then -- escrita no registrador A com um dado da memoria
                        state <= read_mem;
                    elsif opcode = x"02" then
                        state <= write_mem; -- escrita na memoria com o valor da saida do registrador A
                    elsif opcode = x"05" then
                        state <= jmp; -- jump
                    elsif opcode = x"03" or opcode = x"04" then
                        state <= bs1; -- beq e blt
                    elsif opcode = x"FF" then
                        state <= halt; -- halt
						  else 
								state <= w_back; -- estado para auxiliar no sincronismo da maquina de estados
                    end if;
                when ld_imed =>
                  --  state <= w_back; -- foi retirado pois estava atrasando na execucao na placa
							state <= fetch;
                when w_back =>
                    state <= fetch;
                when swap_mul =>
                  --  state <= w_back;
						state <= fetch;
                when ula =>
                 --   state <= w_back;
						state <= fetch;
                when read_mem =>
                    state <= fetch;
					  --   state <= w_back; -- foi retirado pois estava atrasando na execucao na placa
                when write_mem =>
                 --   state <= w_back;
							state <= fetch; 
                when jmp =>
                 --   state <= w_back;
							state <= fetch;
                when halt =>
                    state <= halt;
                when bs1 =>
                   -- state <= w_back;
						 state <= fetch;
            end case;
        end if;
    end process;
    
output: process(state, ula_out, opcode)
begin
    w_flaga <= '0'; -- inicializando as saidas
    w_flagb <= '0';
    up <= '0';
    we <= '0';
    load <= '0';
    aluop <= "000";
    sel_rom <= '0';
    wr <= '0';
    
    case state is
        when state0 =>
        when fetch =>
        when decode =>
        when ld_imed =>
            w_flaga <= '1'; -- escreve no reg A 
            up <= '1'; -- incrementa endereco da ROM
        when w_back =>
            if opcode = x"01" then
                w_flaga <= '1'; -- escreve no reg A
            end if;
        when swap_mul =>
            if opcode = x"20" then -- altera o seletor da ula para operacao correta
                aluop <= "001";
            elsif opcode = x"70" then
                aluop <= "101";
            end if;
            w_flaga <= '1'; -- escreve nos regs
            w_flagb <= '1';
            up <= '1'; -- incrementa endereco da ROM
        when ula =>
            if opcode = x"10" then -- altera o seletor da ula para operacao correta
                aluop <= "000";
            elsif opcode = x"30" then
                aluop <= "010";
            elsif opcode = x"40" then
                aluop <= "011";
            elsif opcode = x"50" then
                aluop <= "100";
            end if;
            w_flaga <= '1'; -- escreve no reg A
            up <= '1'; -- incrementa endereco da ROM
        when read_mem =>
            w_flaga <= '1'; -- escreve no reg A
            up <= '1'; -- incrementa endereco da ROM
            wr <= '1'; -- habilita leitura
        when write_mem =>
            up <= '1'; -- incrementa endereco da ROM
            we <= '1'; -- habilita escrita 
        when jmp =>
            load <= '1'; -- carrega o endereco de memoria para ROM
            sel_rom <= '1'; -- seleciona operacao de desvio
        when halt =>
        when bs1 =>
            if opcode = x"03" then -- altera o seletor da ula para operacao correta de beq e blt
                aluop <= "110";
            elsif opcode = x"04" then
                aluop <= "111";
            end if;
            if ula_out = '1' then -- se verdadeiro realiza o jump
                load <='1';
                sel_rom <='1';
            elsif ula_out = '0' then
                up <= '1'; -- se falso incrementa endereco da ROM
            end if;
    end case;
    
end process output;
end architecture RTL;
