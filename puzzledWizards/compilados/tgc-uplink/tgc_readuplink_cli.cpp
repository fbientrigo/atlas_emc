// tgc_readuplink_cli.cpp
// CLI simple de prueba para TgcReadUplink (UIO): lee registros clave.

#include <iostream>
#include <iomanip>
#include <array>
#include <cstdint>
#include <stdexcept>
#include "TgcReadUplink.hpp"

static inline void print_hex32(const char* label, uint32_t v) {
  std::cout << std::setw(16) << label
              << "0x" << std::uppercase << std::hex
              << std::setw(8) << std::setfill('0') << v
              << std::dec << std::setfill(' ') << '\n';
}

int main() {
    try {
        // Abrir por nombre de dispositivo UIO
        TgcReadUplink dev("tgc_readUplink_regs");

        // Lecturas básicas
        uint32_t magic = dev.readMagicValue();
        print_hex32("magic:", magic);

        // data_group_0 .. data_group_8 usando punteros a método
        using ReadFn = uint32_t (TgcReadUplink::*)();
        const std::array<ReadFn, 9> groupFns = {
            &TgcReadUplink::readDataGroup0Value,
            &TgcReadUplink::readDataGroup1Value,
            &TgcReadUplink::readDataGroup2Value,
            &TgcReadUplink::readDataGroup3Value,
            &TgcReadUplink::readDataGroup4Value,
            &TgcReadUplink::readDataGroup5Value,
            &TgcReadUplink::readDataGroup6Value,
            &TgcReadUplink::readDataGroup7Value,
            &TgcReadUplink::readDataGroup8Value
        };

        for (size_t i = 0; i < groupFns.size(); ++i) {
            uint32_t val = (dev.*groupFns[i])();
            std::string label = "data_group_" + std::to_string(i) + ":";
            print_hex32(label.c_str(), val);
        }

        // data_header
        uint32_t header = dev.readDataHeaderValue();
        print_hex32("data_header:", header);

        // clk_thresh
        uint32_t clk = dev.readClkThreshValue();
        print_hex32("clk_thresh:", clk);

	std::cout << clk << std::endl;
        // Nota: si luego quieres escribir clk_thresh:
        // dev.writeClkThreshValue(0x000000AB);

        return 0;
    } catch (const std::exception& e) {
        std::cerr << "[ERROR] " << e.what() << '\n';
        return 1;
    }
}
