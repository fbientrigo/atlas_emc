-- -----------------------------------------------------------------------------
-- 'fw_monitor' Register Definitions
-- Revision: 237
-- -----------------------------------------------------------------------------
-- Generated on 2024-06-06 at 12:15 (UTC) by airhdl version 2023.07.1-936312266
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

package fw_monitor_regs_pkg is

    -- Revision number of the 'fw_monitor' register map
    constant FW_MONITOR_REVISION : natural := 237;

    -- Default base address of the 'fw_monitor' register map
    constant FW_MONITOR_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"B0000000");

    -- Size of the 'fw_monitor' register map, in bytes
    constant FW_MONITOR_RANGE_BYTES : natural := 20;

    -- Register 'reset_reg_1'
    constant RESET_REG_1_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000000"); -- address offset of the 'reset_reg_1' register

    -- Field 'reset_reg_1.emp_lpgbt_ip'
    constant RESET_REG_1_EMP_LPGBT_IP_BIT_OFFSET : natural := 0; -- bit offset of the 'emp_lpgbt_ip' field
    constant RESET_REG_1_EMP_LPGBT_IP_BIT_WIDTH : natural := 13; -- bit width of the 'emp_lpgbt_ip' field
    constant RESET_REG_1_EMP_LPGBT_IP_RESET : std_logic_vector(12 downto 0) := std_logic_vector'("0000000000000"); -- reset value of the 'emp_lpgbt_ip' field

    -- Register 'reset_reg_2'
    constant RESET_REG_2_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000004"); -- address offset of the 'reset_reg_2' register

    -- Field 'reset_reg_2.tx_reset'
    constant RESET_REG_2_TX_RESET_BIT_OFFSET : natural := 0; -- bit offset of the 'tx_reset' field
    constant RESET_REG_2_TX_RESET_BIT_WIDTH : natural := 13; -- bit width of the 'tx_reset' field
    constant RESET_REG_2_TX_RESET_RESET : std_logic_vector(12 downto 0) := std_logic_vector'("0000000000000"); -- reset value of the 'tx_reset' field

    -- Field 'reset_reg_2.rx_reset'
    constant RESET_REG_2_RX_RESET_BIT_OFFSET : natural := 13; -- bit offset of the 'rx_reset' field
    constant RESET_REG_2_RX_RESET_BIT_WIDTH : natural := 13; -- bit width of the 'rx_reset' field
    constant RESET_REG_2_RX_RESET_RESET : std_logic_vector(25 downto 13) := std_logic_vector'("0000000000000"); -- reset value of the 'rx_reset' field

    -- Register 'status_reg_1'
    constant STATUS_REG_1_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'status_reg_1' register

    -- Field 'status_reg_1.tx_alignment'
    constant STATUS_REG_1_TX_ALIGNMENT_BIT_OFFSET : natural := 0; -- bit offset of the 'tx_alignment' field
    constant STATUS_REG_1_TX_ALIGNMENT_BIT_WIDTH : natural := 13; -- bit width of the 'tx_alignment' field
    constant STATUS_REG_1_TX_ALIGNMENT_RESET : std_logic_vector(12 downto 0) := std_logic_vector'("0000000000000"); -- reset value of the 'tx_alignment' field

    -- Register 'status_reg_2'
    constant STATUS_REG_2_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000000C"); -- address offset of the 'status_reg_2' register

    -- Field 'status_reg_2.tx_ready'
    constant STATUS_REG_2_TX_READY_BIT_OFFSET : natural := 0; -- bit offset of the 'tx_ready' field
    constant STATUS_REG_2_TX_READY_BIT_WIDTH : natural := 13; -- bit width of the 'tx_ready' field
    constant STATUS_REG_2_TX_READY_RESET : std_logic_vector(12 downto 0) := std_logic_vector'("0000000000000"); -- reset value of the 'tx_ready' field

    -- Field 'status_reg_2.rx_ready'
    constant STATUS_REG_2_RX_READY_BIT_OFFSET : natural := 13; -- bit offset of the 'rx_ready' field
    constant STATUS_REG_2_RX_READY_BIT_WIDTH : natural := 13; -- bit width of the 'rx_ready' field
    constant STATUS_REG_2_RX_READY_RESET : std_logic_vector(25 downto 13) := std_logic_vector'("0000000000000"); -- reset value of the 'rx_ready' field

    -- Register 'status_reg_3'
    constant STATUS_REG_3_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000010"); -- address offset of the 'status_reg_3' register

    -- Field 'status_reg_3.lpgbt_rx_locked'
    constant STATUS_REG_3_LPGBT_RX_LOCKED_BIT_OFFSET : natural := 0; -- bit offset of the 'lpgbt_rx_locked' field
    constant STATUS_REG_3_LPGBT_RX_LOCKED_BIT_WIDTH : natural := 13; -- bit width of the 'lpgbt_rx_locked' field
    constant STATUS_REG_3_LPGBT_RX_LOCKED_RESET : std_logic_vector(12 downto 0) := std_logic_vector'("0000000000000"); -- reset value of the 'lpgbt_rx_locked' field

    -- Field 'status_reg_3.lpgbt_tx_ready'
    constant STATUS_REG_3_LPGBT_TX_READY_BIT_OFFSET : natural := 13; -- bit offset of the 'lpgbt_tx_ready' field
    constant STATUS_REG_3_LPGBT_TX_READY_BIT_WIDTH : natural := 13; -- bit width of the 'lpgbt_tx_ready' field
    constant STATUS_REG_3_LPGBT_TX_READY_RESET : std_logic_vector(25 downto 13) := std_logic_vector'("0000000000000"); -- reset value of the 'lpgbt_tx_ready' field

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

end fw_monitor_regs_pkg;
