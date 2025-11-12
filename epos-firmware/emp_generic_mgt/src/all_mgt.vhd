----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2020 02:22:46 PM
-- Design Name: 
-- Module Name: emp_transceivers - Behavioral
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

--use work.matrix_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity all_mgt is

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
		MGT_REFCLK_FF_P       : in  std_logic;
		MGT_REFCLK_FF_N       : in  std_logic;
		MGT_REFCLK_SFP_P      : in  std_logic;
		MGT_REFCLK_SFP_N      : in  std_logic;
		MGT_FREEDRPCLK_i      : in  std_logic;
		MGT_REFCLK_FF_320_o   : out std_logic;
		MGT_REFCLK_FF_40_o    : out std_logic; 
		MGT_REFCLK_SFP_320_o  : out std_logic;
		MGT_REFCLK_SFP_40_o   : out std_logic;  
		MGT_RXUSRCLK_o        : out std_logic_vector(12 downto 0);
		--=============--
		-- Control     --
		--=============--
		MGT_FF_TXPolarity_i      : in  std_logic_vector(11 downto 0);
		MGT_FF_RXPolarity_i      : in  std_logic_vector(11 downto 0);
		MGT_SFP_TXPolarity_i  : in  std_logic_vector(0 downto 0);
		MGT_SFP_RXPolarity_i  : in  std_logic_vector(0 downto 0);
		MGT_RXSlide_i         : in  std_logic_vector(12 downto 0);
		MGT_ENTXCALIBIN_i     : in  std_logic_vector(12 downto 0);
		--=============--
		-- Status      --
		--=============--
		-- TX aligned signal
		MGT_TX_ALIGNED_FF_o  : out std_logic_vector(11 downto 0);
		MGT_TX_ALIGNED_SFP_o : out std_logic;
		-- TX/RX Ready signals
		MGT_TXREADY_FF_o     : out std_logic_vector(11 downto 0);
		MGT_RXREADY_FF_o     : out std_logic_vector(11 downto 0);
		MGT_TXREADY_SFP_o    : out std_logic;
		MGT_RXREADY_SFP_o    : out std_logic;
		--=============--
		-- Resets      --
		--=============--
		MGT_TXRESET_FF_i     : in std_logic_vector(11 downto 0);
		MGT_RXRESET_FF_i     : in std_logic_vector(11 downto 0);
		MGT_TXRESET_SFP_i    : in std_logic;
		MGT_RXRESET_SFP_i    : in std_logic;
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
end all_mgt;

architecture Behavioral of all_mgt is

	component emp_transceiver_channel_gthe4_common_wrapper is
		port(
			GTHE4_COMMON_BGBYPASSB         : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_BGMONITORENB      : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_BGPDB             : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_BGRCALOVRD        : in  std_logic_vector(4 downto 0);
			GTHE4_COMMON_BGRCALOVRDENB     : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_DRPADDR           : in  std_logic_vector(15 downto 0);
			GTHE4_COMMON_DRPCLK            : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_DRPDI             : in  std_logic_vector(15 downto 0);
			GTHE4_COMMON_DRPEN             : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_DRPWE             : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTGREFCLK0        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTGREFCLK1        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTNORTHREFCLK00   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTNORTHREFCLK01   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTNORTHREFCLK10   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTNORTHREFCLK11   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTREFCLK00        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTREFCLK01        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTREFCLK10        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTREFCLK11        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTSOUTHREFCLK00   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTSOUTHREFCLK01   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTSOUTHREFCLK10   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_GTSOUTHREFCLK11   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_PCIERATEQPLL0     : in  std_logic_vector(2 downto 0);
			GTHE4_COMMON_PCIERATEQPLL1     : in  std_logic_vector(2 downto 0);
			GTHE4_COMMON_PMARSVD0          : in  std_logic_vector(7 downto 0);
			GTHE4_COMMON_PMARSVD1          : in  std_logic_vector(7 downto 0);
			GTHE4_COMMON_QPLL0CLKRSVD0     : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0CLKRSVD1     : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0FBDIV        : in  std_logic_vector(7 downto 0);
			GTHE4_COMMON_QPLL0LOCKDETCLK   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0LOCKEN       : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0PD           : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0REFCLKSEL    : in  std_logic_vector(2 downto 0);
			GTHE4_COMMON_QPLL0RESET        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1CLKRSVD0     : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1CLKRSVD1     : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1FBDIV        : in  std_logic_vector(7 downto 0);
			GTHE4_COMMON_QPLL1LOCKDETCLK   : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1LOCKEN       : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1PD           : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1REFCLKSEL    : in  std_logic_vector(2 downto 0);
			GTHE4_COMMON_QPLL1RESET        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLLRSVD1         : in  std_logic_vector(7 downto 0);
			GTHE4_COMMON_QPLLRSVD2         : in  std_logic_vector(4 downto 0);
			GTHE4_COMMON_QPLLRSVD3         : in  std_logic_vector(4 downto 0);
			GTHE4_COMMON_QPLLRSVD4         : in  std_logic_vector(7 downto 0);
			GTHE4_COMMON_RCALENB           : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_SDM0DATA          : in  std_logic_vector(24 downto 0);
			GTHE4_COMMON_SDM0RESET         : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_SDM0TOGGLE        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_SDM0WIDTH         : in  std_logic_vector(1 downto 0);
			GTHE4_COMMON_SDM1DATA          : in  std_logic_vector(24 downto 0);
			GTHE4_COMMON_SDM1RESET         : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_SDM1TOGGLE        : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_SDM1WIDTH         : in  std_logic_vector(1 downto 0);
			GTHE4_COMMON_TCONGPI           : in  std_logic_vector(9 downto 0);
			GTHE4_COMMON_TCONPOWERUP       : in  std_logic_vector(0 downto 0);
			GTHE4_COMMON_TCONRESET         : in  std_logic_vector(1 downto 0);
			GTHE4_COMMON_TCONRSVDIN1       : in  std_logic_vector(1 downto 0);
			GTHE4_COMMON_DRPDO             : out std_logic_vector(15 downto 0);
			GTHE4_COMMON_DRPRDY            : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_PMARSVDOUT0       : out std_logic_vector(7 downto 0);
			GTHE4_COMMON_PMARSVDOUT1       : out std_logic_vector(7 downto 0);
			GTHE4_COMMON_QPLL0FBCLKLOST    : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0LOCK         : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0OUTCLK       : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0OUTREFCLK    : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL0REFCLKLOST   : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1FBCLKLOST    : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1LOCK         : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1OUTCLK       : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1OUTREFCLK    : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLL1REFCLKLOST   : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_QPLLDMONITOR0     : out std_logic_vector(7 downto 0);
			GTHE4_COMMON_QPLLDMONITOR1     : out std_logic_vector(7 downto 0);
			GTHE4_COMMON_REFCLKOUTMONITOR0 : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_REFCLKOUTMONITOR1 : out std_logic_vector(0 downto 0);
			GTHE4_COMMON_RXRECCLK0SEL      : out std_logic_vector(1 downto 0);
			GTHE4_COMMON_RXRECCLK1SEL      : out std_logic_vector(1 downto 0);
			GTHE4_COMMON_SDM0FINALOUT      : out std_logic_vector(3 downto 0);
			GTHE4_COMMON_SDM0TESTDATA      : out std_logic_vector(14 downto 0);
			GTHE4_COMMON_SDM1FINALOUT      : out std_logic_vector(3 downto 0);
			GTHE4_COMMON_SDM1TESTDATA      : out std_logic_vector(14 downto 0);
			GTHE4_COMMON_TCONGPO           : out std_logic_vector(9 downto 0);
			GTHE4_COMMON_TCONRSVDOUT0      : out std_logic_vector(0 downto 0)
		);
	end component;
	
	COMPONENT mgt_channel_inst_0
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_1
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_2
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_3
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_4
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_5
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_6
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_7
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_8
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_9
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_10
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	COMPONENT mgt_channel_inst_11
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
    END COMPONENT;
	  
    COMPONENT mgt_channel_inst_12
	   PORT(
            MGT_FREEDRPCLK_i  : in  std_logic;
		    MGT_RXUSRCLK_o    : out std_logic;
            MGT_TXRESET_i     : in  std_logic;
            MGT_RXRESET_i     : in  std_logic;
            MGT_TXPolarity_i  : in  std_logic;
            MGT_RXPolarity_i  : in  std_logic;
            MGT_RXSlide_i     : in  std_logic;
            MGT_ENTXCALIBIN_i : in  std_logic;
            MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
            MGT_TXREADY_o     : out std_logic;
            MGT_RXREADY_o     : out std_logic;
            MGT_TX_ALIGNED_o  : out std_logic;
            MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
            MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
            RXn_i             : in  std_logic;
            RXp_i             : in  std_logic;
            TXn_o             : out std_logic;
            TXp_o             : out std_logic;
            --===============--
            -- from master quad
            --===============--
            mgt_qpll0lock     : in  std_logic;
            qpll0clk          : in  std_logic;                      
            qpll0refclk       : in  std_logic;                     
            qpll1clk          : in  std_logic;                        
            qpll1refclk       : in  std_logic;  
            --===============--
		    -- to master quad
		    --===============--
		    qpll0reset        : out std_logic
	   );
	END COMPONENT;
	
	type integer_array is array (natural range <>) of integer;
    type boolean_vector is array (natural range <>) of boolean;

	constant c_NUMBER_QUADS       : integer                                                 := 4;
	constant c_NUMBER_CHANNELS    : integer                                                 := 13;
	constant c_CHANNEL_ENABLE     : boolean_vector(c_NUMBER_CHANNELS -1 downto 0)           := (0 => CH0_EN, 1 => CH1_EN, 2 => CH2_EN, 3 => CH3_EN, 4 => CH4_EN, 5 => CH5_EN, 
	                                                                                               6 => CH6_EN, 7 => CH7_EN, 8 => CH8_EN, 9 => CH9_EN, 10 => CH10_EN, 11 => CH11_EN, 12 => CH12_EN);
	-- c_MASTER_CHANNEL_QUADS associates each channel to a quad following the convention (CHANNEL_NUMBER => QUAD_NUMBER)
	constant c_MASTER_CHANNEL_QUADS      : integer_array(c_NUMBER_CHANNELS - 1 downto 0)    := (0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 1, 5 => 1, 6 => 1, 7 => 1, 8 => 2, 9 => 2, 10 => 2, 11 => 2, 12 => 3);
	-- c_MASTER_PLL_RESET_CHANNELS associates a 'master' channel to each quad for the common PLL reset following the convention (QUAD_NUMBER => CHANNEL_NUMBER)
	constant c_MASTER_PLL_RESET_CHANNELS : integer_array(c_NUMBER_QUADS - 1 downto 0)       := (0 => RESET_QUAD_0, 1 => RESET_QUAD_1, 2 => RESET_QUAD_2, 3 => 12);

	-- Common <-> MGT
	-- A dummy signal for the PLL reset is created for all channels (master_mgt_to_common_qpll0reset)
	-- Only the ones in c_MASTER_PLL_RESET_CHANNELS will be connected to the common via master_mgt_to_common_qpll0reset_common   
	signal master_mgt_to_common_qpll0reset        : std_logic_vector(c_NUMBER_CHANNELS - 1 downto 0);
	signal master_mgt_to_common_qpll0reset_common : std_logic_vector(c_NUMBER_QUADS - 1 downto 0);
	signal master_common_to_mgt_qpll0lock         : std_logic_vector(c_NUMBER_QUADS - 1 downto 0);
	signal master_common_to_mgt_qpll0outclk       : std_logic_vector(c_NUMBER_QUADS - 1 downto 0);
	signal master_common_to_mgt_qpll0outrefclk    : std_logic_vector(c_NUMBER_QUADS - 1 downto 0);
	signal master_common_to_mgt_qpll1outclk       : std_logic_vector(c_NUMBER_QUADS - 1 downto 0);
	signal master_common_to_mgt_qpll1outrefclk    : std_logic_vector(c_NUMBER_QUADS - 1 downto 0);
	
    signal MGT_REFCLK_FF_i : std_logic;
	signal MGT_REFCLK_FF_o : std_logic;
	signal MGT_REFLCK_BUF_FF_320_o : std_logic;
	signal MGT_REFLCK_BUF_FF_40_o : std_logic;
	
	signal MGT_REFCLK_SFP_i : std_logic;
	signal MGT_REFCLK_SFP_o : std_logic;
	signal MGT_REFLCK_BUF_SFP_320_o : std_logic;
	signal MGT_REFLCK_BUF_SFP_40_o : std_logic;
	
begin
    --------------------
    -- MGT(GTX) reference clock:  
	mgt_clock_sfp_ibufds : ibufds_gte4
		generic map(
			REFCLK_EN_TX_PATH  => '0',
			REFCLK_HROW_CK_SEL => (others => '0'),
			REFCLK_ICNTL_RX    => (others => '0')
		)
		port map(
			O     => MGT_REFCLK_SFP_i,
			ODIV2 => MGT_REFCLK_SFP_o,
			CEB   => '0',
			I     => MGT_REFCLK_SFP_P,
			IB    => MGT_REFCLK_SFP_N
		);
		
	-- MGT 320 MHz reference clock
    mgt_clock_sfp_buffer320 : bufg_gt
        port map(
            O       => MGT_REFLCK_BUF_SFP_320_o,
            I       => MGT_REFCLK_SFP_o,
            CE      => '1',
            DIV     => "000",
            CLR     => '0',
            CLRMASK => '0',
            CEMASK  => '0'
        );
    MGT_REFCLK_SFP_320_o    <= MGT_REFLCK_BUF_SFP_320_o;
    
    -- MGT 40 MHz reference clock 
    mgt_clock_sfp_buffer40 : bufg_gt
        port map(
            O       => MGT_REFLCK_BUF_SFP_40_o,
            I       => MGT_REFCLK_SFP_o,
            CE      => '1',
            DIV     => "111",
            CLR     => '0',
            CLRMASK => '0',
            CEMASK  => '0'
        );
    MGT_REFCLK_SFP_40_o    <= MGT_REFLCK_BUF_SFP_40_o;
    -----------------------

	-- MGT(GTX) reference clock:  
	mgt_clock_ibufds : ibufds_gte4
		generic map(
			REFCLK_EN_TX_PATH  => '0',
			REFCLK_HROW_CK_SEL => (others => '0'),
			REFCLK_ICNTL_RX    => (others => '0')
		)
		port map(
			O     => MGT_REFCLK_FF_i,
			ODIV2 => MGT_REFCLK_FF_o,
			CEB   => '0',
			I     => MGT_REFCLK_FF_P,
			IB    => MGT_REFCLK_FF_N
		);
		
	-- MGT 320 MHz reference clock
    mgt_clock_buffer320 : bufg_gt
        port map(
            O       => MGT_REFLCK_BUF_FF_320_o,
            I       => MGT_REFCLK_FF_o,
            CE      => '1',
            DIV     => "000",
            CLR     => '0',
            CLRMASK => '0',
            CEMASK  => '0'
        );
    MGT_REFCLK_FF_320_o    <= MGT_REFLCK_BUF_FF_320_o;
    
    -- MGT 40 MHz reference clock 
    mgt_clock_buffer40 : bufg_gt
        port map(
            O       => MGT_REFLCK_BUF_FF_40_o,
            I       => MGT_REFCLK_FF_o,
            CE      => '1',
            DIV     => "111",
            CLR     => '0',
            CLRMASK => '0',
            CEMASK  => '0'
        );
    MGT_REFCLK_FF_40_o    <= MGT_REFLCK_BUF_FF_40_o;
 
    gen_master_quads : for i in 0 to 2 generate
        gen_condition : if c_CHANNEL_ENABLE(i*4) OR c_CHANNEL_ENABLE((i*4)+1) OR c_CHANNEL_ENABLE((i*4)+2) OR c_CHANNEL_ENABLE((i*4)+3) generate
            mgt_common_wrapper : emp_transceiver_channel_gthe4_common_wrapper
                port map(
                    GTHE4_COMMON_BGBYPASSB         => "1",
                    GTHE4_COMMON_BGMONITORENB      => "1",
                    GTHE4_COMMON_BGPDB             => "1",
                    GTHE4_COMMON_BGRCALOVRD        => "11111",
                    GTHE4_COMMON_BGRCALOVRDENB     => "1",
                    GTHE4_COMMON_DRPADDR           => "0000000000000000",
                    GTHE4_COMMON_DRPCLK            => "0",
                    GTHE4_COMMON_DRPDI             => "0000000000000000",
                    GTHE4_COMMON_DRPEN             => "0",
                    GTHE4_COMMON_DRPWE             => "0",
                    GTHE4_COMMON_GTGREFCLK0        => "0",
                    GTHE4_COMMON_GTGREFCLK1        => "0",
                    GTHE4_COMMON_GTNORTHREFCLK00   => "0",
                    GTHE4_COMMON_GTNORTHREFCLK01   => "0",
                    GTHE4_COMMON_GTNORTHREFCLK10   => "0",
                    GTHE4_COMMON_GTNORTHREFCLK11   => "0",
                    GTHE4_COMMON_GTREFCLK00(0)     => MGT_REFCLK_FF_i,
                    GTHE4_COMMON_GTREFCLK01(0)     => MGT_REFCLK_FF_i,
                    GTHE4_COMMON_GTREFCLK10        => "0",
                    GTHE4_COMMON_GTREFCLK11        => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK00   => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK01   => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK10   => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK11   => "0",
                    GTHE4_COMMON_PCIERATEQPLL0     => "000",
                    GTHE4_COMMON_PCIERATEQPLL1     => "000",
                    GTHE4_COMMON_PMARSVD0          => "00000000",
                    GTHE4_COMMON_PMARSVD1          => "00000000",
                    GTHE4_COMMON_QPLL0CLKRSVD0     => "0",
                    GTHE4_COMMON_QPLL0CLKRSVD1     => "0",
                    GTHE4_COMMON_QPLL0FBDIV        => "00000000",
                    GTHE4_COMMON_QPLL0LOCKDETCLK   => "0",
                    GTHE4_COMMON_QPLL0LOCKEN       => "1",
                    GTHE4_COMMON_QPLL0PD           => "0",
                    GTHE4_COMMON_QPLL0REFCLKSEL    => "001",
                    GTHE4_COMMON_QPLL0RESET(0)     => master_mgt_to_common_qpll0reset_common(i),
                    GTHE4_COMMON_QPLL1CLKRSVD0     => "0",
                    GTHE4_COMMON_QPLL1CLKRSVD1     => "0",
                    GTHE4_COMMON_QPLL1FBDIV        => "00000000",
                    GTHE4_COMMON_QPLL1LOCKDETCLK   => "0",
                    GTHE4_COMMON_QPLL1LOCKEN       => "0",
                    GTHE4_COMMON_QPLL1PD           => "1",
                    GTHE4_COMMON_QPLL1REFCLKSEL    => "001",
                    GTHE4_COMMON_QPLL1RESET        => "0",
                    GTHE4_COMMON_QPLLRSVD1         => "00000000",
                    GTHE4_COMMON_QPLLRSVD2         => "00000",
                    GTHE4_COMMON_QPLLRSVD3         => "00000",
                    GTHE4_COMMON_QPLLRSVD4         => "00000000",
                    GTHE4_COMMON_RCALENB           => "1",
                    GTHE4_COMMON_SDM0DATA          => "0000000000000000000000000",
                    GTHE4_COMMON_SDM0RESET         => "0",
                    GTHE4_COMMON_SDM0TOGGLE        => "0",
                    GTHE4_COMMON_SDM0WIDTH         => "00",
                    GTHE4_COMMON_SDM1DATA          => "0000000000000000000000000",
                    GTHE4_COMMON_SDM1RESET         => "0",
                    GTHE4_COMMON_SDM1TOGGLE        => "0",
                    GTHE4_COMMON_SDM1WIDTH         => "00",
                    GTHE4_COMMON_TCONGPI           => "0000000000",
                    GTHE4_COMMON_TCONPOWERUP       => "0",
                    GTHE4_COMMON_TCONRESET         => "00",
                    GTHE4_COMMON_TCONRSVDIN1       => "00",
                    GTHE4_COMMON_DRPDO             => open,
                    GTHE4_COMMON_DRPRDY            => open,
                    GTHE4_COMMON_PMARSVDOUT0       => open,
                    GTHE4_COMMON_PMARSVDOUT1       => open,
                    GTHE4_COMMON_QPLL0FBCLKLOST    => open,
                    GTHE4_COMMON_QPLL0LOCK(0)      => master_common_to_mgt_qpll0lock(i),
                    GTHE4_COMMON_QPLL0OUTCLK(0)    => master_common_to_mgt_qpll0outclk(i),
                    GTHE4_COMMON_QPLL0OUTREFCLK(0) => master_common_to_mgt_qpll0outrefclk(i),
                    GTHE4_COMMON_QPLL0REFCLKLOST   => open,
                    GTHE4_COMMON_QPLL1FBCLKLOST    => open,
                    GTHE4_COMMON_QPLL1LOCK         => open,
                    GTHE4_COMMON_QPLL1OUTCLK(0)    => master_common_to_mgt_qpll1outclk(i),
                    GTHE4_COMMON_QPLL1OUTREFCLK(0) => master_common_to_mgt_qpll1outrefclk(i),
                    GTHE4_COMMON_QPLL1REFCLKLOST   => open,
                    GTHE4_COMMON_QPLLDMONITOR0     => open,
                    GTHE4_COMMON_QPLLDMONITOR1     => open,
                    GTHE4_COMMON_REFCLKOUTMONITOR0 => open,
                    GTHE4_COMMON_REFCLKOUTMONITOR1 => open,
                    GTHE4_COMMON_RXRECCLK0SEL      => open,
                    GTHE4_COMMON_RXRECCLK1SEL      => open,
                    GTHE4_COMMON_SDM0FINALOUT      => open,
                    GTHE4_COMMON_SDM0TESTDATA      => open,
                    GTHE4_COMMON_SDM1FINALOUT      => open,
                    GTHE4_COMMON_SDM1TESTDATA      => open,
                    GTHE4_COMMON_TCONGPO           => open,
                    GTHE4_COMMON_TCONRSVDOUT0      => open
                );
            master_mgt_to_common_qpll0reset_common(i) <= master_mgt_to_common_qpll0reset(c_MASTER_PLL_RESET_CHANNELS(i));
        end generate gen_condition;
	end generate gen_master_quads;
	
	gen_condition : if c_CHANNEL_ENABLE(12) generate
            mgt_common_wrapper : emp_transceiver_channel_gthe4_common_wrapper
                port map(
                    GTHE4_COMMON_BGBYPASSB         => "1",
                    GTHE4_COMMON_BGMONITORENB      => "1",
                    GTHE4_COMMON_BGPDB             => "1",
                    GTHE4_COMMON_BGRCALOVRD        => "11111",
                    GTHE4_COMMON_BGRCALOVRDENB     => "1",
                    GTHE4_COMMON_DRPADDR           => "0000000000000000",
                    GTHE4_COMMON_DRPCLK            => "0",
                    GTHE4_COMMON_DRPDI             => "0000000000000000",
                    GTHE4_COMMON_DRPEN             => "0",
                    GTHE4_COMMON_DRPWE             => "0",
                    GTHE4_COMMON_GTGREFCLK0        => "0",
                    GTHE4_COMMON_GTGREFCLK1        => "0",
                    GTHE4_COMMON_GTNORTHREFCLK00   => "0",
                    GTHE4_COMMON_GTNORTHREFCLK01   => "0",
                    GTHE4_COMMON_GTNORTHREFCLK10   => "0",
                    GTHE4_COMMON_GTNORTHREFCLK11   => "0",
                    GTHE4_COMMON_GTREFCLK00(0)     => MGT_REFCLK_SFP_i,
                    GTHE4_COMMON_GTREFCLK01(0)     => MGT_REFCLK_SFP_i,
                    GTHE4_COMMON_GTREFCLK10        => "0",
                    GTHE4_COMMON_GTREFCLK11        => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK00   => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK01   => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK10   => "0",
                    GTHE4_COMMON_GTSOUTHREFCLK11   => "0",
                    GTHE4_COMMON_PCIERATEQPLL0     => "000",
                    GTHE4_COMMON_PCIERATEQPLL1     => "000",
                    GTHE4_COMMON_PMARSVD0          => "00000000",
                    GTHE4_COMMON_PMARSVD1          => "00000000",
                    GTHE4_COMMON_QPLL0CLKRSVD0     => "0",
                    GTHE4_COMMON_QPLL0CLKRSVD1     => "0",
                    GTHE4_COMMON_QPLL0FBDIV        => "00000000",
                    GTHE4_COMMON_QPLL0LOCKDETCLK   => "0",
                    GTHE4_COMMON_QPLL0LOCKEN       => "1",
                    GTHE4_COMMON_QPLL0PD           => "0",
                    GTHE4_COMMON_QPLL0REFCLKSEL    => "001",
                    GTHE4_COMMON_QPLL0RESET(0)     => master_mgt_to_common_qpll0reset_common(3),
                    GTHE4_COMMON_QPLL1CLKRSVD0     => "0",
                    GTHE4_COMMON_QPLL1CLKRSVD1     => "0",
                    GTHE4_COMMON_QPLL1FBDIV        => "00000000",
                    GTHE4_COMMON_QPLL1LOCKDETCLK   => "0",
                    GTHE4_COMMON_QPLL1LOCKEN       => "0",
                    GTHE4_COMMON_QPLL1PD           => "1",
                    GTHE4_COMMON_QPLL1REFCLKSEL    => "001",
                    GTHE4_COMMON_QPLL1RESET        => "0",
                    GTHE4_COMMON_QPLLRSVD1         => "00000000",
                    GTHE4_COMMON_QPLLRSVD2         => "00000",
                    GTHE4_COMMON_QPLLRSVD3         => "00000",
                    GTHE4_COMMON_QPLLRSVD4         => "00000000",
                    GTHE4_COMMON_RCALENB           => "1",
                    GTHE4_COMMON_SDM0DATA          => "0000000000000000000000000",
                    GTHE4_COMMON_SDM0RESET         => "0",
                    GTHE4_COMMON_SDM0TOGGLE        => "0",
                    GTHE4_COMMON_SDM0WIDTH         => "00",
                    GTHE4_COMMON_SDM1DATA          => "0000000000000000000000000",
                    GTHE4_COMMON_SDM1RESET         => "0",
                    GTHE4_COMMON_SDM1TOGGLE        => "0",
                    GTHE4_COMMON_SDM1WIDTH         => "00",
                    GTHE4_COMMON_TCONGPI           => "0000000000",
                    GTHE4_COMMON_TCONPOWERUP       => "0",
                    GTHE4_COMMON_TCONRESET         => "00",
                    GTHE4_COMMON_TCONRSVDIN1       => "00",
                    GTHE4_COMMON_DRPDO             => open,
                    GTHE4_COMMON_DRPRDY            => open,
                    GTHE4_COMMON_PMARSVDOUT0       => open,
                    GTHE4_COMMON_PMARSVDOUT1       => open,
                    GTHE4_COMMON_QPLL0FBCLKLOST    => open,
                    GTHE4_COMMON_QPLL0LOCK(0)      => master_common_to_mgt_qpll0lock(3),
                    GTHE4_COMMON_QPLL0OUTCLK(0)    => master_common_to_mgt_qpll0outclk(3),
                    GTHE4_COMMON_QPLL0OUTREFCLK(0) => master_common_to_mgt_qpll0outrefclk(3),
                    GTHE4_COMMON_QPLL0REFCLKLOST   => open,
                    GTHE4_COMMON_QPLL1FBCLKLOST    => open,
                    GTHE4_COMMON_QPLL1LOCK         => open,
                    GTHE4_COMMON_QPLL1OUTCLK(0)    => master_common_to_mgt_qpll1outclk(3),
                    GTHE4_COMMON_QPLL1OUTREFCLK(0) => master_common_to_mgt_qpll1outrefclk(3),
                    GTHE4_COMMON_QPLL1REFCLKLOST   => open,
                    GTHE4_COMMON_QPLLDMONITOR0     => open,
                    GTHE4_COMMON_QPLLDMONITOR1     => open,
                    GTHE4_COMMON_REFCLKOUTMONITOR0 => open,
                    GTHE4_COMMON_REFCLKOUTMONITOR1 => open,
                    GTHE4_COMMON_RXRECCLK0SEL      => open,
                    GTHE4_COMMON_RXRECCLK1SEL      => open,
                    GTHE4_COMMON_SDM0FINALOUT      => open,
                    GTHE4_COMMON_SDM0TESTDATA      => open,
                    GTHE4_COMMON_SDM1FINALOUT      => open,
                    GTHE4_COMMON_SDM1TESTDATA      => open,
                    GTHE4_COMMON_TCONGPO           => open,
                    GTHE4_COMMON_TCONRSVDOUT0      => open
                );
            master_mgt_to_common_qpll0reset_common(3) <= master_mgt_to_common_qpll0reset(c_MASTER_PLL_RESET_CHANNELS(3));
        end generate gen_condition;

    Firefly_gen : IF COM_SEL = 0 GENERATE	
        channel_0_gen: IF CH0_EN = true GENERATE
            channel_0 : mgt_channel_inst_0
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(0),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(0),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(0),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(0),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(0),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(0),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(0),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(0),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(0),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(0),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH0_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH0_o,
                        RXn_i                =>  RXn_i(0),
                        RXp_i                =>  RXp_i(0),
                        TXn_o                =>  TXn_o(0),
                        TXp_o                =>  TXp_o(0),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(0)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(0)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(0)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(0)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(0)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(0)
                );
        END GENERATE;
        
        channel_1_gen: IF CH1_EN = true GENERATE
           channel_1 : mgt_channel_inst_1
               port map(
                    MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                    MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(1),
                    MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(1),
                    MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(1),
                    MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(1),
                    MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(1),
                    MGT_RXSlide_i        =>  MGT_RXSlide_i(1),
                    MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(1),
                    MGT_TXCALIB_i        =>  (others => '0'),
                    MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(1),
                    MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(1),
                    MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(1),
                    MGT_TX_PIPHASE_o     =>  open,
                    MGT_USRWORD_i        =>  MGT_USRWORD_CH1_i,
                    MGT_USRWORD_o        =>  MGT_USRWORD_CH1_o,
                    RXn_i                =>  RXn_i(1),
                    RXp_i                =>  RXp_i(1),
                    TXn_o                =>  TXn_o(1),
                    TXp_o                =>  TXp_o(1),
                    --===============--
                    -- from master quad
                    --===============--
                    mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(1)),
                    qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(1)),
                    qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(1)),
                    qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(1)),
                    qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(1)),
                    --===============--
                    -- to master quad
                    --===============--
                    qpll0reset          => master_mgt_to_common_qpll0reset(1)
            );
        END GENERATE;
        
        channel_2_gen: IF CH2_EN = true GENERATE
           channel_2 : mgt_channel_inst_2
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(2),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(2),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(2),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(2),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(2),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(2),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(2),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(2),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(2),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(2),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH2_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH2_o,
                        RXn_i                =>  RXn_i(2),
                        RXp_i                =>  RXp_i(2),
                        TXn_o                =>  TXn_o(2),
                        TXp_o                =>  TXp_o(2),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(2)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(2)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(2)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(2)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(2)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(2)
                );
        END GENERATE;
        
        channel_3_gen: IF CH3_EN = true GENERATE
            channel_3 : mgt_channel_inst_3
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(3),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(3),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(3),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(3),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(3),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(3),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(3),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(3),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(3),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(3),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH3_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH3_o,
                        RXn_i                =>  RXn_i(3),
                        RXp_i                =>  RXp_i(3),
                        TXn_o                =>  TXn_o(3),
                        TXp_o                =>  TXp_o(3),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(3)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(3)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(3)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(3)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(3)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(3)
                );
        END GENERATE;
        
        channel_4_gen: IF CH4_EN = true GENERATE
           channel_4 : mgt_channel_inst_4
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(4),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(4),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(4),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(4),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(4),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(4),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(4),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(4),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(4),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(4),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH4_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH4_o,
                        RXn_i                =>  RXn_i(4),
                        RXp_i                =>  RXp_i(4),
                        TXn_o                =>  TXn_o(4),
                        TXp_o                =>  TXp_o(4),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(4)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(4)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(4)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(4)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(4)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(4)
                );
        END GENERATE;
        
        channel_5_gen: IF CH5_EN = true GENERATE
           channel_5 : mgt_channel_inst_5
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(5),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(5),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(5),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(5),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(5),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(5),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(5),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(5),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(5),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(5),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH5_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH5_o,
                        RXn_i                =>  RXn_i(5),
                        RXp_i                =>  RXp_i(5),
                        TXn_o                =>  TXn_o(5),
                        TXp_o                =>  TXp_o(5),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(5)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(5)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(5)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(5)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(5)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(5)
                );
        END GENERATE;
        
        channel_6_gen: IF CH6_EN = true GENERATE
            channel_6 : mgt_channel_inst_6
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(6),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(6),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(6),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(6),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(6),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(6),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(6),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(6),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(6),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(6),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH6_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH6_o,
                        RXn_i                =>  RXn_i(6),
                        RXp_i                =>  RXp_i(6),
                        TXn_o                =>  TXn_o(6),
                        TXp_o                =>  TXp_o(6),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(6)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(6)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(6)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(6)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(6)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(6)
                );
        END GENERATE;
        
        channel_7_gen: IF CH7_EN = true GENERATE
            channel_7 : mgt_channel_inst_7
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(7),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(7),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(7),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(7),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(7),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(7),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(7),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(7),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(7),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(7),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH7_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH7_o,
                        RXn_i                =>  RXn_i(7),
                        RXp_i                =>  RXp_i(7),
                        TXn_o                =>  TXn_o(7),
                        TXp_o                =>  TXp_o(7),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(7)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(7)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(7)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(7)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(7)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(7)
                );
        END GENERATE;
        
        channel_8_gen: IF CH8_EN = true GENERATE
           channel_8 : mgt_channel_inst_8
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(8),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(8),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(8),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(8),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(8),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(8),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(8),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(8),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(8),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(8),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH8_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH8_o,
                        RXn_i                =>  RXn_i(8),
                        RXp_i                =>  RXp_i(8),
                        TXn_o                =>  TXn_o(8),
                        TXp_o                =>  TXp_o(8),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(8)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(8)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(8)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(8)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(8)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(8)
                );
        END GENERATE;
        
        channel_9_gen: IF CH9_EN = true GENERATE
            channel_9 : mgt_channel_inst_9
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(9),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(9),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(9),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(9),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(9),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(9),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(9),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(9),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(9),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(9),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH9_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH9_o,
                        RXn_i                =>  RXn_i(9),
                        RXp_i                =>  RXp_i(9),
                        TXn_o                =>  TXn_o(9),
                        TXp_o                =>  TXp_o(9),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(9)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(9)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(9)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(9)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(9)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(9)
                );
        END GENERATE;
        
        channel_10_gen: IF CH10_EN = true GENERATE
           channel_10 : mgt_channel_inst_10
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(10),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(10),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(10),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(10),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(10),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(10),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(10),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(10),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(10),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(10),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH10_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH10_o,
                        RXn_i                =>  RXn_i(10),
                        RXp_i                =>  RXp_i(10),
                        TXn_o                =>  TXn_o(10),
                        TXp_o                =>  TXp_o(10),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(10)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(10)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(10)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(10)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(10)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(10)
                );
        END GENERATE;
        
        channel_11_gen: IF CH11_EN = true GENERATE
            channel_11 : mgt_channel_inst_11
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(11),
                        MGT_TXRESET_i        =>  MGT_TXRESET_FF_i(11),
                        MGT_RXRESET_i        =>  MGT_RXRESET_FF_i(11),
                        MGT_TXPolarity_i     =>  MGT_FF_TXPolarity_i(11),
                        MGT_RXPolarity_i     =>  MGT_FF_RXPolarity_i(11),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(11),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(11),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_FF_o(11),
                        MGT_RXREADY_o        =>  MGT_RXREADY_FF_o(11),
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_FF_o(11),
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH11_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH11_o,
                        RXn_i                =>  RXn_i(11),
                        RXp_i                =>  RXp_i(11),
                        TXn_o                =>  TXn_o(11),
                        TXp_o                =>  TXp_o(11),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(11)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(11)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(11)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(11)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(11)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(11)
                );
                END GENERATE;
        END GENERATE;
        
    SFP_GEN : IF COM_SEL = 1 GENERATE
         channel_11_gen: IF CH11_EN = true GENERATE          
            channel_12 : mgt_channel_inst_12
                port map(
                        MGT_FREEDRPCLK_i     =>  MGT_FREEDRPCLK_i, 
                        MGT_RXUSRCLK_o       =>  MGT_RXUSRCLK_o(12),
                        MGT_TXRESET_i        =>  MGT_TXRESET_SFP_i,
                        MGT_RXRESET_i        =>  MGT_RXRESET_SFP_i,
                        MGT_TXPolarity_i     =>  MGT_SFP_TXPolarity_i(0),
                        MGT_RXPolarity_i     =>  MGT_SFP_RXPolarity_i(0),
                        MGT_RXSlide_i        =>  MGT_RXSlide_i(12),
                        MGT_ENTXCALIBIN_i    =>  MGT_ENTXCALIBIN_i(12),
                        MGT_TXCALIB_i        =>  (others => '0'),
                        MGT_TXREADY_o        =>  MGT_TXREADY_SFP_o,
                        MGT_RXREADY_o        =>  MGT_RXREADY_SFP_o,
                        MGT_TX_ALIGNED_o     =>  MGT_TX_ALIGNED_SFP_o,
                        MGT_TX_PIPHASE_o     =>  open,
                        MGT_USRWORD_i        =>  MGT_USRWORD_CH12_i,
                        MGT_USRWORD_o        =>  MGT_USRWORD_CH12_o,
                        RXn_i                =>  RXn_i(12),
                        RXp_i                =>  RXp_i(12),
                        TXn_o                =>  TXn_o(12),
                        TXp_o                =>  TXp_o(12),
                        --===============--
                        -- from master quad
                        --===============--
                        mgt_qpll0lock       =>  master_common_to_mgt_qpll0lock(c_MASTER_CHANNEL_QUADS(12)),
                        qpll0clk            =>  master_common_to_mgt_qpll0outclk(c_MASTER_CHANNEL_QUADS(12)),
                        qpll0refclk         =>  master_common_to_mgt_qpll0outrefclk(c_MASTER_CHANNEL_QUADS(12)),
                        qpll1clk            =>  master_common_to_mgt_qpll1outclk(c_MASTER_CHANNEL_QUADS(12)),
                        qpll1refclk         =>  master_common_to_mgt_qpll1outrefclk(c_MASTER_CHANNEL_QUADS(12)),
                        --===============--
                        -- to master quad
                        --===============--
                        qpll0reset          => master_mgt_to_common_qpll0reset(12)
                );
                END GENERATE;
            END GENERATE;                
end Behavioral;