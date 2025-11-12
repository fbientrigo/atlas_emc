------------------------------------------------------
--! @file
--! @author Daniel Blasco Serrano <daniel.blasco.serrano@cern.ch> (CERN - EP-ESE-FE)
--! @version 1.0
--! @brief EMP top file firmware v1
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
-- Custom libraries
use work.lpgbtfpga_package.all;
use work.matrix_pkg.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--
entity emp_lpgbt is
	generic(
		AXI_ADDR_WIDTH : integer                       := 32;              -- width of the AXI address bus		
		BASEADDR       : std_logic_vector(31 downto 0) := x"A0000000"     -- the register file's system base address
	);
	port(
		-- ==================================== MGT signals ==========================================
		--=============--
		-- Clocks      --
		--=============--
		MGT_RXUSRCLK_i               : in  std_logic; -- MGT IP 320MHz reference input clock
		MGT_TXUSRCLK_i               : in  std_logic; -- MGT IP 320MHz recovered input clock
		--=============--
		-- Control     --
		--=============--
		MGT_RXSlide_o                : out std_logic;
		--==============--
		-- Data         --
		--==============--
		MGT_USRWORD_o                : out std_logic_vector(31 downto 0);
		MGT_USRWORD_i                : in  std_logic_vector(31 downto 0);
		-- ============================================================================================

		-- ================================= Data signals  ============================================
		logicCLK40_i                 : in std_logic; -- clock synq with downlink word
		lpgbtfpga_uplinkUserData_o   : out std_logic_vector(229 downto 0);
		lpgbtfpga_uplinkEcData_o     : out std_logic_vector(1 downto 0);
		lpgbtfpga_uplinkIcData_o     : out std_logic_vector(1 downto 0);
		lpgbtfpga_downlinkUserData_i : in  std_logic_vector(31 downto 0);
		
		uplinkReady_o                : out std_logic; --! Uplink ready status
		-- ============================================================================================
        
        -- External reset
		EXT_RST                      : in  std_logic;
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
		s_axi_bready                 : in  std_logic;
		-- ============================================================================================

		-- Interrupt
		int_lpgbt_resp               : out std_logic; -- lpGBT response received interrupt
		
		-- Debug signals
		status_emp_lpgbt_o           : out std_logic_vector(1 downto 0)

	);
end emp_lpgbt;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--
architecture behavioral of emp_lpgbt is

	-- =========================================== Components declarations ========================================

	-- LpGBT FPGA
	component lpgbtFpga_10g24 is
		GENERIC(
			FEC : integer range 0 to 2  --! FEC selection can be: FEC5 or FEC12
		);
		PORT(
			-- Clocks
			downlinkClk_i               : in std_logic; --! 40MHz user clock
			uplinkClk_i                 : in std_logic; --! 40MHz user clock

			downlinkRst_i               : in std_logic; --! Reset the downlink path
			uplinkRst_i                 : in std_logic; --! Reset the uplink path

			-- Down link
			downlinkData_i              : in std_logic_vector(35 downto 0); --! Downlink data (user)
            downlinkStrobe_i            : in std_logic;
            cdc_downlink_ready          : in std_logic;
            
			downLinkBypassInterleaver_i : in  std_logic; --! Bypass downlink interleaver (test purpose only)
			downLinkBypassFECEncoder_i  : in  std_logic; --! Bypass downlink FEC (test purpose only)
			downLinkBypassScrambler_i   : in  std_logic; --! Bypass downlink scrambler (test purpose only)
			downlinkReady_o             : out std_logic; --! Downlink ready status

			-- Up link
		    uplinkData_o                : out std_logic_vector(233 downto 0);
            uplinkStrobe_o              : out std_logic;
            cdc_uplink_reset                : out std_logic;

			uplinkBypassInterleaver_i   : in  std_logic; --! Bypass uplink interleaver (test purpose only)
			uplinkBypassFECEncoder_i    : in  std_logic; --! Bypass uplink FEC (test purpose only)
			uplinkBypassScrambler_i     : in  std_logic; --! Bypass uplink scrambler (test purpose only)

			uplinkFECCorrectedClear_i   : in  std_logic; --! Uplink FEC corrected error clear (debugging)
			uplinkFECCorrectedLatched_o : out std_logic; --! Uplink FEC corrected error latched (debugging)

			-- MGT
			clk_mgtfreedrpclk_i         : in  std_logic; --! 100MHz Free-running clock
			clk_mgtTxClk_i              : in  std_logic;
			clk_mgtRxClk_i              : in  std_logic;
			mgt_slide_debug_o           : out std_logic;
			downlink_mgtword_o          : out std_logic_vector(31 downto 0);
			uplink_mgtword_i            : in  std_logic_vector(31 downto 0);
			
			--Debug
			rx_header_locked_o          : out std_logic
		);
	end component;

	-- GBT-SC IC Interface
	component ic_top
		generic(
			g_ToLpGBT    : integer range 0 to 1 := 0;
			g_FIFO_DEPTH : integer              := 20 --! Depth of the internal FIFO used to improve the timming performance
		);
		port(
			-- Clock and reset
			tx_clk_i            : in  std_logic; --! Tx clock (Tx_frameclk_o from GBT-FPGA IP): must be a multiple of the LHC frequency
			tx_clk_en           : in  std_logic; --! Tx clock enable signal must be used in case of multi-cycle path(tx_clk_i > LHC frequency). By default: always enabled

			rx_clk_i            : in  std_logic; --! Rx clock (Rx_frameclk_o from GBT-FPGA IP): must be a multiple of the LHC frequency
			rx_clk_en           : in  std_logic; --! Rx clock enable signal must be used in case of multi-cycle path(rx_clk_i > LHC frequency). By default: always enabled

			rx_reset_i          : in  std_logic; --! Reset RX datapath
			tx_reset_i          : in  std_logic; --! Reset TX datapath

			-- Configuration
			tx_GBTx_address_i   : in  std_logic_vector(7 downto 0); --! I2C address of the GBTx
			tx_register_addr_i  : in  std_logic_vector(15 downto 0); --! Address of the first register to be accessed
			tx_nb_to_be_read_i  : in  std_logic_vector(15 downto 0); --! Number of words/bytes to be read (only for read transactions)

			parity_err_mask_i   : in  std_logic_vector(7 downto 0);
			-- Internal FIFO
			wr_clk_i            : in  std_logic; --! Fifo's writing clock
			tx_wr_i             : in  std_logic; --! Request a write operation into the internal FIFO (Data to GBTx)
			tx_data_to_gbtx_i   : in  std_logic_vector(7 downto 0); --! Data to be written into the internal FIFO

			rd_clk_i            : in  std_logic;
			rx_rd_i             : in  std_logic; --! Request a read operation of the internal FIFO (GBTx reply)
			rx_data_from_gbtx_o : out std_logic_vector(7 downto 0); --! Data from the FIFO

			-- FSM Control
			tx_start_write_i    : in  std_logic; --! Request a write config. to the GBTx
			tx_start_read_i     : in  std_logic; --! Request a read config. to the GBTx

			-- Status
			tx_ready_o          : out std_logic; --! IC core ready for a transaction
			rx_empty_o          : out std_logic; --! Rx FIFO is empty (no reply from GBTx)

			-- IC lines
			tx_data_o           : out std_logic_vector(1 downto 0); --! (TX) Array of bits to be mapped to the TX GBT-Frame (bits 83/84)
			rx_data_i           : in  std_logic_vector(1 downto 0) --! (RX) Array of bits to be mapped to the RX GBT-Frame (bits 83/84)
		);
	end component;
	
	-- CDC-TX unit from TClink library
	COMPONENT cdc_tx is
		generic(
			g_CLOCK_A_RATIO : integer := 1; --! Ratio between strobe period and clock A period
			g_CLOCK_B_RATIO : integer := 8; --! Ratio between strobe period and clock B period (>=4)
			g_ACC_PHASE     : integer := 125*8; --! Phase accumulator number - only relevant for fixed phase operation
			g_PHASE_SIZE    : integer := 10 --! ceil(log2(g_ACC_PHASE))
		);
		port(
			-- Interface A (latch - from where data comes)
			reset_a_i     : in  std_logic; --! reset (only de-assert when all clocks and strobe A are stable)	
			clk_a_i       : in  std_logic; --! clock A
			data_a_i      : in  std_logic_vector; --! data A
			strobe_a_i    : in  std_logic; --! strobe A

			-- Interface B (capture - to where data goes)                                                 
			clk_b_i       : in  std_logic; --! clock B
			data_b_o      : out std_logic_vector; --! data B (connected to vector of same size as data_a_i)
			strobe_b_o    : out std_logic; --! strobe B
			ready_b_o     : out std_logic; --! ready B (CDC is operating)

			-- Only relevant for fixed-phase operation
			clk_freerun_i : in  std_logic; --! Free-running clock (125MHz)	
			phase_o       : out std_logic_vector(g_PHASE_SIZE - 1 downto 0); --! Phase to check fixed-phase
			phase_calib_i : in  std_logic_vector(g_PHASE_SIZE - 1 downto 0); --! Phase measured in first reset
			phase_force_i : in  std_logic --! Force the phase to be the calibrated one

		);
	end component cdc_tx;
	
	-- CDC-RX unit from TClink library
	COMPONENT cdc_rx is
		generic(
			g_CLOCK_A_RATIO : integer := 8; --! Frequency ratio between slow and fast frequencies (>4)
			g_PHASE_SIZE    : integer := 3 --! log2(g_CLOCK_A_RATIO)
		);
		port(
			-- Interface A (latch - from where data comes)
			reset_a_i     : in  std_logic; --! reset (only de-assert when all clocks and strobes are stable)		
			clk_a_i       : in  std_logic; --! clock A
			data_a_i      : in  std_logic_vector; --! data A
			strobe_a_i    : in  std_logic; --! strobe A

			-- Interface B (capture_a - to where data goes) 
			clk_b_i       : in  std_logic; --! clock B
			data_b_o      : out std_logic_vector; --! data B (connected to vector of same size as data_a_i)
			strobe_b_i    : in  std_logic; --! strobe B
			ready_b_o     : out std_logic; --! Inteface is ready 

			-- Only relevant for fixed-phase operation
			phase_o       : out std_logic_vector(g_PHASE_SIZE - 1 downto 0); --! Phase to check fixed-phase
			phase_calib_i : in  std_logic_vector(g_PHASE_SIZE - 1 downto 0); --! Phase measured in first reset
			phase_force_i : in  std_logic --! Force the phase to be the calibrated one

		);
	end component cdc_rx;
	
	COMPONENT xlx_ku_mgt_ip_reset_synchronizer is
		port(
			CLK_IN  : in  std_logic;
			RST_IN  : in  std_logic;
			RST_OUT : out std_logic
		);
	end component xlx_ku_mgt_ip_reset_synchronizer;

	component emp_lpgbt_ic_clerk_regs
		generic(
			AXI_ADDR_WIDTH : integer                       := 32 -- width of the AXI address bus
			--BASEADDR       : std_logic_vector(31 downto 0) := x"A0000000" -- the register file's system base address
		);
		port(
		    BASEADDR       : in std_logic_vector(31 downto 0); -- the register file's system base address
			-- Clock and Reset
			axi_aclk                  : in  std_logic;
			axi_aresetn               : in  std_logic;
			-- AXI Write Address Channel
			s_axi_awaddr              : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
			s_axi_awprot              : in  std_logic_vector(2 downto 0);
			s_axi_awvalid             : in  std_logic;
			s_axi_awready             : out std_logic;
			-- AXI Write Data Channel
			s_axi_wdata               : in  std_logic_vector(31 downto 0);
			s_axi_wstrb               : in  std_logic_vector(3 downto 0);
			s_axi_wvalid              : in  std_logic;
			s_axi_wready              : out std_logic;
			-- AXI Read Address Channel
			s_axi_araddr              : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
			s_axi_arprot              : in  std_logic_vector(2 downto 0);
			s_axi_arvalid             : in  std_logic;
			s_axi_arready             : out std_logic;
			-- AXI Read Data Channel
			s_axi_rdata               : out std_logic_vector(31 downto 0);
			s_axi_rresp               : out std_logic_vector(1 downto 0);
			s_axi_rvalid              : out std_logic;
			s_axi_rready              : in  std_logic;
			-- AXI Write Response Channel
			s_axi_bresp               : out std_logic_vector(1 downto 0);
			s_axi_bvalid              : out std_logic;
			s_axi_bready              : in  std_logic;
			-- User Ports          
			magic_strobe              : out std_logic; -- Strobe signal for register 'magic' (pulsed when the register is read from the bus)
			magic_value               : in  std_logic_vector(31 downto 0); -- Value of register 'magic', field 'value'
			control_strobe            : out std_logic; -- Strobe signal for register 'control' (pulsed when the register is written from the bus)
			control_fifoctrl          : out std_logic_vector(1 downto 0); -- Value of register 'control', field 'FIFOCtrl'
			control_lpgbtctrl         : out std_logic_vector(1 downto 0); -- Value of register 'control', field 'lpGBTCtrl'
			control_single_write_read : out std_logic_vector(0 downto 0); -- Value of register 'control', field 'single_write_read'
			control_nb_read           : out std_logic_vector(15 downto 0); -- Value of register 'control', field 'NB_read'
			status_strobe             : out std_logic; -- Strobe signal for register 'status' (pulsed when the register is read from the bus)
			status_ready_flag         : in  std_logic_vector(0 downto 0); -- Value of register 'status', field 'ready_flag'
			status_empty_flag         : in  std_logic_vector(0 downto 0); -- Value of register 'status', field 'empty_flag'
			status_parity_error       : in  std_logic_vector(0 downto 0); -- Value of register 'status', field 'parity_error'
			status_timeout_error      : in  std_logic_vector(0 downto 0); -- Value of register 'status', field 'timeout_error'
			data_rx_strobe            : out std_logic; -- Strobe signal for register 'data_rx' (pulsed when the register is read from the bus)
			data_rx_data              : in  std_logic_vector(7 downto 0); -- Value of register 'data_rx', field 'data'
			data_tx_strobe            : out std_logic; -- Strobe signal for register 'data_tx' (pulsed when the register is written from the bus)
			data_tx_data              : out std_logic_vector(7 downto 0); -- Value of register 'data_tx', field 'data'
			register_addr_strobe      : out std_logic; -- Strobe signal for register 'register_addr' (pulsed when the register is written from the bus)
			register_addr_addr        : out std_logic_vector(15 downto 0); -- Value of register 'register_addr', field 'addr'
			lpgbt_addr_strobe         : out std_logic; -- Strobe signal for register 'lpGBT_addr' (pulsed when the register is written from the bus)
			lpgbt_addr_addr           : out std_logic_vector(7 downto 0); -- Value of register 'lpGBT_addr', field 'addr'
			interrupt_enable_strobe   : out std_logic; -- Strobe signal for register 'interrupt_enable' (pulsed when the register is written from the bus)
			interrupt_enable_ic_resp  : out std_logic_vector(0 downto 0); -- Value of register 'interrupt_enable', field 'IC_resp'
			interrupt_flags_strobe    : out std_logic; -- Strobe signal for register 'interrupt_flags' (pulsed when the register is read from the bus)
			interrupt_flags_ic_resp   : in  std_logic_vector(0 downto 0); -- Value of register 'interrupt_flags', field 'IC_resp'
			interrupt_clear_strobe    : out std_logic; -- Strobe signal for register 'interrupt_clear' (pulsed when the register is written from the bus)
			interrupt_clear_ic_resp   : out std_logic_vector(0 downto 0); -- Value of register 'interrupt_clear', field 'IC_resp'
			reset_strobe              : out std_logic; -- Strobe signal for register 'reset' (pulsed when the register is written from the bus)
			reset_reset               : out std_logic_vector(0 downto 0); -- Value of register 'reset', field 'reset'
			counter_lhc_clock_strobe  : out std_logic; -- Strobe signal for register 'counter_lhc_clock' (pulsed when the register is written from the bus)
			counter_lhc_clock_value   : out std_logic_vector(31 downto 0) -- Value of register 'counter_lhc_clock', field 'value'
		);
	end component;

	-- ==================================== Signals declaration =============================================

	-- Clock signals
	signal lpgbtfpga_mgttxclk_s : std_logic;
	signal lpgbtfpga_mgtrxclk_s : std_logic;
	signal logicclk40           : std_logic;

	-- Reset
	signal reset_general               : std_logic;
	signal lpgbtfpga_downlinkrst_s     : std_logic;
	signal lpgbtfpga_downlinkrst_sync  : std_logic;
	signal lpgbtfpga_uplinkrst_s       : std_logic;
	signal lpgbtfpga_uplinkrst_cdc     : std_logic;
	
	--CDC ready & clk enable signals
	signal cdc_tx_ready        : std_logic;
	signal downlinkStrobe320   : std_logic;
	signal cdc_rx_ready        : std_logic;
	signal uplinkStrobe320     : std_logic;

	-- MGT
	signal downlink_mgtword_s    : std_logic_vector(31 downto 0);
	signal uplink_mgtword_s      : std_logic_vector(31 downto 0);
	signal lpgbtfpga_mgt_rxslide : std_logic;

	-- Downlink processed data
	signal lpgbtfpga_downlinkUserData_s : std_logic_vector(31 downto 0);
	signal lpgbtfpga_downlinkEcData_s   : std_logic_vector(1 downto 0);
	signal lpgbtfpga_downlinkIcData_s   : std_logic_vector(1 downto 0);
	signal lpgbtfpga_downlinkData_40    : std_logic_vector(35 downto 0);
	signal lpgbtfpga_downlinkData_320   : std_logic_vector(35 downto 0);
	
	-- Uplink processed data
	signal lpgbtfpga_uplinkData_40      : std_logic_vector(233 downto 0);
	signal lpgbtfpga_uplinkData_320     : std_logic_vector(233 downto 0);
	signal lpgbtfpga_uplinkUserData_s   : std_logic_vector(229 downto 0);
	signal lpgbtfpga_uplinkEcData_s     : std_logic_vector(1 downto 0);
	signal lpgbtfpga_uplinkIcData_s     : std_logic_vector(1 downto 0);
	signal uplinkReady_s                : std_logic;

	-- GBT-SC IC Control signals
	signal IC_tx_wr_s          : std_logic;
	signal IC_rx_rd_s          : std_logic;
	signal IC_tx_start_write_s : std_logic;
	signal IC_tx_start_read_s  : std_logic;

	-- IC channel FSM
	type fsm_state_ic_t is (idle, sending_command, waiting_resp, reading_FIFO, finish);
	signal fsm_state_ic             : fsm_state_ic_t        := idle;
	signal data_rx_data_FIFO        : std_logic_vector(7 downto 0);
	signal parity_check             : std_logic_vector(7 downto 0);
	signal control_nb_read_ic       : std_logic_vector(15 downto 0);
	signal FIFO_cnt                 : integer range 0 to 31 := 0;
	signal next_FIFO_byte_available : integer range 0 to 2  := 0;

	-- AirHDL signals:
	signal magic_strobe              : std_logic;
	signal magic_value               : std_logic_vector(31 downto 0);
	signal control_strobe            : std_logic;
	signal control_fifoctrl          : std_logic_vector(1 downto 0);
	signal control_lpgbtctrl         : std_logic_vector(1 downto 0);
	signal control_single_write_read : std_logic_vector(0 downto 0);
	signal control_nb_read           : std_logic_vector(15 downto 0);
	signal status_strobe             : std_logic;
	signal status_ready_flag         : std_logic_vector(0 downto 0);
	signal status_empty_flag         : std_logic_vector(0 downto 0);
	signal status_parity_error       : std_logic_vector(0 downto 0);
	signal status_timeout_error      : std_logic_vector(0 downto 0);
	signal data_rx_strobe            : std_logic;
	signal data_rx_data              : std_logic_vector(7 downto 0);
	signal data_tx_strobe            : std_logic;
	signal data_tx_data              : std_logic_vector(7 downto 0);
	signal register_addr_strobe      : std_logic;
	signal register_addr_addr        : std_logic_vector(15 downto 0);
	signal lpgbt_addr_strobe         : std_logic;
	signal lpgbt_addr_addr           : std_logic_vector(7 downto 0);
	signal interrupt_enable_strobe   : std_logic;
	signal interrupt_enable_ic_resp  : std_logic_vector(0 downto 0);
	signal interrupt_flags_strobe    : std_logic;
	signal interrupt_flags_ic_resp   : std_logic_vector(0 downto 0);
	signal interrupt_clear_strobe    : std_logic;
	signal interrupt_clear_ic_resp   : std_logic_vector(0 downto 0);
	signal reset_strobe              : std_logic;
	signal reset_reset               : std_logic_vector(0 downto 0);
	signal counter_lhc_clock_strobe  : std_logic;
	signal counter_lhc_clock_value   : std_logic_vector(31 downto 0);

begin
	-- Reset signal
	reset_general <= EXT_RST or not axi_aresetn or reset_reset(0);

	-- MGT signals
	lpgbtfpga_mgtrxclk_s <= MGT_RXUSRCLK_i;
	lpgbtfpga_mgttxclk_s <= MGT_TXUSRCLK_i;

	MGT_RXSlide_o <= lpgbtfpga_mgt_rxslide;

	MGT_USRWORD_o    <= downlink_mgtword_s;
	uplink_mgtword_s <= MGT_USRWORD_i;

	-- lpGBT data
	lpgbtfpga_uplinkUserData_o <= lpgbtfpga_uplinkUserData_s;
	lpgbtfpga_uplinkEcData_o   <= lpgbtfpga_uplinkEcData_s;
	lpgbtfpga_uplinkIcData_o   <= lpgbtfpga_uplinkIcData_s;

	lpgbtfpga_downlinkUserData_s <= lpgbtfpga_downlinkUserData_i;
	lpgbtfpga_downlinkEcData_s   <= "11"; 
	
	uplinkReady_o                <= uplinkReady_s;
	
	txrdy_sync : xlx_ku_mgt_ip_reset_synchronizer
		port map(
			CLK_IN  => lpgbtfpga_mgttxclk_s,
			RST_IN  => lpgbtfpga_downlinkrst_s,
			RST_OUT => lpgbtfpga_downlinkrst_sync
		);

    lpgbtfpga_downlinkData_40 <= lpgbtfpga_downlinkIcData_s & lpgbtfpga_downlinkEcData_s & lpgbtfpga_downlinkUserData_s;
    cdc_tx_inst : cdc_tx
		generic map(
			g_CLOCK_A_RATIO => 1,
			g_CLOCK_B_RATIO => 8,
			g_ACC_PHASE     => 125*8,
			g_PHASE_SIZE    => 10
		)
		port map(
			-- Interface A (latch - from where data comes)
			reset_a_i     => lpgbtfpga_downlinkrst_sync,
			clk_a_i       => logicclk40,
			data_a_i      => lpgbtfpga_downlinkData_40,
			strobe_a_i    => '1',
			-- Interface B (capture - to where data goes)                                                 
			clk_b_i       => lpgbtfpga_mgttxclk_s,
			data_b_o      => lpgbtfpga_downlinkData_320,
			strobe_b_o    => downlinkStrobe320,
			ready_b_o     => cdc_tx_ready,
			-- Only relevant for fixed-phase operation
			clk_freerun_i => axi_aclk,
			phase_o       => open,
			phase_calib_i => (others => '0'),
			phase_force_i => '0'
		);
	
	
	cdc_rx_inst : cdc_rx
		generic map(
			g_CLOCK_A_RATIO => 8,       --! Frequency ratio between slow and fast frequencies (>4)
			g_PHASE_SIZE    => 3        --! log2(g_CLOCK_A_RATIO)
		)
		port map(
			-- Interface A (latch - from where data comes)
			reset_a_i     => lpgbtfpga_uplinkrst_cdc,
			clk_a_i       => lpgbtfpga_mgtrxclk_s,
			data_a_i      => lpgbtfpga_uplinkData_320,
			strobe_a_i    => uplinkStrobe320,
			-- Interface B (capture_a - to where data goes) 
			clk_b_i       => logicclk40,
			data_b_o      => lpgbtfpga_uplinkData_40,
			strobe_b_i    => '1',
			ready_b_o     => cdc_rx_ready,
			-- Only relevant for fixed-phase operation
			phase_o       => open,
			phase_calib_i => (others => '0'),
			phase_force_i => '0'
		);
		
		lpgbtfpga_uplinkUserData_s <= lpgbtfpga_uplinkData_40(229 downto 0); --! Uplink data (user)
		lpgbtfpga_uplinkEcData_s   <= lpgbtfpga_uplinkData_40(231 downto 230); --! Uplink EC field
        lpgbtfpga_uplinkIcData_s   <= lpgbtfpga_uplinkData_40(233 downto 232); --! Uplink IC field
        uplinkReady_s              <= cdc_rx_ready;
        
	-- Register map
	reg_map : emp_lpgbt_ic_clerk_regs
		generic map(
			AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
			--BASEADDR       => BASEADDR
		)
		port map(
		    BASEADDR       => BASEADDR,
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
			magic_strobe              => magic_strobe,
			magic_value               => magic_value,
			control_strobe            => control_strobe,
			control_fifoctrl          => control_fifoctrl,
			control_lpgbtctrl         => control_lpgbtctrl,
			control_single_write_read => control_single_write_read,
			control_nb_read           => control_nb_read,
			status_strobe             => status_strobe,
			status_ready_flag         => status_ready_flag,
			status_empty_flag         => status_empty_flag,
			status_parity_error       => status_parity_error,
			status_timeout_error      => status_timeout_error,
			data_rx_strobe            => data_rx_strobe,
			data_rx_data              => data_rx_data,
			data_tx_strobe            => data_tx_strobe,
			data_tx_data              => data_tx_data,
			register_addr_strobe      => register_addr_strobe,
			register_addr_addr        => register_addr_addr,
			lpgbt_addr_strobe         => lpgbt_addr_strobe,
			lpgbt_addr_addr           => lpgbt_addr_addr,
			interrupt_enable_strobe   => interrupt_enable_strobe,
			interrupt_enable_ic_resp  => interrupt_enable_ic_resp,
			interrupt_flags_strobe    => interrupt_flags_strobe,
			interrupt_flags_ic_resp   => interrupt_flags_ic_resp,
			interrupt_clear_strobe    => interrupt_clear_strobe,
			interrupt_clear_ic_resp   => interrupt_clear_ic_resp,
			reset_strobe              => reset_strobe,
			reset_reset               => reset_reset,
			counter_lhc_clock_strobe  => counter_lhc_clock_strobe,
			counter_lhc_clock_value   => counter_lhc_clock_value
		);
	magic_value <= x"656D7049";
    
    -- Clocks  are now divided within own MMCM I
    logicclk40 <= logicCLK40_i;

	-- LpGBT FPGA
	lpgbtFpga_top_inst : lpgbtFpga_10g24
		generic map(
			FEC => FEC5
		)
		port map(
			-- Clocks
			downlinkClk_i               => lpgbtfpga_mgttxclk_s,
			uplinkClk_i                 => lpgbtfpga_mgtrxclk_s,
			downlinkRst_i               => lpgbtfpga_downlinkrst_s,
			uplinkRst_i                 => lpgbtfpga_uplinkrst_s,
			-- Down link
            downlinkData_i              => lpgbtfpga_downlinkData_320,
            downlinkStrobe_i            => downlinkStrobe320,
            cdc_downlink_ready          => cdc_tx_ready,
			downLinkBypassInterleaver_i => '0',
			downLinkBypassFECEncoder_i  => '0',
			downLinkBypassScrambler_i   => '0',
			downlinkReady_o             => status_emp_lpgbt_o(1), --Debug
			-- Up link
			uplinkData_o                => lpgbtfpga_uplinkData_320,         
            uplinkStrobe_o              => uplinkStrobe320,
            cdc_uplink_reset            => lpgbtfpga_uplinkrst_cdc,
			uplinkBypassInterleaver_i   => '0',
			uplinkBypassFECEncoder_i    => '0',
			uplinkBypassScrambler_i     => '0',
			uplinkFECCorrectedClear_i   => '0',
			uplinkFECCorrectedLatched_o => open,
			-- Clocks
			clk_mgtfreedrpclk_i         => axi_aclk,
			clk_mgtTxClk_i              => lpgbtfpga_mgttxclk_s,
			clk_mgtRxClk_i              => lpgbtfpga_mgtrxclk_s,
			-- MGT signals
			mgt_slide_debug_o           => lpgbtfpga_mgt_rxslide,
			downlink_mgtword_o          => downlink_mgtword_s,
			uplink_mgtword_i            => uplink_mgtword_s,
			--Debug
			rx_header_locked_o          => status_emp_lpgbt_o(0)
		);

	lpgbtfpga_downlinkrst_s <= reset_general;
	lpgbtfpga_uplinkrst_s   <= reset_general;

	-- IC Module
	ic_top_inst : ic_top
		generic map(
			g_ToLpGBT    => 1,
			g_FIFO_DEPTH => 10
		)
		port map(
			-- Clock and reset
			tx_clk_i            => logicclk40, --! Tx clock (Tx_frameclk_o from GBT-FPGA IP): must be a multiple of the LHC frequency
			tx_clk_en           => '1', --! Tx clock enable signal must be used in case of multi-cycle path(tx_clk_i > LHC frequency). By default: always enabled

			rx_clk_i            => logicclk40, --! Rx clock (Rx_frameclk_o from GBT-FPGA IP): must be a multiple of the LHC frequency
			rx_clk_en           => '1', --! Rx clock enable signal must be used in case of multi-cycle path(rx_clk_i > LHC frequency). By default: always enabled

			rx_reset_i          => lpgbtfpga_uplinkrst_s, --! Reset RX datapath
			tx_reset_i          => lpgbtfpga_downlinkrst_s, --! Reset TX datapath

			-- Configuration
			tx_GBTx_address_i   => lpgbt_addr_addr, --! I2C address of the GBTx
			tx_register_addr_i  => register_addr_addr, --! Address of the first register to be accessed
			tx_nb_to_be_read_i  => control_nb_read_ic, --! Number of words/bytes to be read (only for read transactions)

			parity_err_mask_i   => (others => '0'),
			-- Internal FIFO
			wr_clk_i            => axi_aclk, --! Fifo's writing clock
			tx_wr_i             => IC_tx_wr_s, --! Request a write operation into the internal FIFO (Data to GBTx)
			tx_data_to_gbtx_i   => data_tx_data, --! Data to be written into the internal FIFO

			rd_clk_i            => axi_aclk,
			rx_rd_i             => IC_rx_rd_s, --! Request a read operation of the internal FIFO (GBTx reply)
			rx_data_from_gbtx_o => data_rx_data_FIFO, --! Data from the FIFO

			-- FSM Control
			tx_start_write_i    => IC_tx_start_write_s, --! Request a write config. to the GBTx
			tx_start_read_i     => IC_tx_start_read_s, --! Request a read config. to the GBTx

			-- Status
			tx_ready_o          => status_ready_flag(0), --! IC core ready for a transaction
			rx_empty_o          => status_empty_flag(0), --! Rx FIFO is empty (no reply from GBTx)

			-- IC lines
			tx_data_o           => lpgbtfpga_downlinkIcData_s, --! (TX) Array of bits to be mapped to the TX GBT-Frame (bits 83/84)
			rx_data_i           => lpgbtfpga_uplinkIcData_s --! (RX) Array of bits to be mapped to the RX GBT-Frame (bits 83/84)
		);

	-- IC FSM
	ic_fsm : process(axi_aclk)
		variable lpgbt_resp_timeout : integer range 0 to 100000000 := 100000000; -- 1 second timeout watchdog
		variable IC_empty_flag_old  : std_logic                    := '0';
	begin
		if rising_edge(axi_aclk) then

			if reset_general = '1' then
				fsm_state_ic               <= idle;
				interrupt_flags_ic_resp(0) <= '0';
				IC_rx_rd_s                 <= '0';
				IC_tx_wr_s                 <= '0';
				IC_tx_start_read_s         <= '0';
				IC_tx_start_write_s        <= '0';
				data_rx_data               <= (others => '0');
				control_nb_read_ic         <= (others => '0');
				status_timeout_error(0)    <= '0';
				status_parity_error(0)     <= '0';
				lpgbt_resp_timeout := 100000000;
				IC_empty_flag_old := '0';
				parity_check             <= x"00";
				next_FIFO_byte_available <= 0;
				FIFO_cnt                 <= 0;

			elsif control_single_write_read(0) = '1' then -- Only for single read/write. Byte read written automatically and parity bit checked
				case fsm_state_ic is

					when idle =>
						if (control_fifoctrl(1) = '1' or control_lpgbtctrl(1) = '1') and control_strobe = '1' then -- Write the byte and wait for lpgbt response
							-- Clear previous errors
							status_timeout_error(0) <= '0';
							status_parity_error(0)  <= '0';
							if status_ready_flag(0) = '1' then
								IC_tx_wr_s   <= '1'; -- write to FIFO
								fsm_state_ic <= sending_command;
							end if;

						elsif (control_fifoctrl(0) = '1' or control_lpgbtctrl(0) = '1') and control_strobe = '1' then -- Read request to lpgbt
							-- Clear previous errors
							status_timeout_error(0) <= '0';
							status_parity_error(0)  <= '0';
							if status_ready_flag(0) = '1' then
								IC_tx_start_read_s <= '1'; -- read command to lpgbt
								control_nb_read_ic <= x"0001"; --only one byte allowed
								lpgbt_resp_timeout := 100000000;
								fsm_state_ic       <= waiting_resp;
							end if;
						end if;

					when sending_command =>
						IC_tx_wr_s          <= '0';
						IC_tx_start_write_s <= '1'; --send data to lpgbt
						lpgbt_resp_timeout  := 100000000;
						fsm_state_ic        <= waiting_resp;

					when waiting_resp =>
						IC_tx_start_write_s <= '0';
						IC_tx_start_read_s  <= '0';
						lpgbt_resp_timeout  := lpgbt_resp_timeout - 1;
						if status_empty_flag(0) = '0' and (data_rx_data_FIFO = x"E0" or data_rx_data_FIFO = x"E1") then -- start reading FIFO
							IC_rx_rd_s               <= '1'; --start pulling from FIFO
							FIFO_cnt                 <= 0;
							next_FIFO_byte_available <= 0;
							parity_check             <= x"00";
							lpgbt_resp_timeout       := 100000000;
							fsm_state_ic             <= reading_FIFO;
						elsif lpgbt_resp_timeout = 0 then -- waiting during 1 second, rise error flag
							status_timeout_error(0) <= '1';
							fsm_state_ic            <= finish;
						end if;

					when reading_FIFO => -- reading all the bytes on the fifo

						lpgbt_resp_timeout := lpgbt_resp_timeout - 1;
						IC_rx_rd_s         <= '0'; -- wait until next byte is available

						if status_empty_flag(0) = '1' then -- need to wait until empy flag goes '1' again, before reading next byte					
							next_FIFO_byte_available <= 1;
						elsif next_FIFO_byte_available = 1 then -- wait extra clock cycle for timing issues
							next_FIFO_byte_available <= 2;
						elsif next_FIFO_byte_available = 2 then
							IC_rx_rd_s   <= '1';
							parity_check <= parity_check xor data_rx_data_FIFO; --save the parity calc

							if FIFO_cnt = 2 then -- number of bytes received should be 1 (0:7)
								if data_rx_data_FIFO = x"1" then
									fsm_state_ic <= finish;
								end if;
							elsif FIFO_cnt = 3 then -- number of bytes received should be 1 (8:15)
								if data_rx_data_FIFO = x"0" then
									fsm_state_ic <= finish;
								end if;
							elsif FIFO_cnt = 6 then -- get the data
								data_rx_data <= data_rx_data_FIFO;
							elsif FIFO_cnt = 7 then -- check parity byte
								if parity_check = data_rx_data_FIFO then
									interrupt_flags_ic_resp(0) <= '1'; -- trigger interrupt
								else
									status_parity_error(0) <= '1';
								end if;
								fsm_state_ic <= finish;
							end if;
							next_FIFO_byte_available <= 0;
							FIFO_cnt <= FIFO_cnt + 1;

						elsif lpgbt_resp_timeout = 0 then -- waiting during 1 second, rise error flag
							status_timeout_error(0) <= '1';
							fsm_state_ic            <= finish;
						end if;

					when finish =>
						IC_rx_rd_s   <= '0';
						fsm_state_ic <= idle;

				end case;

			else                        -- Multiple read/writes. PS manages FIFO and parity bit
				IC_rx_rd_s          <= control_fifoctrl(0) and control_strobe;
				IC_tx_wr_s          <= control_fifoctrl(1) and control_strobe;
				IC_tx_start_read_s  <= control_lpgbtctrl(0) and control_strobe;
				IC_tx_start_write_s <= control_lpgbtctrl(1) and control_strobe;
				data_rx_data        <= data_rx_data_FIFO;
				control_nb_read_ic  <= control_nb_read;

				-- Trigger interrupt when receiving something
				if status_empty_flag(0) = '0' and IC_empty_flag_old = '1' then -- Falling edge generates interrupt
					interrupt_flags_ic_resp(0) <= '1';
				end if;

				IC_empty_flag_old := status_empty_flag(0);
			end if;

			-- Interrupt clear
			if interrupt_clear_ic_resp(0) = '1' then -- Clear the interrupt pulse next clock cycle
				interrupt_flags_ic_resp(0) <= '0';
			end if;

		end if;
	end process;

	int_lpgbt_resp <= interrupt_flags_ic_resp(0) and interrupt_enable_ic_resp(0); -- Interrupt signal

end behavioral;