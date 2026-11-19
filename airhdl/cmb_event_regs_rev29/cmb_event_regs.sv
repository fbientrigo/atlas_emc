// -------------------------------------------------------------------------------------------------
// 'cmb_event' Register Component
// Revision: 29
// -------------------------------------------------------------------------------------------------
// Generated on 2026-11-17 at 04:50 (UTC) by airhdl version 2023.07.1-936312266
// -------------------------------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// -------------------------------------------------------------------------------------------------

`default_nettype none

module cmb_event_regs #(
    parameter AXI_ADDR_WIDTH = 32, // width of the AXI address bus
    parameter logic [31:0] BASEADDR = 32'hA01B0000 // the register file's system base address
    ) (
    // Clock and Reset
    input  wire                      axi_aclk,
    input  wire                      axi_aresetn,

    // AXI Write Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [2:0]                s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,

    // AXI Write Data Channel
    input  wire [31:0]               s_axi_wdata,
    input  wire [3:0]                s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,

    // AXI Read Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [2:0]                s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,

    // AXI Read Data Channel
    output wire [31:0]               s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    // AXI Write Response Channel
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,

    // User Ports
    output wire magic_strobe, // strobe signal for register 'magic' (pulsed when the register is read from the bus)
    input wire [31:0] magic_value, // value of field 'magic.value'
    output wire control_strobe, // strobe signal for register 'control' (pulsed when the register is written from the bus)
    output wire [0:0] control_enable, // value of field 'control.enable'
    output wire [0:0] control_ack, // value of field 'control.ack'
    output wire [0:0] control_soft_reset, // value of field 'control.soft_reset'
    output wire [0:0] control_test_start, // value of field 'control.test_start'
    output wire status_strobe, // strobe signal for register 'status' (pulsed when the register is read from the bus)
    input wire [0:0] status_busy, // value of field 'status.busy'
    input wire [0:0] status_ready, // value of field 'status.ready'
    input wire [0:0] status_overflow, // value of field 'status.overflow'
    input wire [0:0] status_veto, // value of field 'status.veto'
    output wire event_size_strobe, // strobe signal for register 'event_size' (pulsed when the register is read from the bus)
    input wire [31:0] event_size_value, // value of field 'event_size.value'
    output wire event_id_strobe, // strobe signal for register 'event_id' (pulsed when the register is read from the bus)
    input wire [31:0] event_id_value, // value of field 'event_id.value'
    output wire overflow_count_strobe, // strobe signal for register 'overflow_count' (pulsed when the register is read from the bus)
    input wire [31:0] overflow_count_value, // value of field 'overflow_count.value'
    output wire [13:0] data_mem_addr, // read/write address for memory 'data_mem'
    input wire [31:0] data_mem_rdata, // read data for memory 'data_mem'
    output wire data_mem_ren // read-enable for memory 'data_mem'
    );

    // Constants
    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    // Registered signals
    logic                           s_axi_awready_r;
    logic                           s_axi_wready_r;
    logic [$bits(s_axi_awaddr)-1:0] s_axi_awaddr_reg_r;
    logic                           s_axi_bvalid_r;
    logic [$bits(s_axi_bresp)-1:0]  s_axi_bresp_r;
    logic                           s_axi_arready_r;
    logic [$bits(s_axi_araddr)-1:0] s_axi_araddr_reg_r;
    logic                           s_axi_rvalid_r;
    logic [$bits(s_axi_rresp)-1:0]  s_axi_rresp_r;
    logic [$bits(s_axi_wdata)-1:0]  s_axi_wdata_reg_r;
    logic [$bits(s_axi_wstrb)-1:0]  s_axi_wstrb_reg_r;
    logic [$bits(s_axi_rdata)-1:0]  s_axi_rdata_r;

    // User-defined registers
    logic s_magic_strobe_r;
    logic [31:0] s_reg_magic_value;
    logic s_control_strobe_r;
    logic [0:0] s_reg_control_enable_r;
    logic [0:0] s_reg_control_ack_r;
    logic [0:0] s_reg_control_soft_reset_r;
    logic [0:0] s_reg_control_test_start_r;
    logic s_status_strobe_r;
    logic [0:0] s_reg_status_busy;
    logic [0:0] s_reg_status_ready;
    logic [0:0] s_reg_status_overflow;
    logic [0:0] s_reg_status_veto;
    logic s_event_size_strobe_r;
    logic [31:0] s_reg_event_size_value;
    logic s_event_id_strobe_r;
    logic [31:0] s_reg_event_id_value;
    logic s_overflow_count_strobe_r;
    logic [31:0] s_reg_overflow_count_value;
    logic [13:0] s_data_mem_raddr_r;
    logic s_data_mem_ren_r;
    logic [31:0] s_data_mem_rdata;

    //----------------------------------------------------------------------------------------------
    // Inputs
    //----------------------------------------------------------------------------------------------

    assign s_reg_magic_value = magic_value;
    assign s_reg_status_busy = status_busy;
    assign s_reg_status_ready = status_ready;
    assign s_reg_status_overflow = status_overflow;
    assign s_reg_status_veto = status_veto;
    assign s_reg_event_size_value = event_size_value;
    assign s_reg_event_id_value = event_id_value;
    assign s_reg_overflow_count_value = overflow_count_value;
    assign s_data_mem_rdata = data_mem_rdata;

    //----------------------------------------------------------------------------------------------
    // Read-transaction FSM
    //----------------------------------------------------------------------------------------------

    localparam MAX_MEMORY_LATENCY = 5;

    typedef enum {
        READ_IDLE,
        READ_REGISTER,
        WAIT_MEMORY_RDATA,
        READ_RESPONSE,
        READ_DONE
    } read_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: read_fsm
        // Registered state variables
        read_state_t v_state_r;
        logic [31:0] v_rdata_r;
        logic [1:0] v_rresp_r;
        logic [$clog2(MAX_MEMORY_LATENCY)-1:0] v_mem_wait_count_r;
        // Combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r          <= READ_IDLE;
            v_rdata_r          <= '0;
            v_rresp_r          <= '0;
            v_mem_wait_count_r <= '0;
            s_axi_arready_r    <= '0;
            s_axi_rvalid_r     <= '0;
            s_axi_rresp_r      <= '0;
            s_axi_araddr_reg_r <= '0;
            s_axi_rdata_r      <= '0;
            s_magic_strobe_r <= '0;
            s_status_strobe_r <= '0;
            s_event_size_strobe_r <= '0;
            s_event_id_strobe_r <= '0;
            s_overflow_count_strobe_r <= '0;
            s_data_mem_raddr_r <= '0;
            s_data_mem_ren_r <= 0;
        end else begin
            // Default values:
            s_axi_arready_r <= 1'b0;
            s_magic_strobe_r <= '0;
            s_status_strobe_r <= '0;
            s_event_size_strobe_r <= '0;
            s_event_id_strobe_r <= '0;
            s_overflow_count_strobe_r <= '0;
            s_data_mem_raddr_r <= '0;

            case (v_state_r) // sigasi @suppress "Default clause missing from case statement"

                // Wait for the start of a read transaction, which is
                // initiated by the assertion of ARVALID
                READ_IDLE: begin
                    if (s_axi_arvalid) begin
                        s_axi_araddr_reg_r <= s_axi_araddr;     // save the read address
                        s_axi_arready_r    <= 1'b1;             // acknowledge the read-address
                        v_state_r          <= READ_REGISTER;
                    end
                end

                // Read from the actual storage element
                READ_REGISTER: begin
                    // Defaults:
                    v_addr_hit = 1'b0;
                    v_rdata_r  <= '0;

                    // Register 'magic' at address offset 0x0
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::MAGIC_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_magic_value;
                        s_magic_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'control' at address offset 0x4
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::CONTROL_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_control_enable_r;
                        v_rdata_r[1:1] <= s_reg_control_ack_r;
                        v_rdata_r[2:2] <= s_reg_control_soft_reset_r;
                        v_rdata_r[3:3] <= s_reg_control_test_start_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'status' at address offset 0x8
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::STATUS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_status_busy;
                        v_rdata_r[1:1] <= s_reg_status_ready;
                        v_rdata_r[2:2] <= s_reg_status_overflow;
                        v_rdata_r[3:3] <= s_reg_status_veto;
                        s_status_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'event_size' at address offset 0xC
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::EVENT_SIZE_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_event_size_value;
                        s_event_size_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'event_id' at address offset 0x10
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::EVENT_ID_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_event_id_value;
                        s_event_id_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'overflow_count' at address offset 0x14
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::OVERFLOW_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_overflow_count_value;
                        s_overflow_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Memory 'data_mem' at address offset 0x1000
                    if (s_axi_araddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + cmb_event_regs_pkg::DATA_MEM_OFFSET) &&
                        s_axi_araddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + cmb_event_regs_pkg::DATA_MEM_OFFSET + cmb_event_regs_pkg::DATA_MEM_DEPTH * 4)) begin
                        v_addr_hit = 1'b1;
                        // Generate memory read address:
                        v_mem_addr = s_axi_araddr_reg_r - AXI_ADDR_WIDTH'(BASEADDR + cmb_event_regs_pkg::DATA_MEM_OFFSET);
                        s_data_mem_raddr_r <= v_mem_addr[15:2]; // output address has 4-byte granularity
                        s_data_mem_ren_r <= 1;
                        v_mem_wait_count_r <= cmb_event_regs_pkg::DATA_MEM_READ_LATENCY;
                        v_state_r <= WAIT_MEMORY_RDATA;
                    end
                    if (v_addr_hit) begin
                        v_rresp_r <= AXI_OKAY;
                    end else begin
                        v_rresp_r <= AXI_SLVERR;
                        // pragma translate_off
                        $warning("ARADDR decode error");
                        // pragma translate_on
                        v_state_r <= READ_RESPONSE;
                    end
                end

                // Wait for memory read data
                WAIT_MEMORY_RDATA: begin
                    if (v_mem_wait_count_r == 0) begin
                        // Memory 'data_mem' at address offset 0x1000
                        if (s_axi_araddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + cmb_event_regs_pkg::DATA_MEM_OFFSET) &&
                            s_axi_araddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + cmb_event_regs_pkg::DATA_MEM_OFFSET + cmb_event_regs_pkg::DATA_MEM_DEPTH * 4)) begin
                            v_rdata_r[31:0] <= s_data_mem_rdata[31:0];
                            s_data_mem_ren_r <= 0;
                        end
                        v_state_r <= READ_RESPONSE;
                    end else begin
                        v_mem_wait_count_r <= v_mem_wait_count_r - 1;
                    end
                end

                // Generate read response
                READ_RESPONSE: begin
                    s_axi_rvalid_r <= 1'b1;
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    v_state_r      <= READ_DONE;
                end

                // Write transaction completed, wait for master RREADY to proceed
                READ_DONE: begin
                    if (s_axi_rready) begin
                        s_axi_rvalid_r <= 1'b0;
                        s_axi_rdata_r  <= '0;
                        v_state_r      <= READ_IDLE;
                    end
                end

            endcase
        end
    end: read_fsm

    //----------------------------------------------------------------------------------------------
    // Write-transaction FSM
    //----------------------------------------------------------------------------------------------

    typedef enum {
        WRITE_IDLE,
        WRITE_ADDR_FIRST,
        WRITE_DATA_FIRST,
        WRITE_UPDATE_REGISTER,
        WRITE_DONE
    } write_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: write_fsm
        // Registered state variables
        write_state_t v_state_r;
        // Combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r                   <= WRITE_IDLE;
            s_axi_awready_r             <= 1'b0;
            s_axi_wready_r              <= 1'b0;
            s_axi_awaddr_reg_r          <= '0;
            s_axi_wdata_reg_r           <= '0;
            s_axi_wstrb_reg_r           <= '0;
            s_axi_bvalid_r              <= 1'b0;
            s_axi_bresp_r               <= '0;

            s_control_strobe_r <= '0;
            s_reg_control_enable_r <= cmb_event_regs_pkg::CONTROL_ENABLE_RESET;
            s_reg_control_ack_r <= cmb_event_regs_pkg::CONTROL_ACK_RESET;
            s_reg_control_soft_reset_r <= cmb_event_regs_pkg::CONTROL_SOFT_RESET_RESET;
            s_reg_control_test_start_r <= cmb_event_regs_pkg::CONTROL_TEST_START_RESET;

        end else begin
            // Default values:
            s_axi_awready_r <= 1'b0;
            s_axi_wready_r  <= 1'b0;
            s_control_strobe_r <= '0;
            v_addr_hit = 1'b0;

            // Self-clearing fields:
            s_reg_control_ack_r <= '0;
            s_reg_control_soft_reset_r <= '0;
            s_reg_control_test_start_r <= '0;

            case (v_state_r) // sigasi @suppress "Default clause missing from case statement"

                // Wait for the start of a write transaction, which may be
                // initiated by either of the following conditions:
                //   * assertion of both AWVALID and WVALID
                //   * assertion of AWVALID
                //   * assertion of WVALID
                WRITE_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r     <= 1'b1; // acknowledge the write-data
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end else if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_ADDR_FIRST;
                    end else if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_DATA_FIRST;
                    end
                end

                // Address-first write transaction: wait for the write-data
                WRITE_ADDR_FIRST: begin
                    if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Data-first write transaction: wait for the write-address
                WRITE_DATA_FIRST: begin
                    if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Update the actual storage element
                WRITE_UPDATE_REGISTER: begin
                    s_axi_bresp_r  <= AXI_OKAY; // default value, may be overriden in case of decode error
                    s_axi_bvalid_r <= 1'b1;


                    // Register  'control' at address offset 0x4
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + cmb_event_regs_pkg::CONTROL_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_control_strobe_r <= 1'b1;
                        // field 'enable':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_control_enable_r[0] <= s_axi_wdata_reg_r[0]; // enable[0]
                        end
                        // field 'ack':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_control_ack_r[0] <= s_axi_wdata_reg_r[1]; // ack[0]
                        end
                        // field 'soft_reset':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_control_soft_reset_r[0] <= s_axi_wdata_reg_r[2]; // soft_reset[0]
                        end
                        // field 'test_start':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_control_test_start_r[0] <= s_axi_wdata_reg_r[3]; // test_start[0]
                        end
                    end






                    if (!v_addr_hit) begin
                        s_axi_bresp_r   <= AXI_SLVERR;
                        // pragma translate_off
                        $warning("AWADDR decode error");
                        // pragma translate_on
                    end
                    v_state_r <= WRITE_DONE;
                end

                // Write transaction completed, wait for master BREADY to proceed
                WRITE_DONE: begin
                    if (s_axi_bready) begin
                        s_axi_bvalid_r <= 1'b0;
                        v_state_r      <= WRITE_IDLE;
                    end
                end
            endcase


        end
    end: write_fsm

    //----------------------------------------------------------------------------------------------
    // Outputs
    //----------------------------------------------------------------------------------------------

    assign s_axi_awready = s_axi_awready_r;
    assign s_axi_wready  = s_axi_wready_r;
    assign s_axi_bvalid  = s_axi_bvalid_r;
    assign s_axi_bresp   = s_axi_bresp_r;
    assign s_axi_arready = s_axi_arready_r;
    assign s_axi_rvalid  = s_axi_rvalid_r;
    assign s_axi_rresp   = s_axi_rresp_r;
    assign s_axi_rdata   = s_axi_rdata_r;

    assign magic_strobe = s_magic_strobe_r;
    assign control_strobe = s_control_strobe_r;
    assign control_enable = s_reg_control_enable_r;
    assign control_ack = s_reg_control_ack_r;
    assign control_soft_reset = s_reg_control_soft_reset_r;
    assign control_test_start = s_reg_control_test_start_r;
    assign status_strobe = s_status_strobe_r;
    assign event_size_strobe = s_event_size_strobe_r;
    assign event_id_strobe = s_event_id_strobe_r;
    assign overflow_count_strobe = s_overflow_count_strobe_r;
    assign data_mem_addr = s_data_mem_raddr_r;
    assign data_mem_ren = s_data_mem_ren_r;

endmodule: cmb_event_regs

`resetall
