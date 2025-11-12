----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2024 11:29:20 AM
-- Design Name: 
-- Module Name: empfw_debughub - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity empfw_debughub is
    generic(
		-- Constants:
        AXI_ADDR_WIDTH : integer                 := 32; -- width of the AXI address bus	
        BASEADDR : std_logic_vector(31 downto 0) := x"B0000000"; -- register bank AXI base address	
        g_SFP_ENABLE                             : boolean := false
	);
    Port ( 
        -- Reset signal to emp_lpgbt
        rst_emp_lpgbt_0         : out std_logic;
        rst_emp_lpgbt_1         : out std_logic;
        rst_emp_lpgbt_2         : out std_logic;
        rst_emp_lpgbt_3         : out std_logic;
        rst_emp_lpgbt_4         : out std_logic;
        rst_emp_lpgbt_5         : out std_logic;
        rst_emp_lpgbt_6         : out std_logic;
        rst_emp_lpgbt_7         : out std_logic;
        rst_emp_lpgbt_8         : out std_logic;
        rst_emp_lpgbt_9         : out std_logic;
        rst_emp_lpgbt_10        : out std_logic;
        rst_emp_lpgbt_11        : out std_logic;
        rst_emp_lpgbt_12        : out std_logic;
        
        -- Reset signals to transceiver IPs
        MGT_TXRESET_o           : out std_logic_vector(11 downto 0);
        MGT_RXRESET_o           : out std_logic_vector(11 downto 0);
        CH12_MGT_TXRESET_o      : out std_logic;
        CH12_MGT_RXRESET_o      : out std_logic;
        
        -- Status if emp_lpgbt is locked to the received frame and tx is ready
        status_emp_lpgbt_0      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_1      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_2      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_3      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_4      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_5      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_6      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_7      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_8      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_9      : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_10     : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_11     : in std_logic_vector(1 downto 0);
        status_emp_lpgbt_12     : in std_logic_vector(1 downto 0);
        
        -- TX aligned status
        tx_aligned_ff_i         : in std_logic_vector(11 downto 0);
        tx_aligned_sfp_i        : in std_logic_vector(0 downto 0);
        
        -- Ready signals from transceiver IPs
        MGT_TXREADY_i           : in std_logic_vector(11 downto 0);
        MGT_RXREADY_i           : in std_logic_vector(11 downto 0);
        CH12_MGT_TXREADY_i      : in std_logic;
        CH12_MGT_RXREADY_i      : in std_logic;
       
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
end empfw_debughub;

architecture Behavioral of empfw_debughub is
    
    -- =========================================== Components declarations ========================================
    
    component fw_monitor_regs
        generic(
                AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address word, in bits
                BASEADDR : std_logic_vector(31 downto 0) := x"B0000000" -- register bank AXI base address
        );
        port(
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
            reset_reg_1_strobe              : out std_logic; -- strobe signal for register 'reset_reg_1' (pulsed when the register is written from the bus)
            reset_reg_1_emp_lpgbt_ip        : out std_logic_vector(12 downto 0); -- write value of field 'reset_reg_1.emp_lpgbt_ip'
            reset_reg_2_strobe              : out std_logic; -- strobe signal for register 'reset_reg_2' (pulsed when the register is written from the bus)
            reset_reg_2_tx_reset            : out std_logic_vector(12 downto 0); -- write value of field 'reset_reg_2.tx_reset'
            reset_reg_2_rx_reset            : out std_logic_vector(12 downto 0); -- write value of field 'reset_reg_2.rx_reset'
            status_reg_1_strobe             : out std_logic; -- strobe signal for register 'status_reg_1' (pulsed when the register is read from the bus)
            status_reg_1_tx_alignment       : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_1.tx_alignment'
            status_reg_2_strobe             : out std_logic; -- strobe signal for register 'status_reg_2' (pulsed when the register is read from the bus)
            status_reg_2_tx_ready           : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_2.tx_ready'
            status_reg_2_rx_ready           : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_2.rx_ready'
            status_reg_3_strobe             : out std_logic; -- strobe signal for register 'status_reg_3' (pulsed when the register is read from the bus)
            status_reg_3_lpgbt_rx_locked    : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_3.lpgbt_rx_locked'
            status_reg_3_lpgbt_tx_ready     : in std_logic_vector(12 downto 0) -- read value of field 'status_reg_3.lpgbt_tx_ready'
    );
    end component;
    
    -- ==================================== Signals declaration =============================================
    
    signal reset_emp_lpgbt_ip_s     : std_logic_vector(12 downto 0);
    signal reset_tx_s               : std_logic_vector(12 downto 0);
    signal reset_rx_s               : std_logic_vector(12 downto 0); 
    signal status_tx_alignment_s    : std_logic_vector(12 downto 0); 
    signal status_tx_ready_s        : std_logic_vector(12 downto 0);
    signal status_rx_ready_s        : std_logic_vector(12 downto 0);
    signal status_lpgbt_rx_locked_s : std_logic_vector(12 downto 0); 
    signal status_lpgbt_tx_ready_s  : std_logic_vector(12 downto 0);
      
begin
    --Output
    rst_emp_lpgbt_0             <= not axi_aresetn or reset_emp_lpgbt_ip_s(0);
    rst_emp_lpgbt_1             <= not axi_aresetn or reset_emp_lpgbt_ip_s(1);
    rst_emp_lpgbt_2             <= not axi_aresetn or reset_emp_lpgbt_ip_s(2);
    rst_emp_lpgbt_3             <= not axi_aresetn or reset_emp_lpgbt_ip_s(3);
    rst_emp_lpgbt_4             <= not axi_aresetn or reset_emp_lpgbt_ip_s(4);
    rst_emp_lpgbt_5             <= not axi_aresetn or reset_emp_lpgbt_ip_s(5);
    rst_emp_lpgbt_6             <= not axi_aresetn or reset_emp_lpgbt_ip_s(6);
    rst_emp_lpgbt_7             <= not axi_aresetn or reset_emp_lpgbt_ip_s(7);
    rst_emp_lpgbt_8             <= not axi_aresetn or reset_emp_lpgbt_ip_s(8);
    rst_emp_lpgbt_9             <= not axi_aresetn or reset_emp_lpgbt_ip_s(9);
    rst_emp_lpgbt_10            <= not axi_aresetn or reset_emp_lpgbt_ip_s(10);
    rst_emp_lpgbt_11            <= not axi_aresetn or reset_emp_lpgbt_ip_s(11);
    rst_emp_lpgbt_12            <= not axi_aresetn or reset_emp_lpgbt_ip_s(12);
    
    MGT_TXRESET_o               <= reset_tx_s(11 downto 0);
    MGT_RXRESET_o               <= reset_rx_s(11 downto 0); 
    CH12_MGT_TXRESET_o          <= reset_tx_s(12);
    CH12_MGT_RXRESET_o          <= reset_rx_s(12);
    
    --Input
    status_tx_alignment_s(11 downto 0)      <= tx_aligned_ff_i;
    status_tx_alignment_s(12)               <= tx_aligned_sfp_i(0);
    
    status_tx_ready_s(11 downto 0)          <= MGT_TXREADY_i;
    status_rx_ready_s(11 downto 0)          <= MGT_RXREADY_i;
    status_tx_ready_s(12)                   <= CH12_MGT_TXREADY_i;
    status_rx_ready_s(12)                   <= CH12_MGT_RXREADY_i;
    
    status_lpgbt_rx_locked_s(0)              <= status_emp_lpgbt_0(0);
    status_lpgbt_rx_locked_s(1)              <= status_emp_lpgbt_1(0);      
    status_lpgbt_rx_locked_s(2)              <= status_emp_lpgbt_2(0);     
    status_lpgbt_rx_locked_s(3)              <= status_emp_lpgbt_3(0);     
    status_lpgbt_rx_locked_s(4)              <= status_emp_lpgbt_4(0);     
    status_lpgbt_rx_locked_s(5)              <= status_emp_lpgbt_5(0);     
    status_lpgbt_rx_locked_s(6)              <= status_emp_lpgbt_6(0);     
    status_lpgbt_rx_locked_s(7)              <= status_emp_lpgbt_7(0);     
    status_lpgbt_rx_locked_s(8)              <= status_emp_lpgbt_8(0);     
    status_lpgbt_rx_locked_s(9)              <= status_emp_lpgbt_9(0);     
    status_lpgbt_rx_locked_s(10)             <= status_emp_lpgbt_10(0);     
    status_lpgbt_rx_locked_s(11)             <= status_emp_lpgbt_11(0);    
    status_lpgbt_rx_locked_s(12)             <= status_emp_lpgbt_12(0);
   
   status_lpgbt_tx_ready_s(0)               <= status_emp_lpgbt_0(1);
   status_lpgbt_tx_ready_s(1)               <= status_emp_lpgbt_1(1);      
   status_lpgbt_tx_ready_s(2)               <= status_emp_lpgbt_2(1);     
   status_lpgbt_tx_ready_s(3)               <= status_emp_lpgbt_3(1);     
   status_lpgbt_tx_ready_s(4)               <= status_emp_lpgbt_4(1);     
   status_lpgbt_tx_ready_s(5)               <= status_emp_lpgbt_5(1);     
   status_lpgbt_tx_ready_s(6)               <= status_emp_lpgbt_6(1);     
   status_lpgbt_tx_ready_s(7)               <= status_emp_lpgbt_7(1);     
   status_lpgbt_tx_ready_s(8)               <= status_emp_lpgbt_8(1);     
   status_lpgbt_tx_ready_s(9)               <= status_emp_lpgbt_9(1);     
   status_lpgbt_tx_ready_s(10)              <= status_emp_lpgbt_10(1);     
   status_lpgbt_tx_ready_s(11)              <= status_emp_lpgbt_11(1);    
   status_lpgbt_tx_ready_s(12)              <= status_emp_lpgbt_12(1);     
    
    reg_map : fw_monitor_regs
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
			reset_reg_1_strobe               => open,            
            reset_reg_1_emp_lpgbt_ip         => reset_emp_lpgbt_ip_s,
            reset_reg_2_strobe               => open,
            reset_reg_2_tx_reset             => reset_tx_s,
            reset_reg_2_rx_reset             => reset_rx_s,
            status_reg_1_strobe              => open,
            status_reg_1_tx_alignment        => status_tx_alignment_s,
            status_reg_2_strobe              => open,
            status_reg_2_tx_ready            => status_tx_ready_s,
            status_reg_2_rx_ready            => status_rx_ready_s,
            status_reg_3_strobe              => open,
            status_reg_3_lpgbt_rx_locked     => status_lpgbt_rx_locked_s,
            status_reg_3_lpgbt_tx_ready      => status_lpgbt_tx_ready_s
		);

end Behavioral;
