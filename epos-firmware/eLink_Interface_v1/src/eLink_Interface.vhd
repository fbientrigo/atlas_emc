----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2024 09:04:48 AM
-- Design Name: 
-- Module Name: eLink_Interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
library unisim;
use unisim.vcomponents.all;


entity eLink_Interface is
    generic(
		-- Constants:
        AXI_ADDR_WIDTH : integer       := 32; -- width of the AXI address bus	
        BASEADDR : std_logic_vector(31 downto 0) := x"A00D0000" -- register bank AXI base address	
	);
    Port(    
        intr                        : out std_logic;
        user_data_in                : in std_logic_vector(229 downto 0);
        user_data_out               : out std_logic_vector(31 downto 0);
        logicCLK                    : in std_logic;
    -- ==================================== AXI bus  ============================================
        -- AXI to Processor part
        -- Clock and Reset
        axi_aclk                     : in  std_logic;
        axi_aresetn                  : in  std_logic;
		-- AXI Write Address Channel
		s_axi_awaddr                 : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awprot                 : in  std_logic_vector(2 downto 0);
		s_axi_awvalid                : in  std_logic;
		s_axi_awready                : out std_logic;
		-- AXI Write Data Channel
		s_axi_wdata                  : in  std_logic_vector(31 downto 0);
		s_axi_wstrb                  : in  std_logic_vector(3 downto 0);
		s_axi_wvalid                 : in  std_logic;
		s_axi_wready                 : out std_logic;
		-- AXI Read Address Channel
		s_axi_araddr                 : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot                 : in  std_logic_vector(2 downto 0);
		s_axi_arvalid                : in  std_logic;
		s_axi_arready                : out std_logic;
		-- AXI Read Data Channel
		s_axi_rdata                  : out std_logic_vector(31 downto 0);
		s_axi_rresp                  : out std_logic_vector(1 downto 0);
		s_axi_rvalid                 : out std_logic;
		s_axi_rready                 : in  std_logic;
		-- AXI Write Response Channel
		s_axi_bresp                  : out std_logic_vector(1 downto 0);
		s_axi_bvalid                 : out std_logic;
		s_axi_bready                 : in  std_logic
    );

end eLink_Interface;

architecture Behavioral of eLink_Interface is

    component eLink_Interface_regs
        generic(
            AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address word, in bits
            BASEADDR : std_logic_vector(31 downto 0) -- register bank AXI base address
        );
        Port(
            -- Clock and Reset
            axi_aclk    : in  std_logic;
            axi_aresetn : in  std_logic;
            -- AXI Write Address Channel
            s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
            s_axi_awprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
            s_axi_awvalid : in  std_logic;
            s_axi_awready : out std_logic;
            -- AXI Write Data Channel
            s_axi_wdata   : in  std_logic_vector(31 downto 0);
            s_axi_wstrb   : in  std_logic_vector(3 downto 0);
            s_axi_wvalid  : in  std_logic;
            s_axi_wready  : out std_logic;
            -- AXI Read Address Channel
            s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
            s_axi_arprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
            s_axi_arvalid : in  std_logic;
            s_axi_arready : out std_logic;
            -- AXI Read Data Channel
            s_axi_rdata   : out std_logic_vector(31 downto 0);
            s_axi_rresp   : out std_logic_vector(1 downto 0);
            s_axi_rvalid  : out std_logic;
            s_axi_rready  : in  std_logic;
            -- AXI Write Response Channel
            s_axi_bresp   : out std_logic_vector(1 downto 0);
            s_axi_bvalid  : out std_logic;
            s_axi_bready  : in  std_logic;
            -- User Ports
            magic_strobe : out std_logic; -- strobe signal for register 'magic' (pulsed when the register is read from the bus)
            magic_value : in std_logic_vector(31 downto 0); -- read value of field 'magic.value'
            status_strobe : out std_logic; -- strobe signal for register 'status' (pulsed when the register is read from the bus)
            status_dlinkfifo_empty : in std_logic_vector(0 downto 0); -- read value of field 'status.dLinkFIFO_empty'
            status_dlinkfifo_full : in std_logic_vector(0 downto 0); -- read value of field 'status.dLinkFIFO_full'
            status_ulinkfifo_empty : in std_logic_vector(0 downto 0); -- read value of field 'status.uLinkFIFO_empty'
            status_ulinkfifo_full : in std_logic_vector(0 downto 0); -- read value of field 'status.uLinkFIFO_full'
            control_strobe : out std_logic; -- strobe signal for register 'control' (pulsed when the register is written from the bus)
            control_ack : out std_logic_vector(0 downto 0); -- write value of field 'control.ACK'
            downlinkdata_strobe : out std_logic; -- strobe signal for register 'downLinkData' (pulsed when the register is written from the bus)
            downlinkdata_dataword : out std_logic_vector(31 downto 0); -- write value of field 'downLinkData.dataWord'
            uplinkdatagrp_0_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_0' (pulsed when the register is read from the bus)
            uplinkdatagrp_0_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_0.dataWord'
            uplinkdatagrp_1_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_1' (pulsed when the register is read from the bus)
            uplinkdatagrp_1_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_1.dataWord'
            uplinkdatagrp_2_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_2' (pulsed when the register is read from the bus)
            uplinkdatagrp_2_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_2.dataWord'
            uplinkdatagrp_3_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_3' (pulsed when the register is read from the bus)
            uplinkdatagrp_3_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_3.dataWord'
            uplinkdatagrp_4_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_4' (pulsed when the register is read from the bus)
            uplinkdatagrp_4_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_4.dataWord'
            uplinkdatagrp_5_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_5' (pulsed when the register is read from the bus)
            uplinkdatagrp_5_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_5.dataWord'
            uplinkdatagrp_6_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_6' (pulsed when the register is read from the bus)
            uplinkdatagrp_6_dataword : in std_logic_vector(31 downto 0) -- read value of field 'upLinkDataGrp_6.dataWord'
        );
    end component;
    
    component FIFO_tx_wrapper
        Port(
            -- FIFO_WRITE
            full        : out std_logic;
            din         : in std_logic_vector(31 downto 0);
            wr_en       : in std_logic;
            wr_clk      : in std_logic;
            -- FIFO_READ
            empty       : out std_logic;
            dout        : out std_logic_vector(31 downto 0);
            rd_en       : in std_logic;
            rd_clk      : in std_logic;
            -- Reset
            rst         : in std_logic
        );
    end component;

    component FIFO_rx_wrapper
        Port(
            -- FIFO_WRITE
            full        : out std_logic;
            din         : in std_logic_vector(223 downto 0);
            wr_en       : in std_logic;
            wr_clk      : in std_logic;
            -- FIFO_READ
            empty       : out std_logic;
            dout        : out std_logic_vector(223 downto 0);
            rd_en       : in std_logic;
            rd_clk      : in std_logic;
            -- Reset
            rst         : in std_logic
        );
    end component;
    
    -- RX-signal
    signal ulData_in_s      : std_logic_vector(229 downto 0);
    
    --TX FIFO signals
    signal TX_WrEN          : std_logic;
    signal TX_RdEN          : std_logic;
    signal tx_in            : std_logic_vector(31 downto 0);
    signal tx_out           : std_logic_vector(31 downto 0);
    
    --RX FIFO signals
    signal RX_WrEN          : std_logic;
    signal RX_RdEN          : std_logic;
    signal rx_in            : std_logic_vector(223 downto 0);
    signal rx_out           : std_logic_vector(223 downto 0);
   
    -- AXI signals
    signal magicValue_s     : std_logic_vector(31 downto 0);
    signal dlFIFO_empty_s   : std_logic_vector(0 downto 0);
    signal dlFIFO_full_s    : std_logic_vector(0 downto 0);
    signal ulFIFO_empty_s   : std_logic_vector(0 downto 0);
    signal ulFIFO_full_s    : std_logic_vector(0 downto 0);
    signal ctrlACK_s        : std_logic_vector(0 downto 0);
    
    signal ctrlStrobe_s     : std_logic;     
    signal dlStrobe_s       : std_logic;
    signal ulGrp0Strobe_s   : std_logic;
    signal ulGrp1Strobe_s   : std_logic;
    signal ulGrp2Strobe_s   : std_logic;
    signal ulGrp3Strobe_s   : std_logic;
    signal ulGrp4Strobe_s   : std_logic;
    signal ulGrp5Strobe_s   : std_logic;
    signal ulGrp6Strobe_s   : std_logic;
    
    signal dlData_s         : std_logic_vector(31 downto 0);
    signal ulGrp0Data_s     : std_logic_vector(31 downto 0);
    signal ulGrp1Data_s     : std_logic_vector(31 downto 0);
    signal ulGrp2Data_s     : std_logic_vector(31 downto 0);
    signal ulGrp3Data_s     : std_logic_vector(31 downto 0);
    signal ulGrp4Data_s     : std_logic_vector(31 downto 0);
    signal ulGrp5Data_s     : std_logic_vector(31 downto 0);
    signal ulGrp6Data_s     : std_logic_vector(31 downto 0);
    
    type fsm_state_eLink_t is (idle, waiting_resp, waiting_read, finish);
	signal fsm_state     : fsm_state_eLink_t := idle;
    signal check_bit     : std_logic;
begin
    
     -- rd_en control txFIFO
    process (logicCLK, axi_aresetn)
    begin
        if axi_aresetn = '0' then
            TX_RdEN <= '0';
        elsif rising_edge(logicCLK) then
            if dlFIFO_empty_s(0) = '0' then
                TX_RdEN <= '1';
                user_data_out <= tx_out;
            else
                TX_RdEN <= '0';
                user_data_out <= (others => '0');
            end if;
        end if;
    end process;
 
 
    -- wr_en control rxFIFO
    process(logicCLK, axi_aresetn)
    begin
        if axi_aresetn = '0' then
            RX_WrEN <= '0';
            rx_in <= (others => '0');
        elsif rising_edge(logicCLK) then
            check_bit <= or ulData_in_s(223 downto 0);
            if check_bit = '1' and dlFIFO_full_s(0) = '0' then
                rx_in <= ulData_in_s(223 downto 0);
                RX_WrEN <= '1';
            else
                rx_in <= (others => '0');
                RX_WrEN <= '0';
            end if;
        end if;
    end process;
     
     
    eLink_fsm : process(axi_aclk, axi_aresetn)
        variable respCon    : std_logic := '0';
        variable regStatus  : std_logic_vector(6 downto 0) := (others => '0');
    begin
        if rising_edge(axi_aclk) then
            if axi_aresetn = '0' then
                regStatus := (others => '0');
                intr <= '0';
                TX_WrEN <= '0';
                tx_in <= (others => '0');
            else
                case fsm_state is
                
                when idle =>
                    if dlStrobe_s = '1' and dlFIFO_full_s(0) = '0' then
                        tx_in <= dlData_s;
                        TX_WrEN <= '1';
                        fsm_state <= waiting_resp;
                    else 
                        TX_WrEN <= '0';
                        tx_in <= (others => '0');
                    end if;
                
                when waiting_resp =>
                    TX_WrEN <= '0';
                    tx_in <= (others => '0');
                    respCon := or rx_out;
                    if respCon = '1' then
                        ulGrp0Data_s <= rx_out(223 downto 192);
                        ulGrp1Data_s <= rx_out(191 downto 160);
                        ulGrp2Data_s <= rx_out(159 downto 128);
                        ulGrp3Data_s <= rx_out(127 downto 96);
                        ulGrp4Data_s <= rx_out(95 downto 64);
                        ulGrp5Data_s <= rx_out(63 downto 32);
                        ulGrp6Data_s <= rx_out(31 downto 0);
                        regStatus := (others => '1');
                        fsm_state <= waiting_read;
                        intr <= '1';
                    end if;
                 
                when waiting_read =>
                    if ulGrp0Strobe_s = '1' then
                        ulGrp0Data_s <= (others => '0');
                        regStatus(0) := '0';
                    elsif ulGrp1Strobe_s = '1' then
                        ulGrp1Data_s <= (others => '0');
                        regStatus(1) := '0';
                    elsif ulGrp2Strobe_s = '1' then
                        ulGrp2Data_s <= (others => '0');
                        regStatus(2) := '0';
                    elsif ulGrp3Strobe_s = '1' then
                        ulGrp3Data_s <= (others => '0');
                        regStatus(3) := '0';
                    elsif ulGrp4Strobe_s = '1' then
                        ulGrp4Data_s <= (others => '0');
                        regStatus(4) := '0';
                    elsif ulGrp5Strobe_s = '1' then
                        ulGrp5Data_s <= (others => '0');
                        regStatus(5) := '0';
                    elsif ulGrp6Strobe_s = '1' then
                        ulGrp6Data_s <= (others => '0');
                        regStatus(6) := '0';
                    elsif (or regStatus) = '0' then
                        fsm_state <= finish;
                    elsif dlStrobe_s = '1' and dlFIFO_full_s(0) = '0' then
                        regStatus := (others => '0');
                        intr <= '0';
                        tx_in <= dlData_s;
                        TX_WrEN <= '1';
                        fsm_state <= waiting_resp;
                    end if;
                    
                when finish =>
                    regStatus := (others => '0');
                    intr <= '0';
                    fsm_state <= idle;
                    
                end case;
            end if;
        end if;
    end process;   
 
          
    txFIFO : FIFO_tx_wrapper
        port map(
            -- FIFO_WRITE
            full        => dlFIFO_full_s(0),
            din         => tx_in,
            wr_en       => TX_WrEN,
            wr_clk      => axi_aclk,
            -- FIFO_READ
            empty       => dlFIFO_empty_s(0),
            dout        => tx_out,
            rd_en       => TX_RdEN,
            rd_clk      => logicCLK,
            -- Reset
            rst         => not axi_aresetn
        );
 
             
    rxFIFO : FIFO_rx_wrapper
        port map(
            -- FIFO_WRITE
            full        => ulFIFO_full_s(0),
            din         => rx_in,
            wr_en       => RX_WrEN,
            wr_clk      => logicCLK,
            -- FIFO_READ
            empty       => ulFIFO_empty_s(0),
            dout        => rx_out,
            rd_en       => '1',
            rd_clk      => axi_aclk,
            -- Reset
            rst         => not axi_aresetn
        );


    reg_map : eLink_Interface_regs
		generic map(
			AXI_ADDR_WIDTH => AXI_ADDR_WIDTH,
			BASEADDR       => BASEADDR
		)
		port map(
            -- Clock and Reset
			axi_aclk                  => axi_aclk,
			axi_aresetn               => axi_aresetn,
			-- AXI Write Address Channel
			s_axi_awaddr              => s_axi_awaddr,
			s_axi_awprot              => s_axi_awprot,
			s_axi_awvalid             => s_axi_awvalid,
			s_axi_awready             => s_axi_awready,
			-- AXI Write Data Channel
			s_axi_wdata               => s_axi_wdata,
			s_axi_wstrb               => s_axi_wstrb,
			s_axi_wvalid              => s_axi_wvalid,
			s_axi_wready              => s_axi_wready,
			-- AXI Read Address Channel
			s_axi_araddr              => s_axi_araddr,
			s_axi_arprot              => s_axi_arprot,
			s_axi_arvalid             => s_axi_arvalid,
			s_axi_arready             => s_axi_arready,
			-- AXI Read Data Channel
			s_axi_rdata               => s_axi_rdata,
			s_axi_rresp               => s_axi_rresp,
			s_axi_rvalid              => s_axi_rvalid,
			s_axi_rready              => s_axi_rready,
			-- AXI Write Response Channel
			s_axi_bresp               => s_axi_bresp,
			s_axi_bvalid              => s_axi_bvalid,
			s_axi_bready              => s_axi_bready,
			-- User Ports  
            magic_strobe              => open,
            magic_value               => magicValue_s,
            status_strobe             => open,
            status_dlinkfifo_empty    => dlFIFO_empty_s,
            status_dlinkfifo_full     => dlFIFO_full_s,
            status_ulinkfifo_empty    => ulFIFO_empty_s,
            status_ulinkfifo_full     => ulFIFO_full_s,
            control_strobe            => ctrlStrobe_s,
            control_ack               => ctrlACK_s,
            downlinkdata_strobe       => dlStrobe_s,
            downlinkdata_dataword     => dlData_s,
            uplinkdatagrp_0_strobe    => ulGrp0Strobe_s,
            uplinkdatagrp_0_dataword  => ulGrp0Data_s,
            uplinkdatagrp_1_strobe    => ulGrp1Strobe_s,
            uplinkdatagrp_1_dataword  => ulGrp1Data_s,
            uplinkdatagrp_2_strobe    => ulGrp2Strobe_s,
            uplinkdatagrp_2_dataword  => ulGrp2Data_s,
            uplinkdatagrp_3_strobe    => ulGrp3Strobe_s,
            uplinkdatagrp_3_dataword  => ulGrp3Data_s,
            uplinkdatagrp_4_strobe    => ulGrp4Strobe_s,
            uplinkdatagrp_4_dataword  => ulGrp4Data_s,
            uplinkdatagrp_5_strobe    => ulGrp5Strobe_s,
            uplinkdatagrp_5_dataword  => ulGrp5Data_s,
            uplinkdatagrp_6_strobe    => ulGrp6Strobe_s,
            uplinkdatagrp_6_dataword  => ulGrp6Data_s
        );
        
        magicValue_s    <= x"736D656D";
        ulData_in_s     <= user_data_in;
        
end Behavioral;
