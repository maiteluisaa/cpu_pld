library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_display is
    port(
        clk : in std_logic;
        rst : in std_logic;
        wr_bus_en : in std_logic;
        data_w   : in  std_logic_vector(15 downto 0);
        mem_addr_bus: in std_logic_vector(7 downto 0);
        hex0 : out std_logic_vector(7 downto 0);
        hex1 : out std_logic_vector(7 downto 0);
        hex2 : out std_logic_vector(7 downto 0);
        hex3 : out std_logic_vector(7 downto 0)
    );
end entity led_display;

architecture RTL of led_display is
    
     function decode (data: std_logic_vector(3 downto 0)) return std_logic_vector is
        variable dec : std_logic_vector(7 downto 0);
    begin
       
        case data is
            when x"0" => dec := "11000000";
            when x"1" => dec := "11111001";
            when x"2" => dec := "10100100";
            when x"3" => dec := "10110000";
            when x"4" => dec := "10011001";
            when x"5" => dec := "10010010";
            when x"6" => dec := "10000010";
            when x"7" => dec := "11111000";
            when x"8" => dec := "10000000";
            when x"9" => dec := "10010000";
            when x"A" => dec := "10001000";
            when x"B" => dec := "10000011";
            when x"C" => dec := "11000110";
            when x"D" => dec := "10100001";
            when x"E" => dec := "10000110";
            when others => dec := "10001110";
        end case;    

        return dec;
    end function;
    
begin
    
    process(clk, rst)
    begin       
        if rst = '1' then
            --! All displays resets to zero
            hex0 <= "11000000";
            hex1 <= "11000000"; 
            hex2 <= "11000000"; 
            hex3 <= "11000000"; 
     --       hex4 <= "11000000"; 
     --       hex5 <= "11000000"; 
     --       hex6 <= "11000000"; 
     --       hex7 <= "11000000"; 
        else
            if rising_edge(clk) then
                if (wr_bus_en = '1' and mem_addr_bus = "11111111") then 
                    hex0 <= decode(data_w(3 downto 0));
                    hex1 <= decode(data_w(7 downto 4));
                    hex2 <= decode(data_w(11 downto 8));
                    hex3 <= decode(data_w(15 downto 12));
                end if;
            end if;
        end if;
    end process;
end architecture RTL;