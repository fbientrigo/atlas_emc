// =============================================================================
// uplink_capture_regs.cpp  — ver uplink_capture_regs.hpp
// 2026-11-16, revision Claude (handoff).
// =============================================================================
#include "uplink_capture_regs.hpp"

#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <dirent.h>
#include <fcntl.h>
#include <stdexcept>
#include <sys/mman.h>
#include <unistd.h>

namespace uc {

// lee un numero (hex "0x..." o decimal) desde un archivo de sysfs; false si no existe
static bool readSysfsU64(const std::string& path, uint64_t& v) {
    FILE* f = std::fopen(path.c_str(), "r");
    if (!f) return false;
    char buf[64] = {};
    bool ok = std::fgets(buf, sizeof buf, f) != nullptr;
    std::fclose(f);
    if (!ok) return false;
    v = std::strtoull(buf, nullptr, 0);
    return true;
}

static uint64_t nowUnixNs() {
    timespec ts{};
    clock_gettime(CLOCK_REALTIME, &ts);
    return uint64_t(ts.tv_sec) * 1000000000ULL + uint64_t(ts.tv_nsec);
}

std::string UplinkCaptureRegs::findUioByAddr(uint64_t addr) {
    DIR* d = opendir("/sys/class/uio");
    if (!d) return "";
    std::string found;
    while (dirent* e = readdir(d)) {
        if (std::strncmp(e->d_name, "uio", 3) != 0) continue;
        uint64_t a = 0;
        if (readSysfsU64(std::string("/sys/class/uio/") + e->d_name + "/maps/map0/addr", a) && a == addr) {
            found = std::string("/dev/") + e->d_name;
            break;
        }
    }
    closedir(d);
    return found;
}

UplinkCaptureRegs::UplinkCaptureRegs(const std::string& uioDev) : dev_(uioDev) {
    // /dev/uioN -> /sys/class/uio/uioN/maps/map0/{addr,size,offset}
    const std::string name = uioDev.substr(uioDev.find_last_of('/') + 1);
    const std::string sys = "/sys/class/uio/" + name + "/maps/map0/";
    uint64_t size = 0, offset = 0;
    if (!readSysfsU64(sys + "addr", map_addr_) || !readSysfsU64(sys + "size", size))
        throw std::runtime_error("no puedo leer " + sys + "{addr,size}");
    readSysfsU64(sys + "offset", offset);  // offset dentro de la pagina (0 si la base esta alineada)
    if (size < MAP_END)
        throw std::runtime_error(uioDev + ": map0 mide " + std::to_string(size) + " bytes, se necesitan >= 0x74");

    fd_ = ::open(uioDev.c_str(), O_RDWR | O_SYNC);
    if (fd_ < 0) throw std::runtime_error("open(" + uioDev + "): " + std::strerror(errno));
    // en UIO, el mapa N se pide con offset N*pagesize; map0 -> 0
    mmap_len_ = size_t(size + offset);
    mmap_ptr_ = ::mmap(nullptr, mmap_len_, PROT_READ | PROT_WRITE, MAP_SHARED, fd_, 0);
    if (mmap_ptr_ == MAP_FAILED) {
        int err = errno;
        ::close(fd_); fd_ = -1; mmap_ptr_ = nullptr;
        throw std::runtime_error("mmap(" + uioDev + "): " + std::strerror(err));
    }
    base_ = reinterpret_cast<volatile uint32_t*>(static_cast<char*>(mmap_ptr_) + offset);
    map_size_ = size_t(size);
}

UplinkCaptureRegs::UplinkCaptureRegs(volatile uint32_t* base, size_t bytes)
    : base_(base), map_size_(bytes), map_addr_(BASE_ADDR), dev_("(memoria de prueba)") {
    if (bytes < MAP_END) throw std::runtime_error("memoria de prueba < 0x74 bytes");
}

UplinkCaptureRegs::~UplinkCaptureRegs() {
    if (mmap_ptr_) ::munmap(mmap_ptr_, mmap_len_);
    if (fd_ >= 0) ::close(fd_);
}

uint32_t UplinkCaptureRegs::rd(uint32_t off) const {
    if (off >= MAP_END || (off & 3u))
        throw std::out_of_range("offset fuera del mapa 0x00..0x70 (SLVERR en hardware)");
    // volatile: el compilador no reordena ni elimina lecturas. En el A53 la memoria del UIO es
    // Device-nGnRE: los accesos al mismo periferico salen en orden de programa.
    return base_[off >> 2];
}

bool UplinkCaptureRegs::isNewFirmware(uint32_t* magic_out) const {
    const uint32_t m = rd(OFF_MAGIC);  // 0x00 responde OKAY en ambos bitstreams
    if (magic_out) *magic_out = m;
    return m == BUILD_ID_EXPECTED;
}

bool UplinkCaptureRegs::readCoherent(Snapshot& out, unsigned max_tries) const {
    for (unsigned t = 1; t <= max_tries; ++t) {
        const uint32_t s1 = rd(OFF_STATUS);
        if (st_busy(s1)) continue;                       // captura en curso (BUSY=1 durante 4 periodos de 25 ns = 100 ns)
        for (unsigned k = 0; k < 8; ++k) out.a[k] = rd(OFF_A0 + 4 * k);
        for (unsigned k = 0; k < 8; ++k) out.b[k] = rd(OFF_B0 + 4 * k);
        for (unsigned g = 0; g < 7; ++g) out.d[g] = rd(OFF_D0 + 4 * g);
        const uint32_t s2 = rd(OFF_STATUS);
        // uplink_capture.vhd garantiza: A/B/diag solo cambian con BUSY=1, y SEQ cambia con BUSY=1
        // antes y despues del flanco. Si s1 y s2 tienen BUSY=0 y el mismo SEQ, no hubo captura entre medio.
        if (!st_busy(s2) && st_seq(s1) == st_seq(s2)) {
            out.status = s2;
            out.tries = t;
            out.t_unix_ns = nowUnixNs();
            return true;
        }
    }
    return false;
}

}  // namespace uc
