-- -----------------------------------------------------------------------------
-- 'emp_lpgbt_ic_clerk' Register Component
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

use work.emp_lpgbt_ic_clerk_regs_pkg.all;

entity emp_lpgbt_ic_clerk_regs is
    generic(
        AXI_ADDR_WIDTH : integer := 32  -- width of the AXI address bus
        --BASEADDR : std_logic_vector(31 downto 0) := x"A0000000" -- the register file's system base address		
    );
    port(
        BASEADDR : in std_logic_vector(31 downto 0); -- the register file's system base address;
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
        magic_strobe : out std_logic; -- Strobe signal for register 'magic' (pulsed when the register is read from the bus)
        magic_value : in std_logic_vector(31 downto 0); -- Value of register 'magic', field 'value'
        control_strobe : out std_logic; -- Strobe signal for register 'control' (pulsed when the register is written from the bus)
        control_fifoctrl : out std_logic_vector(1 downto 0); -- Value of register 'control', field 'FIFOCtrl'
        control_lpgbtctrl : out std_logic_vector(1 downto 0); -- Value of register 'control', field 'lpGBTCtrl'
        control_single_write_read : out std_logic_vector(0 downto 0); -- Value of register 'control', field 'single_write_read'
        control_nb_read : out std_logic_vector(15 downto 0); -- Value of register 'control', field 'NB_read'
        status_strobe : out std_logic; -- Strobe signal for register 'status' (pulsed when the register is read from the bus)
        status_ready_flag : in std_logic_vector(0 downto 0); -- Value of register 'status', field 'ready_flag'
        status_empty_flag : in std_logic_vector(0 downto 0); -- Value of register 'status', field 'empty_flag'
        status_parity_error : in std_logic_vector(0 downto 0); -- Value of register 'status', field 'parity_error'
        status_timeout_error : in std_logic_vector(0 downto 0); -- Value of register 'status', field 'timeout_error'
        data_rx_strobe : out std_logic; -- Strobe signal for register 'data_rx' (pulsed when the register is read from the bus)
        data_rx_data : in std_logic_vector(7 downto 0); -- Value of register 'data_rx', field 'data'
        data_tx_strobe : out std_logic; -- Strobe signal for register 'data_tx' (pulsed when the register is written from the bus)
        data_tx_data : out std_logic_vector(7 downto 0); -- Value of register 'data_tx', field 'data'
        register_addr_strobe : out std_logic; -- Strobe signal for register 'register_addr' (pulsed when the register is written from the bus)
        register_addr_addr : out std_logic_vector(15 downto 0); -- Value of register 'register_addr', field 'addr'
        lpgbt_addr_strobe : out std_logic; -- Strobe signal for register 'lpGBT_addr' (pulsed when the register is written from the bus)
        lpgbt_addr_addr : out std_logic_vector(7 downto 0); -- Value of register 'lpGBT_addr', field 'addr'
        interrupt_enable_strobe : out std_logic; -- Strobe signal for register 'interrupt_enable' (pulsed when the register is written from the bus)
        interrupt_enable_ic_resp : out std_logic_vector(0 downto 0); -- Value of register 'interrupt_enable', field 'IC_resp'
        interrupt_flags_strobe : out std_logic; -- Strobe signal for register 'interrupt_flags' (pulsed when the register is read from the bus)
        interrupt_flags_ic_resp : in std_logic_vector(0 downto 0); -- Value of register 'interrupt_flags', field 'IC_resp'
        interrupt_clear_strobe : out std_logic; -- Strobe signal for register 'interrupt_clear' (pulsed when the register is written from the bus)
        interrupt_clear_ic_resp : out std_logic_vector(0 downto 0); -- Value of register 'interrupt_clear', field 'IC_resp'
        reset_strobe : out std_logic; -- Strobe signal for register 'reset' (pulsed when the register is written from the bus)
        reset_reset : out std_logic_vector(0 downto 0); -- Value of register 'reset', field 'reset'
        counter_lhc_clock_strobe : out std_logic; -- Strobe signal for register 'counter_lhc_clock' (pulsed when the register is written from the bus)
        counter_lhc_clock_value : out std_logic_vector(31 downto 0) -- Value of register 'counter_lhc_clock', field 'value'
    );
end entity emp_lpgbt_ic_clerk_regs;

architecture RTL of emp_lpgbt_ic_clerk_regs is

    -- Constants
    constant AXI_OKAY           : std_logic_vector(1 downto 0) := "00";
    constant AXI_DECERR         : std_logic_vector(1 downto 0) := "11";

    -- Registered signals
    signal s_axi_awready_r    : std_logic;
    signal s_axi_wready_r     : std_logic;
    signal s_axi_awaddr_reg_r : unsigned(s_axi_awaddr'range);
    signal s_axi_bvalid_r     : std_logic;
    signal s_axi_bresp_r      : std_logic_vector(s_axi_bresp'range);
    signal s_axi_arready_r    : std_logic;
    signal s_axi_araddr_reg_r : unsigned(s_axi_araddr'range);
    signal s_axi_rvalid_r     : std_logic;
    signal s_axi_rresp_r      : std_logic_vector(s_axi_rresp'range);
    signal s_axi_wdata_reg_r  : std_logic_vector(s_axi_wdata'range);
    signal s_axi_wstrb_reg_r  : std_logic_vector(s_axi_wstrb'range);
    signal s_axi_rdata_r      : std_logic_vector(s_axi_rdata'range);
    
    -- User-defined registers
    signal s_magic_strobe_r : std_logic;
    signal s_reg_magic_value : std_logic_vector(31 downto 0);
    signal s_control_strobe_r : std_logic;
    signal s_reg_control_fifoctrl_r : std_logic_vector(1 downto 0);
    signal s_reg_control_lpgbtctrl_r : std_logic_vector(1 downto 0);
    signal s_reg_control_single_write_read_r : std_logic_vector(0 downto 0);
    signal s_reg_control_nb_read_r : std_logic_vector(15 downto 0);
    signal s_status_strobe_r : std_logic;
    signal s_reg_status_ready_flag : std_logic_vector(0 downto 0);
    signal s_reg_status_empty_flag : std_logic_vector(0 downto 0);
    signal s_reg_status_parity_error : std_logic_vector(0 downto 0);
    signal s_reg_status_timeout_error : std_logic_vector(0 downto 0);
    signal s_data_rx_strobe_r : std_logic;
    signal s_reg_data_rx_data : std_logic_vector(7 downto 0);
    signal s_data_tx_strobe_r : std_logic;
    signal s_reg_data_tx_data_r : std_logic_vector(7 downto 0);
    signal s_register_addr_strobe_r : std_logic;
    signal s_reg_register_addr_addr_r : std_logic_vector(15 downto 0);
    signal s_lpgbt_addr_strobe_r : std_logic;
    signal s_reg_lpgbt_addr_addr_r : std_logic_vector(7 downto 0);
    signal s_interrupt_enable_strobe_r : std_logic;
    signal s_reg_interrupt_enable_ic_resp_r : std_logic_vector(0 downto 0);
    signal s_interrupt_flags_strobe_r : std_logic;
    signal s_reg_interrupt_flags_ic_resp : std_logic_vector(0 downto 0);
    signal s_interrupt_clear_strobe_r : std_logic;
    signal s_reg_interrupt_clear_ic_resp_r : std_logic_vector(0 downto 0);
    signal s_reset_strobe_r : std_logic;
    signal s_reg_reset_reset_r : std_logic_vector(0 downto 0);
    signal s_counter_lhc_clock_strobe_r : std_logic;
    signal s_reg_counter_lhc_clock_value_r : std_logic_vector(31 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Inputs
    --
    s_reg_magic_value <= magic_value;
    s_reg_status_ready_flag <= status_ready_flag;
    s_reg_status_empty_flag <= status_empty_flag;
    s_reg_status_parity_error <= status_parity_error;
    s_reg_status_timeout_error <= status_timeout_error;
    s_reg_data_rx_data <= data_rx_data;
    s_reg_interrupt_flags_ic_resp <= interrupt_flags_ic_resp;

    ----------------------------------------------------------------------------
    -- Read-transaction FSM
    --    
    read_fsm : process(axi_aclk, axi_aresetn) is
        constant MEM_WAIT_COUNT : natural := 2;
        type t_state is (IDLE, READ_REGISTER, WAIT_MEMORY_RDATA, READ_RESPONSE, DONE);
        -- registered state variables
        variable v_state_r          : t_state;
        variable v_rdata_r          : std_logic_vector(31 downto 0);
        variable v_rresp_r          : std_logic_vector(s_axi_rresp'range);
        variable v_mem_wait_count_r : natural range 0 to MEM_WAIT_COUNT - 1;
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
            s_data_rx_strobe_r <= '0';
            s_interrupt_flags_strobe_r <= '0';
 
        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_arready_r <= '0';
            s_magic_strobe_r <= '0';
            s_status_strobe_r <= '0';
            s_data_rx_strobe_r <= '0';
            s_interrupt_flags_strobe_r <= '0';

            case v_state_r is

                -- Wait for the start of a read transaction, which is 
                -- initiated by the assertion of ARVALID
                when IDLE =>
                    v_mem_wait_count_r := 0;
                    --
                    if s_axi_arvalid = '1' then
                        s_axi_araddr_reg_r <= unsigned(s_axi_araddr); -- save the read address
                        s_axi_arready_r    <= '1'; -- acknowledge the read-address
                        v_state_r          := READ_REGISTER;
                    end if;

                -- Read from the actual storage element
                when READ_REGISTER =>
                    -- defaults:
                    v_addr_hit := false;
                    v_rdata_r  := (others => '0');
                    
                    -- register 'magic' at address offset 0x0 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + MAGIC_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_magic_value;
                        s_magic_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'control' at address offset 0x4 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + CONTROL_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(1 downto 0) := s_reg_control_fifoctrl_r;
                        v_rdata_r(3 downto 2) := s_reg_control_lpgbtctrl_r;
                        v_rdata_r(4 downto 4) := s_reg_control_single_write_read_r;
                        v_rdata_r(31 downto 16) := s_reg_control_nb_read_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'status' at address offset 0x8 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + STATUS_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_status_ready_flag;
                        v_rdata_r(1 downto 1) := s_reg_status_empty_flag;
                        v_rdata_r(2 downto 2) := s_reg_status_parity_error;
                        v_rdata_r(3 downto 3) := s_reg_status_timeout_error;
                        s_status_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'data_rx' at address offset 0xC 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + DATA_RX_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(7 downto 0) := s_reg_data_rx_data;
                        s_data_rx_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'data_tx' at address offset 0x10 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + DATA_TX_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(7 downto 0) := s_reg_data_tx_data_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'register_addr' at address offset 0x14 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + REGISTER_ADDR_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_register_addr_addr_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'lpGBT_addr' at address offset 0x18 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + LPGBT_ADDR_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(7 downto 0) := s_reg_lpgbt_addr_addr_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'interrupt_enable' at address offset 0x1C 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + INTERRUPT_ENABLE_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_interrupt_enable_ic_resp_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'interrupt_flags' at address offset 0x20 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + INTERRUPT_FLAGS_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_interrupt_flags_ic_resp;
                        s_interrupt_flags_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'interrupt_clear' at address offset 0x24 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + INTERRUPT_CLEAR_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_interrupt_clear_ic_resp_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'reset' at address offset 0x28 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + RESET_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_reset_reset_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- register 'counter_lhc_clock' at address offset 0x100 
                    if s_axi_araddr_reg_r = resize(unsigned(BASEADDR) + COUNTER_LHC_CLOCK_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_counter_lhc_clock_value_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    --
                    if v_addr_hit then
                        v_rresp_r := AXI_OKAY;
                    else
                        v_rresp_r := AXI_DECERR;
                        -- pragma translate_off
                        report "ARADDR decode error" severity warning;
                        -- pragma translate_on
                        v_state_r := READ_RESPONSE;
                    end if;

                -- Wait for memory read data
                when WAIT_MEMORY_RDATA =>
                    if v_mem_wait_count_r = MEM_WAIT_COUNT-1 then
                        v_state_r      := READ_RESPONSE;
                    else
                        v_mem_wait_count_r := v_mem_wait_count_r + 1;
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

    ----------------------------------------------------------------------------
    -- Write-transaction FSM
    --    
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
            s_reg_control_fifoctrl_r <= CONTROL_FIFOCTRL_RESET;
            s_reg_control_lpgbtctrl_r <= CONTROL_LPGBTCTRL_RESET;
            s_reg_control_single_write_read_r <= CONTROL_SINGLE_WRITE_READ_RESET;
            s_reg_control_nb_read_r <= CONTROL_NB_READ_RESET;
            s_data_tx_strobe_r <= '0';
            s_reg_data_tx_data_r <= DATA_TX_DATA_RESET;
            s_register_addr_strobe_r <= '0';
            s_reg_register_addr_addr_r <= REGISTER_ADDR_ADDR_RESET;
            s_lpgbt_addr_strobe_r <= '0';
            s_reg_lpgbt_addr_addr_r <= LPGBT_ADDR_ADDR_RESET;
            s_interrupt_enable_strobe_r <= '0';
            s_reg_interrupt_enable_ic_resp_r <= INTERRUPT_ENABLE_IC_RESP_RESET;
            s_interrupt_clear_strobe_r <= '0';
            s_reg_interrupt_clear_ic_resp_r <= INTERRUPT_CLEAR_IC_RESP_RESET;
            s_reset_strobe_r <= '0';
            s_reg_reset_reset_r <= RESET_RESET_RESET;
            s_counter_lhc_clock_strobe_r <= '0';
            s_reg_counter_lhc_clock_value_r <= COUNTER_LHC_CLOCK_VALUE_RESET;

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_awready_r <= '0';
            s_axi_wready_r  <= '0';
            s_control_strobe_r <= '0';
            s_data_tx_strobe_r <= '0';
            s_register_addr_strobe_r <= '0';
            s_lpgbt_addr_strobe_r <= '0';
            s_interrupt_enable_strobe_r <= '0';
            s_interrupt_clear_strobe_r <= '0';
            s_reset_strobe_r <= '0';
            s_counter_lhc_clock_strobe_r <= '0';

            -- Self-clearing fields:
            s_reg_control_fifoctrl_r <= (others => '0');
            s_reg_control_lpgbtctrl_r <= (others => '0');
            s_reg_interrupt_clear_ic_resp_r <= (others => '0');
            s_reg_reset_reset_r <= (others => '0');

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
                    -- register 'control' at address offset 0x4
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + CONTROL_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_control_strobe_r <= '1';
                        -- field 'FIFOCtrl':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_fifoctrl_r(0) <= s_axi_wdata_reg_r(0); -- FIFOCtrl(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_fifoctrl_r(1) <= s_axi_wdata_reg_r(1); -- FIFOCtrl(1)
                        end if;
                        -- field 'lpGBTCtrl':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_lpgbtctrl_r(0) <= s_axi_wdata_reg_r(2); -- lpGBTCtrl(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_lpgbtctrl_r(1) <= s_axi_wdata_reg_r(3); -- lpGBTCtrl(1)
                        end if;
                        -- field 'single_write_read':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_single_write_read_r(0) <= s_axi_wdata_reg_r(4); -- single_write_read(0)
                        end if;
                        -- field 'NB_read':
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(0) <= s_axi_wdata_reg_r(16); -- NB_read(0)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(1) <= s_axi_wdata_reg_r(17); -- NB_read(1)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(2) <= s_axi_wdata_reg_r(18); -- NB_read(2)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(3) <= s_axi_wdata_reg_r(19); -- NB_read(3)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(4) <= s_axi_wdata_reg_r(20); -- NB_read(4)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(5) <= s_axi_wdata_reg_r(21); -- NB_read(5)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(6) <= s_axi_wdata_reg_r(22); -- NB_read(6)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_control_nb_read_r(7) <= s_axi_wdata_reg_r(23); -- NB_read(7)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(8) <= s_axi_wdata_reg_r(24); -- NB_read(8)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(9) <= s_axi_wdata_reg_r(25); -- NB_read(9)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(10) <= s_axi_wdata_reg_r(26); -- NB_read(10)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(11) <= s_axi_wdata_reg_r(27); -- NB_read(11)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(12) <= s_axi_wdata_reg_r(28); -- NB_read(12)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(13) <= s_axi_wdata_reg_r(29); -- NB_read(13)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(14) <= s_axi_wdata_reg_r(30); -- NB_read(14)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_control_nb_read_r(15) <= s_axi_wdata_reg_r(31); -- NB_read(15)
                        end if;
                    end if;
                    -- register 'data_tx' at address offset 0x10
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + DATA_TX_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_data_tx_strobe_r <= '1';
                        -- field 'data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(0) <= s_axi_wdata_reg_r(0); -- data(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(1) <= s_axi_wdata_reg_r(1); -- data(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(2) <= s_axi_wdata_reg_r(2); -- data(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(3) <= s_axi_wdata_reg_r(3); -- data(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(4) <= s_axi_wdata_reg_r(4); -- data(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(5) <= s_axi_wdata_reg_r(5); -- data(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(6) <= s_axi_wdata_reg_r(6); -- data(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_data_tx_data_r(7) <= s_axi_wdata_reg_r(7); -- data(7)
                        end if;
                    end if;
                    -- register 'register_addr' at address offset 0x14
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + REGISTER_ADDR_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_register_addr_strobe_r <= '1';
                        -- field 'addr':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(0) <= s_axi_wdata_reg_r(0); -- addr(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(1) <= s_axi_wdata_reg_r(1); -- addr(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(2) <= s_axi_wdata_reg_r(2); -- addr(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(3) <= s_axi_wdata_reg_r(3); -- addr(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(4) <= s_axi_wdata_reg_r(4); -- addr(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(5) <= s_axi_wdata_reg_r(5); -- addr(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(6) <= s_axi_wdata_reg_r(6); -- addr(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_register_addr_addr_r(7) <= s_axi_wdata_reg_r(7); -- addr(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(8) <= s_axi_wdata_reg_r(8); -- addr(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(9) <= s_axi_wdata_reg_r(9); -- addr(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(10) <= s_axi_wdata_reg_r(10); -- addr(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(11) <= s_axi_wdata_reg_r(11); -- addr(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(12) <= s_axi_wdata_reg_r(12); -- addr(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(13) <= s_axi_wdata_reg_r(13); -- addr(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(14) <= s_axi_wdata_reg_r(14); -- addr(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_register_addr_addr_r(15) <= s_axi_wdata_reg_r(15); -- addr(15)
                        end if;
                    end if;
                    -- register 'lpGBT_addr' at address offset 0x18
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + LPGBT_ADDR_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_lpgbt_addr_strobe_r <= '1';
                        -- field 'addr':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(0) <= s_axi_wdata_reg_r(0); -- addr(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(1) <= s_axi_wdata_reg_r(1); -- addr(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(2) <= s_axi_wdata_reg_r(2); -- addr(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(3) <= s_axi_wdata_reg_r(3); -- addr(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(4) <= s_axi_wdata_reg_r(4); -- addr(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(5) <= s_axi_wdata_reg_r(5); -- addr(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(6) <= s_axi_wdata_reg_r(6); -- addr(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_lpgbt_addr_addr_r(7) <= s_axi_wdata_reg_r(7); -- addr(7)
                        end if;
                    end if;
                    -- register 'interrupt_enable' at address offset 0x1C
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + INTERRUPT_ENABLE_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_interrupt_enable_strobe_r <= '1';
                        -- field 'IC_resp':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_interrupt_enable_ic_resp_r(0) <= s_axi_wdata_reg_r(0); -- IC_resp(0)
                        end if;
                    end if;
                    -- register 'interrupt_clear' at address offset 0x24
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + INTERRUPT_CLEAR_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_interrupt_clear_strobe_r <= '1';
                        -- field 'IC_resp':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_interrupt_clear_ic_resp_r(0) <= s_axi_wdata_reg_r(0); -- IC_resp(0)
                        end if;
                    end if;
                    -- register 'reset' at address offset 0x28
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + RESET_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_reset_strobe_r <= '1';
                        -- field 'reset':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_reset_reset_r(0) <= s_axi_wdata_reg_r(0); -- reset(0)
                        end if;
                    end if;
                    -- register 'counter_lhc_clock' at address offset 0x100
                    if s_axi_awaddr_reg_r = resize(unsigned(BASEADDR) + COUNTER_LHC_CLOCK_OFFSET, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;                        
                        s_counter_lhc_clock_strobe_r <= '1';
                        -- field 'value':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(1) <= s_axi_wdata_reg_r(1); -- value(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(2) <= s_axi_wdata_reg_r(2); -- value(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(3) <= s_axi_wdata_reg_r(3); -- value(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(4) <= s_axi_wdata_reg_r(4); -- value(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(5) <= s_axi_wdata_reg_r(5); -- value(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(6) <= s_axi_wdata_reg_r(6); -- value(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_counter_lhc_clock_value_r(7) <= s_axi_wdata_reg_r(7); -- value(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(8) <= s_axi_wdata_reg_r(8); -- value(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(9) <= s_axi_wdata_reg_r(9); -- value(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(10) <= s_axi_wdata_reg_r(10); -- value(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(11) <= s_axi_wdata_reg_r(11); -- value(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(12) <= s_axi_wdata_reg_r(12); -- value(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(13) <= s_axi_wdata_reg_r(13); -- value(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(14) <= s_axi_wdata_reg_r(14); -- value(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_counter_lhc_clock_value_r(15) <= s_axi_wdata_reg_r(15); -- value(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(16) <= s_axi_wdata_reg_r(16); -- value(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(17) <= s_axi_wdata_reg_r(17); -- value(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(18) <= s_axi_wdata_reg_r(18); -- value(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(19) <= s_axi_wdata_reg_r(19); -- value(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(20) <= s_axi_wdata_reg_r(20); -- value(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(21) <= s_axi_wdata_reg_r(21); -- value(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(22) <= s_axi_wdata_reg_r(22); -- value(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_counter_lhc_clock_value_r(23) <= s_axi_wdata_reg_r(23); -- value(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(24) <= s_axi_wdata_reg_r(24); -- value(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(25) <= s_axi_wdata_reg_r(25); -- value(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(26) <= s_axi_wdata_reg_r(26); -- value(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(27) <= s_axi_wdata_reg_r(27); -- value(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(28) <= s_axi_wdata_reg_r(28); -- value(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(29) <= s_axi_wdata_reg_r(29); -- value(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(30) <= s_axi_wdata_reg_r(30); -- value(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_counter_lhc_clock_value_r(31) <= s_axi_wdata_reg_r(31); -- value(31)
                        end if;
                    end if;
                    --
                    if not v_addr_hit then
                        s_axi_bresp_r <= AXI_DECERR;
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

    ----------------------------------------------------------------------------
    -- Outputs
    --
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
    control_fifoctrl <= s_reg_control_fifoctrl_r;
    control_lpgbtctrl <= s_reg_control_lpgbtctrl_r;
    control_single_write_read <= s_reg_control_single_write_read_r;
    control_nb_read <= s_reg_control_nb_read_r;
    status_strobe <= s_status_strobe_r;
    data_rx_strobe <= s_data_rx_strobe_r;
    data_tx_strobe <= s_data_tx_strobe_r;
    data_tx_data <= s_reg_data_tx_data_r;
    register_addr_strobe <= s_register_addr_strobe_r;
    register_addr_addr <= s_reg_register_addr_addr_r;
    lpgbt_addr_strobe <= s_lpgbt_addr_strobe_r;
    lpgbt_addr_addr <= s_reg_lpgbt_addr_addr_r;
    interrupt_enable_strobe <= s_interrupt_enable_strobe_r;
    interrupt_enable_ic_resp <= s_reg_interrupt_enable_ic_resp_r;
    interrupt_flags_strobe <= s_interrupt_flags_strobe_r;
    interrupt_clear_strobe <= s_interrupt_clear_strobe_r;
    interrupt_clear_ic_resp <= s_reg_interrupt_clear_ic_resp_r;
    reset_strobe <= s_reset_strobe_r;
    reset_reset <= s_reg_reset_reset_r;
    counter_lhc_clock_strobe <= s_counter_lhc_clock_strobe_r;
    counter_lhc_clock_value <= s_reg_counter_lhc_clock_value_r;

end architecture RTL;
