# Registro de fuentes y cobertura

Baseline GitHub: `c02a33b645dc70fb4076add25b78c5246589676e`. Consulta del 24-10-2026. [Repositorio](https://github.com/fbientrigo/atlas_emc).

## Procedencia y límites

El archivo ZIP adjunto se analizó desde la copia local suministrada. El respaldo completo `.tar.gz` no estaba entre los archivos materializados en esta sesión. El paquete indica su procedencia; no equivale a inspección forense del disco completo. Se verificó SHA-256 de los 77 elementos contra el MANIFEST del ZIP: 77 coincidencias. No se han ejecutado binarios ni scripts del respaldo.

Los gitingest adjuntos sirven para comparación estática. No contienen un commit/fecha de extracción identificados. Las comparaciones focales de `libuio/base.c`, `mem.c`, `LpGbtUioBackend.cpp` y `lpGbtRegister.cpp` no muestran diferencias de código, solo líneas vacías finales. Esto no demuestra igualdad de repos completos o binarios.

| Archivo de entrada | SHA-256 |
|---|---|
| `Trenz_EMP_lpGBT_Work_P0_curado.zip` | `41ad3aefcf684279639665983fb8644dbdf112e8aadf694d115c279de5f17f33` |
| `01-libuio_gitingest.txt` | `fe77fac9b5f2d387222d9581409d02e4d0607f18a0b1a83b82d5dfabf09fc6d6` |
| `02-lpgbtsw_gitingest.txt` | `0b593e9c3b1cdce3159f9a531f5f7057b45cff27a7fa1eebaaefbb4fff679640` |

## Extractos navegables

Los extractos de `evidencias.json` conservan números de línea del archivo completo y su hash; son cortes documentales, no fuentes de build. No incluyen historiales completos, credenciales, SSH ni logs personales. Los archivos originales no se han modificado.

| ID | Tema | Ruta original |
|---|---|---|
| B01 | CLI de payload | `read_all_lpgbt/tgc_readuplink_cli.cpp` |
| B02 | Getters de payload | `read_all_lpgbt/TgcReadUplink.cpp` |
| B03 | Acceso MMIO volatile | `libuio/mem.c` |
| B04 | Lookup y mmap UIO | `libuio/base.c` |
| B05 | Tabla del monitor | `emp-tools/empTools/fwStatus/fwStatus.cpp` |
| B06 | Control IC activo | `LpGbtSw/LpGbtUioBackend/LpGbtUioBackend.cpp` |
| B07 | Offsets del controlador IC | `LpGbtSw/include/LpGbtUioBackend/AxiRegisterDefinitions.h` |
| B08 | Ayuda y acciones ReadPRBS | `puzzled_working/readprbs_cli.cpp` |
| B09 | Máscara corregida ReadPRBS | `puzzled_working/ReadPRBS.cpp` |
| R01 | Ruta de UserData y CDC | `epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd` |
| R02 | Core uplink: cabecera y campos | `epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/lpgbt-fpga/lpgbtfpga_uplink.vhd` |
| R03 | Conexiones de estado | `epos-firmware/empfw_debughub/src/empfw_debughub.vhd` |
| R04 | Plantilla de máscaras | `puzzledWizards/templates/airhdl_to_cppbody.jinja` |
| R05 | Variante antigua de un grupo | `puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp` |
| R06 | CDC de recepción | `epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/cdc_user/cdc_rx.vhd` |

## Archivos GitHub consultados

Inventario selectivo guiado por el índice del ZIP; se leyeron las notas P0 completas y se hicieron inspecciones focales de código RTL/software. Consultar el mapa para los rangos concretos utilizados. Listar un archivo aquí no certifica revisión exhaustiva de todas sus líneas.

| Archivo | Git blob SHA |
|---|---|
| [ChargeMonitoringSystem_obsidian/20_Documents/AXI4-Lite communication between PL and PS.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/20_Documents/AXI4-Lite%20communication%20between%20PL%20and%20PS.md) | `903d94f64ac1c318348e8013142d8679a99bc84d` |
| [ChargeMonitoringSystem_obsidian/20_Documents/Elink_communication_between_CMB_and_EMCI.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/20_Documents/Elink_communication_between_CMB_and_EMCI.md) | `0d1a370a6a22747271e68491043b766f035745fc` |
| [ChargeMonitoringSystem_obsidian/20_Documents/Interaction_with_lpgbt.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/20_Documents/Interaction_with_lpgbt.md) | `d3cc905d038513548e2e7736f51714cb0e3fb1a2` |
| [ChargeMonitoringSystem_obsidian/20_Documents/Technical_Design_Report_TGC_ChaMS.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/20_Documents/Technical_Design_Report_TGC_ChaMS.md) | `d391f64f63b8c0ed1b7ddc65cf88fc08a8f51b2a` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0905-encendidoEMP.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0905-encendidoEMP.md) | `28b6297c3aa012ac0e7fd751c780be57a61d5549` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0915c-Mapa de conexion.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0915c-Mapa%20de%20conexion.md) | `2617e99366e6d08783070842635f2f84829c77b9` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0916-mapa MGT.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0916-mapa%20MGT.md) | `17fd1a1f15e871b008c6ecbdb451fe73ab15e2d8` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0918-AXI Addressing.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0918-AXI%20Addressing.md) | `5732aa50b9b2101fd95f893c778e1e0f3899c6d9` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0923-Testing Master branch firmware.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0923-Testing%20Master%20branch%20firmware.md) | `5f79bac439cbaaf77c78f2888bf4b2ec047ec9ce` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0924-getting data out.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0924-getting%20data%20out.md) | `3199f85ea61adc058fc1848267c9976ea78d85c4` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0929-PRBS Signal para lpgbt.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0929-PRBS%20Signal%20para%20lpgbt.md) | `2dbe091ba4dd494cf6e354031dcf4085396cc61c` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0930-LibUIO Implementation.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0930-LibUIO%20Implementation.md) | `9b9ed5187f07efc25482bf6ae36f616bb2209fdb` |
| [ChargeMonitoringSystem_obsidian/30_Notes/0930-version 0.2v emp_firmware.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0930-version%200.2v%20emp_firmware.md) | `4e27ea72f8dd4b96b82328d37986c91b5d5e03f4` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1001-creando un uio.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1001-creando%20un%20uio.md) | `0999d057c100ccebe0362ef9adf16dd0ce2cf79f` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1002-Codigo de recepción.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1002-Codigo%20de%20recepci%C3%B3n.md) | `a9157aa7486b689b2b3d03ebc1228d30bdc2c50e` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1006-Tenemos lectura.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1006-Tenemos%20lectura.md) | `7daf4b9899c0b80cd0e78d7612c090f9ee162086` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1006-UnderstandSignal_UplinkReady.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1006-UnderstandSignal_UplinkReady.md) | `284599a0b9a8c25f29f1b8aa8e7996c02a9685e1` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1007-multipleLPGBT.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1007-multipleLPGBT.md) | `dc9f13e93593fe96979549e7ddecccbb921c387c` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1010-elink.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1010-elink.md) | `fe1e0a825369120a0cfb514546864a13a5a11633` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1013-GettingData elinks.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1013-GettingData%20elinks.md) | `e848d18aa435d9a21f5cdf4288322bcdc84bb4eb` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1021-Loopback real.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1021-Loopback%20real.md) | `f51ae8f3f0506913c3ad2de2d7e66de98ccd2271` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1024-lpgbt outs official repo.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1024-lpgbt%20outs%20official%20repo.md) | `a75937ffd84c274268d28e3471f6660549dd182e` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1028-1031-Testing.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1028-1031-Testing.md) | `4aa7da5f207dbebff1d533c10257216ea0bfb35a` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1028-Pruebas de envio de constante.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1028-Pruebas%20de%20envio%20de%20constante.md) | `a57728c9375155d6bbcd8243f323665a522bc8be` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1209-Conectar y configurar ssh para EMP en U vs CERN.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1209-Conectar%20y%20configurar%20ssh%20para%20EMP%20en%20U%20vs%20CERN.md) | `ee956757bda0fd29d5cc7554b5e458f84b7438f0` |
| [ChargeMonitoringSystem_obsidian/30_Notes/1210-Rehaciendo Setup en la Serena.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1210-Rehaciendo%20Setup%20en%20la%20Serena.md) | `58451b700c1f793d19b61d8fa3dd996f263afd32` |
| [ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/Memory Directions.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/Memory%20Directions.md) | `b8ffd544fe92167d7ebf3573b530920d6ac4b1fa` |
| [ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/reading1006_basic_configs.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/reading1006_basic_configs.md) | `cdc216ce85ca16772e9604e88720cf15cdd44bc1` |
| [atlas_epos/etools/loadFirmare.sh](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/atlas_epos/etools/loadFirmare.sh) | `3039ce922839c34320697afa9ea35471e15abe5f` |
| [epos-firmware/README.md](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/README.md) | `c9520cf058bbd63c1f0a798dddc69bc0461a5814` |
| [epos-firmware/eLink_Interface_v1/src/eLink_Interface.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/eLink_Interface_v1/src/eLink_Interface.vhd) | `6b041eef88498ca85a07a00dd9a9351cd283e55c` |
| [epos-firmware/emp-firmware-2023.2/emp-firmware-2023.2.srcs/sources_1/bd/emp_fw_TE0807/emp_fw_TE0807.bd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp-firmware-2023.2/emp-firmware-2023.2.srcs/sources_1/bd/emp_fw_TE0807/emp_fw_TE0807.bd) | `13374bbe40ddcd9729420ac0122e15c2bd5e6387` |
| [epos-firmware/emp_generic_mgt/src/transceivers.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_generic_mgt/src/transceivers.vhd) | `cceb0b3239616fbe404e8b82693d145cc9503bf2` |
| [epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/cdc_user/cdc_rx.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/cdc_user/cdc_rx.vhd) | `8ba91bb2f29c484221a2c77a96746af039791e22` |
| [epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/lpgbt-fpga/kcu105/hdl/lpgbtfpga_10g24.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/lpgbt-fpga/kcu105/hdl/lpgbtfpga_10g24.vhd) | `ac37e21feaa999b27a8dd1fbe172939064d865c1` |
| [epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/lpgbt-fpga/lpgbtfpga_uplink.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/lpgbt-fpga/lpgbtfpga_uplink.vhd) | `12fbdb788d7416eef937f5368bf1f88e94cb2a82` |
| [epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd) | `8e7b217fd08ffcae387890dd50338fa439c699af` |
| [epos-firmware/empfw_debughub/src/empfw_debughub.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/empfw_debughub/src/empfw_debughub.vhd) | `2cae54e636cf1f036cd0d7f6a16d3c2d3307747b` |
| [epos-firmware/empfw_debughub/src/fw_monitor_regs.vhd](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/empfw_debughub/src/fw_monitor_regs.vhd) | `484263116cf9701deeead0854feb29ca1fef956e` |
| [puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp) | `dfbf311227a9f4dd05e023d5143f828063269390` |
| [puzzledWizards/templates/airhdl_to_cppbody.jinja](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/templates/airhdl_to_cppbody.jinja) | `d0713c971669e2f7882626c477caf3b2d9ce11c5` |
| [puzzledWizards/tgc_readUplink_regs.json](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/tgc_readUplink_regs.json) | `5ecd98d3a76abad98fee1af69d40c7d1d4eaeb0c` |

## Respaldo: integridad del material seleccionado

La lista siguiente registra integridad y cobertura disponible; no implica análisis exhaustivo de todos los archivos. Las referencias F1–F12 de la guía identifican los puntos inspeccionados que respaldan el procedimiento.

| Ruta original relativa | Líneas | SHA-256 |
|---|---|---|
| `read_all_lpgbt/Readme.md` | 2 | `d2c208fd54a084ab67e679fbb3b6ad968dd069c42c6e973125caf17414446c07` |
| `read_all_lpgbt/tgc_readuplink_cli.cpp` | 64 | `03cb6c414059ab55e2fcdcb162faed1287d00c8afd0b5cac434acf1836c098d3` |
| `read_all_lpgbt/TgcReadUplink.cpp` | 312 | `0bbd3f71777adcaa7b7400dd2fca5987e1faebc1088509cf3a45a28d341db7dd` |
| `read_all_lpgbt/TgcReadUplink.hpp` | 74 | `2462b9a08f73efa302bb9666f4ad8f612541c0d7da2471f3e8e9e836701a4df8` |
| `libuio/CMakeLists.txt` | 21 | `e036f106b87817e0781d73563e0a92d9bbe9f8a5280efb5d2282f2a4cdb5d8b1` |
| `libuio/libuio.h` | 102 | `d749c3df33d93c877675a5a554d44caa6ffa1d6f1b9180650107ee57626a04ac` |
| `libuio/libuio_internal.h` | 65 | `54c9c93360fb6c998f40c9e16a0733e3bf5b7f2fe2ef5e094330f4f317a4d527` |
| `libuio/base.c` | 457 | `1d0bd3d6b57d6b8a7679d7955ebe1c324af9c2a5f94219ece97101a4569fadd3` |
| `libuio/helper.c` | 321 | `195be567a2a5626983a624d3e9e1a18763615aa07f75d351f3189fce885815db` |
| `libuio/mem.c` | 339 | `8389dcd2dbf901b128acfaa7dd88bffc6151b45d5ce1bcb23623b3497c73099c` |
| `libuio/irq.c` | 118 | `7fd1da139db63e4658ce622145962ea6ca016ebcd50ea3c7797bbc2cd64c4ef7` |
| `libuio/attr.c` | 251 | `dfc41c0762a84b64c5ae4bf4786d0258ba6e64aef99298e13e3cfb359ae8988a` |
| `libuio/lsuio.c` | 194 | `a676034c9809cc42235c1ba467a876a899f6cd55e88a192d581965b31333f74b` |
| `libuio/readuio.c` | 101 | `0fafe942a21bd449e55e4f2e927eb429696c4a0139c6a9597f1bebb5a700d27e` |
| `LpGbtSw/README.md` | 22 | `7011df0c3015eae99961a4a05801bf090c269c0948cb5fbf58bc91b46cbeaa33` |
| `LpGbtSw/CMakeLists.txt` | 56 | `a40d38f9f7fc35dfdfcfa421d3986ba92b8a32b3d7d61ec65441a4b7744d5731` |
| `LpGbtSw/build.sh` | 8 | `c274253a75e15c2c4909ba957a0155983221e285bbe064b32083890801c460d0` |
| `LpGbtSw/Demonstrators/CMakeLists.txt` | 26 | `64aa0442d7b8d9bb56047d35e351c344063a2b06f413f05ca54dff8b061d9c61` |
| `LpGbtSw/Demonstrators/include/DemonstratorsCommon.h` | 31 | `54ce37b92d17574b18687e95467392203051364028b34a7f27c45a638877aad0` |
| `LpGbtSw/Demonstrators/LpGbtRegister/lpGbtRegister.cpp` | 129 | `90444908a0653def9d39d6164e6edf0a0309f94814e2ea33c2c6222518cd17fc` |
| `LpGbtSw/Demonstrators/LpGbtRegister/CMakeLists.txt` | 9 | `7495efd2fc33c20856a748e572884a65b883072486801e68a87893432f5129af` |
| `LpGbtSw/Demonstrators/LpGbtConfiguration/lpGbtConfiguration.cpp` | 215 | `f3e7c8c8ebb27e96565df32fe254ce4bb4d8f71149625dcb633d630f3f3c8179` |
| `LpGbtSw/Demonstrators/LpGbtConfiguration/CMakeLists.txt` | 9 | `9234ce916b11583ec8caa3bd95849a56a4d6351419448e21f42c0700b8ad87b0` |
| `LpGbtSw/Demonstrators/LpGbtGpio/lpGbtGpio.cpp` | 155 | `b981f8bfdb644745ad5e5e5e4229e51bf8237d06fe032759364a89c318b25c28` |
| `LpGbtSw/Demonstrators/LpGbtAdc/lpGbtAdc.cpp` | 107 | `d8c5cdba849d504639f98132e59eb937ee6888441e46b761adfeb3f733562e70` |
| `LpGbtSw/LpGbtRegisterClerkFactory/RegisterClerkFactory.cpp` | 60 | `de97c52b231af3cfa9f78c7c26314f919b8a4260f87c2d113c06b98d7c347a03` |
| `LpGbtSw/LpGbtUioBackend/LpGbtUioBackend.cpp` | 90 | `d416be9f64a29ae2e71dc1f340d4b8d7b5c65cf209cebfc3ac67407286ef70de` |
| `LpGbtSw/LpGbtUioBackend/LpGbtUioBackendCommon.cpp` | 51 | `5084383f9e2bfbef69f04b1ac5ce33f8a4d503a4cfe228221f0ae994c2705738` |
| `LpGbtSw/LpGbtUioBackend/LpGbtUioFunctions.cpp` | 249 | `f0bf5c9fe02e632ac8eb020e6b94cb2ded039075e30c8d0edf92477750eac330` |
| `LpGbtSw/LpGbt/LpGbt.cpp` | 34 | `f62db688e5b5a7303098ba2aec661b123040727d1dc6cb6149b9d780ed85b346` |
| `LpGbtSw/LpGbt/Adc.cpp` | 204 | `0f582cb0332f7932279488f9fe084e8eed293f3fe48e20980997954b890ccb63` |
| `LpGbtSw/LpGbt/Gpio.cpp` | 279 | `b526858eecb54fb3313ac4e449d6aafd33d3176e82fbab4966ade416266a9534` |
| `LpGbtSw/include/LpGbt/LpGbt.h` | 41 | `7a7bffa171d403e8861634718fbede60532e0a34e0e340396ac2129f5f7f18cd` |
| `LpGbtSw/include/LpGbt/LpGbtDefinitions.h` | 36 | `b9de354e1c6af16bcb0c80a3f15ec5ed577c684aa1cd2efd9139272361d7c3d4` |
| `LpGbtSw/include/LpGbt/LpGbtRegisterMap.h` | 17 | `9bbfd8aa2bf783da2b09f5af4f6aeb02b5a89bc4a78502299d42a23ed4d0c5f7` |
| `LpGbtSw/include/LpGbt/Adc.h` | 96 | `a281bb51ff8647ef2539f05370d29b5d9374296c66d365e2722cf677d93602bc` |
| `LpGbtSw/include/LpGbt/Gpio.h` | 127 | `a783acab0510b12cbfec648f4d3c009f5148595d24ba7cbdfda24b2ae145538d` |
| `LpGbtSw/include/LpGbtUioBackend/AxiRegisterDefinitions.h` | 25 | `2eebdfa8608aa066fdb52b2e380534fa5feb35c05d6396ff748f6ea1367e391e` |
| `LpGbtSw/include/LpGbtUioBackend/LpGbtUioFunctions.h` | 36 | `ca00eb64e993f33634084e3cc53c56a82e740e5c67db2cb1a870c6f5361be184` |
| `LpGbtSw/include/LpGbtUioBackend/LpGbtUioBackend.h` | 34 | `1b7e39569a3aca5981a18df9e9e72d748dccde369821cb247eeeae0e0d598418` |
| `LpGbtSw/include/LpGbtUioBackend/LpGbtUioBackendCommon.h` | 25 | `8d0ba3379d69f5fa0d495162b895d595aaa62651084d433072eb7ab001a9cebb` |
| `LpGbtSw/include/LpGbtRegisterClerkInterface/RegisterClerkInterface.h` | 34 | `6dd3ce433dc96decefe4c615a6cb631c56ad9a7ede0515e5ef2050ba28ba423f` |
| `LpGbtSw/include/LpGbtRegisterClerkFactory/RegisterClerkFactory.h` | 21 | `88ede0bdaf861adf4badf3dfe7b8d197bd8190096959e87a56e167819e43e197` |
| `LpGbtSw/include/Common/LpGbtExceptions.h` | 30 | `b447a25e7e03aed1ab5b6803b96f24751ddb43af8be2997c3316099239af8a99` |
| `LpGbtSw/include/LpGbt/LpgbtRegisterMapV1.h` | 2056 | `e72b33d2151d8b33c8a7f85fbf44a3bc97ba258e3b39d7a76642ad621ba4200a` |
| `epos/etools/loadFirmare.sh` | 115 | `fde084a0594290929d34957d75d1b12e6e366d914f7e7e27dc489af16633cd2e` |
| `epos/etools/README.md` | 36 | `49fd301cb08031595af73d7712e4c713d804f03d13e7984b9045fb3bbb829ba7` |
| `emp-tools/empTools/fwStatus/fwStatus.cpp` | 117 | `8cca295f177e0d9ada056f2c2932e5c16770e578fa51291df37d56bdfe71c3ea` |
| `emp-tools/empTools/fwStatus/CMakeLists.txt` | 6 | `ae9b764a5b99546c5f413ae29d7500030fad8ecb3a51f8d7f9b5787da6cb3008` |
| `emp-tools/empTools/include/commonTools.hpp` | 24 | `b5fb6f5d96d3ae4ac419ac3aebe15f9494f985c1e8079bff64f16efb1199d7dc` |
| `emp-tools/empTools/CMakeLists.txt` | 25 | `310353057553498682757484a0f34d4aeca8e37c0f2f633beb9444747b8fb1d2` |
| `emp-tools/include/fwMonitor/fwMonitor.hpp` | 27 | `9d51f2a6a848d4795d86512b08f946f12753d1c9c762b731e5b37ac820997e8d` |
| `emp-tools/src/fwMonitor/fwMonitor.cpp` | 48 | `e318e2e2cf29cea1c19de38f73ee0609e4737981b00958849e3dd50c06ced69e` |
| `emp-tools/include/axiBackend/axiRegisterMap.hpp` | 70 | `d888841934032a5eaf72c1199a1ac9b5442c7fc334f05449da70cfb259fc6fa0` |
| `emp-tools/include/axiBackend/uioFunctions.hpp` | 22 | `a48a49366bbea100abb8e3a9eb24da724e81e21135f1c9bdc2c4dd69b363a400` |
| `emp-tools/src/axiBackend/uioFunctions.cpp` | 179 | `3f0c676526a2fb66e4c275336141dfe233840eea8092036f9fcd6ce7eac19acf` |
| `emp-tools/pyMonitor/empMonitor.py` | 115 | `6707d3d7fceece86555cd340c6ca644e5f2408efd9af35fd673764188507ffdc` |
| `puzzled_working/ReadPRBS.cpp` | 159 | `8b9c20426548a898c43e03e5324f39b36710fdc81356dd73c465e5b79e613022` |
| `puzzled_working/ReadPRBS.hpp` | 43 | `26bd6d4389ef2617bfcca85310a54ed7d6e2076dc480206824f6527ecfea7b4c` |
| `puzzled_working/Read_PRBS.c` | 99 | `4e056687719c407e9985d5d28ec521c16e8b9a4e67b64349f114705f3cf5da47` |
| `puzzled_working/Read_PRBS.h` | 37 | `c9e7f3ee49adaf07729b2dc6fb87594b28a0942fd28246fc7839382534897a76` |
| `puzzled_working/readprbs_cli.cpp` | 313 | `04c46f8beedb36853c173f1ed21d0391f20779c9dd40f060674a20d2d5c6f071` |
| `puzzled_working/readprbs_cli_minimal.cpp` | 33 | `cc5dc8be70245e3f65d16f93acd6fbbf9a2cf802252011e16cd3f4a26bdf80e0` |
| `puzzled_working/Makefile` | 103 | `0c6b60759a0ca7a0ce5449887e067b9a4c1b5fd647142ed4d912e75883cf250f` |
| `puzzled_writePRBS/patch_bits.py` | 48 | `d659f0b265515b2e0b196afb5397931351ad1f2f27f5fe14944e701b0eded0bd` |
| `puzzled_writePRBS/ReadPRBS.cpp` | 163 | `dde56661c1d60cc9517811edcc0ffba92bcade126b882928c57fe50d727102fa` |
| `puzzled_writePRBS/readprbs_cli.cpp` | 313 | `04c46f8beedb36853c173f1ed21d0391f20779c9dd40f060674a20d2d5c6f071` |
| `test_uio/test_open.c` | 20 | `010fc55685498da7d12dbf1aca9cd4d58e36432a59c5ea0f4ebe1c2db07c0513` |
| `test_uio/uio_peek.c` | 11 | `6b29a774c8f4cc2c4ceb4049d14c5aa5ab32d030a7639fa29284a8559727f6e2` |
| `test_uio/readuio.c` | 36 | `baf8c1d0e9af62983db7bc14455df33f75f276711d3d3a16508bad370bb53f41` |
| `read_lpgbt10.sh` | 18 | `3391f10d4207e9145db60b6d0c5d5d7c3d21e7ef57b422e3db9ad5177772e201` |
| `watch_devmem.sh` | 26 | `2221914dfe1d1c16e087ca59375901c6c674f1308b2f373276543fe8dfbbaeb7` |
| `sweep_clock.sh` | 56 | `007bc726e48fa0a6d1a0b8aa0aa91f628a857d9081f33ad7c7e115ea82f21dcc` |
| `test_saturation.sh` | 65 | `241ed6fae270ebb6edd3ca06725e42150c015268aa5df382908fe6dd35b5f315` |
| `1024/send_and_read.sh` | 54 | `a46cce2af26b058ea45a8a9fbdb004ac850c320a232978a1af0317be8d575c5f` |
| `1024/typical_out/0xAAAAAAAA.txt` | 12 | `005eb9eb14e2aca5f778d515d3bbbc3352effbc25146396aa87568da3c582632` |
| `clk_sweep_results.log` | 64 | `556a5dec3a502227004549c40b03739fdba61666a91bd16c53e5f6937c07ba5e` |

## Búsquedas negativas y sus límites

- Árbol completo del baseline: 2526 entradas, respuesta no truncada. Se usó para localizar rutas, no para leer todo su contenido.
- No hay `AGENTS.md` en ese árbol.
- No se encontraron fuentes `.vhd/.v/.sv` con nombre `tgc_readUplink`, `Read_PRBS` o variantes del nombre en el árbol; el BD tampoco contiene esas instancias. No se excluye una implementación con otro nombre, en otro repositorio, dentro de artefactos binarios o fuera del backup curado.
- El BD sí contiene una asignación explícita A00D/A00E a interrupt controllers. La incompatibilidad con scripts históricos no es solo una ausencia de archivos.
- Las fichas TDR/Interaction/Elink consultadas enlazan PDFs y están vacías; los PDFs no se leyeron en esta entrega.
- Las imágenes citadas por las notas no se interpretaron como prueba de conexión actual. Los estados posteriores de hardware y otras ramas no se han auditado exhaustivamente.

## Ampliación del 24-10-2026: bloqueo intermitente

La edición ampliada contiene 28 extractos identificados, incluyendo R07–R15 y B10–B13. Sus rutas, rangos y SHA-256 están en `evidencias.json`. Se inspeccionaron además `ic_top.vhd`, `ic_rx.vhd`, `ic_rx_fifo.vhd` y el package del controlador IC en el mismo baseline c02a33b. Los hashes corresponden a los archivos locales inspeccionados; los enlaces remotos están fijados al commit. La observación del usuario sobre recuperación temporal tras reiniciar es testimonio histórico recibido el 24-10-2026, no una prueba actual.

La documentación oficial de Linux UIO, /proc y GNU timeout respalda únicamente conceptos de sistema operativo; no acredita el firmware. Enlaces en el documento 10. No se inspeccionó hardware real ni se compiló/simuló el diseño completo.
