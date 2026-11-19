// =============================================================================
// fw_sim.hpp — emulador en software de uplink_capture.vhd + tgc_readUplink_regs rev 28,
// SOLO para probar el software sin placa (emp_acq_capture --simulate, test_coherent).
// Escribe en un bloque de memoria los registros en el MISMO orden que el RTL:
//   E0: BUSY=1, banco A, diag byte0   E1: banco B, diag byte1   E2: diag byte2
//   E3: diag byte3, SEQ+1             E4: BUSY=0
// "Fuente" simulada: canal 0 de g0/g1 con periodo 2 frames (como lo diagnosticado),
// canal 0 de g2..g6 = contador; resto de bits derivados del numero de frame, de modo
// que cualquier mezcla de capturas distintas se detecta.
// Limitacion: los dos hilos comparten memoria 'volatile' sin atomicos (carrera formal); el orden de
// escrituras que se usa esta garantizado en x86 (TSO), no en ARM. Es una prueba de logica, no de hardware.
// 2026-11-16, revision Claude (handoff).
// =============================================================================
#pragma once
#include <atomic>
#include <chrono>
#include <cstdint>
#include <thread>
#include "uplink_capture_regs.hpp"

namespace uc {

class FirmwareSim {
public:
    // mem: al menos MAP_END bytes. period_us: tiempo entre capturas (10000 = 100 Hz real).
    FirmwareSim(volatile uint32_t* mem, unsigned period_us, unsigned step_spin = 0)
        : m_(mem), period_us_(period_us), spin_(step_spin) {
        m_[OFF_MAGIC >> 2] = BUILD_ID_EXPECTED;
        m_[OFF_VERSION >> 2] = BUILD_ID_EXPECTED;
        m_[OFF_STATUS >> 2] = 0;
    }
    ~FirmwareSim() { stop(); }
    void start() { run_ = true; th_ = std::thread([this] { loop(); }); }
    void stop() { if (run_.exchange(false) && th_.joinable()) th_.join(); }

    // canal 0 del grupo g en el frame f, tal como sale del firmware 0xCA970003 (REVERSE_WIDTH=8: orden
    // de bits YA corregido, 1er bit recibido en el MSB). g0/g1 imitan la hipotesis a probar con
    // analysis/elink_align.py: la fuente manda 0xC4 con cada bit DUPLICADO (patron de 16 bits = 2 frames)
    // y queda un desfase fijo de 3 (g0) / 5 (g1) bits, que se corrige en software.
    static uint8_t ch0(uint64_t f, unsigned g) {
        if (g < 2) {
            const unsigned phase = (g == 0) ? 3 : 5;
            uint8_t byte = 0;
            for (unsigned i = 0; i < 8; ++i) {                    // i = orden de llegada dentro del frame
                const unsigned t = unsigned((f * 8 + i + phase) % 16);   // posicion en el patron de 16 bits
                const unsigned src_bit = 7 - t / 2;               // 0xC4 MSB primero, cada bit dos veces
                byte |= uint8_t(((0xC4u >> src_bit) & 1u) << (7 - i));  // primer bit recibido -> MSB
            }
            return byte;
        }
        return uint8_t(f + g);
    }
    // palabra k del frame f (k=0..6), y la 7 con 6 bits
    static uint32_t word(uint64_t f, unsigned k) {
        if (k == 7) return uint32_t(f & 0x3F);
        return (uint32_t(f * 7 + k) << 8) | ch0(f, k);
    }

private:
    void w(uint32_t off, uint32_t v) { m_[off >> 2] = v; }
    void step() { for (volatile unsigned i = 0; i < spin_; ++i) {} }
    void loop() {
        uint64_t f = 1000;   // numero de frame
        uint32_t seq = 0;
        auto next = std::chrono::steady_clock::now();
        uint32_t d[7] = {};
        while (run_) {
            next += std::chrono::microseconds(period_us_);
            std::this_thread::sleep_until(next);
            const uint32_t rdy = 0x3;
            // E0
            w(OFF_STATUS, (seq << 8) | 0x4 | rdy); step();
            for (unsigned k = 0; k < 8; ++k) { w(OFF_A0 + 4 * k, word(f, k)); }
            for (unsigned g = 0; g < 7; ++g) { d[g] = (d[g] & 0xFFFFFF00u) | ch0(f, g); w(OFF_D0 + 4 * g, d[g]); }
            step();
            // E1
            for (unsigned k = 0; k < 8; ++k) { w(OFF_B0 + 4 * k, word(f + 1, k)); }
            for (unsigned g = 0; g < 7; ++g) { d[g] = (d[g] & 0xFFFF00FFu) | (uint32_t(ch0(f + 1, g)) << 8); w(OFF_D0 + 4 * g, d[g]); }
            step();
            // E2
            for (unsigned g = 0; g < 7; ++g) { d[g] = (d[g] & 0xFF00FFFFu) | (uint32_t(ch0(f + 2, g)) << 16); w(OFF_D0 + 4 * g, d[g]); }
            step();
            // E3
            for (unsigned g = 0; g < 7; ++g) { d[g] = (d[g] & 0x00FFFFFFu) | (uint32_t(ch0(f + 3, g)) << 24); w(OFF_D0 + 4 * g, d[g]); }
            seq = (seq + 1) & 0xFFFFFF;
            w(OFF_STATUS, (seq << 8) | 0x4 | rdy); step();
            // E4
            w(OFF_STATUS, (seq << 8) | rdy);
            f += 400000;   // PERIOD frames despues
        }
    }
    volatile uint32_t* m_;
    unsigned period_us_, spin_;
    std::atomic<bool> run_{false};
    std::thread th_;
};

}  // namespace uc
