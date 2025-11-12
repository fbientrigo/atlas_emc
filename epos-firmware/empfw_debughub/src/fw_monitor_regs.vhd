----------------------------------------------------------------------------------------------------
-- 'fw_monitor' Register Component
-- Revision: 237
----------------------------------------------------------------------------------------------------
-- Generated on 2024-06-06 at 12:15 (UTC) by airhdl version 2023.07.1-936312266
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

use work.fw_monitor_regs_pkg.all;

entity fw_monitor_regs is
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
        reset_reg_1_strobe : out std_logic; -- strobe signal for register 'reset_reg_1' (pulsed when the register is written from the bus)
        reset_reg_1_emp_lpgbt_ip : out std_logic_vector(12 downto 0); -- write value of field 'reset_reg_1.emp_lpgbt_ip'
        reset_reg_2_strobe : out std_logic; -- strobe signal for register 'reset_reg_2' (pulsed when the register is written from the bus)
        reset_reg_2_tx_reset : out std_logic_vector(12 downto 0); -- write value of field 'reset_reg_2.tx_reset'
        reset_reg_2_rx_reset : out std_logic_vector(12 downto 0); -- write value of field 'reset_reg_2.rx_reset'
        status_reg_1_strobe : out std_logic; -- strobe signal for register 'status_reg_1' (pulsed when the register is read from the bus)
        status_reg_1_tx_alignment : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_1.tx_alignment'
        status_reg_2_strobe : out std_logic; -- strobe signal for register 'status_reg_2' (pulsed when the register is read from the bus)
        status_reg_2_tx_ready : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_2.tx_ready'
        status_reg_2_rx_ready : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_2.rx_ready'
        status_reg_3_strobe : out std_logic; -- strobe signal for register 'status_reg_3' (pulsed when the register is read from the bus)
        status_reg_3_lpgbt_rx_locked : in std_logic_vector(12 downto 0); -- read value of field 'status_reg_3.lpgbt_rx_locked'
        status_reg_3_lpgbt_tx_ready : in std_logic_vector(12 downto 0) -- read value of field 'status_reg_3.lpgbt_tx_ready'
    );
end entity fw_monitor_regs;

architecture RTL of fw_monitor_regs is

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
    signal s_reset_reg_1_strobe_r : std_logic;
    signal s_reg_reset_reg_1_emp_lpgbt_ip_r : std_logic_vector(12 downto 0);
    signal s_reset_reg_2_strobe_r : std_logic;
    signal s_reg_reset_reg_2_tx_reset_r : std_logic_vector(12 downto 0);
    signal s_reg_reset_reg_2_rx_reset_r : std_logic_vector(12 downto 0);
    signal s_status_reg_1_strobe_r : std_logic;
    signal s_reg_status_reg_1_tx_alignment : std_logic_vector(12 downto 0);
    signal s_status_reg_2_strobe_r : std_logic;
    signal s_reg_status_reg_2_tx_ready : std_logic_vector(12 downto 0);
    signal s_reg_status_reg_2_rx_ready : std_logic_vector(12 downto 0);
    signal s_status_reg_3_strobe_r : std_logic;
    signal s_reg_status_reg_3_lpgbt_rx_locked : std_logic_vector(12 downto 0);
    signal s_reg_status_reg_3_lpgbt_tx_ready : std_logic_vector(12 downto 0);

begin

    ------------------------------------------------------------------------------------------------
    -- Inputs
    ------------------------------------------------------------------------------------------------

    s_reg_status_reg_1_tx_alignment <= status_reg_1_tx_alignment;
    s_reg_status_reg_2_tx_ready <= status_reg_2_tx_ready;
    s_reg_status_reg_2_rx_ready <= status_reg_2_rx_ready;
    s_reg_status_reg_3_lpgbt_rx_locked <= status_reg_3_lpgbt_rx_locked;
    s_reg_status_reg_3_lpgbt_tx_ready <= status_reg_3_lpgbt_tx_ready;

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
            s_status_reg_1_strobe_r <= '0';
            s_status_reg_2_strobe_r <= '0';
            s_status_reg_3_strobe_r <= '0';

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_arready_r <= '0';
            s_status_reg_1_strobe_r <= '0';
            s_status_reg_2_strobe_r <= '0';
            s_status_reg_3_strobe_r <= '0';

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

                    -- Register 'status_reg_1' at address offset 0x8
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + STATUS_REG_1_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(12 downto 0) := s_reg_status_reg_1_tx_alignment;
                        s_status_reg_1_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'status_reg_2' at address offset 0xC
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + STATUS_REG_2_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(12 downto 0) := s_reg_status_reg_2_tx_ready;
                        v_rdata_r(25 downto 13) := s_reg_status_reg_2_rx_ready;
                        s_status_reg_2_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'status_reg_3' at address offset 0x10
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + STATUS_REG_3_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(12 downto 0) := s_reg_status_reg_3_lpgbt_rx_locked;
                        v_rdata_r(25 downto 13) := s_reg_status_reg_3_lpgbt_tx_ready;
                        s_status_reg_3_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
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
            s_reset_reg_1_strobe_r <= '0';
            s_reg_reset_reg_1_emp_lpgbt_ip_r <= RESET_REG_1_EMP_LPGBT_IP_RESET;
            s_reset_reg_2_strobe_r <= '0';
            s_reg_reset_reg_2_tx_reset_r <= RESET_REG_2_TX_RESET_RESET;
            s_reg_reset_reg_2_rx_reset_r <= RESET_REG_2_RX_RESET_RESET;

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_awready_r <= '0';
            s_axi_wready_r  <= '0';
            s_reset_reg_1_strobe_r <= '0';
            s_reset_reg_2_strobe_r <= '0';

            -- Self-clearing fields:
            s_reg_reset_reg_1_emp_lpgbt_ip_r <= (others => '0');
            s_reg_reset_reg_2_tx_reset_r <= (others => '0');
            s_reg_reset_reg_2_rx_reset_r <= (others => '0');

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
                    -- Register 'reset_reg_1' at address offset 0x0
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + RESET_REG_1_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_reset_reg_1_strobe_r <= '1';
                        -- Field 'emp_lpgbt_ip':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(0) <= s_axi_wdata_reg_r(0); -- emp_lpgbt_ip(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(1) <= s_axi_wdata_reg_r(1); -- emp_lpgbt_ip(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(2) <= s_axi_wdata_reg_r(2); -- emp_lpgbt_ip(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(3) <= s_axi_wdata_reg_r(3); -- emp_lpgbt_ip(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(4) <= s_axi_wdata_reg_r(4); -- emp_lpgbt_ip(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(5) <= s_axi_wdata_reg_r(5); -- emp_lpgbt_ip(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(6) <= s_axi_wdata_reg_r(6); -- emp_lpgbt_ip(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(7) <= s_axi_wdata_reg_r(7); -- emp_lpgbt_ip(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(8) <= s_axi_wdata_reg_r(8); -- emp_lpgbt_ip(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(9) <= s_axi_wdata_reg_r(9); -- emp_lpgbt_ip(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(10) <= s_axi_wdata_reg_r(10); -- emp_lpgbt_ip(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(11) <= s_axi_wdata_reg_r(11); -- emp_lpgbt_ip(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_1_emp_lpgbt_ip_r(12) <= s_axi_wdata_reg_r(12); -- emp_lpgbt_ip(12)
                        end if;
                    end if;
                    -- Register 'reset_reg_2' at address offset 0x4
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + RESET_REG_2_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_reset_reg_2_strobe_r <= '1';
                        -- Field 'tx_reset':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(0) <= s_axi_wdata_reg_r(0); -- tx_reset(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(1) <= s_axi_wdata_reg_r(1); -- tx_reset(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(2) <= s_axi_wdata_reg_r(2); -- tx_reset(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(3) <= s_axi_wdata_reg_r(3); -- tx_reset(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(4) <= s_axi_wdata_reg_r(4); -- tx_reset(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(5) <= s_axi_wdata_reg_r(5); -- tx_reset(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(6) <= s_axi_wdata_reg_r(6); -- tx_reset(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(7) <= s_axi_wdata_reg_r(7); -- tx_reset(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(8) <= s_axi_wdata_reg_r(8); -- tx_reset(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(9) <= s_axi_wdata_reg_r(9); -- tx_reset(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(10) <= s_axi_wdata_reg_r(10); -- tx_reset(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(11) <= s_axi_wdata_reg_r(11); -- tx_reset(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_tx_reset_r(12) <= s_axi_wdata_reg_r(12); -- tx_reset(12)
                        end if;
                        -- Field 'rx_reset':
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(0) <= s_axi_wdata_reg_r(13); -- rx_reset(0)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(1) <= s_axi_wdata_reg_r(14); -- rx_reset(1)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(2) <= s_axi_wdata_reg_r(15); -- rx_reset(2)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(3) <= s_axi_wdata_reg_r(16); -- rx_reset(3)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(4) <= s_axi_wdata_reg_r(17); -- rx_reset(4)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(5) <= s_axi_wdata_reg_r(18); -- rx_reset(5)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(6) <= s_axi_wdata_reg_r(19); -- rx_reset(6)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(7) <= s_axi_wdata_reg_r(20); -- rx_reset(7)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(8) <= s_axi_wdata_reg_r(21); -- rx_reset(8)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(9) <= s_axi_wdata_reg_r(22); -- rx_reset(9)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(10) <= s_axi_wdata_reg_r(23); -- rx_reset(10)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(11) <= s_axi_wdata_reg_r(24); -- rx_reset(11)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_reset_reg_2_rx_reset_r(12) <= s_axi_wdata_reg_r(25); -- rx_reset(12)
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

    reset_reg_1_strobe <= s_reset_reg_1_strobe_r;
    reset_reg_1_emp_lpgbt_ip <= s_reg_reset_reg_1_emp_lpgbt_ip_r;
    reset_reg_2_strobe <= s_reset_reg_2_strobe_r;
    reset_reg_2_tx_reset <= s_reg_reset_reg_2_tx_reset_r;
    reset_reg_2_rx_reset <= s_reg_reset_reg_2_rx_reset_r;
    status_reg_1_strobe <= s_status_reg_1_strobe_r;
    status_reg_2_strobe <= s_status_reg_2_strobe_r;
    status_reg_3_strobe <= s_status_reg_3_strobe_r;

end architecture RTL;
