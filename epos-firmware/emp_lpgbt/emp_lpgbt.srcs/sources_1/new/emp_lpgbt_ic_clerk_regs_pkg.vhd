-- -----------------------------------------------------------------------------
-- 'emp_lpgbt_ic_clerk' Register Definitions
-- Revision: 201
-- -----------------------------------------------------------------------------
-- Generated on 2021-01-18 at 16:32 (UTC) by airhdl version 2020.10.1
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

package emp_lpgbt_ic_clerk_regs_pkg is

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


    -- Revision number of the 'emp_lpgbt_ic_clerk' register map
    constant EMP_LPGBT_IC_CLERK_REVISION : natural := 201;

    -- Default base address of the 'emp_lpgbt_ic_clerk' register map 
    constant EMP_LPGBT_IC_CLERK_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"A0000000");
    
    -- Register 'magic'
    constant MAGIC_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000000"); -- address offset of the 'magic' register
    -- Field 'magic.value'
    constant MAGIC_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant MAGIC_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant MAGIC_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("01100101011011010111000001001001"); -- reset value of the 'value' field
    
    -- Register 'control'
    constant CONTROL_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000004"); -- address offset of the 'control' register
    -- Field 'control.FIFOCtrl'
    constant CONTROL_FIFOCTRL_BIT_OFFSET : natural := 0; -- bit offset of the 'FIFOCtrl' field
    constant CONTROL_FIFOCTRL_BIT_WIDTH : natural := 2; -- bit width of the 'FIFOCtrl' field
    constant CONTROL_FIFOCTRL_RESET : std_logic_vector(1 downto 0) := std_logic_vector'("00"); -- reset value of the 'FIFOCtrl' field
    -- Enumerated values for field 'control.FIFOCtrl'
    constant CONTROL_FIFOCTRL_DEFAULT : natural := 0;
    constant CONTROL_FIFOCTRL_READ : natural := 1;
    constant CONTROL_FIFOCTRL_WRITE : natural := 2;
    constant CONTROL_FIFOCTRL_ERR : natural := 3;
    -- Field 'control.lpGBTCtrl'
    constant CONTROL_LPGBTCTRL_BIT_OFFSET : natural := 2; -- bit offset of the 'lpGBTCtrl' field
    constant CONTROL_LPGBTCTRL_BIT_WIDTH : natural := 2; -- bit width of the 'lpGBTCtrl' field
    constant CONTROL_LPGBTCTRL_RESET : std_logic_vector(3 downto 2) := std_logic_vector'("00"); -- reset value of the 'lpGBTCtrl' field
    -- Enumerated values for field 'control.lpGBTCtrl'
    constant CONTROL_LPGBTCTRL_DEFAULT : natural := 0;
    constant CONTROL_LPGBTCTRL_READ : natural := 1;
    constant CONTROL_LPGBTCTRL_WRITE : natural := 2;
    constant CONTROL_LPGBTCTRL_ERR : natural := 3;
    -- Field 'control.single_write_read'
    constant CONTROL_SINGLE_WRITE_READ_BIT_OFFSET : natural := 4; -- bit offset of the 'single_write_read' field
    constant CONTROL_SINGLE_WRITE_READ_BIT_WIDTH : natural := 1; -- bit width of the 'single_write_read' field
    constant CONTROL_SINGLE_WRITE_READ_RESET : std_logic_vector(4 downto 4) := std_logic_vector'("0"); -- reset value of the 'single_write_read' field
    -- Field 'control.NB_read'
    constant CONTROL_NB_READ_BIT_OFFSET : natural := 16; -- bit offset of the 'NB_read' field
    constant CONTROL_NB_READ_BIT_WIDTH : natural := 16; -- bit width of the 'NB_read' field
    constant CONTROL_NB_READ_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'NB_read' field
    
    -- Register 'status'
    constant STATUS_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'status' register
    -- Field 'status.ready_flag'
    constant STATUS_READY_FLAG_BIT_OFFSET : natural := 0; -- bit offset of the 'ready_flag' field
    constant STATUS_READY_FLAG_BIT_WIDTH : natural := 1; -- bit width of the 'ready_flag' field
    constant STATUS_READY_FLAG_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'ready_flag' field
    -- Field 'status.empty_flag'
    constant STATUS_EMPTY_FLAG_BIT_OFFSET : natural := 1; -- bit offset of the 'empty_flag' field
    constant STATUS_EMPTY_FLAG_BIT_WIDTH : natural := 1; -- bit width of the 'empty_flag' field
    constant STATUS_EMPTY_FLAG_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'empty_flag' field
    -- Field 'status.parity_error'
    constant STATUS_PARITY_ERROR_BIT_OFFSET : natural := 2; -- bit offset of the 'parity_error' field
    constant STATUS_PARITY_ERROR_BIT_WIDTH : natural := 1; -- bit width of the 'parity_error' field
    constant STATUS_PARITY_ERROR_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'parity_error' field
    -- Field 'status.timeout_error'
    constant STATUS_TIMEOUT_ERROR_BIT_OFFSET : natural := 3; -- bit offset of the 'timeout_error' field
    constant STATUS_TIMEOUT_ERROR_BIT_WIDTH : natural := 1; -- bit width of the 'timeout_error' field
    constant STATUS_TIMEOUT_ERROR_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'timeout_error' field
    
    -- Register 'data_rx'
    constant DATA_RX_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000000C"); -- address offset of the 'data_rx' register
    -- Field 'data_rx.data'
    constant DATA_RX_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'data' field
    constant DATA_RX_DATA_BIT_WIDTH : natural := 8; -- bit width of the 'data' field
    constant DATA_RX_DATA_RESET : std_logic_vector(7 downto 0) := std_logic_vector'("00000000"); -- reset value of the 'data' field
    
    -- Register 'data_tx'
    constant DATA_TX_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000010"); -- address offset of the 'data_tx' register
    -- Field 'data_tx.data'
    constant DATA_TX_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'data' field
    constant DATA_TX_DATA_BIT_WIDTH : natural := 8; -- bit width of the 'data' field
    constant DATA_TX_DATA_RESET : std_logic_vector(7 downto 0) := std_logic_vector'("00000000"); -- reset value of the 'data' field
    
    -- Register 'register_addr'
    constant REGISTER_ADDR_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000014"); -- address offset of the 'register_addr' register
    -- Field 'register_addr.addr'
    constant REGISTER_ADDR_ADDR_BIT_OFFSET : natural := 0; -- bit offset of the 'addr' field
    constant REGISTER_ADDR_ADDR_BIT_WIDTH : natural := 16; -- bit width of the 'addr' field
    constant REGISTER_ADDR_ADDR_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'addr' field
    
    -- Register 'lpGBT_addr'
    constant LPGBT_ADDR_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000018"); -- address offset of the 'lpGBT_addr' register
    -- Field 'lpGBT_addr.addr'
    constant LPGBT_ADDR_ADDR_BIT_OFFSET : natural := 0; -- bit offset of the 'addr' field
    constant LPGBT_ADDR_ADDR_BIT_WIDTH : natural := 8; -- bit width of the 'addr' field
    constant LPGBT_ADDR_ADDR_RESET : std_logic_vector(7 downto 0) := std_logic_vector'("00000000"); -- reset value of the 'addr' field
    
    -- Register 'interrupt_enable'
    constant INTERRUPT_ENABLE_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000001C"); -- address offset of the 'interrupt_enable' register
    -- Field 'interrupt_enable.IC_resp'
    constant INTERRUPT_ENABLE_IC_RESP_BIT_OFFSET : natural := 0; -- bit offset of the 'IC_resp' field
    constant INTERRUPT_ENABLE_IC_RESP_BIT_WIDTH : natural := 1; -- bit width of the 'IC_resp' field
    constant INTERRUPT_ENABLE_IC_RESP_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'IC_resp' field
    
    -- Register 'interrupt_flags'
    constant INTERRUPT_FLAGS_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000020"); -- address offset of the 'interrupt_flags' register
    -- Field 'interrupt_flags.IC_resp'
    constant INTERRUPT_FLAGS_IC_RESP_BIT_OFFSET : natural := 0; -- bit offset of the 'IC_resp' field
    constant INTERRUPT_FLAGS_IC_RESP_BIT_WIDTH : natural := 1; -- bit width of the 'IC_resp' field
    constant INTERRUPT_FLAGS_IC_RESP_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'IC_resp' field
    
    -- Register 'interrupt_clear'
    constant INTERRUPT_CLEAR_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000024"); -- address offset of the 'interrupt_clear' register
    -- Field 'interrupt_clear.IC_resp'
    constant INTERRUPT_CLEAR_IC_RESP_BIT_OFFSET : natural := 0; -- bit offset of the 'IC_resp' field
    constant INTERRUPT_CLEAR_IC_RESP_BIT_WIDTH : natural := 1; -- bit width of the 'IC_resp' field
    constant INTERRUPT_CLEAR_IC_RESP_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'IC_resp' field
    
    -- Register 'reset'
    constant RESET_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000028"); -- address offset of the 'reset' register
    -- Field 'reset.reset'
    constant RESET_RESET_BIT_OFFSET : natural := 0; -- bit offset of the 'reset' field
    constant RESET_RESET_BIT_WIDTH : natural := 1; -- bit width of the 'reset' field
    constant RESET_RESET_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'reset' field
    
    -- Register 'counter_lhc_clock'
    constant COUNTER_LHC_CLOCK_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000100"); -- address offset of the 'counter_lhc_clock' register
    -- Field 'counter_lhc_clock.value'
    constant COUNTER_LHC_CLOCK_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant COUNTER_LHC_CLOCK_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant COUNTER_LHC_CLOCK_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

end emp_lpgbt_ic_clerk_regs_pkg;
