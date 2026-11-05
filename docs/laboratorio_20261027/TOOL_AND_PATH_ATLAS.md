# Atlas de herramientas, rutas y evidencia

[Inicio](START_HERE.md) · [Arquitectura](SYSTEM_MAP.md) · [Auditoría](AUDIT_AND_UNCERTAINTIES.md)

## Convención de ubicaciones

- **B/**: raíz al extraer `trenz-tgc-backup-20261023.tar.gz`. Es un respaldo histórico, no `$HOME` de la placa actual.
- **R/**: raíz de `atlas_emc`, main consultado `3379d3e12c9b4d1fd99019678bc8023e594455a8`.
- **D/**: ruta absoluta esperada **en el dispositivo**, pendiente de localizar. No se presume que exista.
- **XSA!miembro / BSP!miembro**: archivo dentro de un contenedor; no carpeta Linux instalada.

Esta entrega contiene análisis, no los binarios del respaldo. Las fuentes B se consultan en el TAR original. Los enlaces R son relativos a este repositorio.

## Elegir la herramienta

Compatibilidad actual de **todas** las herramientas hardware: **DESCONOCIDA** hasta inventariar la instalación. La columna final precisa su contrato histórico.

| Herramienta / clase | Path exacto y origen | Función; entrada → salida | Dependencias | Compatibilidad y evidencia |
|---|---|---|---|---|
| `TgcReadUplink` | B/read_all_lpgbt/TgcReadUplink.cpp; `.hpp` | Nombre o número UIO → getters de registros; también setter de threshold | C++, libuio | Mapa TGC de nueve grupos; B02 |
| `tgc_readuplink_cli` | B/read_all_lpgbt/tgc_readuplink_cli; fuente `.cpp` | Sin argumentos → doce etiquetas hex y threshold decimal | ELF AArch64; libuio y runtime C++ | Nombre fijo `tgc_readUplink_regs`; B01. Prioridad de lectura si coincide el mapa |
| Variante de un grupo | [R/puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp](../../puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp) | Un `data_groups` con lectura/escritura | C++, libuio | **No** sustituye al lector B; R05 |
| `ReadPRBS` | B/puzzled_working/ReadPRBS.cpp; B/puzzled_writePRBS/ReadPRBS.cpp | magic/status/data y escritura de control/data | C++, libuio | Mismo mapa 0,4,8,12; máscaras implementadas de forma diferente; B04 |
| `readprbs_cli` | B/puzzled_working/readprbs_cli; B/puzzled_writePRBS/readprbs_cli | Nombre/número, acción → lectura o estímulo interno | ELF AArch64; wrapper estático según Makefile, libuio dinámica | Dos ELF diferentes; fuentes CLI idénticas. `--selftest` solo lee, no valida valores; B04 |
| `fwMonitor` | B/EMPToolsArtifacts/bin_TRENZ/fwMonitor; también `bin_EMP` y B/clk_files/EMPToolsArtifacts/bin_{TRENZ,EMP}/fwMonitor | `--id N` → tabla de estados | Boost program_options 1.75, libuio, C++ | Cuatro hashes distintos. Fuente B/emp-tools/empTools/fwStatus/fwStatus.cpp; B05 |
| `clkProgrammer` | B/EMPToolsArtifacts/bin_TRENZ/clkProgrammer; otras tres ubicaciones paralelas | `-i`: estados I2C; `-c`: programa Si5345 | Boost 1.75, libuio por enlace, driver I2C y bus correcto | TRENZ usa i2c-13, EMP i2c-1 en fuente; confirmar enumeración. Riesgo de página en lectura; B06 |
| `libuio` | B/libuio/{base.c,mem.c,irq.c,libuio.h,libuio.so} | Sysfs/UIO → mmap y cargas/escrituras MMIO | libc y GLib en fuente/build | Offset en bytes, map0 para lectores; `uio_read32` no comprueba límites; B03 |
| `readuio` | B/test_uio/readuio; fuente B/test_uio/readuio.c | `NOMBRE OFFSET...` → palabras hex | libuio | Selección explícita, sin límites/alineación. Alternativa solo con mapa validado; B08 |
| Otra fuente `readuio` | B/libuio/readuio.c | Igual sintaxis → salida decimal `%d` | libuio/GLib | No asumir mismo formato ni mismo binario que B/test_uio/readuio |
| `uio_peek`, `test_open` | B/test_uio/uio_peek.c; B/test_uio/test_open.c y ELF homónimos | Lectura de offset cero | POSIX mmap / libuio | Fijan uio4/uio0. No recomendados para la sesión |
| `lsuio` | B/libuio/lsuio; fuente `lsuio.c` | Enumeración; `-a` abre/mapea | libuio | Defecto de `free` en fuente; preferir sysfs; B03 |
| `lpGbtRegister` | B/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister | URI backend y registro chip → byte o escritura | Boost program_options/system/filesystem 1.75, libuio, C++ | Control IC, no payload; backend también simulado; B07 |
| `lpGbtConfiguration` | B/LpGbtSw/build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration | Lectura masiva o archivo `.cnf` → configuración chip | Familia LpGbtSw | Incluso leer provoca transacciones IC activas; no inventariar ejecutándolo |
| `lpGbtAdc`, `lpGbtGpio` | B/LpGbtSw/build/Demonstrators/LpGbtAdc/lpGbtAdc; B/LpGbtSw/build/Demonstrators/LpGbtGpio/lpGbtGpio | Funciones del ADC/GPIO del chip | Familia LpGbtSw | Administración/periféricos del chip; no captura FE |
| `registerTranslator` | B/LpGbtSw/build/Demonstrators/RegisterTranslator/registerTranslator | Traducción de registros | Familia LpGbtSw | No acredita comunicación física; fuente en Demonstrators/RegisterTranslator |
| Lectura `devmem` | B/read_lpgbt10.sh; B/watch_devmem.sh | Dirección física → palabras/byte bajo | Bash, BusyBox, permisos /dev/mem | Bases fijas, bucles; detalles B10. No inventario pasivo |
| Estímulos `devmem` | B/test_saturation.sh; B/sweep_clock.sh; B/1024/send_and_read.sh | Patrón/threshold → escrituras y lecturas | Bash, BusyBox | **Acciones con efectos**, sin contrato de build actual; B10 |
| Diagnóstico y comparación | [R/docs/recuperacion/diagnostico/atlas_diagnostico.py](../recuperacion/diagnostico/atlas_diagnostico.py); [R/docs/recuperacion/web/logica.js](../recuperacion/web/logica.js) | Inventario, plan, captura supervisada, informe / dos salidas TGC → XOR | Python estándar / navegador | Perfil de nueve grupos; no decodifica FE. Pruebas locales, no hardware; R08 |
| Cargador | B/epos/etools/loadFirmare.sh; [R/atlas_epos/etools/loadFirmare.sh](../../atlas_epos/etools/loadFirmare.sh) | Nombre DTBO → sustituye overlay | Bash/configfs/FPGA manager | Se escribe `loadFirmare`, no `loadFirmware`; B09. Listar no es cargar |
| Firmware | B/epos/hw-description/ y B/epos/epos-bsp/ | XSA/BSP → descripción hardware y configuración de build | Vivado/PetaLinux para regenerar; ZIP/TAR para inspeccionar | Familias X01–X04; no identifican por sí solas la carga actual |
| Overlays de lectura | [R/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/out_lpgbt_10_cd/pl.dtsi](../../atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/out_lpgbt_10_cd/pl.dtsi), variantes `dd` y `direct` | DTBO + bit.bin → descripción/carga candidata | Kernel/configfs compatibles | R06; presentes en repo, ausentes del TAR; RTL del TGC aún falta |

## Localización sin ejecutar hardware

En el **PC de análisis**, fijar `RESPALDO` y `REPO` a las raíces reales. Son lecturas pasivas de archivos:

```bash
: "${RESPALDO:?Ruta de extracción del TAR}"
: "${REPO:?Ruta local de atlas_emc}"
rg --files "$RESPALDO" "$REPO" | rg 'TgcReadUplink|readprbs_cli|fwStatus|si5345|readuio|pl\.dtsi|\.xsa$'
rg -n 'uio_read32|uio_write32|readDataGroup|readRegister' \
  "$RESPALDO/read_all_lpgbt" "$RESPALDO/LpGbtSw/LpGbtUioBackend"
```

En el **dispositivo**, sin asumir el directorio de extracción:

```bash
# LECTURA PASIVA: localización; no invoca los candidatos.
for t in tgc_readuplink_cli readprbs_cli readuio fwMonitor clkProgrammer lpGbtRegister; do
  command -v "$t" || true
done
find "$HOME" /usr/bin /usr/local/bin /opt -xdev -type f \
  \( -name tgc_readuplink_cli -o -name readprbs_cli -o -name readuio \
  -o -name fwMonitor -o -name clkProgrammer -o -name lpGbtRegister \) -print 2>busqueda.err
```

`find` es alternativa portable cuando no hay `rg`. Preservar `busqueda.err`: permisos insuficientes no prueban ausencia.

| Ruta D esperada | Qué buscar; límite |
|---|---|
| `/sys/class/uio/uio*/name` y `maps/map*/{addr,size,offset}` | Nombre → nodo/mapa actuales; no garantiza respuesta AXI |
| `/dev/uioN` | Nodo de acceso; no abrir durante inventario |
| `/proc/device-tree`, `/sys/firmware/devicetree/base` | Árbol efectivo; analizar celdas/reg/ranges según ancestros |
| `/lib/firmware` | Archivos disponibles; no significa cargados |
| `/configfs/device-tree/overlays`, `/sys/kernel/config/device-tree/overlays` | Estado de overlays si el sistema lo expone; no montar ni modificar para inventariar |
| `/sys/class/fpga_manager` | Estado reportado; `operating` no identifica bytes del bitstream |
| `/usr/bin/clkProgrammer` | Ruta del servicio histórico; comprobar existencia/hash |
| `/etc/systemd/system`, `/usr/lib/systemd/system` | Unidad de arranque que podría programar reloj; usar `systemctl cat`, nunca iniciar/reiniciar como prueba pasiva |
| `/boot` | Archivos de arranque que existan realmente; el TAR no es una imagen íntegra de SD |

## Fuentes primarias para abrir

### B01

B/read_all_lpgbt/tgc_readuplink_cli.cpp:18–64. `main()`, nombre fijo, nueve getters, header/threshold, último decimal. ELF homónimo: SHA-256 `91c0de21b8cf6975129563411773b0c3fa437c3b0a96e398e5a1fea04ab7cb66`; Build ID `6e958bba99359edfac698be3ca539ac91f4c0529`. Símbolos presentes para todos los getters, sin prueba de build reproducible.

### B02

B/read_all_lpgbt/TgcReadUplink.cpp:25–37,45–292,297–311. Apertura, mapa y máscaras. SHA-256 `0bbd3f71777adcaa7b7400dd2fca5987e1faebc1088509cf3a45a28d341db7dd`.

### B03

B/libuio/base.c:246–271 y 344–388; `mem.c:209–221`; `irq.c`; `lsuio.c:77–169`. Lookup por primer nombre coincidente, mmap RW y carga volatile; no usar números de UIO históricos. No hay chequeo de límites en `uio_read32`.

### B04

B/puzzled_working/readprbs_cli.cpp:198–201,264–286; B/puzzled_working/ReadPRBS.cpp:45–158; B/puzzled_writePRBS/ReadPRBS.cpp:142–162; B/puzzled_working/Makefile. Fuentes CLI completas idénticas por bytes. ELF working SHA-256 `ed8a1c1018759b1d5cd4542e12fe35f6fa4883727992272204a821cf04242184`; writePRBS `faf03bc3359550cf5a9c479b6fe76d7edb19d042e5e648a58573f2451b0c6f27`.

El selftest lee magic/status y cinco veces data, e imprime OK sin comprobar resultados. Las escrituras se ejecutan por flags separados. `--json` produce líneas JSON precedidas por el mensaje del constructor; no es un documento JSON único limpio.

### B05

B/emp-tools/empTools/fwStatus/fwStatus.cpp:84–115; B/emp-tools/src/fwMonitor/fwMonitor.cpp:35–45; B/emp-tools/src/axiBackend/uioFunctions.cpp:17–40,93–176; B/emp-tools/include/axiBackend/axiRegisterMap.hpp:38–68. `fwMonitor` viene de `fwStatus.cpp`. Estados en +0x08/+0x0C/+0x10; no lee un ID de build.

### B06

B/emp-tools/empTools/si5345_i2c/main_si5345.cpp:21–24,50–84; B/emp-tools/src/i2cDevices/si5345.cpp:9–59; B/emp-tools/src/i2cBackend/i2c.cpp:73–88; B/emp-tools/include/Si5345/si5345-revD.h:41–48. `-i` consulta I2C, no es inventario de archivos ni MMIO pasivo. `readRegister` descarta el byte de página sin seleccionarla; `writeRegister` sí selecciona. El postámbulo acaba en página 0x0B. Un error atrapado puede acabar con retorno 0 en `main`; revisar logs.

B/emp-tools/systemd_service/systemd-programclock.service: `ExecStart=/usr/bin/clkProgrammer -c`. **INFERIDO:** un reboot podría alterar reloj mediante esa unidad; solo si está instalada/activa. No se ha demostrado que explique el fallo.

### B07

B/LpGbtSw/Demonstrators/LpGbtRegister/lpGbtRegister.cpp; B/LpGbtSw/LpGbtUioBackend/LpGbtUioBackend.cpp:16–63; B/LpGbtSw/LpGbtUioBackend/LpGbtUioFunctions.cpp:99–126,172–230; B/LpGbtSw/include/LpGbtUioBackend/AxiRegisterDefinitions.h:7–23; B/LpGbtSw/include/LpGbt/{LpgbtRegisterMapV0.h,LpgbtRegisterMapV1.h}.

La build conservada tiene `HAVE_UIO=ON`, `USE_LPGBT_V0=OFF` en B/LpGbtSw/build/CMakeCache.txt:243,281; `flags.make` y `link.txt` aportan receta parcial. No son prueba criptográfica de procedencia del ELF. `TrigoLpGbt` aparece en el gitingest adjunto, **no** en los Demonstrators del TAR: no confundirlo con herramienta instalada.

### B08

B/test_uio/readuio.c:6–35; B/libuio/readuio.c:50–100; B/test_uio/uio_peek.c:6–10; B/test_uio/test_open.c:5–19. Variantes de acceso; no añadir una segunda lectura de diagnóstico si la primera está atascada.

### B09

B/epos/etools/loadFirmare.sh:19–63,79–115; B/epos/epos-rootfs/README.md. La raíz contiene recetas de rootfs y módulos, no una imagen del sistema actual. El cargador retira el overlay previo antes de crear el nuevo; no hay rollback automático. Opciones largas anunciadas no funcionan por el `getopts` previo.

### B10

B/read_lpgbt10.sh:4–17; B/watch_devmem.sh:7–25; B/sweep_clock.sh:28–44; B/test_saturation.sh:20–55; B/1024/send_and_read.sh:21–49. Omisiones de +0x18, máscara de byte bajo, espera sin límite, errores ocultos y escrituras históricas. Las capturas están en B/1024/{out,typical_out}/ y B/data_0x00000090, B/data_0x00000090_1280, B/data_0x000000aa; no incluyen identidad suficiente para validar FE.

### R01

[R/epos-firmware/emp-firmware-2023.2/emp-firmware-2023.2.srcs/sources_1/bd/emp_fw_TE0807/emp_fw_TE0807.bd](../../epos-firmware/emp-firmware-2023.2/emp-firmware-2023.2.srcs/sources_1/bd/emp_fw_TE0807/emp_fw_TE0807.bd). Claves `design.design_info`, `components`, `nets`, `addressing`. No asumir que representa los XSA del respaldo.

### R02

[Core lpgbtfpga_uplink.vhd](../../epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/lpgbt-fpga/lpgbtfpga_uplink.vhd):263–325,404–524. Alineación y recuperación del protocolo.

### R03

[Wrapper emp_lpgbt.vhd](../../epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd):420–498,573–610,731–768; [cdc_rx.vhd](../../epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/imports/cdc_user/cdc_rx.vhd):130–218; [debughub](../../epos-firmware/empfw_debughub/src/empfw_debughub.vhd):212–246. Es software/RTL recuperado; la síntesis activa no está identificada.

### R04

[JSON TGC de nueve grupos](../../puzzledWizards/tgc_readUplink_regs.json):12–251; revisión 27. Nombres, offsets y descripciones; no reemplaza al RTL de captura.

### R05

[Clase TGC de un grupo](../../puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp):64–139; [plantilla de máscaras](../../puzzledWizards/templates/airhdl_to_cppbody.jinja):110–121. El desplazamiento `1 << bitWidth` no es válido para width=32 en un int de 32 bits; las copias B están parcheadas para sus campos 32/0.

### R06

R/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/out_lpgbt_10_{cd,dd,direct}/: cada carpeta contiene `pl.dtsi`, `.dtbo` y `.bit.bin` homónimos. [cd/pl.dtsi](../../atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/out_lpgbt_10_cd/pl.dtsi):11,29–35,173–179; mismos nodos de interés en dd/direct. Se inspeccionó la declaración textual y se verificaron propiedades correspondientes en los DTBO; esto no acredita la lógica del bitstream.

### R07

[Ensayos 1028–1031](../../ChargeMonitoringSystem_obsidian/30_Notes/1028-1031-Testing.md), [1006: loopback](../../ChargeMonitoringSystem_obsidian/30_Notes/1006-Tenemos%20lectura.md), [mapa posterior](../../ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/Memory%20Directions.md). Notas históricas, no resultados de esta sesión ni una única configuración.

### R08

[Supervisor](../recuperacion/diagnostico/atlas_diagnostico.py), [pruebas](../recuperacion/diagnostico/test_atlas_diagnostico.py), [documentación](../recuperacion/12_SCRIPT_DIAGNOSTICO.md). `inventario` no abre MMIO; `capturar` sí lanza el lector autorizado. El timeout no es un watchdog AXI.

### R09

[eLink_Interface.vhd](../../epos-firmware/eLink_Interface_v1/src/eLink_Interface.vhd):236–368. Siete grupos, captura disparada por envío, flags de lectura consumibles, reset sin asignación explícita de FSM. Es una implementación alternativa; **no se ha identificado con** `elink_memory_interface` del HWH ni con TGC.

### X01

B/epos/hw-description/trenz-xV23-03-00-00/hw_desc.xsa!emp_fw_TE0807.hwh:4,4567–4568,4701–4708,12085. Sistema XCZU4EG, `elink_memory_interfa_0` en A00D0000–A00D3FFF, UserData de pipeline 11 y reloj `clk_wiz_0_clk_out1`. VLNV `user.org:user:elink_memory_interface:1.0`, revisión de core 2.

Mismo XSA por hash dentro de B/epos/epos-bsp/trenz-xV23-03-00-00/epos_trenz.bsp!new_trenz_bsp/project-spec/hw-description/system.xsa. En ese BSP: `new_trenz_bsp/components/plnx_workspace/device-tree/device-tree/pl.dtsi:29–34` declara la interfaz como `xlnx,elink-memory-interface-1.0`, no `generic-uio`. La configuración histórica de kernel/arranque debe cotejarse con `/proc/cmdline`, nunca aplicarse automáticamente.

### X02

B/epos/hw-description/emp-xV23-01-00-00/hw_desc.xsa!emp_fw_TE0807.hwh:4,4567–4568,4701–4708,12086. También 13 IC y e-link en A00D0000. Su copia está en B/epos/epos-bsp/emp-xV23-03-00-00/epos_emp.bsp; la nomenclatura BSP/XSA ya difiere.

### X03

B/epos/hw-description/trenz-02-00-00/trenz_siclk-fw.xsa; B/epos/hw-description/trenz-02-00-01/system.xsa; B/epos/hw-description/emp-01-00-00/emp_fw_v0.11.xsa. Miembro `emp_firmware_TE0807.hwh`: `SYSTEMINFO`, `MODULE elink_memory_interfa_0` y `MEMRANGE`. Doce IC; interfaz en A00C0000. Leer sus puertos: las conexiones de reloj no son idénticas entre versiones.

### X04

B/epos/hw-description/trenz-01-00-00/emp_firmware_TE0807_wrapper.xsa; B/epos/hw-description/enclustra-00-00-00/emp-firmware.xsa; B/epos/hw-description/enclustra-01-00-00/emp-firmware-enclustra-01-00-00.xsa; B/epos/hw-description/enclustra-reference-design/emp_enclustra_rd.xsa. Los dos primeros usan una familia anterior 0x800…; Enclustra 01 contiene interfaz en A00C0000. Son modelos/exportaciones diferentes, no reemplazos directos.

## Dependencias y duplicados: decisiones útiles

Los tres ELF de lectores B01/B04 declaran `libuio.so`, `libstdc++.so.6`, `libm.so.6`, `libgcc_s.so.1` y `libc.so.6`, intérprete `/lib/ld-linux-aarch64.so.1`, sin RPATH observado. Los EMPTools añaden Boost program_options 1.75 y RPATH `$ORIGIN/../lib`; esas carpetas de artefactos **no incluyen** su directorio `lib`. LpGbtRegister añade Boost system/filesystem 1.75. Esto exige resolver dependencias en la placa; no basta copiar el ejecutable.

`read_all_lpgbt` no conserva Makefile/CMake. Los símbolos ELF son compatibles con la clase de nueve grupos, pero falta receta exacta. Los Makefile PRBS conservan bibliotecas C y C++, `.orig`, `~` y objetos: no asumir que el archivo más reciente produjo el ELF. `LpGbtSw/build` sí conserva CMakeCache, objetos y link.txt; es mejor evidencia de build, aunque no una reproducción probada.

Cuatro copias de cada EMPTool tienen hashes distintos. Las cadenas de los ELF `clkProgrammer` son coherentes con i2c-1 en EMP e i2c-13 en TRENZ; cadenas no prueban la rama ejecutada. Las diferencias restantes de contenido no se han atribuido a una revisión fuente concreta. No seleccionar automáticamente `clk_files` por su nombre.

## Inventario completo: alcance

Se enumeraron y extrajeron las 2.653 entradas del TAR, y se calcularon hashes para los 2.048 archivos regulares. Se inspeccionaron además los diez BSP anidados y sus XSA: nueve XSA externos y dos contenidos XSA adicionales distintos dentro de BSP, con 16 miembros HWH en total. No apareció RTL `.vhd`/`.v` del capturador ni módulos TGC/Read_PRBS en esos HWH. No se inspeccionó una SD viva, ni se hizo ingeniería inversa de los bitstreams.

| Familia | Archivos regulares | Clasificación |
|---|---:|---|
| `epos/` | 1575 | Infraestructura, vendor Device Tree, 9 XSA, 10 BSP, rootfs/arranque; predominan fuentes del generador DT, no firmware FE |
| `LpGbtSw/` | 232 | Fuentes, cabeceras, mapas, configuración de ejemplo, build y ELF |
| `libuio/` | 59 | Fuentes, biblioteca y build |
| `emp-tools/` | 48 | Fuentes, configuración Si5345 y unidad systemd; no árbol completo de dependencias |
| `puzzled_working/`, `puzzled_writePRBS/` | 26 + 28 | Wrappers C/C++, CLI, objetos, librerías y versiones antiguas |
| `EMPToolsArtifacts/`, `clk_files/` | 12 + 12 | Ejecutables, variantes EMP/TRENZ |
| `read_all_lpgbt/`, `test_uio/` | 7 + 9 | Lector de nueve grupos y utilidades de prueba |
| `1024/` | 23 | Dos versiones de script, 20 capturas `.txt` y una nota `.md` |
| Archivos en raíz | 17 | Scripts/ediciones, tres series de lectura, barrido, paquetes e historial privado |

El manifiesto completo de trabajo contiene rutas/tamaños/hashes, pero no se publica junto al PR para evitar divulgar metadatos privados innecesarios. Se publican únicamente rutas y resultados técnicos revisados. Los historiales, credenciales potenciales, paquetes y configuraciones de red no se incorporan a esta entrega.

SHA-256 del TAR: `60fd64b63bbcea0c7ddb3791b1095af3882a2d767835f8c6f2a1f42b46cfaf01`. Su nombre fecha el respaldo, no todas las mediciones; las capturas `1024` contienen fechas de 2025.
