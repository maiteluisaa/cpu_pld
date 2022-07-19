library ieee;   
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram is
    
    Generic (
            constant size_mem: integer := 256;
                     size_bits: integer := 16
    
    );
    
    port (
        clk : in std_logic;
        addr: in unsigned(7 downto 0);
        -- Must exist to infer RAM.
        we : in std_logic;  
        data_in : in std_logic_vector((size_bits - 1) downto 0);
        q : out std_logic_vector((size_bits - 1) downto 0)
    );
end entity;

architecture rtl of ram is

    type mem is array (0 to (size_mem - 1)) of std_logic_vector((size_bits - 1) downto 0);
    signal ram_block: mem;
    
    -- Initialize memory with constant values
    -- Does work with Quartus
    -- signal ram_block: mem := ("1000000", "1111001", "0100100", "0110000",  -- 0, 1, 2, 3
    --                          "0011001", "0010010", "0000010", "1111000",  -- 4, 5, 6, 7 
    --                           "0000000", "0010000", "0001000", "0000011",  -- 8, 9, A, B 
    --                            "0100111", "0100001", "0000110", "0001110",  -- C, D, E, F
    --                            others => (others => '0'));

begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if we = '1' then 
                ram_block(to_integer(addr)) <= data_in;
            end if;
            q <= ram_block(to_integer(addr));
        end if;
    end process;    
end rtl;