Utilizaremos entonces la base del programa PuzzledWizard el cual generá las funciones que aprovechan los offsets de los registros para leer y escribir en estos.

## Arreglos necesarios
Es importante tener en cuenta que PuzzledWizard tiene una consideración importante con datos arriba o igual a 32bits, y es que es necesario hacer un arreglo a la mascara

El firmware quedó con el nombre
- emp_read_1003.dtbo

![[firmware_readup_1003.png]]

Una vez se consigue generar y cargar a firmware correctamente
comenzamos a orquestar con el PuzzledWizard

```powershell
fabi@zephyrus:~/puzzledWizards$ ls
README.md  fix_bits.py  generate.py  output  output_tgc_readuplink_1002  sample  saved_json  templates
fabi@zephyrus:~/puzzledWizards$ mv /mnt/c/Users/Asus/Downloads/tgc_readUplink_regs.json .
fabi@zephyrus:~/puzzledWizards$ ls
README.md  fix_bits.py  generate.py  output  output_tgc_readuplink_1002  sample  saved_json  templates  tgc_readUplink_regs.json
fabi@zephyrus:~/puzzledWizards$ python3 generate.py tgc_readUplink_regs.json
Component name is tgc_readUplink
Will generate c_lib_header
Generating output/tgc_readUplink.h...
Formatted  output/tgc_readUplink.h
Will generate c_lib_body
Generating output/tgc_readUplink.c...
Formatted  output/tgc_readUplink.c
Will generate cpp_lib_header
Generating output/TgcReadUplink.hpp...
Formatted  output/TgcReadUplink.hpp
Will generate cpp_lib_body
Generating output/TgcReadUplink.cpp...
Formatted  output/TgcReadUplink.cpp
Will generate cpp_python
Generating output/TgcReadUplinkPython.cpp...
Formatted  output/TgcReadUplinkPython.cpp
fabi@zephyrus:~/puzzledWizards$ python3 fix_bits.py output/TgcReadUplink.cpp
Patched output/TgcReadUplink.cpp: 1 Read, 1 Write
fabi@zephyrus:~/puzzledWizards$
```

Incorporando el pequeño arreglo con regexp.

Los archivos que necesitaremos son pocos, solo
- cpp
- hpp

```bash
fabi@zephyrus:~/puzzledWizards/output$ scp TgcReadUplink.cpp tgc_cms@trenz-tgc:/home/tgc_cms/puzzled_getData
tgc_cms@trenz-tgc's password:
TgcReadUplink.cpp                                                                                100% 8133     1.3MB/s   00:00
fabi@zephyrus:~/puzzledWizards/output$ scp TgcReadUplink.hpp tgc_cms@trenz-tgc:/home/tgc_cms/puzzled_getData
tgc_cms@trenz-tgc's password:
TgcReadUplink.hpp                                                                                100% 1548   503.4KB/s   00:00
```


### Problematica
Ocurre un detalle que es que Vivado automaticamente me modificó el Base Address que se presenta
0x4_0000_0000, cuando tanto en codigo como en BD aparece como 0xA00E0000

por tanto se modificó lo que aparecé en base address 

entonces se cambio el nombre como
`emp_read_fixed_1003` 

Luego al configurar:
```
# cargo el firmware
sudo epos/etools/loadFirmare.sh emp_read_fixed_1003.dtbo

# modifico el clkthresh para que tenga cada 2 relojes el update del valor
sudo busybox devmem 0xA00E002C 32 0x00000002

```

aqui los distintos valores
![[registerReadingSystem.png]]

es posible leer el grupo 0 con
```
while true; do sudo busybox devmem 0xA00E0004 32; done
```

- Importante: no intentar usar devmem para escribir en registros READ_ONLY, devmem bloqueará el sistema de recibir más comandos.

## Estado
Se consigue efectivamente leer datos aqui dentro
además de que ha sido posible el usar el PiGbt para programar que es lo que se le pasa. Todo esto en el contexto de testing.

Lo que se hace primero es configurar el reloj:
```bash
sudo busybox devmem 0xA00E002C 32 0x00000002
```

Luego configuramos el dato a enviar
```bash
sudo ./puzzled_working/readprbs_cli --by-name Read_PRBS_regs --write-data 0xEECCCC11
```

Entonces para leer los registros
```bash
sudo ./puzzled_getData/tgc_readuplink_cli
```


```
          magic:0x00000000
   data_group_0:0x00000000
   data_group_1:0x00000000
   data_group_2:0xAAAAAAAA
   data_group_3:0xAAAAAAAA
   data_group_4:0xAAAAAAAA
   data_group_5:0xAAAAAAAA
   data_group_6:0xAAAAAAAA
   data_group_7:0x00000003
   data_group_8:0x00000000
    data_header:0x00000000
     clk_thresh:0x00000100
```

Sin embargo no ha sido claro o directo como leer los datos que provienen del downlink, se propone que debe ser algo relacionado con u Loopback.

Para esto se está modificando

Explorando como se mapean los canales
![[LpGbt_uplink_channels.png]]






___

## Codigo fuente
```cpp
// readprbs_cli.cpp
// CLI de pruebas para ReadPRBS (UIO): lee/escribe registros clave, repite en bucle o secuencia desde archivo.
// Uso rápido:
//   ./readprbs_cli --by-name Read_PRBS_regs --selftest
//   ./readprbs_cli --by-name Read_PRBS_regs --write-sequence valores.txt --sleep-ms 500

#include <iostream>
#include <string>
#include <vector>
#include <cstdint>
#include <cstdlib>
#include <chrono>
#include <thread>
#include <stdexcept>
#include <iomanip>
#include <fstream>
#include <sstream>
#include "ReadPRBS.hpp"

struct Options {
    // Selección de dispositivo
    bool useByName = false;
    bool useByNum  = false;
    std::string uioName;
    unsigned uioNum = 0;

    // Acciones
    bool readMagic   = false;
    bool readStatus  = false;
    bool readData    = false;
    bool writeData   = false;
    bool writeCtrl   = false;
    bool writeSeq    = false;
    uint32_t dataVal = 0;
    uint32_t ctrlVal = 0;
    std::string seqFile;

    // Modo self-test
    bool selfTest = false;

    // Repetición
    unsigned repeat = 1;
    unsigned sleepMs = 0;

    // Output
    bool json = false;
    bool verbose = false;
};

static void print_usage(const char* prog) {
    std::cerr <<
R"(readprbs_cli — pruebas de UIO ReadPRBS

Selección de dispositivo (elige una):
  --by-name <UIO_NAME>         Abrir por nombre (e.g., "Read_PRBS")
  --by-num  <UIO_NUM>          Abrir por número de /dev/uio (e.g., 0)

Acciones (puedes combinar varias):
  --read-magic                 Lee registro 'magic' (offset 0)
  --read-status                Lee registro 'status' (offset 8)
  --read-data                  Lee registro 'data_prbs' (offset 12)
  --write-data <VAL>           Escribe 'data_prbs' (uint32)
  --write-control <VAL>        Escribe 'control' (uint32)
  --write-sequence <FILE>      Escribe valores de archivo (uno por línea, hex o decimal)
  --selftest                   Ejecuta prueba integral rápida

Repetición / salida:
  --repeat <N>                 Repite N veces (por defecto 1)
  --sleep-ms <MS>              Espera MS milisegundos entre repeticiones o entre valores de secuencia
  --json                       Salida en JSON (máquina)
  --verbose                    Mensajes adicionales
  --help                       Esta ayuda
)";
}

static bool parse_uint32(const std::string& s, uint32_t& out) {
    try {
        size_t idx=0;
        unsigned long long v = 0;
        if (s.rfind("0x",0)==0 || s.rfind("0X",0)==0) {
            v = std::stoull(s, &idx, 16);
        } else {
            v = std::stoull(s, &idx, 10);
        }
        if (idx != s.size() || v > 0xFFFFFFFFull) return false;
        out = static_cast<uint32_t>(v);
        return true;
    } catch (...) {
        return false;
    }
}

static bool parse_uint(const std::string& s, unsigned& out) {
    try {
        size_t idx=0;
        unsigned long long v = std::stoull(s, &idx, 10);
        if (idx != s.size() || v > 0xFFFFFFFFull) return false;
        out = static_cast<unsigned>(v);
        return true;
    } catch (...) {
        return false;
    }
}

static Options parse_args(int argc, char** argv) {
    Options opt;
    if (argc <= 1) {
        print_usage(argv[0]);
        std::exit(2);
    }
    for (int i=1; i<argc; ++i) {
        std::string a = argv[i];
        auto needVal = [&](const char* flag)->std::string {
            if (i+1 >= argc) {
                std::cerr << "Falta valor para " << flag << "\n";
                print_usage(argv[0]);
                std::exit(2);
            }
            return std::string(argv[++i]);
        };

        if (a == "--help" || a == "-h") {
            print_usage(argv[0]);
            std::exit(0);
        } else if (a == "--by-name") {
            opt.useByName = true;
            opt.uioName = needVal("--by-name");
        } else if (a == "--by-num") {
            opt.useByNum = true;
            std::string v = needVal("--by-num");
            unsigned tmp;
            if (!parse_uint(v, tmp)) {
                std::cerr << "Valor inválido para --by-num: " << v << "\n";
                std::exit(2);
            }
            opt.uioNum = tmp;
        } else if (a == "--read-magic") {
            opt.readMagic = true;
        } else if (a == "--read-status") {
            opt.readStatus = true;
        } else if (a == "--read-data") {
            opt.readData = true;
        } else if (a == "--write-data") {
            opt.writeData = true;
            std::string v = needVal("--write-data");
            uint32_t tmp;
            if (!parse_uint32(v, tmp)) {
                std::cerr << "Valor inválido para --write-data: " << v << "\n";
                std::exit(2);
            }
            opt.dataVal = tmp;
        } else if (a == "--write-control") {
            opt.writeCtrl = true;
            std::string v = needVal("--write-control");
            uint32_t tmp;
            if (!parse_uint32(v, tmp)) {
                std::cerr << "Valor inválido para --write-control: " << v << "\n";
                std::exit(2);
            }
            opt.ctrlVal = tmp;
        } else if (a == "--write-sequence") {
            opt.writeSeq = true;
            opt.seqFile = needVal("--write-sequence");
        } else if (a == "--selftest") {
            opt.selfTest = true;
        } else if (a == "--repeat") {
            std::string v = needVal("--repeat");
            unsigned tmp;
            if (!parse_uint(v, tmp) || tmp == 0) {
                std::cerr << "Valor inválido para --repeat: " << v << "\n";
                std::exit(2);
            }
            opt.repeat = tmp;
        } else if (a == "--sleep-ms") {
            std::string v = needVal("--sleep-ms");
            unsigned tmp;
            if (!parse_uint(v, tmp)) {
                std::cerr << "Valor inválido para --sleep-ms: " << v << "\n";
                std::exit(2);
            }
            opt.sleepMs = tmp;
        } else if (a == "--json") {
            opt.json = true;
        } else if (a == "--verbose") {
            opt.verbose = true;
        } else {
            std::cerr << "Opción desconocida: " << a << "\n";
            print_usage(argv[0]);
            std::exit(2);
        }
    }

    if (!(opt.useByName ^ opt.useByNum)) {
        std::cerr << "Debes especificar exactamente uno: --by-name o --by-num\n";
        std::exit(2);
    }

    // Si no hay acciones, activar self-test por defecto
    if (!(opt.readMagic || opt.readStatus || opt.readData || opt.writeData || opt.writeCtrl || opt.writeSeq || opt.selfTest)) {
        opt.selfTest = true;
    }
    return opt;
}

static int run_actions(ReadPRBS& dev, const Options& opt) {
    auto out_hex32 = [](uint32_t v) {
        std::ostringstream oss;
        oss << "0x" << std::hex << std::setw(8) << std::setfill('0') << v;
        return oss.str();
    };

    auto do_read_magic = [&]() {
        uint32_t v = dev.readMagicValue();
        if (opt.json) std::cout << "{\"magic\":" << v << "}\n";
        else          std::cout << "magic = " << out_hex32(v) << " (" << v << ")\n";
        return 0;
    };

    auto do_read_status = [&]() {
        uint32_t v = dev.readStatusValue();
        if (opt.json) std::cout << "{\"status\":" << v << "}\n";
        else          std::cout << "status = " << out_hex32(v) << " (" << v << ")\n";
        return 0;
    };

    auto do_read_data = [&]() {
        uint32_t v = dev.readDataPrbsValue();
        if (opt.json) std::cout << "{\"data_prbs\":" << v << "}\n";
        else          std::cout << "data_prbs = " << out_hex32(v) << " (" << v << ")\n";
        return 0;
    };

    auto do_write_control = [&]() {
        if (opt.verbose) std::cerr << "Escribiendo control = " << opt.ctrlVal << "\n";
        dev.writeControlValue(opt.ctrlVal);
        return 0;
    };

    auto do_write_data = [&]() {
        if (opt.verbose) std::cerr << "Escribiendo data_prbs = " << opt.dataVal << "\n";
        dev.writeDataPrbsValue(opt.dataVal);
        return 0;
    };

    auto do_write_sequence = [&]() {
        std::ifstream fin(opt.seqFile);
        if (!fin) throw std::runtime_error("No se puede abrir archivo " + opt.seqFile);
        std::string line;
        while (std::getline(fin, line)) {
            if (line.empty()) continue;
            uint32_t val;
            if (!parse_uint32(line, val)) {
                std::cerr << "Línea inválida: " << line << "\n";
                continue;
            }
            if (opt.verbose) std::cerr << "Escribiendo " << out_hex32(val) << "\n";
            dev.writeDataPrbsValue(val);
            if (opt.sleepMs)
                std::this_thread::sleep_for(std::chrono::milliseconds(opt.sleepMs));
        }
        return 0;
    };

    auto do_selftest = [&]() {
        if (!opt.json) std::cout << "[SELFTEST] Inicio\n";
        do_read_magic();
        do_read_status();
        for (int i=0; i<5; ++i) {
            do_read_data();
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        if (!opt.json) std::cout << "[SELFTEST] OK\n";
        return 0;
    };

    for (unsigned r=0; r<opt.repeat; ++r) {
        if (opt.selfTest)           do_selftest();
        if (opt.readMagic)          do_read_magic();
        if (opt.readStatus)         do_read_status();
        if (opt.writeCtrl)          do_write_control();
        if (opt.writeData)          do_write_data();
        if (opt.writeSeq)           do_write_sequence();
        if (opt.readData)           do_read_data();
        if (opt.sleepMs && r+1<opt.repeat)
            std::this_thread::sleep_for(std::chrono::milliseconds(opt.sleepMs));
    }
    return 0;
}

int main(int argc, char** argv) {
    try {
        Options opt = parse_args(argc, argv);

        if (opt.verbose) {
            if (opt.useByName) std::cerr << "Abriendo por nombre: " << opt.uioName << "\n";
            else               std::cerr << "Abriendo por número: " << opt.uioNum << "\n";
        }

        if (opt.useByName) {
            ReadPRBS dev(opt.uioName);
            return run_actions(dev, opt);
        } else {
            ReadPRBS dev(opt.uioNum);
            return run_actions(dev, opt);
        }
    } catch (const std::exception& e) {
        std::cerr << "Fallo: " << e.what() << "\n";
        return 1;
    } catch (...) {
        std::cerr << "Fallo desconocido.\n";
        return 1;
    }
}
```