// =============================================================================
// snapshot_checks.hpp — invariantes de un snapshot que el firmware garantiza por
// construccion (uplink_capture.vhd) y que se pueden verificar SOLO leyendo registros.
// Usado por emp_acq_capture --check (criterio C6) y por test_coherent.
// 2026-11-16, revision Claude (handoff).
// =============================================================================
#pragma once
#include <cstdint>
#include "uplink_capture_regs.hpp"

namespace uc {

// C6: consistencia interna de UNA captura.
//  - d_g[7:0]  == a_g[7:0]  : diag byte0 y banco A salen del mismo frame N   (uplink_capture.vhd, E0)
//  - d_g[15:8] == b_g[7:0]  : diag byte1 y banco B salen del mismo frame N+1 (uplink_capture.vhd, E1)
//  - a7[31:6] == 0, b7[31:6] == 0 : empaquetado de la palabra 7 (funcion word, k=7)
// Devuelve 0 si todo OK; si no, un bitmask con el primer tipo de falla.
inline unsigned checkInternal(const Snapshot& s) {
    unsigned bad = 0;
    for (unsigned g = 0; g < 7; ++g) {
        if ((s.d[g] & 0xFFu) != (s.a[g] & 0xFFu)) bad |= 1u;
        if (((s.d[g] >> 8) & 0xFFu) != (s.b[g] & 0xFFu)) bad |= 2u;
    }
    if ((s.a[7] >> 6) != 0 || (s.b[7] >> 6) != 0) bad |= 4u;
    if (st_reserved(s.status) != 0) bad |= 8u;
    return bad;
}

// Diagnostico (no es criterio de aceptacion del firmware): periodicidad del canal 0 del grupo g
inline bool diagPeriod2(uint32_t d) { return (d & 0xFF) == ((d >> 16) & 0xFF) && ((d >> 8) & 0xFF) == (d >> 24); }
inline bool diagPeriod1(uint32_t d) { return diagPeriod2(d) && (d & 0xFF) == ((d >> 8) & 0xFF); }
inline uint8_t bitrev8(uint8_t x) {
    x = uint8_t((x & 0xF0) >> 4 | (x & 0x0F) << 4);
    x = uint8_t((x & 0xCC) >> 2 | (x & 0x33) << 2);
    return uint8_t((x & 0xAA) >> 1 | (x & 0x55) << 1);
}

}  // namespace uc
