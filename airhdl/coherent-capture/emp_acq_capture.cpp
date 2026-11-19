// =============================================================================
// emp_acq_capture.cpp — adquisicion coherente del canal lpGBT 10 (uplink_capture)
//
//   emp_acq_capture --check                 criterios de aceptacion C0..C7 (≈10 s), exit 0 = PASS
//   emp_acq_capture --out run.csv --seconds 28800   log de 8 h, una fila por SEQ nuevo
//   emp_acq_capture --simulate --check      lo mismo contra un firmware emulado (sin placa)
//
// Cada fila del CSV = un snapshot coherente (UplinkCaptureRegs::readCoherent):
//   t_unix_ns  : CLOCK_REALTIME al aceptar el snapshot
//   seq        : STATUS[31:8]   (uplink_capture.vhd, contador de capturas, 24 bits)
//   seq_gap    : seq - seq_anterior (1 = no se perdio ninguna captura; >1 = el software se atraso)
//   tries      : intentos de readCoherent (1 = a la primera)
//   status     : STATUS crudo (0x50)   rdy_a/rdy_b: STATUS[0]/[1]
//   a0..a7     : frame N   (0x04..0x20, word(frame_a,k))
//   b0..b7     : frame N+1 (0x30..0x4C, word(frame_b,k))
//   d0..d6     : canal 0 del grupo g en frames N..N+3, byte j = N+j (0x54..0x6C, diag(g))
// Tamano: ~300 bytes/fila a 100 Hz ≈ 870 MB en 8 h.
//
// Compilar:  make            (o:  g++ -O2 -std=c++17 -pthread emp_acq_capture.cpp uplink_capture_regs.cpp)
// 2026-11-16, revision Claude (handoff). Reemplaza emp_acq_coherente.cpp (ver _superseded_gemini/).
// =============================================================================
#include <atomic>
#include <chrono>
#include <cinttypes>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <map>
#include <memory>
#include <string>
#include <thread>
#include <vector>

#include "fw_sim.hpp"
#include "snapshot_checks.hpp"
#include "uplink_capture_regs.hpp"

using namespace uc;

static std::atomic<bool> g_run{true};
static void onSignal(int) { g_run = false; }

struct Opts {
    std::string uio;            // "" = buscar por direccion 0xA0180000
    std::string out;            // "" = nombre automatico, "-" = stdout
    double seconds = 0;         // 0 = hasta Ctrl-C
    unsigned poll_us = 1000;    // periodo de sondeo de STATUS (capturas cada 10 ms)
    bool check = false;
    double check_seconds = 10;
    bool simulate = false;
    bool skip_magic_gate = false; // solo si el Tcl aviso que magic_value ya estaba conectado
};

static void usage(const char* p) {
    std::fprintf(stderr,
        "uso: %s [--uio /dev/uioN] [--out archivo.csv|-] [--seconds S] [--poll-us US]\n"
        "        [--check [--check-seconds S]] [--simulate] [--skip-magic-gate]\n"
        "  --skip-magic-gate: usar SOLO si magic (0x00) no lleva BUILD_ID (log del Tcl); identifica por 0x70.\n"
        "                     Con el bitstream viejo cargado, leer 0x70 da SLVERR (SIGBUS o SError).\n"
        "  sin --uio busca el UIO cuyo map0 empieza en 0x%" PRIX64 "\n", p, BASE_ADDR);
}

static bool parse(int argc, char** argv, Opts& o) {
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        auto val = [&](const char* f) -> const char* {
            if (i + 1 >= argc) { std::fprintf(stderr, "falta valor para %s\n", f); std::exit(2); }
            return argv[++i];
        };
        if (a == "--uio") o.uio = val("--uio");
        else if (a == "--out") o.out = val("--out");
        else if (a == "--seconds") o.seconds = std::atof(val("--seconds"));
        else if (a == "--poll-us") o.poll_us = unsigned(std::atoi(val("--poll-us")));
        else if (a == "--check") o.check = true;
        else if (a == "--check-seconds") o.check_seconds = std::atof(val("--check-seconds"));
        else if (a == "--simulate") o.simulate = true;
        else if (a == "--skip-magic-gate") o.skip_magic_gate = true;
        else if (a == "-h" || a == "--help") { usage(argv[0]); std::exit(0); }
        else { std::fprintf(stderr, "opcion desconocida: %s\n", a.c_str()); usage(argv[0]); return false; }
    }
    return true;
}

// -------- bucle de sondeo comun a --check y al logger --------
struct PollStats {
    uint64_t attempts = 0, accepted = 0, first_try = 0, failed = 0, missed = 0;
};

// Llama a 'emit(snap, gap)' una vez por cada SEQ nuevo leido de forma coherente.
template <class Emit>
static void pollLoop(const UplinkCaptureRegs& r, const Opts& o, double seconds, PollStats& ps, Emit emit) {
    const auto t0 = std::chrono::steady_clock::now();
    bool have_last = false;
    uint32_t last_seq = 0;
    while (g_run) {
        if (seconds > 0 && std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count() >= seconds) break;
        const uint32_t st = r.rd(OFF_STATUS);
        // SEQ = 0 sin fila previa = todavia no hubo ninguna captura desde la carga (registros en 0): no se registra.
        // (Tras la vuelta del contador, ~46,6 h, SEQ = 0 si se registra porque ya hay fila previa.)
        const bool pre_first_capture = !have_last && st_seq(st) == 0;
        if (!pre_first_capture && !st_busy(st) && (!have_last || st_seq(st) != last_seq)) {
            Snapshot s;
            ++ps.attempts;
            if (r.readCoherent(s, 8)) {
                const uint32_t seq = st_seq(s.status);
                if ((have_last || seq != 0) && (!have_last || seq != last_seq)) {
                    const uint32_t gap = have_last ? seq_diff(seq, last_seq) : 0;  // 0 = primera fila
                    if (gap > 1) ps.missed += gap - 1;
                    have_last = true;
                    last_seq = seq;
                    ++ps.accepted;
                    if (s.tries == 1) ++ps.first_try;
                    emit(s, gap);
                }
            } else {
                ++ps.failed;
            }
        }
        std::this_thread::sleep_for(std::chrono::microseconds(o.poll_us));
    }
}

// Identifica el bitstream. Normal: lee solo 0x00. Con --skip-magic-gate: lee 0x70 (peligroso en el viejo).
static bool identify(const UplinkCaptureRegs& r, const Opts& o, uint32_t& val) {
    if (o.skip_magic_gate) {
        std::fprintf(stderr, "AVISO: --skip-magic-gate, leyendo 0x70 sin verificar 0x00\n");
        val = r.rd(OFF_VERSION);
        return val == BUILD_ID_EXPECTED;
    }
    return r.isNewFirmware(&val);
}

// -------- modo --check: criterios de aceptacion de HANDOFF_uplink_capture.md --------
static int runCheck(const UplinkCaptureRegs& r, const Opts& o) {
    int fails = 0;
    auto res = [&](const char* id, bool ok, const std::string& msg) {
        std::printf("%-3s %-4s %s\n", id, ok ? "PASS" : "FAIL", msg.c_str());
        if (!ok) ++fails;
    };
    char buf[512];

    // C0: el UIO apunta a 0xA0180000 y mapea >= 0x74 bytes (=> device tree sin cambios)
    std::snprintf(buf, sizeof buf, "%s map0 addr=0x%" PRIX64 " size=0x%zX (esperado 0xA0180000, >=0x74)",
                  r.device().c_str(), r.mapAddr(), r.mapSize());
    res("C0", r.mapAddr() == BASE_ADDR && r.mapSize() >= MAP_END, buf);

    // C1: magic (0x00) = BUILD_ID. Unico registro seguro en el bitstream viejo.
    uint32_t magic = 0;
    const bool c1 = identify(r, o, magic);
    std::snprintf(buf, sizeof buf, "%s = 0x%08X (esperado 0x%08X)", o.skip_magic_gate ? "0x70 version (--skip-magic-gate)" : "0x00 magic",
                  magic, BUILD_ID_EXPECTED);
    res("C1", c1, buf);
    if (!c1) {
        std::printf("    -> bitstream viejo (o magic sin conectar): NO se leen 0x30..0x70 (darian SLVERR). Fin.\n");
        return 1;
    }
    // C2: version (0x70)
    const uint32_t ver = r.rd(OFF_VERSION);
    std::snprintf(buf, sizeof buf, "0x70 version = 0x%08X", ver);
    res("C2", ver == BUILD_ID_EXPECTED, buf);

    // Recolectar snapshots durante check_seconds
    std::vector<Snapshot> snaps;
    snaps.reserve(size_t(o.check_seconds * 120) + 16);
    PollStats ps;
    const uint32_t st0 = r.rd(OFF_STATUS);
    const auto t0 = std::chrono::steady_clock::now();
    pollLoop(r, o, o.check_seconds, ps, [&](const Snapshot& s, uint32_t) { snaps.push_back(s); });
    const uint32_t st1 = r.rd(OFF_STATUS);
    const double dt = std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();

    // C3: ritmo de SEQ = 40 MHz / PERIOD(400000) = 100 Hz (±0,5 %)
    const double rate = seq_diff(st_seq(st1), st_seq(st0)) / dt;
    std::snprintf(buf, sizeof buf, "SEQ: %.3f capturas/s en %.1f s (esperado 100 ±0,5) -> clk40 medido ≈ %.4f MHz; STATUS[7:3]=%u",
                  rate, dt, rate * 400000 / 1e6, st_reserved(st1));
    res("C3", rate > 99.5 && rate < 100.5 && st_reserved(st1) == 0, buf);

    // C4: uplink_ready en A y B en todos los snapshots
    size_t rdy_ok = 0;
    for (auto& s : snaps) rdy_ok += (st_rdya(s.status) && st_rdyb(s.status));
    std::snprintf(buf, sizeof buf, "STATUS[1:0]=11 en %zu/%zu snapshots (si el log del Tcl dice 'tied to 1', este criterio no informa el enlace)",
                  rdy_ok, snaps.size());
    res("C4", !snaps.empty() && rdy_ok == snaps.size(), buf);

    // C5: lectura coherente: ninguna falla tras 8 intentos y >= 99 % a la primera
    std::snprintf(buf, sizeof buf, "readCoherent: %" PRIu64 " aceptados, %" PRIu64 " a la primera, %" PRIu64 " fallidos",
                  ps.accepted, ps.first_try, ps.failed);
    res("C5", ps.accepted > 0 && ps.failed == 0 && ps.first_try * 100 >= ps.accepted * 99, buf);

    // C6: consistencia interna (snapshot_checks.hpp::checkInternal) en el 100 %
    size_t bad = 0; unsigned first_bad = 0;
    for (auto& s : snaps) if (unsigned b = checkInternal(s)) { if (!bad) first_bad = b; ++bad; }
    std::snprintf(buf, sizeof buf, "d_g[7:0]=a_g[7:0], d_g[15:8]=b_g[7:0], a7/b7[31:6]=0: %zu/%zu malos (mask 0x%X)",
                  bad, snaps.size(), first_bad);
    res("C6", !snaps.empty() && bad == 0, buf);

    // C7 (informativo): capturas perdidas por el software con poll de poll_us
    std::snprintf(buf, sizeof buf, "capturas perdidas (seq_gap>1): %" PRIu64 " con --poll-us %u (informativo)", ps.missed, o.poll_us);
    std::printf("C7  INFO %s\n", buf);

    // Diagnostico del enlace (no es criterio del firmware): canal 0 de cada grupo
    std::printf("DIAG canal 0 por grupo (d_g = frames N..N+3, byte0 = N):\n");
    for (unsigned g = 0; g < 7; ++g) {
        size_t p2 = 0, p1 = 0;
        std::map<uint32_t, size_t> hist;
        for (auto& s : snaps) { p2 += diagPeriod2(s.d[g]); p1 += diagPeriod1(s.d[g]); ++hist[s.d[g]]; }
        uint32_t top = 0; size_t topn = 0;
        for (auto& kv : hist) if (kv.second > topn) { top = kv.first; topn = kv.second; }
        std::printf("  g%u: periodo2 %zu/%zu, periodo1 %zu/%zu, valor mas comun 0x%08X (%zu veces), bytes N,N+1 con bits invertidos: 0x%02X 0x%02X\n",
                    g, p2, snaps.size(), p1, snaps.size(), top, topn,
                    bitrev8(uint8_t(top & 0xFF)), bitrev8(uint8_t((top >> 8) & 0xFF)));
    }
    std::printf("RESULTADO: %s (%d criterio(s) fallido(s))\n", fails ? "FAIL" : "PASS", fails);
    return fails ? 1 : 0;
}

// -------- modo logger --------
static int runLog(const UplinkCaptureRegs& r, const Opts& o) {
    uint32_t magic = 0;
    if (!identify(r, o, magic)) {
        std::fprintf(stderr, "identificacion = 0x%08X != 0x%08X: bitstream viejo; no leo 0x30..0x70 (SLVERR). Abortando.\n",
                     magic, BUILD_ID_EXPECTED);
        return 1;
    }
    std::string path = o.out;
    if (path.empty()) {
        char name[64]; std::time_t t = std::time(nullptr); std::tm tmv{}; localtime_r(&t, &tmv);
        std::strftime(name, sizeof name, "uplink_capture_%Y%m%d_%H%M%S.csv", &tmv);
        path = name;
    }
    FILE* f = (path == "-") ? stdout : std::fopen(path.c_str(), "w");
    if (!f) { std::perror(path.c_str()); return 1; }
    static char iobuf[1 << 20];
    std::setvbuf(f, iobuf, _IOFBF, sizeof iobuf);

    std::fprintf(f, "# emp_acq_capture (uplink_capture rev BUILD_ID 0x%08X) dev=%s map0=0x%" PRIX64 " poll_us=%u\n",
                 r.rd(OFF_VERSION), r.device().c_str(), r.mapAddr(), o.poll_us);
    std::fprintf(f, "# columnas: ver cabecera de software/emp_acq_capture.cpp; registros en vivado/tgc_readUplink_regs_pkg.vhd rev 28\n");
    std::fprintf(f, "t_unix_ns,seq,seq_gap,tries,status,rdy_a,rdy_b");
    for (int k = 0; k < 8; ++k) std::fprintf(f, ",a%d", k);
    for (int k = 0; k < 8; ++k) std::fprintf(f, ",b%d", k);
    for (int g = 0; g < 7; ++g) std::fprintf(f, ",d%d", g);
    std::fprintf(f, "\n");

    PollStats ps;
    uint64_t rows = 0, bad = 0;
    auto last_flush = std::chrono::steady_clock::now();
    pollLoop(r, o, o.seconds, ps, [&](const Snapshot& s, uint32_t gap) {
        std::fprintf(f, "%" PRIu64 ",%u,%u,%u,0x%08X,%d,%d", s.t_unix_ns, st_seq(s.status), gap, s.tries,
                     s.status, int(st_rdya(s.status)), int(st_rdyb(s.status)));
        for (int k = 0; k < 8; ++k) std::fprintf(f, ",0x%08X", s.a[k]);
        for (int k = 0; k < 8; ++k) std::fprintf(f, ",0x%08X", s.b[k]);
        for (int g = 0; g < 7; ++g) std::fprintf(f, ",0x%08X", s.d[g]);
        std::fprintf(f, "\n");
        ++rows;
        if (checkInternal(s)) ++bad;
        auto now = std::chrono::steady_clock::now();
        if (now - last_flush > std::chrono::seconds(1)) { std::fflush(f); last_flush = now; }
    });
    std::fflush(f);
    if (f != stdout) std::fclose(f);
    std::fprintf(stderr, "filas=%" PRIu64 " perdidas(seq_gap-1)=%" PRIu64 " fallidas=%" PRIu64
                 " a_la_primera=%" PRIu64 " inconsistentes(C6)=%" PRIu64 " -> %s\n",
                 rows, ps.missed, ps.failed, ps.first_try, bad, path.c_str());
    return 0;
}

int main(int argc, char** argv) {
    Opts o;
    if (!parse(argc, argv, o)) return 2;
    std::signal(SIGINT, onSignal);
    std::signal(SIGTERM, onSignal);
    try {
        // orden de declaracion = orden inverso de destruccion: regs, luego sim (para el hilo), luego fake
        std::vector<uint32_t> fake;
        std::unique_ptr<FirmwareSim> sim;
        std::unique_ptr<UplinkCaptureRegs> regs;
        if (o.simulate) {
            fake.assign(0x4000 / 4, 0);
            sim.reset(new FirmwareSim(fake.data(), 10000));   // 100 Hz como el bitstream real
            sim->start();
            regs.reset(new UplinkCaptureRegs(fake.data(), fake.size() * 4));
        } else {
            std::string dev = o.uio.empty() ? UplinkCaptureRegs::findUioByAddr(BASE_ADDR) : o.uio;
            if (dev.empty()) {
                std::fprintf(stderr, "no encontre ningun /sys/class/uio/uio*/maps/map0/addr = 0x%" PRIX64 "\n", BASE_ADDR);
                return 1;
            }
            regs.reset(new UplinkCaptureRegs(dev));
        }
        const int rc = o.check ? runCheck(*regs, o) : runLog(*regs, o);
        if (sim) sim->stop();
        return rc;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "error: %s\n", e.what());
        return 1;
    }
}
