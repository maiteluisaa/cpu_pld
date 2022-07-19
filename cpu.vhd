library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk : in std_logic;
        rst : in std_logic;
        data_in_bus : in std_logic_vector(15 downto 0);
        
        wre_bus_en: out std_logic;
        wr_bus_en : out std_logic;
        mem_addr_bus: out std_logic_vector(7 downto 0);
        data_out_bus : out std_logic_vector(15 downto 0)
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
 --   signal hex0 : std_logic_vector(7 downto 0);
 --   signal hex1 : std_logic_vector(7 downto 0);
 --   signal hex2 : std_logic_vector(7 downto 0);
 --   signal hex3 : std_logic_vector(7 downto 0);
    
begin

    ir_inst:entity work.ir
    port map(
        clk       => clk,
        en        => en,
        reset     => rst,
        data      => q_a,
        opcode    => opcode,
        immediate => immediate,
        mem_addr  => mem_addr
    );
    
    reg_A:entity work.reg16bits
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
        
    rom_inst: entity work.romdual
        port map(
        address  => rom_addres,
        clock    => clk,
        q    => q_a          
        );


     fsm_inst:entity work.fsm
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
    
    pc_inst:entity work.pc
        port map(
            clk     => clk,
            load    => load,
            reset   => rst,
            up      => up,
            data_in => data_in,
            data    => pc_data
        );
    
    ula_inst:entity work.ula
        port map(
            a          => rega_out,
            b          => regb_out,
            aluop      => aluop,
            result_lsb => result_lsb,
            result_msb => data_inb
        );
        
    ram_inst: entity work.ram
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
    
                
    datain_ram <= std_logic_vector(rega_out);
    
    mem_addr_bus <= std_logic_vector(mem_addr);
    data_out_bus <= std_logic_vector(rega_out);
    
    
    data_in <= mem_addr (7 downto 0);
    ula_out <= result_lsb (0);
        
    with opcode select -- opera��o de load immediate e multiplica��o
    qa(7 downto 0) <= signed(immediate) when x"60",
                       result_lsb(7 downto 0) when others;
    
   with opcode select -- opera��o de load immediate e multiplica��o
   qa(15 downto 8) <= (others=>'0') when x"60",      
                      result_lsb(15 downto 8) when others; 
   
   with mem_addr select
   ql <= data_in_bus when "11111101",
         data_in_bus when "11111110",
         data_in_bus when "11111111", --n�o � poss�vel ler o registrador de sa�da
         q when others;
           
   with opcode select -- opera��o da ula e escrita da mem�ria no reg A
   in_a <= qa when x"10",
           qa when x"20",
           qa when x"30",
           qa when x"40",               
           qa when x"50",
           qa when x"60",
           qa when x"70",
           signed(ql) when x"01",
			  x"FFFF" when x"00",
			  (others=>'0') when others;    
                
   with sel_rom select -- opera��es de desvio de mem�ria rom 
   rom_addres <= std_logic_vector(mem_addr (7 downto 0)) when '1', -- std_logic_vector(mem_addr (7 downto 0)) when '1',
                 std_logic_vector(pc_data) when others; --std_logic_vector(pc_data) when others;
                   
  process(we, mem_addr, wr)
  begin
      we_ram <= '0';
      wr_bus_en <= '0';
      wre_bus_en <= '0';
      
      if we = '1' then -- write mem state
        if mem_addr < "11111101" then
            we_ram <= '1';
        elsif mem_addr = "11111111" then
            wr_bus_en <= '1';
        end if;
     end if;
    
    if wr = '1' then
        if mem_addr = "11111101" or mem_addr = "11111110" then
            wre_bus_en <= '1';
        end if;
    end if;
      
  end process; 
  
end architecture RTL;
