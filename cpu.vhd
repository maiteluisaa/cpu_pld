library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- cpu que realiza operações de desvio, aritmética, lógica e memória

entity cpu is
    port(
        clk : in std_logic; -- entrada de clk
        rst : in std_logic; -- entrada de rst assíncrono
        data_in_bus : in std_logic_vector(15 downto 0); -- entrada das chaves
        
        rd_bus_en: out std_logic; -- sinal de enable de leitura da chave
        wr_bus_en : out std_logic; -- sinal de enable de escrita nos displays 7 seg
        mem_addr_bus: out std_logic_vector(7 downto 0); -- endereco de memoria (chaves ou displays 7 seg)
        data_out_bus : out std_logic_vector(15 downto 0) -- dado dos displays 7 seg
    );
end entity cpu;

architecture RTL of cpu is
    signal en : std_logic := '1';
    signal opcode : std_logic_vector(7 downto 0);
    signal immediate : std_logic_vector(7 downto 0);
    signal mem_addr : unsigned(7 downto 0);
    signal w_flaga : std_logic;
    signal w_flagb : std_logic;
    signal data_in : unsigned (7 downto 0);
    signal pc_data : unsigned (7 downto 0);
    signal load : std_logic := '0';
    signal up : std_logic;
    signal we : std_logic;
    signal q_a : std_logic_vector(15 downto 0);
    signal rega_out : signed (15 downto 0) := (others=>'0');
    signal regb_out : signed (15 downto 0) := (others=>'0');
    signal result_lsb : signed (15 downto 0);
    signal aluop : std_logic_vector(2 downto 0);
    signal data_inb : signed (15 downto 0);
    signal qa : signed(15 downto 0);
    signal q : std_logic_vector(15 downto 0);
    signal in_a : signed(15 downto 0);
    signal datain_ram : std_logic_vector (15 downto 0);
    signal ula_out : std_logic;
    signal sel_rom : std_logic;
    signal we_ram : std_logic;
    signal ql : std_logic_vector(15 downto 0);
    signal rom_addres : std_logic_vector (7 downto 0);
    signal q_b : std_logic_vector(15 downto 0);
    signal wr : std_logic;
    
begin

    ir_inst:entity work.ir -- instanciando o registrador de instrução
    port map(
        clk       => clk,
        en        => en,
        reset     => rst,
        data      => q_a,
        opcode    => opcode,
        immediate => immediate,
        mem_addr  => mem_addr
    );
    
    reg_A:entity work.reg16bits -- instanciando os registradores de 16 bits A e B
        port map(
            clk     => clk,
            clear   => rst,
            w_flag  => w_flaga,
            data_in => in_a,
            reg_out => rega_out
        );
        
    reg_B:entity work.reg16bits
        port map(
            clk     => clk,
            clear   => rst,
            w_flag  => w_flagb,
            data_in => data_inb,
            reg_out => regb_out
        );    
        
    rom_inst: entity work.romdual -- instanciando a memoria ROM (inicializada com arquivo .mif na execução)
        port map(
        address  => rom_addres,
        clock    => clk,
        q    => q_a          
        );


     fsm_inst:entity work.fsm -- instanciando a máquina de estados
        port map(
            clk       => clk,
            opcode    => opcode,
            w_flaga => w_flaga,
            w_flagb => w_flagb,
            we => we,
            up => up,
            load => load,
            rst     => rst,
            ula_out => ula_out,
            aluop => aluop,
            sel_rom => sel_rom,   
            wr => wr
        );   
    
    pc_inst:entity work.pc -- instanciando o contador de programa
        port map(
            clk     => clk,
            load    => load,
            reset   => rst,
            up      => up,
            data_in => data_in,
            data    => pc_data
        );
    
    ula_inst:entity work.ula -- instanciando a ula
        port map(
            a          => rega_out,
            b          => regb_out,
            aluop      => aluop,
            result_lsb => result_lsb,
            result_msb => data_inb
        );
        
    ram_inst: entity work.ram -- instanciando a memoria RAM
        generic map(
            size_mem  => 256,
            size_bits => 16
        )
        port map(
            clk     => clk,
            addr    => mem_addr(7 downto 0),
            we      => we_ram,
            data_in => datain_ram,
            q       => q
        );
    
    -- conversao de tipos  
	 
    datain_ram <= std_logic_vector(rega_out);
    
    mem_addr_bus <= std_logic_vector(mem_addr);
    data_out_bus <= std_logic_vector(rega_out);
    
    
    data_in <= mem_addr (7 downto 0);
    ula_out <= result_lsb (0); -- variável que auxilia nas operações beq e blt
        
    with opcode select -- auxilia nas operacoes li e mul, necessario escrever na parte alta e baixa de qa
    qa(7 downto 0) <= signed(immediate) when x"60",
                       result_lsb(7 downto 0) when others;
    
   with opcode select -- auxilia nas operacoes li e mul, necessario escrever na parte alta e baixa de qa
   qa(15 downto 8) <= (others=>'0') when x"60",      
                      result_lsb(15 downto 8) when others; 
   
   with mem_addr select -- fazendo os desvios para os enderecos do display 7 seg e das chaves
   ql <= data_in_bus when "11111101",
         data_in_bus when "11111110",
         data_in_bus when "11111111", -- nao e possivel ler saida, por isso o desvio para as chaves
         q when others;
           
   with opcode select -- auxilia nas operacoes da ula e de escrita no regA com valor da memoria RAM
   in_a <= qa when x"10",
           qa when x"20",
           qa when x"30",
           qa when x"40",               
           qa when x"50",
           qa when x"60",
           qa when x"70",
           signed(ql) when x"01",
			  (others=>'0') when others;    
                
   with sel_rom select -- muda o endereco da ROM conforme operacao, jmp -> memoria ram, operacao normal -> contador de programa
   rom_addres <= std_logic_vector(mem_addr (7 downto 0)) when '1', 
                 std_logic_vector(pc_data) when others; 
                   
  process(we, mem_addr, wr)
  begin
      we_ram <= '0'; -- enable de escrita na ram
      wr_bus_en <= '0'; -- enable de escrita nos displays 7seg
      rd_bus_en <= '0'; -- enable de leitura das chaves
      
      if we = '1' then -- aciona os enables conforme endereco e estado write_mem da fsm
        if mem_addr < "11111101" then
            we_ram <= '1';
        elsif mem_addr = "11111111" then
            wr_bus_en <= '1';
        end if;
     end if;
    
    if wr = '1' then
        if mem_addr = "11111101" or mem_addr = "11111110" then
            rd_bus_en <= '1';
        end if;
    end if;
  end process; 
  
end architecture RTL;
