-- -----------------------------------------------------------------------------
-- 'cmb_event' Register Component
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

------------- Begin cut here for COMPONENT Declaration -------------------------
component cmb_event_regs
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
end component;
------------- End COMPONENT Declaration ----------------------------------------

------------- Begin cut here for CONSTANT and SIGNAL Declarations --------------
-- Constants:
constant AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address bus
constant BASEADDR : std_logic_vector(31 downto 0) := x"A01B0000"; -- the register file's system base address

-- AXI interface signals:
signal axi_aclk    : std_logic;
signal axi_aresetn : std_logic;
signal s_axi_awaddr  : std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
signal s_axi_awprot  : std_logic_vector(2 downto 0);
signal s_axi_awvalid : std_logic;
signal s_axi_awready : std_logic;
signal s_axi_wdata   : std_logic_vector(31 downto 0);
signal s_axi_wstrb   : std_logic_vector(3 downto 0);
signal s_axi_wvalid  : std_logic;
signal s_axi_wready  : std_logic;
signal s_axi_araddr  : std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
signal s_axi_arprot  : std_logic_vector(2 downto 0);
signal s_axi_arvalid : std_logic;
signal s_axi_arready : std_logic;
signal s_axi_rdata   : std_logic_vector(31 downto 0);
signal s_axi_rresp   : std_logic_vector(1 downto 0);
signal s_axi_rvalid  : std_logic;
signal s_axi_rready  : std_logic;
signal s_axi_bresp   : std_logic_vector(1 downto 0);
signal s_axi_bvalid  : std_logic;
signal s_axi_bready  : std_logic;

-- User signals:
signal magic_strobe : std_logic;
signal magic_value : std_logic_vector(31 downto 0);
signal control_strobe : std_logic;
signal control_enable : std_logic_vector(0 downto 0);
signal control_ack : std_logic_vector(0 downto 0);
signal control_soft_reset : std_logic_vector(0 downto 0);
signal control_test_start : std_logic_vector(0 downto 0);
signal status_strobe : std_logic;
signal status_busy : std_logic_vector(0 downto 0);
signal status_ready : std_logic_vector(0 downto 0);
signal status_overflow : std_logic_vector(0 downto 0);
signal status_veto : std_logic_vector(0 downto 0);
signal event_size_strobe : std_logic;
signal event_size_value : std_logic_vector(31 downto 0);
signal event_id_strobe : std_logic;
signal event_id_value : std_logic_vector(31 downto 0);
signal overflow_count_strobe : std_logic;
signal overflow_count_value : std_logic_vector(31 downto 0);
signal data_mem_addr : std_logic_vector(13 downto 0);
signal data_mem_rdata : std_logic_vector(31 downto 0);
------------- End CONSTANT and SIGNAL Declarations -----------------------------

------------- Begin cut here for INSTANTIATION Template ------------------------
your_instance_name : cmb_event_regs
    generic map (
        AXI_ADDR_WIDTH => AXI_ADDR_WIDTH,
        BASEADDR => BASEADDR
    )
    port map(
        -- Clock and Reset
        axi_aclk    => axi_aclk,
        axi_aresetn => axi_aresetn,
        -- AXI Write Address Channel
        s_axi_awaddr  => s_axi_awaddr,
        s_axi_awprot  => s_axi_awprot,
        s_axi_awvalid => s_axi_awvalid,
        s_axi_awready => s_axi_awready,
        -- AXI Write Data Channel
        s_axi_wdata   => s_axi_wdata,
        s_axi_wstrb   => s_axi_wstrb,
        s_axi_wvalid  => s_axi_wvalid,
        s_axi_wready  => s_axi_wready,
        -- AXI Read Address Channel
        s_axi_araddr  => s_axi_araddr,
        s_axi_arprot  => s_axi_arprot,
        s_axi_arvalid => s_axi_arvalid,
        s_axi_arready => s_axi_arready,
        -- AXI Read Data Channel
        s_axi_rdata   => s_axi_rdata,
        s_axi_rresp   => s_axi_rresp,
        s_axi_rvalid  => s_axi_rvalid,
        s_axi_rready  => s_axi_rready,
        -- AXI Write Response Channel
        s_axi_bresp   => s_axi_bresp,
        s_axi_bvalid  => s_axi_bvalid,
        s_axi_bready  => s_axi_bready,
        -- User Ports
        magic_strobe => magic_strobe,
        magic_value => magic_value,
        control_strobe => control_strobe,
        control_enable => control_enable,
        control_ack => control_ack,
        control_soft_reset => control_soft_reset,
        control_test_start => control_test_start,
        status_strobe => status_strobe,
        status_busy => status_busy,
        status_ready => status_ready,
        status_overflow => status_overflow,
        status_veto => status_veto,
        event_size_strobe => event_size_strobe,
        event_size_value => event_size_value,
        event_id_strobe => event_id_strobe,
        event_id_value => event_id_value,
        overflow_count_strobe => overflow_count_strobe,
        overflow_count_value => overflow_count_value,
        data_mem_addr => data_mem_addr,
        data_mem_rdata => data_mem_rdata
    );
------------- End INSTANTIATION Template ---------------------------------------
