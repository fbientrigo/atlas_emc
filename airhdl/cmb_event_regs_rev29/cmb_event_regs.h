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

#ifndef CMB_EVENT_REGS_H
#define CMB_EVENT_REGS_H

/* Revision number of the 'cmb_event' register map */
#define CMB_EVENT_REVISION 29

/* Default base address of the 'cmb_event' register map */
#define CMB_EVENT_DEFAULT_BASEADDR 0xA01B0000

/* Size of the 'cmb_event' register map, in bytes */
#define CMB_EVENT_RANGE_BYTES 45184

/* Register 'magic' */
#define MAGIC_OFFSET 0x00000000 /* address offset of the 'magic' register */

/* Field  'magic.value' */
#define MAGIC_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define MAGIC_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define MAGIC_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define MAGIC_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'control' */
#define CONTROL_OFFSET 0x00000004 /* address offset of the 'control' register */

/* Field  'control.enable' */
#define CONTROL_ENABLE_BIT_OFFSET 0 /* bit offset of the 'enable' field */
#define CONTROL_ENABLE_BIT_WIDTH 1 /* bit width of the 'enable' field */
#define CONTROL_ENABLE_BIT_MASK 0x00000001 /* bit mask of the 'enable' field */
#define CONTROL_ENABLE_RESET 0x0 /* reset value of the 'enable' field */

/* Field  'control.ack' */
#define CONTROL_ACK_BIT_OFFSET 1 /* bit offset of the 'ack' field */
#define CONTROL_ACK_BIT_WIDTH 1 /* bit width of the 'ack' field */
#define CONTROL_ACK_BIT_MASK 0x00000002 /* bit mask of the 'ack' field */
#define CONTROL_ACK_RESET 0x0 /* reset value of the 'ack' field */

/* Field  'control.soft_reset' */
#define CONTROL_SOFT_RESET_BIT_OFFSET 2 /* bit offset of the 'soft_reset' field */
#define CONTROL_SOFT_RESET_BIT_WIDTH 1 /* bit width of the 'soft_reset' field */
#define CONTROL_SOFT_RESET_BIT_MASK 0x00000004 /* bit mask of the 'soft_reset' field */
#define CONTROL_SOFT_RESET_RESET 0x0 /* reset value of the 'soft_reset' field */

/* Field  'control.test_start' */
#define CONTROL_TEST_START_BIT_OFFSET 3 /* bit offset of the 'test_start' field */
#define CONTROL_TEST_START_BIT_WIDTH 1 /* bit width of the 'test_start' field */
#define CONTROL_TEST_START_BIT_MASK 0x00000008 /* bit mask of the 'test_start' field */
#define CONTROL_TEST_START_RESET 0x0 /* reset value of the 'test_start' field */

/* Register 'status' */
#define STATUS_OFFSET 0x00000008 /* address offset of the 'status' register */

/* Field  'status.busy' */
#define STATUS_BUSY_BIT_OFFSET 0 /* bit offset of the 'busy' field */
#define STATUS_BUSY_BIT_WIDTH 1 /* bit width of the 'busy' field */
#define STATUS_BUSY_BIT_MASK 0x00000001 /* bit mask of the 'busy' field */
#define STATUS_BUSY_RESET 0x0 /* reset value of the 'busy' field */

/* Field  'status.ready' */
#define STATUS_READY_BIT_OFFSET 1 /* bit offset of the 'ready' field */
#define STATUS_READY_BIT_WIDTH 1 /* bit width of the 'ready' field */
#define STATUS_READY_BIT_MASK 0x00000002 /* bit mask of the 'ready' field */
#define STATUS_READY_RESET 0x0 /* reset value of the 'ready' field */

/* Field  'status.overflow' */
#define STATUS_OVERFLOW_BIT_OFFSET 2 /* bit offset of the 'overflow' field */
#define STATUS_OVERFLOW_BIT_WIDTH 1 /* bit width of the 'overflow' field */
#define STATUS_OVERFLOW_BIT_MASK 0x00000004 /* bit mask of the 'overflow' field */
#define STATUS_OVERFLOW_RESET 0x0 /* reset value of the 'overflow' field */

/* Field  'status.veto' */
#define STATUS_VETO_BIT_OFFSET 3 /* bit offset of the 'veto' field */
#define STATUS_VETO_BIT_WIDTH 1 /* bit width of the 'veto' field */
#define STATUS_VETO_BIT_MASK 0x00000008 /* bit mask of the 'veto' field */
#define STATUS_VETO_RESET 0x0 /* reset value of the 'veto' field */

/* Register 'event_size' */
#define EVENT_SIZE_OFFSET 0x0000000C /* address offset of the 'event_size' register */

/* Field  'event_size.value' */
#define EVENT_SIZE_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define EVENT_SIZE_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define EVENT_SIZE_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define EVENT_SIZE_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'event_id' */
#define EVENT_ID_OFFSET 0x00000010 /* address offset of the 'event_id' register */

/* Field  'event_id.value' */
#define EVENT_ID_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define EVENT_ID_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define EVENT_ID_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define EVENT_ID_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'overflow_count' */
#define OVERFLOW_COUNT_OFFSET 0x00000014 /* address offset of the 'overflow_count' register */

/* Field  'overflow_count.value' */
#define OVERFLOW_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define OVERFLOW_COUNT_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define OVERFLOW_COUNT_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define OVERFLOW_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'data_mem' */
#define DATA_MEM_OFFSET 0x00001000 /* address offset of the 'data_mem' register */
#define DATA_MEM_DEPTH 10272 /* depth of the 'data_mem' memory, in elements */

/* Field  'data_mem.value' */
#define DATA_MEM_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define DATA_MEM_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define DATA_MEM_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define DATA_MEM_VALUE_RESET 0x0 /* reset value of the 'value' field */

#endif  /* CMB_EVENT_REGS_H */
