// -----------------------------------------------------------------------------
// 'cmb_event' Register Definitions
// Revision: 29
// -----------------------------------------------------------------------------
// Generated on 2026-11-17 at 04:50 (UTC) by airhdl version 2023.07.1-936312266
// -----------------------------------------------------------------------------
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
// -----------------------------------------------------------------------------

package cmb_event_regs_pkg;

    // Revision number of the 'cmb_event' register map
    localparam CMB_EVENT_REVISION = 29;

    // Default base address of the 'cmb_event' register map
    localparam logic [31:0] CMB_EVENT_DEFAULT_BASEADDR = 32'hA01B0000;

    // Size of the 'cmb_event' register map, in bytes
    localparam CMB_EVENT_RANGE_BYTES = 45184;

    // Register 'magic'
    localparam logic [31:0] MAGIC_OFFSET = 32'h00000000; // address offset of the 'magic' register
    // Field 'magic.value'
    localparam MAGIC_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam MAGIC_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] MAGIC_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'control'
    localparam logic [31:0] CONTROL_OFFSET = 32'h00000004; // address offset of the 'control' register
    // Field 'control.enable'
    localparam CONTROL_ENABLE_BIT_OFFSET = 0; // bit offset of the 'enable' field
    localparam CONTROL_ENABLE_BIT_WIDTH = 1; // bit width of the 'enable' field
    localparam logic [0:0] CONTROL_ENABLE_RESET = 1'b0; // reset value of the 'enable' field
    // Field 'control.ack'
    localparam CONTROL_ACK_BIT_OFFSET = 1; // bit offset of the 'ack' field
    localparam CONTROL_ACK_BIT_WIDTH = 1; // bit width of the 'ack' field
    localparam logic [1:1] CONTROL_ACK_RESET = 1'b0; // reset value of the 'ack' field
    // Field 'control.soft_reset'
    localparam CONTROL_SOFT_RESET_BIT_OFFSET = 2; // bit offset of the 'soft_reset' field
    localparam CONTROL_SOFT_RESET_BIT_WIDTH = 1; // bit width of the 'soft_reset' field
    localparam logic [2:2] CONTROL_SOFT_RESET_RESET = 1'b0; // reset value of the 'soft_reset' field
    // Field 'control.test_start'
    localparam CONTROL_TEST_START_BIT_OFFSET = 3; // bit offset of the 'test_start' field
    localparam CONTROL_TEST_START_BIT_WIDTH = 1; // bit width of the 'test_start' field
    localparam logic [3:3] CONTROL_TEST_START_RESET = 1'b0; // reset value of the 'test_start' field

    // Register 'status'
    localparam logic [31:0] STATUS_OFFSET = 32'h00000008; // address offset of the 'status' register
    // Field 'status.busy'
    localparam STATUS_BUSY_BIT_OFFSET = 0; // bit offset of the 'busy' field
    localparam STATUS_BUSY_BIT_WIDTH = 1; // bit width of the 'busy' field
    localparam logic [0:0] STATUS_BUSY_RESET = 1'b0; // reset value of the 'busy' field
    // Field 'status.ready'
    localparam STATUS_READY_BIT_OFFSET = 1; // bit offset of the 'ready' field
    localparam STATUS_READY_BIT_WIDTH = 1; // bit width of the 'ready' field
    localparam logic [1:1] STATUS_READY_RESET = 1'b0; // reset value of the 'ready' field
    // Field 'status.overflow'
    localparam STATUS_OVERFLOW_BIT_OFFSET = 2; // bit offset of the 'overflow' field
    localparam STATUS_OVERFLOW_BIT_WIDTH = 1; // bit width of the 'overflow' field
    localparam logic [2:2] STATUS_OVERFLOW_RESET = 1'b0; // reset value of the 'overflow' field
    // Field 'status.veto'
    localparam STATUS_VETO_BIT_OFFSET = 3; // bit offset of the 'veto' field
    localparam STATUS_VETO_BIT_WIDTH = 1; // bit width of the 'veto' field
    localparam logic [3:3] STATUS_VETO_RESET = 1'b0; // reset value of the 'veto' field

    // Register 'event_size'
    localparam logic [31:0] EVENT_SIZE_OFFSET = 32'h0000000C; // address offset of the 'event_size' register
    // Field 'event_size.value'
    localparam EVENT_SIZE_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam EVENT_SIZE_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] EVENT_SIZE_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'event_id'
    localparam logic [31:0] EVENT_ID_OFFSET = 32'h00000010; // address offset of the 'event_id' register
    // Field 'event_id.value'
    localparam EVENT_ID_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam EVENT_ID_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] EVENT_ID_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'overflow_count'
    localparam logic [31:0] OVERFLOW_COUNT_OFFSET = 32'h00000014; // address offset of the 'overflow_count' register
    // Field 'overflow_count.value'
    localparam OVERFLOW_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam OVERFLOW_COUNT_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] OVERFLOW_COUNT_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'data_mem'
    localparam logic [31:0] DATA_MEM_OFFSET = 32'h00001000; // address offset of the 'data_mem' register
    localparam DATA_MEM_DEPTH = 10272; // depth of the 'data_mem' memory, in elements
    localparam DATA_MEM_READ_LATENCY = 1; // read latency of the 'data_mem' memory, in clock cycles
    // Field 'data_mem.value'
    localparam DATA_MEM_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam DATA_MEM_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] DATA_MEM_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

endpackage: cmb_event_regs_pkg
