-------------------------------------------------------------------
-- Name        : de0_lite.vhd
-- Author      : 
-- Version     : 0.1
-- Copyright   : Departamento de Eletrônica, Florianópolis, IFSC
-- Description : Projeto base DE10-Lite
-------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;

entity de10_lite is 
	port (
		---------- CLOCK ----------
		ADC_CLK_10:	in std_logic;
		MAX10_CLK1_50: in std_logic;
		MAX10_CLK2_50: in std_logic;
		
		----------- SDRAM ------------
		DRAM_ADDR: out std_logic_vector (12 downto 0);
		DRAM_BA: out std_logic_vector (1 downto 0);
		DRAM_CAS_N: out std_logic;
		DRAM_CKE: out std_logic;
		DRAM_CLK: out std_logic;
		DRAM_CS_N: out std_logic;		
		DRAM_DQ: inout std_logic_vector(15 downto 0);
		DRAM_LDQM: out std_logic;
		DRAM_RAS_N: out std_logic;
		DRAM_UDQM: out std_logic;
		DRAM_WE_N: out std_logic;
		
		----------- SEG7 ------------
		HEX0: out std_logic_vector(7 downto 0);
		HEX1: out std_logic_vector(7 downto 0);
		HEX2: out std_logic_vector(7 downto 0);
		HEX3: out std_logic_vector(7 downto 0);
		HEX4: out std_logic_vector(7 downto 0);
		HEX5: out std_logic_vector(7 downto 0);

		----------- KEY ------------
		KEY: in std_logic_vector(1 downto 0);

		----------- LED ------------
		LEDR: out std_logic_vector(9 downto 0);

		----------- SW ------------
		SW: in std_logic_vector(9 downto 0);

		----------- VGA ------------
		VGA_B: out std_logic_vector(3 downto 0);
		VGA_G: out std_logic_vector(3 downto 0);
		VGA_HS: out std_logic;
		VGA_R: out std_logic_vector(3 downto 0);
		VGA_VS: out std_logic;
	
		----------- Accelerometer ------------
		GSENSOR_CS_N: out std_logic;
		GSENSOR_INT: in std_logic_vector(2 downto 1);
		GSENSOR_SCLK: out std_logic;
		GSENSOR_SDI: inout std_logic;
		GSENSOR_SDO: inout std_logic;
	
		----------- Arduino ------------
		ARDUINO_IO: inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N: inout std_logic
	);
end entity;


architecture rtl of de10_lite is

   signal mem_addr_bus : std_logic_vector(7 downto 0);
	signal data_in_bus : std_logic_vector(7 downto 0);
   signal data_out_bus : std_logic_vector(15 downto 0);
	signal data_out_bus_reg : std_logic_vector(15 downto 0);
   signal wr_bus_en : std_logic;
	signal clk: std_logic;
	signal rd: std_logic;
	signal hex00: std_logic_vector(7 downto 0);
	signal hex01: std_logic_vector(7 downto 0);
	signal hex02: std_logic_vector(7 downto 0);
	signal hex03: std_logic_vector(7 downto 0);
	 
begin

	 pll_inst: entity work.PLLL
      port map(
          areset => '0',
          inclk0 => ADC_CLK_10,
          c0 => clk
      );    

	
	cpu_inst:entity work.cpu
	  port map(
			clk          => clk,
			rst          => SW(0),
			wr_bus_en    => wr_bus_en,
			mem_addr_bus => mem_addr_bus,
			data_out_bus => data_out_bus,
			data_in_bus => data_out_bus_reg,
			rd_bus_en => rd
	  ); 
	  
	  led_isnt: entity work.led_display
        port map(
            clk          => clk,
            rst          => SW(0),
            wr_bus_en    => wr_bus_en,
            data_w       => data_out_bus,
            mem_addr_bus => mem_addr_bus,
            hex0         => hex00,
            hex1         => hex01,
            hex2         => hex02,
            hex3         => hex03
        );
		  
	  key_inst: entity work.key_reg
        port map(
            clk => clk,
            rst => SW(0),
            mem_addr_bus => mem_addr_bus,
            data_r => SW(8 downto 1),
            data_out => data_out_bus_reg,
            rd => rd
        ); 
	  
	 
	  HEX0 <= hex00;
	  HEX1 <= hex01;
	  HEX2 <= hex02;
	  HEX3 <= hex03;
	  
	  
	 
end;

