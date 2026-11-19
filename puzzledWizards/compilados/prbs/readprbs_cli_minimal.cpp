// readprbs_cli.cpp
// CLI de pruebas para ReadPRBS (UIO): lee/escribe registros clave y repite en bucle si se solicita.

#include <iostream>
#include <string>
#include <vector>
#include <cstdint>
#include <cstdlib>
#include <chrono>
#include <thread>
#include <stdexcept>
#include <iomanip>
#include "ReadPRBS.hpp"

int main(int argc, char** argv) {

   ReadPRBS dev("Read_PRBS_regs");
   uint32_t magic_value = dev.readMagicValue();

   std::cout << "magic number: ";
   std::cout << std::hex << magic_value << std::endl;
   uint32_t data_value = dev.readDataPrbsValue();
   std::cout << "data value before write: ";
   std::cout << std::hex << data_value << std::endl;

   uint32_t to_write = 0xaaaaeeee;
   dev.writeDataPrbsValue(to_write);

   uint32_t data_value2 = dev.readDataPrbsValue();
   std::cout << "data value after write: ";
   std::cout << std::hex << data_value2 << std::endl;

}
