----------------------------------------------------------------------------------------------------
-- 'eLink_Interface' Register Component
-- Revision: 66
----------------------------------------------------------------------------------------------------
-- Generated on 2024-07-31 at 11:17 (UTC) by airhdl version 2023.07.1-936312266
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

use work.eLink_Interface_regs_pkg.all;

entity eLink_Interface_regs is
    generic(
        AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address word, in bits
        BASEADDR : std_logic_vector(31 downto 0) -- register bank AXI base address
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
        status_strobe : out std_logic; -- strobe signal for register 'status' (pulsed when the register is read from the bus)
        status_dlinkfifo_empty : in std_logic_vector(0 downto 0); -- read value of field 'status.dLinkFIFO_empty'
        status_dlinkfifo_full : in std_logic_vector(0 downto 0); -- read value of field 'status.dLinkFIFO_full'
        status_ulinkfifo_empty : in std_logic_vector(0 downto 0); -- read value of field 'status.uLinkFIFO_empty'
        status_ulinkfifo_full : in std_logic_vector(0 downto 0); -- read value of field 'status.uLinkFIFO_full'
        control_strobe : out std_logic; -- strobe signal for register 'control' (pulsed when the register is written from the bus)
        control_ack : out std_logic_vector(0 downto 0); -- write value of field 'control.ACK'
        downlinkdata_strobe : out std_logic; -- strobe signal for register 'downLinkData' (pulsed when the register is written from the bus)
        downlinkdata_dataword : out std_logic_vector(31 downto 0); -- write value of field 'downLinkData.dataWord'
        uplinkdatagrp_0_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_0' (pulsed when the register is read from the bus)
        uplinkdatagrp_0_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_0.dataWord'
        uplinkdatagrp_1_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_1' (pulsed when the register is read from the bus)
        uplinkdatagrp_1_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_1.dataWord'
        uplinkdatagrp_2_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_2' (pulsed when the register is read from the bus)
        uplinkdatagrp_2_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_2.dataWord'
        uplinkdatagrp_3_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_3' (pulsed when the register is read from the bus)
        uplinkdatagrp_3_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_3.dataWord'
        uplinkdatagrp_4_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_4' (pulsed when the register is read from the bus)
        uplinkdatagrp_4_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_4.dataWord'
        uplinkdatagrp_5_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_5' (pulsed when the register is read from the bus)
        uplinkdatagrp_5_dataword : in std_logic_vector(31 downto 0); -- read value of field 'upLinkDataGrp_5.dataWord'
        uplinkdatagrp_6_strobe : out std_logic; -- strobe signal for register 'upLinkDataGrp_6' (pulsed when the register is read from the bus)
        uplinkdatagrp_6_dataword : in std_logic_vector(31 downto 0) -- read value of field 'upLinkDataGrp_6.dataWord'
    );
end entity eLink_Interface_regs;

architecture RTL of eLink_Interface_regs is

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
    signal s_status_strobe_r : std_logic;
    signal s_reg_status_dlinkfifo_empty : std_logic_vector(0 downto 0);
    signal s_reg_status_dlinkfifo_full : std_logic_vector(0 downto 0);
    signal s_reg_status_ulinkfifo_empty : std_logic_vector(0 downto 0);
    signal s_reg_status_ulinkfifo_full : std_logic_vector(0 downto 0);
    signal s_control_strobe_r : std_logic;
    signal s_reg_control_ack_r : std_logic_vector(0 downto 0);
    signal s_downlinkdata_strobe_r : std_logic;
    signal s_reg_downlinkdata_dataword_r : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_0_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_0_dataword : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_1_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_1_dataword : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_2_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_2_dataword : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_3_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_3_dataword : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_4_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_4_dataword : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_5_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_5_dataword : std_logic_vector(31 downto 0);
    signal s_uplinkdatagrp_6_strobe_r : std_logic;
    signal s_reg_uplinkdatagrp_6_dataword : std_logic_vector(31 downto 0);

begin

    ------------------------------------------------------------------------------------------------
    -- Inputs
    ------------------------------------------------------------------------------------------------

    s_reg_magic_value <= magic_value;
    s_reg_status_dlinkfifo_empty <= status_dlinkfifo_empty;
    s_reg_status_dlinkfifo_full <= status_dlinkfifo_full;
    s_reg_status_ulinkfifo_empty <= status_ulinkfifo_empty;
    s_reg_status_ulinkfifo_full <= status_ulinkfifo_full;
    s_reg_uplinkdatagrp_0_dataword <= uplinkdatagrp_0_dataword;
    s_reg_uplinkdatagrp_1_dataword <= uplinkdatagrp_1_dataword;
    s_reg_uplinkdatagrp_2_dataword <= uplinkdatagrp_2_dataword;
    s_reg_uplinkdatagrp_3_dataword <= uplinkdatagrp_3_dataword;
    s_reg_uplinkdatagrp_4_dataword <= uplinkdatagrp_4_dataword;
    s_reg_uplinkdatagrp_5_dataword <= uplinkdatagrp_5_dataword;
    s_reg_uplinkdatagrp_6_dataword <= uplinkdatagrp_6_dataword;

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
            s_magic_strobe_r <= '0';
            s_status_strobe_r <= '0';
            s_uplinkdatagrp_0_strobe_r <= '0';
            s_uplinkdatagrp_1_strobe_r <= '0';
            s_uplinkdatagrp_2_strobe_r <= '0';
            s_uplinkdatagrp_3_strobe_r <= '0';
            s_uplinkdatagrp_4_strobe_r <= '0';
            s_uplinkdatagrp_5_strobe_r <= '0';
            s_uplinkdatagrp_6_strobe_r <= '0';

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_arready_r <= '0';
            s_magic_strobe_r <= '0';
            s_status_strobe_r <= '0';
            s_uplinkdatagrp_0_strobe_r <= '0';
            s_uplinkdatagrp_1_strobe_r <= '0';
            s_uplinkdatagrp_2_strobe_r <= '0';
            s_uplinkdatagrp_3_strobe_r <= '0';
            s_uplinkdatagrp_4_strobe_r <= '0';
            s_uplinkdatagrp_5_strobe_r <= '0';
            s_uplinkdatagrp_6_strobe_r <= '0';

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
                    -- Register 'status' at address offset 0x4
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + STATUS_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_status_dlinkfifo_empty;
                        v_rdata_r(1 downto 1) := s_reg_status_dlinkfifo_full;
                        v_rdata_r(2 downto 2) := s_reg_status_ulinkfifo_empty;
                        v_rdata_r(3 downto 3) := s_reg_status_ulinkfifo_full;
                        s_status_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_0' at address offset 0x14
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_0_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_0_dataword;
                        s_uplinkdatagrp_0_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_1' at address offset 0x18
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_1_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_1_dataword;
                        s_uplinkdatagrp_1_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_2' at address offset 0x1C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_2_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_2_dataword;
                        s_uplinkdatagrp_2_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_3' at address offset 0x20
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_3_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_3_dataword;
                        s_uplinkdatagrp_3_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_4' at address offset 0x24
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_4_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_4_dataword;
                        s_uplinkdatagrp_4_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_5' at address offset 0x28
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_5_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_5_dataword;
                        s_uplinkdatagrp_5_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register 'upLinkDataGrp_6' at address offset 0x2C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + UPLINKDATAGRP_6_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(31 downto 0) := s_reg_uplinkdatagrp_6_dataword;
                        s_uplinkdatagrp_6_strobe_r <= '1';
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
            s_control_strobe_r <= '0';
            s_reg_control_ack_r <= CONTROL_ACK_RESET;
            s_downlinkdata_strobe_r <= '0';
            s_reg_downlinkdata_dataword_r <= DOWNLINKDATA_DATAWORD_RESET;

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_awready_r <= '0';
            s_axi_wready_r  <= '0';
            s_control_strobe_r <= '0';
            s_downlinkdata_strobe_r <= '0';

            -- Self-clearing fields:
            s_reg_control_ack_r <= (others => '0');
            s_reg_downlinkdata_dataword_r <= (others => '0');

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
                    -- Register 'control' at address offset 0x8
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + CONTROL_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_control_strobe_r <= '1';
                        -- Field 'ACK':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_control_ack_r(0) <= s_axi_wdata_reg_r(0); -- ACK(0)
                        end if;
                    end if;
                    -- Register 'downLinkData' at address offset 0x10
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + DOWNLINKDATA_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_downlinkdata_strobe_r <= '1';
                        -- Field 'dataWord':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(0) <= s_axi_wdata_reg_r(0); -- dataWord(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(1) <= s_axi_wdata_reg_r(1); -- dataWord(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(2) <= s_axi_wdata_reg_r(2); -- dataWord(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(3) <= s_axi_wdata_reg_r(3); -- dataWord(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(4) <= s_axi_wdata_reg_r(4); -- dataWord(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(5) <= s_axi_wdata_reg_r(5); -- dataWord(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(6) <= s_axi_wdata_reg_r(6); -- dataWord(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_downlinkdata_dataword_r(7) <= s_axi_wdata_reg_r(7); -- dataWord(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(8) <= s_axi_wdata_reg_r(8); -- dataWord(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(9) <= s_axi_wdata_reg_r(9); -- dataWord(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(10) <= s_axi_wdata_reg_r(10); -- dataWord(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(11) <= s_axi_wdata_reg_r(11); -- dataWord(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(12) <= s_axi_wdata_reg_r(12); -- dataWord(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(13) <= s_axi_wdata_reg_r(13); -- dataWord(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(14) <= s_axi_wdata_reg_r(14); -- dataWord(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_downlinkdata_dataword_r(15) <= s_axi_wdata_reg_r(15); -- dataWord(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(16) <= s_axi_wdata_reg_r(16); -- dataWord(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(17) <= s_axi_wdata_reg_r(17); -- dataWord(17)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(18) <= s_axi_wdata_reg_r(18); -- dataWord(18)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(19) <= s_axi_wdata_reg_r(19); -- dataWord(19)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(20) <= s_axi_wdata_reg_r(20); -- dataWord(20)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(21) <= s_axi_wdata_reg_r(21); -- dataWord(21)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(22) <= s_axi_wdata_reg_r(22); -- dataWord(22)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_downlinkdata_dataword_r(23) <= s_axi_wdata_reg_r(23); -- dataWord(23)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(24) <= s_axi_wdata_reg_r(24); -- dataWord(24)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(25) <= s_axi_wdata_reg_r(25); -- dataWord(25)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(26) <= s_axi_wdata_reg_r(26); -- dataWord(26)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(27) <= s_axi_wdata_reg_r(27); -- dataWord(27)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(28) <= s_axi_wdata_reg_r(28); -- dataWord(28)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(29) <= s_axi_wdata_reg_r(29); -- dataWord(29)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(30) <= s_axi_wdata_reg_r(30); -- dataWord(30)
                        end if;
                        if s_axi_wstrb_reg_r(3) = '1' then
                            s_reg_downlinkdata_dataword_r(31) <= s_axi_wdata_reg_r(31); -- dataWord(31)
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
    status_strobe <= s_status_strobe_r;
    control_strobe <= s_control_strobe_r;
    control_ack <= s_reg_control_ack_r;
    downlinkdata_strobe <= s_downlinkdata_strobe_r;
    downlinkdata_dataword <= s_reg_downlinkdata_dataword_r;
    uplinkdatagrp_0_strobe <= s_uplinkdatagrp_0_strobe_r;
    uplinkdatagrp_1_strobe <= s_uplinkdatagrp_1_strobe_r;
    uplinkdatagrp_2_strobe <= s_uplinkdatagrp_2_strobe_r;
    uplinkdatagrp_3_strobe <= s_uplinkdatagrp_3_strobe_r;
    uplinkdatagrp_4_strobe <= s_uplinkdatagrp_4_strobe_r;
    uplinkdatagrp_5_strobe <= s_uplinkdatagrp_5_strobe_r;
    uplinkdatagrp_6_strobe <= s_uplinkdatagrp_6_strobe_r;

end architecture RTL;
