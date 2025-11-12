----------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: Dominic Ecker <dominic.ecker@cern.ch> (CERN)
-- 
-- Create Date: 12/22/2020 04:19:00 PM
-- Design Name: 
-- Module Name: transceivers - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity emp_generic_mgt is

	Generic(
	    -----------
	    g_COM_SEL                 : integer := 0;
	    -----------
		g_MGT_FF_TX_POLARITY_inv  : std_logic_vector(11 downto 0) := "000000000000";
		g_MGT_FF_RX_POLARITY_inv  : std_logic_vector(11 downto 0) := "111111111111";
		g_MGT_SFP_TX_POLARITY_inv : std_logic_vector(0 downto 0) := "0";
		g_MGT_SFP_RX_POLARITY_inv : std_logic_vector(0 downto 0) := "1";
		g_CH0_ENABLE              : boolean := true;
		g_CH1_ENABLE              : boolean := true;
		g_CH2_ENABLE              : boolean := true;
		g_CH3_ENABLE              : boolean := true;
		g_CH4_ENABLE              : boolean := true;
		g_CH5_ENABLE              : boolean := true;
		g_CH6_ENABLE              : boolean := true;
		g_CH7_ENABLE              : boolean := true;
		g_CH8_ENABLE              : boolean := true;
		g_CH9_ENABLE              : boolean := true;
		g_CH10_ENABLE             : boolean := true;
		g_CH11_ENABLE             : boolean := true;
		g_CH12_ENABLE             : boolean := true;
		g_RESET_QUAD_0            : integer := 0;
		g_RESET_QUAD_1            : integer := 4;
		g_RESET_QUAD_2            : integer := 8
		
	);
	Port(   
	    -- Clocks                            
		MGT_REFCLK_FF_P           : in  std_logic;
		MGT_REFCLK_FF_N           : in  std_logic;
		MGT_REFCLK_SFP_P          : in  std_logic;
		MGT_REFCLK_SFP_N          : in  std_logic;
		MGT_FREEDRPCLK_i          : in  std_logic;
		MGT_REFCLK_FF_320_o       : out std_logic;
		MGT_REFCLK_FF_40_o        : out std_logic;
		MGT_REFCLK_SFP_320_o      : out std_logic;
		MGT_REFCLK_SFP_40_o       : out std_logic;  
		
		-- Channel 0
		CH0_MGT_RXUSRCLK_o     : out std_logic;
		CH0_MGT_RXSlide_i      : in  std_logic;
		CH0_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH0_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH0_RXn_i              : in  std_logic;
		CH0_RXp_i              : in  std_logic;
		CH0_TXn_o              : out std_logic;
		CH0_TXp_o              : out std_logic;
		-- Channel 1
		CH1_MGT_RXUSRCLK_o     : out std_logic;
		CH1_MGT_RXSlide_i      : in  std_logic;
		CH1_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH1_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH1_RXn_i              : in  std_logic;
		CH1_RXp_i              : in  std_logic;
		CH1_TXn_o              : out std_logic;
		CH1_TXp_o              : out std_logic;
		-- Channel 2
		CH2_MGT_RXUSRCLK_o     : out std_logic;
		CH2_MGT_RXSlide_i      : in  std_logic;
		CH2_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH2_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH2_RXn_i              : in  std_logic;
		CH2_RXp_i              : in  std_logic;
		CH2_TXn_o              : out std_logic;
		CH2_TXp_o              : out std_logic;
		-- Channel 3
		CH3_MGT_RXUSRCLK_o     : out std_logic;
		CH3_MGT_RXSlide_i      : in  std_logic;
		CH3_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH3_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH3_RXn_i              : in  std_logic;
		CH3_RXp_i              : in  std_logic;
		CH3_TXn_o              : out std_logic;
		CH3_TXp_o              : out std_logic;
		-- Channel 4
		CH4_MGT_RXUSRCLK_o     : out std_logic;
		CH4_MGT_RXSlide_i      : in  std_logic;
		CH4_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH4_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH4_RXn_i              : in  std_logic;
		CH4_RXp_i              : in  std_logic;
		CH4_TXn_o              : out std_logic;
		CH4_TXp_o              : out std_logic;
		-- Channel 5
		CH5_MGT_RXUSRCLK_o     : out std_logic;
		CH5_MGT_RXSlide_i      : in  std_logic;
		CH5_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH5_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH5_RXn_i              : in  std_logic;
		CH5_RXp_i              : in  std_logic;
		CH5_TXn_o              : out std_logic;
		CH5_TXp_o              : out std_logic;
		-- Channel 6
		CH6_MGT_RXUSRCLK_o     : out std_logic;
		CH6_MGT_RXSlide_i      : in  std_logic;
		CH6_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH6_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH6_RXn_i              : in  std_logic;
		CH6_RXp_i              : in  std_logic;
		CH6_TXn_o              : out std_logic;
		CH6_TXp_o              : out std_logic;
		-- Channel 7
		CH7_MGT_RXUSRCLK_o     : out std_logic;
		CH7_MGT_RXSlide_i      : in  std_logic;
		CH7_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH7_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH7_RXn_i              : in  std_logic;
		CH7_RXp_i              : in  std_logic;
		CH7_TXn_o              : out std_logic;
		CH7_TXp_o              : out std_logic;
		-- Channel 8
		CH8_MGT_RXUSRCLK_o     : out std_logic;
		CH8_MGT_RXSlide_i      : in  std_logic;
		CH8_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH8_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH8_RXn_i              : in  std_logic;
		CH8_RXp_i              : in  std_logic;
		CH8_TXn_o              : out std_logic;
		CH8_TXp_o              : out std_logic;
		-- Channel 9
		CH9_MGT_RXUSRCLK_o     : out std_logic;
		CH9_MGT_RXSlide_i      : in  std_logic;
		CH9_MGT_USRWORD_i      : in  std_logic_vector(31 downto 0);
		CH9_MGT_USRWORD_o      : out std_logic_vector(31 downto 0);
		CH9_RXn_i              : in  std_logic;
		CH9_RXp_i              : in  std_logic;
		CH9_TXn_o              : out std_logic;
		CH9_TXp_o              : out std_logic;
		-- Channel 10
		CH10_MGT_RXUSRCLK_o    : out std_logic;
		CH10_MGT_RXSlide_i     : in  std_logic;
		CH10_MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
		CH10_MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
		CH10_RXn_i             : in  std_logic;
		CH10_RXp_i             : in  std_logic;
		CH10_TXn_o             : out std_logic;
		CH10_TXp_o             : out std_logic;
		-- Channel 11
		CH11_MGT_RXUSRCLK_o    : out std_logic;
		CH11_MGT_RXSlide_i     : in  std_logic;
		CH11_MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
		CH11_MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
		CH11_RXn_i             : in  std_logic;
		CH11_RXp_i             : in  std_logic;
		CH11_TXn_o             : out std_logic;
		CH11_TXp_o             : out std_logic;
		-- Channel 12
		CH12_MGT_RXUSRCLK_o    : out std_logic;
		CH12_MGT_RXSlide_i     : in  std_logic;
		CH12_MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
		CH12_MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
		CH12_RXn_i             : in  std_logic;
		CH12_RXp_i             : in  std_logic;
		CH12_TXn_o             : out std_logic;
		CH12_TXp_o             : out std_logic;
		
	-- Firefly
		-- TX aligned signal
		MGT_TX_ALIGNED_FF_o   : out std_logic_vector(11 downto 0);
		-- TX/RX Ready signals
		MGT_TXREADY_FF_o      : out std_logic_vector(11 downto 0);
		MGT_RXREADY_FF_o      : out std_logic_vector(11 downto 0);
		-- TX/RX Reset signals
		MGT_TXRESET_FF_i      : in std_logic_vector(11 downto 0);
		MGT_RXRESET_FF_i      : in std_logic_vector(11 downto 0);
		
	-- SFP+
	    -- TX aligned signal
		MGT_TX_ALIGNED_SFP_o   : out std_logic;
		-- TX/RX Ready signals
		MGT_TXREADY_SFP_o      : out std_logic;
		MGT_RXREADY_SFP_o      : out std_logic;
		-- TX/RX Reset signals
		MGT_TXRESET_SFP_i      : in std_logic;
		MGT_RXRESET_SFP_i      : in std_logic
		
	);
end emp_generic_mgt;

architecture Behavioral of emp_generic_mgt is
   
	component all_mgt is
		Generic(
		    COM_SEL             : integer;
			CH0_EN              : boolean;
            CH1_EN              : boolean; 
            CH2_EN              : boolean; 
            CH3_EN              : boolean;
            CH4_EN              : boolean;
            CH5_EN              : boolean;
            CH6_EN              : boolean;
            CH7_EN              : boolean;
            CH8_EN              : boolean;
            CH9_EN              : boolean;
            CH10_EN             : boolean;
            CH11_EN             : boolean;
            CH12_EN             : boolean;
            RESET_QUAD_0        : integer;
		    RESET_QUAD_1        : integer;
		    RESET_QUAD_2        : integer
		);
		Port(
			--=============--
			-- Clocks      --
			--=============--
			MGT_REFCLK_FF_P         : in  std_logic;
			MGT_REFCLK_FF_N         : in  std_logic;
			MGT_REFCLK_SFP_P        : in  std_logic;
			MGT_REFCLK_SFP_N        : in  std_logic;
			MGT_FREEDRPCLK_i        : in  std_logic;
			MGT_REFCLK_FF_320_o     : out std_logic;
		    MGT_REFCLK_FF_40_o      : out std_logic; 
		    MGT_REFCLK_SFP_320_o    : out std_logic;
		    MGT_REFCLK_SFP_40_o     : out std_logic;  
			MGT_RXUSRCLK_o          : out std_logic_vector(12 downto 0);
			--=============--
			-- Control     --
			--=============--
			MGT_FF_TXPolarity_i     : in  std_logic_vector(11 downto 0);
			MGT_FF_RXPolarity_i     : in  std_logic_vector(11 downto 0);
			MGT_SFP_TXPolarity_i    : in  std_logic_vector(0 downto 0);
			MGT_SFP_RXPolarity_i    : in  std_logic_vector(0 downto 0);
			MGT_RXSlide_i           : in  std_logic_vector(12 downto 0);
			MGT_ENTXCALIBIN_i       : in  std_logic_vector(12 downto 0);
			
			--=============--
			-- Status      --
			--=============--
			MGT_TXREADY_FF_o     : out std_logic_vector(11 downto 0);
			MGT_RXREADY_FF_o     : out std_logic_vector(11 downto 0);
			MGT_TX_ALIGNED_FF_o  : out std_logic_vector(11 downto 0);
			MGT_TXREADY_SFP_o    : out std_logic;
			MGT_RXREADY_SFP_o    : out std_logic;
			MGT_TX_ALIGNED_SFP_o : out std_logic;
			--=============--
			-- Resets      --
			--=============--
			MGT_TXRESET_FF_i     : in  std_logic_vector(11 downto 0);
			MGT_RXRESET_FF_i     : in  std_logic_vector(11 downto 0);
			MGT_TXRESET_SFP_i    : in  std_logic;
			MGT_RXRESET_SFP_i    : in  std_logic;
			--==============--
			-- Data         --
			--==============--
						
			MGT_USRWORD_CH0_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH1_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH2_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH3_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH4_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH5_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH6_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH7_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH8_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH9_i  : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH10_i : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH11_i : in std_logic_vector(31 downto 0);
			MGT_USRWORD_CH12_i : in std_logic_vector(31 downto 0);
			
			MGT_USRWORD_CH0_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH1_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH2_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH3_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH4_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH5_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH6_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH7_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH8_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH9_o  : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH10_o : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH11_o : out std_logic_vector(31 downto 0);
			MGT_USRWORD_CH12_o : out std_logic_vector(31 downto 0);
			
			--===============--
			-- Serial intf.  --
			--===============--
			RXn_i             : in  std_logic_vector(12 downto 0);
			RXp_i             : in  std_logic_vector(12 downto 0);
			TXn_o             : out std_logic_vector(12 downto 0);
			TXp_o             : out std_logic_vector(12 downto 0)
		);
		
	end component;
    constant c_MASTER_NUMBER_CHANNELS    : integer := 13;
    signal refclk_FF_40_o                : std_logic;
    signal refclk_FF_320_o               : std_logic;
    signal refclk_SFP_40_o               : std_logic;
    signal refclk_SFP_320_o              : std_logic;
	signal lpgbtfpga_mgtrxclk_s          : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 1 downto 0);
	signal lpgbtfpga_mgt_rxslide         : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 1 downto 0);
	signal SFP0_RX_N                     : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 1 downto 0);
	signal SFP0_RX_P                     : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 1 downto 0);
	signal SFP0_TX_N                     : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 1 downto 0);
	signal SFP0_TX_P                     : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 1 downto 0);
    signal mgt_tx_aligned_FF_s           : std_logic_vector(c_MASTER_NUMBER_CHANNELS - 2 downto 0);
    signal mgt_tx_aligned_SFP_s          : std_logic;
    
    signal CH0_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH1_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH2_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH3_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH4_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH5_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH6_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH7_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH8_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH9_downlink_mgtword_s            : std_logic_vector(31 downto 0);
    signal CH10_downlink_mgtword_s           : std_logic_vector(31 downto 0);
    signal CH11_downlink_mgtword_s           : std_logic_vector(31 downto 0);
    signal CH12_downlink_mgtword_s           : std_logic_vector(31 downto 0);    
    
	signal CH0_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH1_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH2_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH3_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH4_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH5_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH6_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH7_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH8_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH9_uplink_mgtword_s              : std_logic_vector(31 downto 0);
	signal CH10_uplink_mgtword_s             : std_logic_vector(31 downto 0);
	signal CH11_uplink_mgtword_s             : std_logic_vector(31 downto 0);
	signal CH12_uplink_mgtword_s             : std_logic_vector(31 downto 0) := (others => '0');
        
begin
    MGT_REFCLK_FF_320_o         <= refclk_FF_320_o;
    MGT_REFCLK_FF_40_o          <= refclk_FF_40_o;
    MGT_REFCLK_SFP_320_o        <= refclk_SFP_320_o;
    MGT_REFCLK_SFP_40_o         <= refclk_SFP_40_o;
    MGT_TX_ALIGNED_FF_o         <= mgt_tx_aligned_FF_s;
    MGT_TX_ALIGNED_SFP_o        <= mgt_tx_aligned_SFP_s;
    
    -- Channel 0 --
	CH0_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(0);
	lpgbtfpga_mgt_rxslide(0)    <= CH0_MGT_RXSlide_i;
	CH0_downlink_mgtword_s      <= CH0_MGT_USRWORD_i;
	CH0_MGT_USRWORD_o           <= CH0_uplink_mgtword_s;
	SFP0_RX_N(0)                <= CH0_RXn_i;
	SFP0_RX_P(0)                <= CH0_RXp_i;
	CH0_TXn_o                   <= SFP0_TX_N(0);
	CH0_TXp_o                   <= SFP0_TX_P(0);
	
	-- Channel 1 --
	CH1_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(1);
	lpgbtfpga_mgt_rxslide(1)    <= CH1_MGT_RXSlide_i;
	CH1_downlink_mgtword_s      <= CH1_MGT_USRWORD_i;
	CH1_MGT_USRWORD_o           <= CH1_uplink_mgtword_s;
	SFP0_RX_N(1)                <= CH1_RXn_i;
	SFP0_RX_P(1)                <= CH1_RXp_i;
	CH1_TXn_o                   <= SFP0_TX_N(1);
	CH1_TXp_o                   <= SFP0_TX_P(1);
	
	-- Channel 2 --
	CH2_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(2);
	lpgbtfpga_mgt_rxslide(2)    <= CH2_MGT_RXSlide_i;
	CH2_downlink_mgtword_s      <= CH2_MGT_USRWORD_i;
	CH2_MGT_USRWORD_o           <= CH2_uplink_mgtword_s;
	SFP0_RX_N(2)                <= CH2_RXn_i;
	SFP0_RX_P(2)                <= CH2_RXp_i;
	CH2_TXn_o                   <= SFP0_TX_N(2);
	CH2_TXp_o                   <= SFP0_TX_P(2);
	
	-- Channel 3 --
	CH3_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(3);
	lpgbtfpga_mgt_rxslide(3)    <= CH3_MGT_RXSlide_i;
	CH3_downlink_mgtword_s      <= CH3_MGT_USRWORD_i;
	CH3_MGT_USRWORD_o           <= CH3_uplink_mgtword_s;
	SFP0_RX_N(3)                <= CH3_RXn_i;
	SFP0_RX_P(3)                <= CH3_RXp_i;
	CH3_TXn_o                   <= SFP0_TX_N(3);
	CH3_TXp_o                   <= SFP0_TX_P(3);
	
	-- Channel 4 --
	CH4_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(4);
	lpgbtfpga_mgt_rxslide(4)    <= CH4_MGT_RXSlide_i;
	CH4_downlink_mgtword_s      <= CH4_MGT_USRWORD_i;
	CH4_MGT_USRWORD_o           <= CH4_uplink_mgtword_s;
	SFP0_RX_N(4)                <= CH4_RXn_i;
	SFP0_RX_P(4)                <= CH4_RXp_i;
	CH4_TXn_o                   <= SFP0_TX_N(4);
	CH4_TXp_o                   <= SFP0_TX_P(4);
	
	-- Channel 5 --
	CH5_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(5);
	lpgbtfpga_mgt_rxslide(5)    <= CH5_MGT_RXSlide_i;
	CH5_downlink_mgtword_s      <= CH5_MGT_USRWORD_i;
	CH5_MGT_USRWORD_o           <= CH5_uplink_mgtword_s;
	SFP0_RX_N(5)                <= CH5_RXn_i;
	SFP0_RX_P(5)                <= CH5_RXp_i;
	CH5_TXn_o                   <= SFP0_TX_N(5);
	CH5_TXp_o                   <= SFP0_TX_P(5);
	
	-- Channel 6 --
	CH6_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(6);
	lpgbtfpga_mgt_rxslide(6)    <= CH6_MGT_RXSlide_i;
	CH6_downlink_mgtword_s      <= CH6_MGT_USRWORD_i;
	CH6_MGT_USRWORD_o           <= CH6_uplink_mgtword_s;
	SFP0_RX_N(6)                <= CH6_RXn_i;
	SFP0_RX_P(6)                <= CH6_RXp_i;
	CH6_TXn_o                   <= SFP0_TX_N(6);
	CH6_TXp_o                   <= SFP0_TX_P(6);
	
	-- Channel 7 --
	CH7_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(7);
	lpgbtfpga_mgt_rxslide(7)    <= CH7_MGT_RXSlide_i;
	CH7_downlink_mgtword_s      <= CH7_MGT_USRWORD_i;
	CH7_MGT_USRWORD_o           <= CH7_uplink_mgtword_s;
	SFP0_RX_N(7)                <= CH7_RXn_i;
	SFP0_RX_P(7)                <= CH7_RXp_i;
	CH7_TXn_o                   <= SFP0_TX_N(7);
	CH7_TXp_o                   <= SFP0_TX_P(7);
	
	-- Channel 8 --
	CH8_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(8);
	lpgbtfpga_mgt_rxslide(8)    <= CH8_MGT_RXSlide_i;
	CH8_downlink_mgtword_s      <= CH8_MGT_USRWORD_i;
	CH8_MGT_USRWORD_o           <= CH8_uplink_mgtword_s;
	SFP0_RX_N(8)                <= CH8_RXn_i;
	SFP0_RX_P(8)                <= CH8_RXp_i;
	CH8_TXn_o                   <= SFP0_TX_N(8);
	CH8_TXp_o                   <= SFP0_TX_P(8);
	
	-- Channel 9 --
	CH9_MGT_RXUSRCLK_o          <= lpgbtfpga_mgtrxclk_s(9);
	lpgbtfpga_mgt_rxslide(9)    <= CH9_MGT_RXSlide_i;
	CH9_downlink_mgtword_s      <= CH9_MGT_USRWORD_i;
	CH9_MGT_USRWORD_o           <= CH9_uplink_mgtword_s;
	SFP0_RX_N(9)                <= CH9_RXn_i;
	SFP0_RX_P(9)                <= CH9_RXp_i;
	CH9_TXn_o                   <= SFP0_TX_N(9);
	CH9_TXp_o                   <= SFP0_TX_P(9);
	
	-- Channel 10 --
	CH10_MGT_RXUSRCLK_o         <= lpgbtfpga_mgtrxclk_s(10);
	lpgbtfpga_mgt_rxslide(10)   <= CH10_MGT_RXSlide_i;
	CH10_downlink_mgtword_s     <= CH10_MGT_USRWORD_i;
	CH10_MGT_USRWORD_o          <= CH10_uplink_mgtword_s;
	SFP0_RX_N(10)               <= CH10_RXn_i;
	SFP0_RX_P(10)               <= CH10_RXp_i;
	CH10_TXn_o                  <= SFP0_TX_N(10);
	CH10_TXp_o                  <= SFP0_TX_P(10);
	
	-- Channel 11 --
	CH11_MGT_RXUSRCLK_o         <= lpgbtfpga_mgtrxclk_s(11);
	lpgbtfpga_mgt_rxslide(11)   <= CH11_MGT_RXSlide_i;
	CH11_downlink_mgtword_s     <= CH11_MGT_USRWORD_i;
	CH11_MGT_USRWORD_o          <= CH11_uplink_mgtword_s;
	SFP0_RX_N(11)               <= CH11_RXn_i;
	SFP0_RX_P(11)               <= CH11_RXp_i;
	CH11_TXn_o                  <= SFP0_TX_N(11);
	CH11_TXp_o                  <= SFP0_TX_P(11);
	
	-- Channel 12 --
	CH12_MGT_RXUSRCLK_o         <= lpgbtfpga_mgtrxclk_s(12);
	lpgbtfpga_mgt_rxslide(12)   <= CH12_MGT_RXSlide_i;
	CH12_downlink_mgtword_s     <= CH12_MGT_USRWORD_i;
	CH12_MGT_USRWORD_o          <= CH12_uplink_mgtword_s;
	SFP0_RX_N(12)               <= CH12_RXn_i;
	SFP0_RX_P(12)               <= CH12_RXp_i;
	CH12_TXn_o                  <= SFP0_TX_N(12);
	CH12_TXp_o                  <= SFP0_TX_P(12);

	all_mgt_inst : all_mgt
		generic map(
		    COM_SEL            => g_COM_SEL,
			CH0_EN             => g_CH0_ENABLE,
		    CH1_EN             => g_CH1_ENABLE,
		    CH2_EN             => g_CH2_ENABLE,
		    CH3_EN             => g_CH3_ENABLE,
		    CH4_EN             => g_CH4_ENABLE,
		    CH5_EN             => g_CH5_ENABLE,
		    CH6_EN             => g_CH6_ENABLE,
		    CH7_EN             => g_CH7_ENABLE,
		    CH8_EN             => g_CH8_ENABLE,
		    CH9_EN             => g_CH9_ENABLE,
		    CH10_EN            => g_CH10_ENABLE, 
		    CH11_EN            => g_CH11_ENABLE,
		    CH12_EN            => g_CH12_ENABLE,
		    RESET_QUAD_0       => g_RESET_QUAD_0,
		    RESET_QUAD_1       => g_RESET_QUAD_1,
		    RESET_QUAD_2       => g_RESET_QUAD_2
		)
		port map(
			--=============--
			-- Clocks      --
			--=============--
			MGT_REFCLK_FF_P      => MGT_REFCLK_FF_P,
			MGT_REFCLK_FF_N      => MGT_REFCLK_FF_N,
			MGT_REFCLK_SFP_P     => MGT_REFCLK_SFP_P,
			MGT_REFCLK_SFP_N     => MGT_REFCLK_SFP_N,
			MGT_FREEDRPCLK_i     => MGT_FREEDRPCLK_i,
			MGT_REFCLK_FF_40_o   => refclk_FF_40_o,
			MGT_REFCLK_FF_320_o  => refclk_FF_320_o,
            MGT_REFCLK_SFP_40_o  => refclk_SFP_40_o,
			MGT_REFCLK_SFP_320_o => refclk_SFP_320_o,
			MGT_RXUSRCLK_o       => lpgbtfpga_mgtrxclk_s,
			--=============--
			-- Resets      --
			--=============--
			MGT_TXRESET_FF_i     => MGT_TXRESET_FF_i,
			MGT_RXRESET_FF_i     => MGT_RXRESET_FF_i,
			MGT_TXRESET_SFP_i    => MGT_TXRESET_SFP_i,
			MGT_RXRESET_SFP_i    => MGT_RXRESET_SFP_i,
			--=============--
			-- Control     --
			--=============--
			MGT_FF_TXPolarity_i   => g_MGT_FF_TX_POLARITY_inv,
			MGT_FF_RXPolarity_i   => g_MGT_FF_RX_POLARITY_inv,
			MGT_SFP_TXPolarity_i  => g_MGT_SFP_TX_POLARITY_inv,
			MGT_SFP_RXPolarity_i  => g_MGT_SFP_RX_POLARITY_inv,
			MGT_RXSlide_i         => lpgbtfpga_mgt_rxslide,
			MGT_ENTXCALIBIN_i     => (others => '0'),
			--=============--
			-- Status      --
			--=============--
			MGT_TXREADY_FF_o     => MGT_TXREADY_FF_o,
			MGT_RXREADY_FF_o     => MGT_RXREADY_FF_o,
			MGT_TXREADY_SFP_o     => MGT_TXREADY_SFP_o,
			MGT_RXREADY_SFP_o     => MGT_RXREADY_SFP_o,
			MGT_TX_ALIGNED_FF_o  => mgt_tx_aligned_FF_s,
			MGT_TX_ALIGNED_SFP_o  => mgt_tx_aligned_SFP_s,
			--==============--
			-- Data         --
			--==============--
			MGT_USRWORD_CH0_i      => CH0_downlink_mgtword_s,
			MGT_USRWORD_CH1_i      => CH1_downlink_mgtword_s,
			MGT_USRWORD_CH2_i      => CH2_downlink_mgtword_s,
			MGT_USRWORD_CH3_i      => CH3_downlink_mgtword_s,
			MGT_USRWORD_CH4_i      => CH4_downlink_mgtword_s,
			MGT_USRWORD_CH5_i      => CH5_downlink_mgtword_s,
			MGT_USRWORD_CH6_i      => CH6_downlink_mgtword_s,
			MGT_USRWORD_CH7_i      => CH7_downlink_mgtword_s,
			MGT_USRWORD_CH8_i      => CH8_downlink_mgtword_s,
			MGT_USRWORD_CH9_i      => CH9_downlink_mgtword_s,
			MGT_USRWORD_CH10_i     => CH10_downlink_mgtword_s,
			MGT_USRWORD_CH11_i     => CH11_downlink_mgtword_s,
			MGT_USRWORD_CH12_i     => CH12_downlink_mgtword_s,
			
			MGT_USRWORD_CH0_o      => CH0_uplink_mgtword_s,
			MGT_USRWORD_CH1_o      => CH1_uplink_mgtword_s,
			MGT_USRWORD_CH2_o      => CH2_uplink_mgtword_s,
			MGT_USRWORD_CH3_o      => CH3_uplink_mgtword_s,
			MGT_USRWORD_CH4_o      => CH4_uplink_mgtword_s,
			MGT_USRWORD_CH5_o      => CH5_uplink_mgtword_s,
			MGT_USRWORD_CH6_o      => CH6_uplink_mgtword_s,
			MGT_USRWORD_CH7_o      => CH7_uplink_mgtword_s,
			MGT_USRWORD_CH8_o      => CH8_uplink_mgtword_s,
			MGT_USRWORD_CH9_o      => CH9_uplink_mgtword_s,
			MGT_USRWORD_CH10_o     => CH10_uplink_mgtword_s,
			MGT_USRWORD_CH11_o     => CH11_uplink_mgtword_s,
			MGT_USRWORD_CH12_o     => CH12_uplink_mgtword_s,
			--===============--
			-- Serial intf.  --
			--===============--
			RXn_i             => SFP0_RX_N,
			RXp_i             => SFP0_RX_P,
			TXn_o             => SFP0_TX_N,
			TXp_o             => SFP0_TX_P
		);

end Behavioral;