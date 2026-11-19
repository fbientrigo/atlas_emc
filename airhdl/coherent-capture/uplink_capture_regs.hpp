// =============================================================================
// uplink_capture_regs.hpp
// Acceso a tgc_readUplink_regs_10 (base 0xA0180000, 16 KiB, UIO) con lectura
// coherente del snapshot que publica uplink_capture.vhd.
//
// Fuente de cada dato (para no tener que reconstruirlo despues):
//   offsets          -> vivado/tgc_readUplink_regs_pkg.vhd rev 28 (*_OFFSET)
//   a0..a7 (0x04..)  -> uplink_capture.vhd, word(frame_a,k): frame N, mismo corte que registerSplit
//   b0..b7 (0x30..)  -> uplink_capture.vhd, word(frame_b,k): frame N+1
//   STATUS (0x50)    -> uplink_capture.vhd, 'status <= seq & "00000" & busy & rdy_b & rdy_a'
//   d0..d6 (0x54..)  -> uplink_capture.vhd, diag(g): canal 0 del grupo g, frames N..N+3 (byte j = N+j)
//   magic (0x00)     -> en el BD se conecta a uplink_capture_0/version (apply_uplink_capture.tcl, paso 5)
//   version (0x70)   -> uplink_capture.vhd generic BUILD_ID
//
// Regla de seguridad: en el bitstream VIEJO los offsets 0x30..0x70 responden SLVERR,
// que en el Zynq MPSoC termina en SIGBUS (o en un SError del kernel). Por eso
// UplinkCaptureRegs::isNewFirmware() lee SOLO 0x00 y todo lo demas exige que pase.
//
// 2026-11-16, revision Claude (handoff). Reemplaza ReadUplinkCapture.* (ver _superseded_gemini/).
// =============================================================================
#pragma once

#include <cstddef>
#include <cstdint>
#include <string>

namespace uc {

// ---- mapa de registros (bytes) : vivado/tgc_readUplink_regs_pkg.vhd rev 28 ----
constexpr uint32_t OFF_MAGIC      = 0x00;  // = BUILD_ID en el bitstream nuevo, 0 en el viejo
constexpr uint32_t OFF_A0         = 0x04;  // data_group_0..7 = a0..a7 (0x04..0x20), compatibles con el software viejo
constexpr uint32_t OFF_CLK_THRESH = 0x2C;  // RW legacy (no se usa en el canal 10)
constexpr uint32_t OFF_B0         = 0x30;  // b0..b7 (0x30..0x4C)
constexpr uint32_t OFF_STATUS     = 0x50;
constexpr uint32_t OFF_D0         = 0x54;  // d0..d6 (0x54..0x6C)
constexpr uint32_t OFF_VERSION    = 0x70;
constexpr uint32_t MAP_END        = 0x74;  // primer offset NO mapeado (SLVERR): nunca leer >= 0x74

constexpr uint64_t BASE_ADDR         = 0xA0180000ULL;  // assign_bd_address de tgc_readUplink_regs_10
constexpr uint32_t BUILD_ID_EXPECTED = 0xCA970003u;    // uplink_capture.vhd, generic BUILD_ID

// ---- campos de STATUS : uplink_capture.vhd ----
inline uint32_t st_seq (uint32_t s) { return s >> 8; }            // [31:8] SEQ, 24 bits
inline bool     st_busy(uint32_t s) { return (s >> 2) & 1u; }     // [2]  1 = actualizando A/B/diag/SEQ
inline bool     st_rdyb(uint32_t s) { return (s >> 1) & 1u; }     // [1]  uplink_ready en frame N+1
inline bool     st_rdya(uint32_t s) { return s & 1u; }            // [0]  uplink_ready en frame N
inline uint32_t st_reserved(uint32_t s) { return (s >> 3) & 0x1Fu; } // [7:3] siempre 0
inline uint32_t seq_diff(uint32_t newer, uint32_t older) { return (newer - older) & 0xFFFFFFu; } // modulo 2^24

// Un snapshot coherente (todas las palabras de la MISMA captura)
struct Snapshot {
    uint64_t t_unix_ns = 0;  // CLOCK_REALTIME al aceptar (para correlacionar con otros logs)
    uint32_t status = 0;     // STATUS leido antes y despues (iguales, BUSY=0)
    uint32_t a[8] = {};      // frame N
    uint32_t b[8] = {};      // frame N+1
    uint32_t d[7] = {};      // canal 0 de cada grupo, frames N..N+3
    unsigned tries = 0;      // intentos usados por readCoherent (1 = a la primera)
};

class UplinkCaptureRegs {
public:
    // Busca el /dev/uioN cuyo map0 empieza en 'addr' (via /sys/class/uio/uio*/maps/map0/addr).
    // Devuelve "" si no hay. Asi no depende de que siga siendo /dev/uio18 despues de un reboot.
    static std::string findUioByAddr(uint64_t addr = BASE_ADDR);

    // Abre /dev/uioN y mapea map0 completo (tamano desde sysfs). Lanza std::runtime_error.
    explicit UplinkCaptureRegs(const std::string& uioDev);
    // Para pruebas: usa memoria ya mapeada (no toma propiedad).
    UplinkCaptureRegs(volatile uint32_t* base, size_t bytes);
    ~UplinkCaptureRegs();
    UplinkCaptureRegs(const UplinkCaptureRegs&) = delete;            // posee fd + mmap: no copiable
    UplinkCaptureRegs& operator=(const UplinkCaptureRegs&) = delete;

    // Lectura de 32 bits; lanza si off >= MAP_END o no esta alineado (protege del SLVERR).
    uint32_t rd(uint32_t off) const;

    // Lee SOLO 0x00. true si = BUILD_ID_EXPECTED. Llamar antes de cualquier otra lectura >= 0x30.
    bool isNewFirmware(uint32_t* magic_out = nullptr) const;

    // Protocolo coherente (simulado en sim/tb_integration_coherent.vhd):
    //   s1 = STATUS; a0..a7; b0..b7; d0..d6; s2 = STATUS
    //   acepta si BUSY(s1)=0, BUSY(s2)=0 y SEQ(s1)=SEQ(s2)
    // Reintenta hasta max_tries (BUSY dura 100 ns cada 10 ms: casi siempre basta 1).
    bool readCoherent(Snapshot& out, unsigned max_tries = 8) const;

    const std::string& device() const { return dev_; }
    uint64_t mapAddr() const { return map_addr_; }
    size_t mapSize() const { return map_size_; }

private:
    volatile uint32_t* base_ = nullptr;
    size_t map_size_ = 0;
    uint64_t map_addr_ = 0;
    int fd_ = -1;
    void* mmap_ptr_ = nullptr;
    size_t mmap_len_ = 0;
    std::string dev_;
};

}  // namespace uc
