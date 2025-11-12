-- -----------------------------------------------------------------------------
-- 'eLink_Interface' Register Definitions
-- Revision: 112
-- -----------------------------------------------------------------------------
-- Generated on 2024-11-06 at 10:23 (UTC) by airhdl version 2023.07.1-936312266
-- -----------------------------------------------------------------------------
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package eLink_Interface_regs_pkg is

    -- Revision number of the 'eLink_Interface' register map
    constant ELINK_INTERFACE_REVISION : natural := 112;

    -- Default base address of the 'eLink_Interface' register map
    constant ELINK_INTERFACE_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"00000000");

    -- Size of the 'eLink_Interface' register map, in bytes
    constant ELINK_INTERFACE_RANGE_BYTES : natural := 48;

    -- Register 'magic'
    constant MAGIC_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000000"); -- address offset of the 'magic' register

    -- Field 'magic.value'
    constant MAGIC_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant MAGIC_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant MAGIC_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'status'
    constant STATUS_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000004"); -- address offset of the 'status' register

    -- Field 'status.dLinkFIFO_empty'
    constant STATUS_DLINKFIFO_EMPTY_BIT_OFFSET : natural := 0; -- bit offset of the 'dLinkFIFO_empty' field
    constant STATUS_DLINKFIFO_EMPTY_BIT_WIDTH : natural := 1; -- bit width of the 'dLinkFIFO_empty' field
    constant STATUS_DLINKFIFO_EMPTY_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'dLinkFIFO_empty' field

    -- Field 'status.dLinkFIFO_full'
    constant STATUS_DLINKFIFO_FULL_BIT_OFFSET : natural := 1; -- bit offset of the 'dLinkFIFO_full' field
    constant STATUS_DLINKFIFO_FULL_BIT_WIDTH : natural := 1; -- bit width of the 'dLinkFIFO_full' field
    constant STATUS_DLINKFIFO_FULL_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'dLinkFIFO_full' field

    -- Field 'status.uLinkFIFO_empty'
    constant STATUS_ULINKFIFO_EMPTY_BIT_OFFSET : natural := 2; -- bit offset of the 'uLinkFIFO_empty' field
    constant STATUS_ULINKFIFO_EMPTY_BIT_WIDTH : natural := 1; -- bit width of the 'uLinkFIFO_empty' field
    constant STATUS_ULINKFIFO_EMPTY_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'uLinkFIFO_empty' field

    -- Field 'status.uLinkFIFO_full'
    constant STATUS_ULINKFIFO_FULL_BIT_OFFSET : natural := 3; -- bit offset of the 'uLinkFIFO_full' field
    constant STATUS_ULINKFIFO_FULL_BIT_WIDTH : natural := 1; -- bit width of the 'uLinkFIFO_full' field
    constant STATUS_ULINKFIFO_FULL_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'uLinkFIFO_full' field

    -- Register 'control'
    constant CONTROL_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'control' register

    -- Field 'control.ACK'
    constant CONTROL_ACK_BIT_OFFSET : natural := 0; -- bit offset of the 'ACK' field
    constant CONTROL_ACK_BIT_WIDTH : natural := 1; -- bit width of the 'ACK' field
    constant CONTROL_ACK_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'ACK' field

    -- Register 'downLinkData'
    constant DOWNLINKDATA_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000010"); -- address offset of the 'downLinkData' register

    -- Field 'downLinkData.dataWord'
    constant DOWNLINKDATA_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant DOWNLINKDATA_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant DOWNLINKDATA_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_0'
    constant UPLINKDATAGRP_0_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000014"); -- address offset of the 'upLinkDataGrp_0' register

    -- Field 'upLinkDataGrp_0.dataWord'
    constant UPLINKDATAGRP_0_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_0_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_0_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_1'
    constant UPLINKDATAGRP_1_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000018"); -- address offset of the 'upLinkDataGrp_1' register

    -- Field 'upLinkDataGrp_1.dataWord'
    constant UPLINKDATAGRP_1_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_1_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_1_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_2'
    constant UPLINKDATAGRP_2_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000001C"); -- address offset of the 'upLinkDataGrp_2' register

    -- Field 'upLinkDataGrp_2.dataWord'
    constant UPLINKDATAGRP_2_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_2_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_2_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_3'
    constant UPLINKDATAGRP_3_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000020"); -- address offset of the 'upLinkDataGrp_3' register

    -- Field 'upLinkDataGrp_3.dataWord'
    constant UPLINKDATAGRP_3_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_3_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_3_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_4'
    constant UPLINKDATAGRP_4_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000024"); -- address offset of the 'upLinkDataGrp_4' register

    -- Field 'upLinkDataGrp_4.dataWord'
    constant UPLINKDATAGRP_4_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_4_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_4_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_5'
    constant UPLINKDATAGRP_5_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000028"); -- address offset of the 'upLinkDataGrp_5' register

    -- Field 'upLinkDataGrp_5.dataWord'
    constant UPLINKDATAGRP_5_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_5_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_5_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Register 'upLinkDataGrp_6'
    constant UPLINKDATAGRP_6_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000002C"); -- address offset of the 'upLinkDataGrp_6' register

    -- Field 'upLinkDataGrp_6.dataWord'
    constant UPLINKDATAGRP_6_DATAWORD_BIT_OFFSET : natural := 0; -- bit offset of the 'dataWord' field
    constant UPLINKDATAGRP_6_DATAWORD_BIT_WIDTH : natural := 32; -- bit width of the 'dataWord' field
    constant UPLINKDATAGRP_6_DATAWORD_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'dataWord' field

    -- Type definitions
    type slv1_array_t is array(natural range <>) of std_logic_vector(0 downto 0);
    type slv2_array_t is array(natural range <>) of std_logic_vector(1 downto 0);
    type slv3_array_t is array(natural range <>) of std_logic_vector(2 downto 0);
    type slv4_array_t is array(natural range <>) of std_logic_vector(3 downto 0);
    type slv5_array_t is array(natural range <>) of std_logic_vector(4 downto 0);
    type slv6_array_t is array(natural range <>) of std_logic_vector(5 downto 0);
    type slv7_array_t is array(natural range <>) of std_logic_vector(6 downto 0);
    type slv8_array_t is array(natural range <>) of std_logic_vector(7 downto 0);
    type slv9_array_t is array(natural range <>) of std_logic_vector(8 downto 0);
    type slv10_array_t is array(natural range <>) of std_logic_vector(9 downto 0);
    type slv11_array_t is array(natural range <>) of std_logic_vector(10 downto 0);
    type slv12_array_t is array(natural range <>) of std_logic_vector(11 downto 0);
    type slv13_array_t is array(natural range <>) of std_logic_vector(12 downto 0);
    type slv14_array_t is array(natural range <>) of std_logic_vector(13 downto 0);
    type slv15_array_t is array(natural range <>) of std_logic_vector(14 downto 0);
    type slv16_array_t is array(natural range <>) of std_logic_vector(15 downto 0);
    type slv17_array_t is array(natural range <>) of std_logic_vector(16 downto 0);
    type slv18_array_t is array(natural range <>) of std_logic_vector(17 downto 0);
    type slv19_array_t is array(natural range <>) of std_logic_vector(18 downto 0);
    type slv20_array_t is array(natural range <>) of std_logic_vector(19 downto 0);
    type slv21_array_t is array(natural range <>) of std_logic_vector(20 downto 0);
    type slv22_array_t is array(natural range <>) of std_logic_vector(21 downto 0);
    type slv23_array_t is array(natural range <>) of std_logic_vector(22 downto 0);
    type slv24_array_t is array(natural range <>) of std_logic_vector(23 downto 0);
    type slv25_array_t is array(natural range <>) of std_logic_vector(24 downto 0);
    type slv26_array_t is array(natural range <>) of std_logic_vector(25 downto 0);
    type slv27_array_t is array(natural range <>) of std_logic_vector(26 downto 0);
    type slv28_array_t is array(natural range <>) of std_logic_vector(27 downto 0);
    type slv29_array_t is array(natural range <>) of std_logic_vector(28 downto 0);
    type slv30_array_t is array(natural range <>) of std_logic_vector(29 downto 0);
    type slv31_array_t is array(natural range <>) of std_logic_vector(30 downto 0);
    type slv32_array_t is array(natural range <>) of std_logic_vector(31 downto 0);

end eLink_Interface_regs_pkg;
