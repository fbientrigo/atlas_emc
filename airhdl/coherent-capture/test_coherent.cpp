// =============================================================================
// test_coherent.cpp — prueba de estres del protocolo de lectura en software, sin placa.
// FirmwareSim (fw_sim.hpp) captura cada ~30 us en otro hilo, escribiendo palabra por
// palabra en el orden del RTL; el hilo principal hace readCoherent en bucle.
// Verifica que NINGUN snapshot aceptado mezcle capturas, y cuenta cuantos habria
// aceptado mal el criterio "solo SEQ" (equivalente software de tb_integration_coherent.vhd).
//   make test
// 2026-11-16, revision Claude (handoff).
// =============================================================================
#include <cstdio>
#include <vector>
#include "fw_sim.hpp"
#include "snapshot_checks.hpp"
#include "uplink_capture_regs.hpp"

using namespace uc;

// consistencia COMPLETA respecto del modelo de fw_sim.hpp (mas estricta que checkInternal)
static bool fullyConsistent(const Snapshot& s) {
    const uint32_t base = s.a[0] >> 8;                     // (f*7) mod 2^24
    for (unsigned k = 0; k < 7; ++k) {
        if ((s.a[k] >> 8) != ((base + k) & 0xFFFFFF)) return false;
        if ((s.b[k] >> 8) != ((base + 7 + k) & 0xFFFFFF)) return false;
    }
    if (((s.a[7] + 1) & 0x3F) != (s.b[7] & 0x3F)) return false;
    for (unsigned g = 0; g < 7; ++g) {
        const uint8_t a0 = s.a[g] & 0xFF;
        const uint8_t b0 = s.b[g] & 0xFF;
        const uint8_t by[4] = {uint8_t(s.d[g]), uint8_t(s.d[g] >> 8), uint8_t(s.d[g] >> 16), uint8_t(s.d[g] >> 24)};
        if (by[0] != a0 || by[1] != b0) return false;
        if (g < 2) { if (by[2] != a0 || by[3] != b0) return false; }
        else if (by[2] != uint8_t(a0 + 2) || by[3] != uint8_t(a0 + 3)) return false;
    }
    return true;
}

int main() {
    std::vector<uint32_t> mem(0x4000 / 4, 0);
    FirmwareSim fw(mem.data(), 30, 20);   // captura cada 30 us, pequenas esperas entre fases
    UplinkCaptureRegs r(mem.data(), mem.size() * 4);
    fw.start();

    // espera la primera captura
    while (st_seq(r.rd(OFF_STATUS)) == 0) {}

    unsigned long attempts = 0, acc_full = 0, torn_full = 0, acc_seq = 0, torn_seq = 0, torn_total = 0;
    const unsigned long N = 400000;
    for (unsigned long i = 0; i < N; ++i) {
        // misma secuencia que readCoherent, pero evaluando los dos criterios
        Snapshot s;
        const uint32_t s1 = r.rd(OFF_STATUS);
        for (unsigned k = 0; k < 8; ++k) s.a[k] = r.rd(OFF_A0 + 4 * k);
        for (unsigned k = 0; k < 8; ++k) s.b[k] = r.rd(OFF_B0 + 4 * k);
        for (unsigned g = 0; g < 7; ++g) s.d[g] = r.rd(OFF_D0 + 4 * g);
        const uint32_t s2 = r.rd(OFF_STATUS);
        s.status = s2;
        ++attempts;
        const bool ok = fullyConsistent(s);
        if (!ok) ++torn_total;
        if (!st_busy(s1) && !st_busy(s2) && st_seq(s1) == st_seq(s2)) { ++acc_full; if (!ok) ++torn_full; }
        if (st_seq(s1) == st_seq(s2)) { ++acc_seq; if (!ok) ++torn_seq; }
    }
    // y la funcion real de la biblioteca
    unsigned long lib_ok = 0, lib_bad = 0, lib_fail = 0;
    for (unsigned long i = 0; i < N; ++i) {
        Snapshot s;
        if (r.readCoherent(s, 8)) { ++lib_ok; if (!fullyConsistent(s) || checkInternal(s)) ++lib_bad; }
        else ++lib_fail;
    }
    fw.stop();
    std::printf("intentos=%lu cortados_reales=%lu | BUSY+SEQ: aceptados=%lu cortados_aceptados=%lu | solo SEQ: aceptados=%lu cortados_aceptados=%lu\n",
                attempts, torn_total, acc_full, torn_full, acc_seq, torn_seq);
    std::printf("readCoherent(): ok=%lu malos=%lu sin_exito_tras_8=%lu\n", lib_ok, lib_bad, lib_fail);
    const bool pass = torn_full == 0 && lib_bad == 0 && torn_total > 0;
    std::printf("%s\n", pass ? "TEST OK" : "TEST FALLA");
    return pass ? 0 : 1;
}
