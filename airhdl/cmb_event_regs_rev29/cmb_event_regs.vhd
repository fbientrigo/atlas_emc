----------------------------------------------------------------------------------------------------
-- 'cmb_event' Register Component
-- Revision: 29
----------------------------------------------------------------------------------------------------
-- Generated on 2026-11-17 at 04:50 (UTC) by airhdl version 2023.07.1-936312266
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cmb_event_regs_pkg.all;

entity cmb_event_regs is
    generic(
        AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address word, in bits
        BASEADDR : std_logic_vector(31 downto 0) := x"A01B0000" -- register bank AXI base address
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
        magic_strobe : out std_logic; -- strobe signal for register 'magic' (pulsed when the register is read from the bus)
        magic_value : in std_logic_vector(31 downto 0); -- read value of field 'magic.value'
        control_strobe : out std_logic; -- strobe signal for register 'control' (pulsed when the register is written from the bus)
        control_enable : out std_logic_vector(0 downto 0); -- write value of field 'control.enable'
        control_ack : out std_logic_vector(0 downto 0); -- write value of field 'control.ack'
        control_soft_reset : out std_logic_vector(0 downto 0); -- write value of field 'control.soft_reset'
        control_test_start : out std_logic_vector(0 downto 0); -- write value of field 'control.test_start'
        status_strobe : out std_logic; -- strobe signal for register 'status' (pulsed when the register is read from the bus)
        status_busy : in std_logic_vector(0 downto 0); -- read value of field 'status.busy'
        status_ready : in std_logic_vector(0 downto 0); -- read value of field 'status.ready'
        status_overflow : in std_logic_vector(0 downto 0); -- read value of field 'status.overflow'
        status_veto : in std_logic_vector(0 downto 0); -- read value of field 'status.veto'
        event_size_strobe : out std_logic; -- strobe signal for register 'event_size' (pulsed when the register is read from the bus)
        event_size_value : in std_logic_vector(31 downto 0); -- read value of field 'event_size.value'
        event_id_strobe : out std_logic; -- strobe signal for register 'event_id' (pulsed when the register is read from the bus)
        event_id_value : in std_logic_vector(31 downto 0); -- read value of field 'event_id.value'
        overflow_count_strobe : out std_logic; -- strobe signal for register 'overflow_count' (pulsed when the register is read from the bus)
        overflow_count_value : in std_logic_vector(31 downto 0); -- read value of field 'overflow_count.value'
        data_mem_addr : out std_logic_vector(13 downto 0); -- read/write address for memory 'data_mem'
        data_mem_rdata : in std_logic_vector(31 downto 0); -- read data for memory 'data_mem'
        data_mem_ren : out std_logic -- read-enable for memory 'data_mem'
    );
end entity cmb_event_regs;

architecture RTL of cmb_event_regs is

    ------------------------------------------------------------------------------------------------
    -- Constants
    ------------------------------------------------------------------------------------------------

    constant AXI_OKAY           : std_logic_vector(1 downto 0) := "00";
    constant AXI_SLVERR         : std_logic_vector(1 downto 0) := "10";

    ------------------------------------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------------------------------------

    -- Registered signals
    signal s_axi_awready_r    : std_logic;
    signal s_axi_wready_r     : std_logic;
    signal s_axi_awaddr_reg_r : unsigned(s_axi_awaddr'range);
    signal s_axi_bvalid_r     : std_logic;
    signal s_axi_bresp_r      : std_logic_vector(s_axi_bresp'range);
    signal s_axi_arready_r    : std_logic;
    signal s_axi_araddr_reg_r : unsigned(AXI_ADDR_WIDTH - 1 downto 0);
    signal s_axi_rvalid_r     : std_logic;
    signal s_axi_rresp_r      : std_logic_vector(s_axi_rresp'range);
    signal s_axi_wdata_reg_r  : std_logic_vector(s_axi_wdata'range);
    signal s_axi_wstrb_reg_r  : std_logic_vector(s_axi_wstrb'range);
    signal s_axi_rdata_r      : std_logic_vector(s_axi_rdata'range);

    -- User-defined registers
    signal s_magic_strobe_r : std_logic;
    signal s_reg_magic_value : std_logic_vector(31 downto 0);
    signal s_control_strobe_r : std_logic;
    signal s_reg_control_enable_r : std_logic_vector(0 downto 0);
    signal s_reg_control_ack_r : std_logic_vector(0 downto 0);
    signal s_reg_control_soft_reset_r : std_logic_vector(0 downto 0);
    signal s_reg_control_test_start_r : std_logic_vector(0 downto 0);
    signal s_status_strobe_r : std_logic;
    signal s_reg_status_busy : std_logic_vector(0 downto 0);
    signal s_reg_status_ready : std_logic_vector(0 downto 0);
    signal s_reg_status_overflow : std_logic_vector(0 downto 0);
    signal s_reg_status_veto : std_logic_vector(0 downto 0);
    signal s_event_size_strobe_r : std_logic;
    signal s_reg_event_size_value : std_logic_vector(31 downto 0);
    signal s_event_id_strobe_r : std_logic;
    signal s_reg_event_id_value : std_logic_vector(31 downto 0);
    signal s_overflow_count_strobe_r : std_logic;
    signal s_reg_overflow_count_value : std_logic_vector(31 downto 0);
    signal s_data_mem_raddr_r : std_logic_vector(13 downto 0);
    signal s_data_mem_ren_r : std_logic;
    signal s_data_mem_rdata : std_logic_vector(31 downto 0);

begin

    ------------------------------------------------------------------------------------------------
    -- Inputs
    ------------------------------------------------------------------------------------------------

    s_reg_magic_value <= magic_value;
    s_reg_status_busy <= status_busy;
    s_reg_status_ready <= status_ready;
    s_reg_status_overflow <= status_overflow;
    s_reg_status_veto <= status_veto;
    s_reg_event_size_value <= event_size_value;
    s_reg_event_id_value <= event_id_value;
    s_reg_overflow_count_value <= overflow_count_value;
    s_data_mem_rdata <= data_mem_rdata;

    ------------------------------------------------------------------------------------------------
    -- Read-transaction FSM
    ------------------------------------------------------------------------------------------------

    read_fsm : process(axi_aclk, axi_aresetn) is
        constant MAX_MEMORY_LATENCY : natural := 5;
        type t_state is (IDLE, READ_REGISTER, WAIT_MEMORY_RDATA, READ_RESPONSE, DONE);
        -- registered state variables
        variable v_state_r          : t_state;
        variable v_rdata_r          : std_logic_vector(31 downto 0);
        variable v_rresp_r          : std_logic_vector(s_axi_rresp'range);
        variable v_mem_wait_count_r : natural range 0 to MAX_MEMORY_LATENCY;
        -- combinatorial helper variables
        variable v_addr_hit : boolean;
        variable v_mem_addr : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    begin
        if axi_aresetn = '0' then
            v_state_r          := IDLE;
            v_rdata_r          := (others => '0');
            v_rresp_r          := (others => '0');
            v_mem_wait_count_r := 0;
            s_axi_arready_r    <= '0';
            s_axi_rvalid_r     <= '0';
            s_axi_rresp_r      <= (others => '0');
            s_axi_araddr_reg_r <= (others => '0');
            s_axi_rdata_r      <= (others => '0');
            s_magic_strobe_r <= '0';
            s_status_strobe_r <= '0';
            s_event_size_strobe_r <= '0';
            s_event_id_strobe_r <= '0';
            s_overflow_count_strobe_r <= '0';
            s_data_mem_raddr_r <= (others => '0');
            s_data_mem_ren_r <= '0';

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_arready_r <= '0';
            s_magic_strobe_r <= '0';
            s_status_strobe_r <= '0';
            s_event_size_strobe_r <= '0';
            s_event_id_strobe_r <= '0';
            s_overflow_count_strobe_r <= '0';
            s_data_mem_raddr_r <= (others => '0');

            case v_state_r is

                -- Wait for the start of a read transaction, which is initiated by the
                -- assertion of ARVALID
                when IDLE =>
                    if s_axi_arvalid = '1' then
                        s_axi_araddr_reg_r <= unsigned(s_axi_araddr); -- save the read address
                        s_axi_arready_r    <= '1'; -- acknowledge the read-address
                        v_state_r          := READ_REGISTER;
                    end if;

                -- Read from the actual storage element
                when READ_REGISTER =>
                    -- Defaults:
                    v_addr_hit := false;
                    v_rdata_r  := (others => '0');

                    -- Register 'magic' at address offset 0x0
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + MAGIC_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_magic_value;
                        s_magic_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'control' at address offset 0x4
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + CONTROL_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_control_enable_r;
                        v_rdata_r(1 downto 1) := s_reg_control_ack_r;
                        v_rdata_r(2 downto 2) := s_reg_control_soft_reset_r;
                        v_rdata_r(3 downto 3) := s_reg_control_test_start_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'status' at address offset 0x8
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + STATUS_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_status_busy;
                        v_rdata_r(1 downto 1) := s_reg_status_ready;
                        v_rdata_r(2 downto 2) := s_reg_status_overflow;
                        v_rdata_r(3 downto 3) := s_reg_status_veto;
                        s_status_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'event_size' at address offset 0xC
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + EVENT_SIZE_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_event_size_value;
                        s_event_size_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'event_id' at address offset 0x10
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + EVENT_ID_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_event_id_value;
                        s_event_id_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'overflow_count' at address offset 0x14
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + OVERFLOW_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_overflow_count_value;
                        s_overflow_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Memory 'data_mem' at address offset 0x1000
                    if s_axi_araddr_reg_r >= resize(unsigned(BASEADDR) + DATA_MEM_OFFSET, AXI_ADDR_WIDTH) and
                        s_axi_araddr_reg_r < resize(unsigned(BASEADDR) + DATA_MEM_OFFSET + DATA_MEM_DEPTH * 4, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        -- Generate memory read address:
                        v_mem_addr := s_axi_araddr_reg_r - resize(unsigned(BASEADDR) + DATA_MEM_OFFSET, AXI_ADDR_WIDTH);
                        s_data_mem_raddr_r <= std_logic_vector(v_mem_addr(15 downto 2)); -- output address has 4-byte granularity
                        s_data_mem_ren_r <= '1';
                        v_mem_wait_count_r := DATA_MEM_READ_LATENCY;
                        v_state_r := WAIT_MEMORY_RDATA;
                    end if;
                    --
                    if v_addr_hit then
                        v_rresp_r := AXI_OKAY;
                    else
                        v_rresp_r := AXI_SLVERR;
                        -- pragma translate_off
                        report "ARADDR decode error" severity warning;
                        -- pragma translate_on
                        v_state_r := READ_RESPONSE;
                    end if;

                -- Wait for memory read data
                when WAIT_MEMORY_RDATA =>
                    if v_mem_wait_count_r = 0 then
                        -- Memory 'data_mem' at address offset 0x1000
                        if s_axi_araddr_reg_r >= resize(unsigned(BASEADDR) + DATA_MEM_OFFSET, AXI_ADDR_WIDTH) and
                            s_axi_araddr_reg_r < resize(unsigned(BASEADDR) + DATA_MEM_OFFSET + DATA_MEM_DEPTH * 4, AXI_ADDR_WIDTH) then
                            v_rdata_r(31 downto 0) := s_data_mem_rdata(31 downto 0);
                            s_data_mem_ren_r <= '0';
                        end if;
                        v_state_r      := READ_RESPONSE;
                    else
                        v_mem_wait_count_r := v_mem_wait_count_r - 1;
                    end if;

                -- Generate read response
                when READ_RESPONSE =>
                    s_axi_rvalid_r <= '1';
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    --
                    v_state_r      := DONE;

                -- Write transaction completed, wait for master RREADY to proceed
                when DONE =>
                    if s_axi_rready = '1' then
                        s_axi_rvalid_r <= '0';
                        s_axi_rdata_r   <= (others => '0');
                        v_state_r      := IDLE;
                    end if;
            end case;
        end if;
    end process read_fsm;

    ------------------------------------------------------------------------------------------------
    -- Write-transaction FSM
    ------------------------------------------------------------------------------------------------

    write_fsm : process(axi_aclk, axi_aresetn) is
        type t_state is (IDLE, ADDR_FIRST, DATA_FIRST, UPDATE_REGISTER, DONE);
        variable v_state_r  : t_state;
        variable v_addr_hit : boolean;
        variable v_mem_addr : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    begin
        if axi_aresetn = '0' then
            v_state_r          := IDLE;
            s_axi_awready_r    <= '0';
            s_axi_wready_r     <= '0';
            s_axi_awaddr_reg_r <= (others => '0');
            s_axi_wdata_reg_r  <= (others => '0');
            s_axi_wstrb_reg_r  <= (others => '0');
            s_axi_bvalid_r     <= '0';
            s_axi_bresp_r      <= (others => '0');
            --
            s_control_strobe_r <= '0';
            s_reg_control_enable_r <= CONTROL_ENABLE_RESET;
            s_reg_control_ack_r <= CONTROL_ACK_RESET;
            s_reg_control_soft_reset_r <= CONTROL_SOFT_RESET_RESET;
            s_reg_control_test_start_r <= CONTROL_TEST_START_RESET;

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_awready_r <= '0';
            s_axi_wready_r  <= '0';
            s_control_strobe_r <= '0';

            -- Self-clearing fields:
            s_reg_control_ack_r <= (others => '0');
            s_reg_control_soft_reset_r <= (others => '0');
            s_reg_control_test_start_r <= (others => '0');

            case v_state_r is

                -- Wait for the start of a write transaction, which may be
                -- initiated by either of the following conditions:
                --   * assertion of both AWVALID and WVALID
                --   * assertion of AWVALID
                --   * assertion of WVALID
                when IDLE =>
                    if s_axi_awvalid = '1' and s_axi_wvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r     <= '1'; -- acknowledge the write-data
                        v_state_r          := UPDATE_REGISTER;
                    elsif s_axi_awvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        v_state_r          := ADDR_FIRST;
                    elsif s_axi_wvalid = '1' then
                        s_axi_wdata_reg_r <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r    <= '1'; -- acknowledge the write-data
                        v_state_r         := DATA_FIRST;
                    end if;

                -- Address-first write transaction: wait for the write-data
                when ADDR_FIRST =>
                    if s_axi_wvalid = '1' then
                        s_axi_wdata_reg_r <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r    <= '1'; -- acknowledge the write-data
                        v_state_r         := UPDATE_REGISTER;
                    end if;

                -- Data-first write transaction: wait for the write-address
                when DATA_FIRST =>
                    if s_axi_awvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        v_state_r          := UPDATE_REGISTER;
                    end if;

                -- Update the actual storage element
                when UPDATE_REGISTER =>
                    s_axi_bresp_r               <= AXI_OKAY; -- default value, may be overriden in case of decode error
                    s_axi_bvalid_r              <= '1';
                    --
                    v_addr_hit := false;
                    -- Register 'control' at address offset 0x4
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + CONTROL_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_control_strobe_r <= '1';
                        -- Field 'enable':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_enable_r(0) <= s_axi_wdata_reg_r(0); -- enable(0)
                        end if;
                        -- Field 'ack':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_ack_r(0) <= s_axi_wdata_reg_r(1); -- ack(0)
                        end if;
                        -- Field 'soft_reset':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_soft_reset_r(0) <= s_axi_wdata_reg_r(2); -- soft_reset(0)
                        end if;
                        -- Field 'test_start':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_test_start_r(0) <= s_axi_wdata_reg_r(3); -- test_start(0)
                        end if;
                    end if;
                    --
                    if not v_addr_hit then
                        s_axi_bresp_r <= AXI_SLVERR;
                        -- pragma translate_off
                        report "AWADDR decode error" severity warning;
                        -- pragma translate_on
                    end if;
                    --
                    v_state_r := DONE;

                -- Write transaction completed, wait for master BREADY to proceed
                when DONE =>
                    if s_axi_bready = '1' then
                        s_axi_bvalid_r <= '0';
                        v_state_r      := IDLE;
                    end if;

            end case;


        end if;
    end process write_fsm;

    ------------------------------------------------------------------------------------------------
    -- Outputs
    ------------------------------------------------------------------------------------------------

    s_axi_awready <= s_axi_awready_r;
    s_axi_wready  <= s_axi_wready_r;
    s_axi_bvalid  <= s_axi_bvalid_r;
    s_axi_bresp   <= s_axi_bresp_r;
    s_axi_arready <= s_axi_arready_r;
    s_axi_rvalid  <= s_axi_rvalid_r;
    s_axi_rresp   <= s_axi_rresp_r;
    s_axi_rdata   <= s_axi_rdata_r;

    magic_strobe <= s_magic_strobe_r;
    control_strobe <= s_control_strobe_r;
    control_enable <= s_reg_control_enable_r;
    control_ack <= s_reg_control_ack_r;
    control_soft_reset <= s_reg_control_soft_reset_r;
    control_test_start <= s_reg_control_test_start_r;
    status_strobe <= s_status_strobe_r;
    event_size_strobe <= s_event_size_strobe_r;
    event_id_strobe <= s_event_id_strobe_r;
    overflow_count_strobe <= s_overflow_count_strobe_r;
    data_mem_addr <= s_data_mem_raddr_r; -- read-only memory
    data_mem_ren <= s_data_mem_ren_r;

end architecture RTL;
