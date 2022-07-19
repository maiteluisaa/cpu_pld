library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
    port(
        clk : in std_logic;
        opcode: in std_logic_vector(7 downto 0);
        w_flaga: out std_logic;
        w_flagb: out std_logic;
        we: out std_logic; -- para escrever na mem�ria
        wr: out std_logic; -- para ler registrador de entrada
        up: out std_logic;
        load: out std_logic;
        rst : in std_logic;
        ula_out : in std_logic;
        aluop: out std_logic_vector (2 downto 0);
        sel_rom: out std_logic -- auxilia na diferencia��o de branch ou pc + 1
    );
end entity fsm;

architecture RTL of fsm is
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
                when decode =>
                    if opcode = x"60" then
                        state <= ld_imed;
                    elsif opcode = x"70" or opcode = x"20" then
                        state <= swap_mul;
                    elsif opcode = x"10" or opcode = x"30" or opcode = x"40" or opcode = x"50" then
                        state <= ula;
                    elsif opcode = x"01" then
                        state <= read_mem;
                    elsif opcode = x"02" then
                        state <= write_mem;
                    elsif opcode = x"05" then
                        state <= jmp;
                    elsif opcode = x"03" then
                        state <= bs1;
                    elsif opcode = x"04" then
                        state <= bs1;
                    elsif opcode = x"FF" then
                        state <= halt;
						  else 
								state <= w_back;
                    end if;
                when ld_imed =>
                  --  state <= w_back;
							state <= fetch;
                when w_back =>
                    state <= fetch;
                when swap_mul =>
                    state <= w_back;
                when ula =>
                    state <= w_back;
                when read_mem =>
                    state <= fetch;
					  --   state <= w_back;
                when write_mem =>
                    state <= w_back; 
                when jmp =>
                    state <= w_back;
                when halt =>
                    state <= halt;
                when bs1 =>
                    state <= w_back;
                    --state <= fetch;
            end case;
        end if;
    end process;
    
output: process(state, ula_out, opcode)
begin
    w_flaga <= '0';
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
            w_flaga <= '1';
            up <= '1';
        when w_back =>
            if opcode = x"01" then
                w_flaga <= '1';
            end if;
        when swap_mul =>
            if opcode = x"20" then
                aluop <= "001";
            elsif opcode = x"70" then
                aluop <= "101";
            end if;
            w_flaga <= '1';
            w_flagb <= '1';
            up <= '1';
        when ula =>
            if opcode = x"10" then
                aluop <= "000";
            elsif opcode = x"30" then
                aluop <= "010";
            elsif opcode = x"40" then
                aluop <= "011";
            elsif opcode = x"50" then
                aluop <= "100";
            end if;
            w_flaga <= '1';
            up <= '1';
        when read_mem =>
            w_flaga <= '1';
            up <= '1';
            wr <= '1';
        when write_mem =>
            up <= '1';
            we <= '1';
        when jmp =>
            load <= '1';
            sel_rom <= '1';
        when halt =>
        when bs1 =>
            if opcode = x"03" then
                aluop <= "110";
            elsif opcode = x"04" then
                aluop <= "111";
            end if;
            if ula_out = '1' then
                load <='1';
                sel_rom <='1';
            elsif ula_out = '0' then
                up <= '1';
            end if;
    end case;
    
end process output;
end architecture RTL;
