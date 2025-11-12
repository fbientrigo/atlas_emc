-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief LpGBT-FPGA Top
-------------------------------------------------------

--! Include the IEEE VHDL standard library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.matrix_pkg.all;

--! Include the LpGBT-FPGA specific package
use work.lpgbtfpga_package.all;

--! Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

entity lpgbtFpga_10g24 is
	GENERIC(
		FEC : integer range 0 to 2      --! FEC selection can be: FEC5 or FEC12
	);
	PORT(
		-- Clocks
		downlinkClk_i               : in  std_logic; --! 40MHz user clock
		uplinkClk_i                 : in  std_logic; --! 40MHz user clock

		downlinkRst_i               : in  std_logic; --! Reset the downlink path
		uplinkRst_i                 : in  std_logic; --! Reset the uplink path

		-- Down link
		downlinkData_i              : in  std_logic_vector(35 downto 0); --! Downlink data (user)
        downlinkStrobe_i            : in  std_logic;
        cdc_downlink_ready          : in  std_logic;
		
		downLinkBypassInterleaver_i : in  std_logic; --! Bypass downlink interleaver (test purpose only)
		downLinkBypassFECEncoder_i  : in  std_logic; --! Bypass downlink FEC (test purpose only)
		downLinkBypassScrambler_i   : in  std_logic; --! Bypass downlink scrambler (test purpose only)
		downlinkReady_o             : out std_logic; --! Downlink ready status

		-- Up link
		uplinkData_o                : out std_logic_vector(233 downto 0);
        uplinkStrobe_o              : out std_logic;
        cdc_uplink_reset            : out std_logic;

		uplinkBypassInterleaver_i   : in  std_logic; --! Bypass uplink interleaver (test purpose only)
		uplinkBypassFECEncoder_i    : in  std_logic; --! Bypass uplink FEC (test purpose only)
		uplinkBypassScrambler_i     : in  std_logic; --! Bypass uplink scrambler (test purpose only)

		uplinkFECCorrectedClear_i   : in  std_logic; --! Uplink FEC corrected error clear (debugging)
		uplinkFECCorrectedLatched_o : out std_logic; --! Uplink FEC corrected error latched (debugging)

		-- MGT
		clk_mgtfreedrpclk_i         : in  std_logic; --! 125MHz Free-running clock
		clk_mgtTxClk_i              : in  std_logic;
		clk_mgtRxClk_i              : in  std_logic;
		mgt_slide_debug_o           : out std_logic;
        --MGT Dataword
		downlink_mgtword_o          : out  std_logic_vector(31 downto 0);
		uplink_mgtword_i            : in  std_logic_vector(31 downto 0);
		
		--Debug 
		rx_header_locked_o             : out std_logic
	);
end lpgbtFpga_10g24;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture behavioral of lpgbtFpga_10g24 is

	COMPONENT lpgbtfpga_downlink
		GENERIC(
			-- Expert parameters
			c_multicyleDelay : integer range 0 to 7 := 3; --! Multicycle delay
			c_clockRatio     : integer              := 8; --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
			c_outputWidth    : integer  --! Transceiver's word size
		);
		port(
			-- Clocks
			clk_i               : in  std_logic; --! Downlink datapath clock (either 320 or 40MHz)
			clkEn_i             : in  std_logic; --! Clock enable (1 over 8 when encoding runs @ 320Mhz, '1' @ 40MHz)
			rst_n_i             : in  std_logic; --! Downlink reset signal (Tx ready from the transceiver)

			-- Down link
			userData_i          : in  std_logic_vector(31 downto 0); --! Downlink data (user)
			ECData_i            : in  std_logic_vector(1 downto 0); --! Downlink EC field
			ICData_i            : in  std_logic_vector(1 downto 0); --! Downlink IC field

			-- Output
			mgt_word_o          : out std_logic_vector((c_outputWidth - 1) downto 0); --! Downlink encoded frame (IC + EC + User Data + FEC)

			-- Configuration
			interleaverBypass_i : in  std_logic; --! Bypass downlink interleaver (test purpose only)
			encoderBypass_i     : in  std_logic; --! Bypass downlink FEC (test purpose only)
			scramblerBypass_i   : in  std_logic; --! Bypass downlink scrambler (test purpose only)

			-- Status
			rdy_o               : out std_logic --! Downlink ready status
		);
	END COMPONENT;

	COMPONENT lpgbtfpga_uplink
		GENERIC(
			-- General configuration
			DATARATE                  : integer range 0 to 2 := DATARATE_10G24; --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
			FEC                       : integer range 0 to 2 := FEC5; --! FEC selection can be: FEC5 or FEC12

			-- Expert parameters
			c_multicyleDelay          : integer range 0 to 7 := 3; --! Multicycle delay
			c_clockRatio              : integer; --! Clock ratio is mgt_userclk / 40 (shall be an integer)
			c_mgtWordWidth            : integer; --! Bus size of the input word
			c_allowedFalseHeader      : integer; --! Number of false header allowed to avoid unlock on frame error
			c_allowedFalseHeaderOverN : integer; --! Number of header checked to know wether the lock is lost or not
			c_requiredTrueHeader      : integer; --! Number of true header required to go in locked state
			c_bitslip_mindly          : integer              := 1; --! Number of clock cycle required when asserting the bitslip signal
			c_bitslip_waitdly         : integer              := 40 --! Number of clock cycle required before being back in a stable state
		);
		PORT(
			-- Clock and reset
			uplinkClk_i         : in  std_logic; --! Input clock (Rx user clock from transceiver)
			uplinkClkOutEn_o    : out std_logic; --! Clock enable to be used in the user's logic
			uplinkRst_n_i       : in  std_logic; --! Uplink reset signal (Rx ready from the transceiver)

			-- Input
			mgt_word_i          : in  std_logic_vector((c_mgtWordWidth - 1) downto 0); --! Input frame coming from the MGT

			-- Data
			userData_o          : out std_logic_vector(229 downto 0); --! User output (decoded data). The payload size varies depending on the
			EcData_o            : out std_logic_vector(1 downto 0); --! EC field value received from the LpGBT
			IcData_o            : out std_logic_vector(1 downto 0); --! IC field value received from the LpGBT

			-- Control
			bypassInterleaver_i : in  std_logic; --! Bypass uplink interleaver (test purpose only)
			bypassFECEncoder_i  : in  std_logic; --! Bypass uplink FEC (test purpose only)
			bypassScrambler_i   : in  std_logic; --! Bypass uplink scrambler (test purpose only)

			-- Transceiver control
			mgt_bitslipCtrl_o   : out std_logic; --! Control the Bitslib/RxSlide port of the Mgt

			-- Status
			dataCorrected_o     : out std_logic_vector(229 downto 0); --! Flag allowing to know which bit(s) were toggled by the FEC
			IcCorrected_o       : out std_logic_vector(1 downto 0); --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
			EcCorrected_o       : out std_logic_vector(1 downto 0); --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
			rdy_o               : out std_logic; --! Ready signal from the uplink decoder
			frameAlignerEven_o  : out std_logic; --! Number of bit slip is even (required only for advanced applications)
            header_locked_o     : out std_logic --! Debug DE
		);
	END COMPONENT;

	-- User CDC Tx    
	signal downlinkData320     : std_logic_vector(35 downto 0);

	-- User CDC Rx    
	signal uplinkData320   : std_logic_vector(233 downto 0);
	signal uplinkStrobe320 : std_logic;

	-- MGT
	signal uplinkReady_s      : std_logic;
	signal downlink_mgtword_s : std_logic_vector(31 downto 0);
	signal uplink_mgtword_s   : std_logic_vector(31 downto 0);
	signal mgt_rxslide_s      : std_logic;

    -- Clocks
	signal clk_mgtTxClk_s     : std_logic;
	signal clk_mgtRxClk_s     : std_logic;

	-- FEC latch flag
	signal uplinkdataCorrected : std_logic_vector(229 downto 0);
	signal uplinkIcCorrected   : std_logic_vector(1 downto 0);
	signal uplinkEcCorrected   : std_logic_vector(1 downto 0);

begin                                   --========####   Architecture Body   ####========--

	--========####   Downlink datapath   ####========--
    downlinkData320 <= downlinkData_i;
	downlink_inst : lpgbtfpga_downlink
		GENERIC MAP(
			-- Expert parameters
			c_multicyleDelay => 3,
			c_clockRatio     => 8,
			c_outputWidth    => 32
		)
		PORT MAP(
			-- Clocks
			clk_i               => clk_mgtTxClk_s,
			clkEn_i             => downlinkStrobe_i,
			rst_n_i             => cdc_downlink_ready,
			-- Down link
			userData_i          => downlinkData320(31 downto 0),
			ECData_i            => downlinkData320(33 downto 32),
			ICData_i            => downlinkData320(35 downto 34),
			-- Output
			mgt_word_o          => downlink_mgtword_s,
			-- Configuration
			interleaverBypass_i => downLinkBypassInterleaver_i,
			encoderBypass_i     => downLinkBypassFECEncoder_i,
			scramblerBypass_i   => downLinkBypassScrambler_i,
			-- Status
			rdy_o               => downlinkReady_o
		);

	--========####   Uplink datapath   ####========--
	cdc_uplink_reset <= not uplinkReady_s;
	uplink_inst : lpgbtfpga_uplink
		GENERIC MAP(
			-- General configuration
			DATARATE                  => DATARATE_10G24,
			FEC                       => FEC,
			-- Expert parameters
			c_multicyleDelay          => 3,
			c_clockRatio              => 8,
			c_mgtWordWidth            => 32,
			c_allowedFalseHeader      => 5,
			c_allowedFalseHeaderOverN => 64,
			c_requiredTrueHeader      => 30,
			c_bitslip_mindly          => 1,
			c_bitslip_waitdly         => 40
		)
		PORT MAP(
			-- Clock and reset
			uplinkClk_i         => clk_mgtRxClk_s,
			uplinkClkOutEn_o    => uplinkStrobe320,
			uplinkRst_n_i       => uplinkRst_i, --DE MOD
			-- Input
			mgt_word_i          => uplink_mgtword_s,
			-- Data
			userData_o          => uplinkData320(229 downto 0),
			EcData_o            => uplinkData320(231 downto 230),
			IcData_o            => uplinkData320(233 downto 232),
			-- Control
			bypassInterleaver_i => uplinkBypassInterleaver_i,
			bypassFECEncoder_i  => uplinkBypassFECEncoder_i,
			bypassScrambler_i   => uplinkBypassScrambler_i,
			-- Transceiver control
			mgt_bitslipCtrl_o   => mgt_rxslide_s,
			-- Status
			dataCorrected_o     => uplinkdataCorrected,
			IcCorrected_o       => uplinkIcCorrected,
			EcCorrected_o       => uplinkEcCorrected,
			rdy_o               => uplinkReady_s,
			frameAlignerEven_o  => open,
			header_locked_o     => rx_header_locked_o
		);
		uplinkData_o      <= uplinkData320;
        uplinkStrobe_o    <= uplinkStrobe320;
        
	--! FEC Corrected Flag for debugging
	upLinkFECCorrected : process(clk_mgtRxClk_s)
	begin
		if rising_edge(clk_mgtRxClk_s) then
			if uplinkFECCorrectedClear_i = '1' then
				uplinkFECCorrectedLatched_o <= '0';
			else
				if ((unsigned(uplinkDataCorrected) /= 0) or (unsigned(uplinkIcCorrected) /= 0) or (unsigned(uplinkEcCorrected) /= 0)) then
					uplinkFECCorrectedLatched_o <= '1';
				end if;
			end if;
		end if;
	end process;


	clk_mgtTxClk_s <= clk_mgtTxClk_i;
	clk_mgtRxClk_s <= clk_mgtRxClk_i;
	
	downlink_mgtword_o <= downlink_mgtword_s;
	uplink_mgtword_s <= uplink_mgtword_i;

	mgt_slide_debug_o <= mgt_rxslide_s;

end behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--