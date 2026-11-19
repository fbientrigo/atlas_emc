-- -----------------------------------------------------------------------------
-- 'cmb_event' Register Definitions
-- Revision: 29
-- -----------------------------------------------------------------------------
-- Generated on 2026-11-17 at 04:50 (UTC) by airhdl version 2023.07.1-936312266
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

package cmb_event_regs_pkg is

    -- Revision number of the 'cmb_event' register map
    constant CMB_EVENT_REVISION : natural := 29;

    -- Default base address of the 'cmb_event' register map
    constant CMB_EVENT_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"A01B0000");

    -- Size of the 'cmb_event' register map, in bytes
    constant CMB_EVENT_RANGE_BYTES : natural := 45184;

    -- Register 'magic'
    constant MAGIC_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000000"); -- address offset of the 'magic' register

    -- Field 'magic.value'
    constant MAGIC_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant MAGIC_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant MAGIC_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'control'
    constant CONTROL_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000004"); -- address offset of the 'control' register

    -- Field 'control.enable'
    constant CONTROL_ENABLE_BIT_OFFSET : natural := 0; -- bit offset of the 'enable' field
    constant CONTROL_ENABLE_BIT_WIDTH : natural := 1; -- bit width of the 'enable' field
    constant CONTROL_ENABLE_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'enable' field

    -- Field 'control.ack'
    constant CONTROL_ACK_BIT_OFFSET : natural := 1; -- bit offset of the 'ack' field
    constant CONTROL_ACK_BIT_WIDTH : natural := 1; -- bit width of the 'ack' field
    constant CONTROL_ACK_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'ack' field

    -- Field 'control.soft_reset'
    constant CONTROL_SOFT_RESET_BIT_OFFSET : natural := 2; -- bit offset of the 'soft_reset' field
    constant CONTROL_SOFT_RESET_BIT_WIDTH : natural := 1; -- bit width of the 'soft_reset' field
    constant CONTROL_SOFT_RESET_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'soft_reset' field

    -- Field 'control.test_start'
    constant CONTROL_TEST_START_BIT_OFFSET : natural := 3; -- bit offset of the 'test_start' field
    constant CONTROL_TEST_START_BIT_WIDTH : natural := 1; -- bit width of the 'test_start' field
    constant CONTROL_TEST_START_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'test_start' field

    -- Register 'status'
    constant STATUS_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'status' register

    -- Field 'status.busy'
    constant STATUS_BUSY_BIT_OFFSET : natural := 0; -- bit offset of the 'busy' field
    constant STATUS_BUSY_BIT_WIDTH : natural := 1; -- bit width of the 'busy' field
    constant STATUS_BUSY_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'busy' field

    -- Field 'status.ready'
    constant STATUS_READY_BIT_OFFSET : natural := 1; -- bit offset of the 'ready' field
    constant STATUS_READY_BIT_WIDTH : natural := 1; -- bit width of the 'ready' field
    constant STATUS_READY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'ready' field

    -- Field 'status.overflow'
    constant STATUS_OVERFLOW_BIT_OFFSET : natural := 2; -- bit offset of the 'overflow' field
    constant STATUS_OVERFLOW_BIT_WIDTH : natural := 1; -- bit width of the 'overflow' field
    constant STATUS_OVERFLOW_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'overflow' field

    -- Field 'status.veto'
    constant STATUS_VETO_BIT_OFFSET : natural := 3; -- bit offset of the 'veto' field
    constant STATUS_VETO_BIT_WIDTH : natural := 1; -- bit width of the 'veto' field
    constant STATUS_VETO_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'veto' field

    -- Register 'event_size'
    constant EVENT_SIZE_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000000C"); -- address offset of the 'event_size' register

    -- Field 'event_size.value'
    constant EVENT_SIZE_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant EVENT_SIZE_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant EVENT_SIZE_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'event_id'
    constant EVENT_ID_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000010"); -- address offset of the 'event_id' register

    -- Field 'event_id.value'
    constant EVENT_ID_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant EVENT_ID_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant EVENT_ID_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'overflow_count'
    constant OVERFLOW_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000014"); -- address offset of the 'overflow_count' register

    -- Field 'overflow_count.value'
    constant OVERFLOW_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant OVERFLOW_COUNT_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant OVERFLOW_COUNT_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'data_mem'
    constant DATA_MEM_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001000"); -- address offset of the 'data_mem' register
    constant DATA_MEM_DEPTH : natural := 10272; -- depth of the 'data_mem' memory, in elements
    constant DATA_MEM_READ_LATENCY : natural := 1; -- read latency of the 'data_mem' memory, in clock cycles

    -- Field 'data_mem.value'
    constant DATA_MEM_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant DATA_MEM_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant DATA_MEM_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

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

end cmb_event_regs_pkg;
