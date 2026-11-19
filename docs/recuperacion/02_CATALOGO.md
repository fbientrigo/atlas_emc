# Catálogo de las herramientas que ya existen

Para leer y capturar con el montaje de noviembre, usa [emp y raw.sh](15_OPERAR_EMP.md). Para las herramientas anteriores, lee primero [las condiciones y comandos de la guía de campo](00_GUIA_CAMPO.md). Este catálogo describe el código; no dice qué está instalado hoy. Las rutas son las del entorno antiguo, y el ZIP curado no trae ningún ELF.

## Elegir por tarea

| Necesitas | Herramienta | Comprueba antes |
|---|---|---|
| Identificar dispositivos | sysfs; si acaso `lsuio -v` | A1, sin `-a`; el `lsuio` recuperado libera mal la memoria. |
| Ver qué firmware hay disponible | `loadFirmare.sh -l` | Lee antes la copia local y no le pases un nombre de firmware. |
| Diagnosticar el transporte | `fwMonitor --id N` | Que exista `empfw_debughub` y su mapa. |
| Ver los grupos de payload | [`emp read`](15_OPERAR_EMP.md#leer-en-la-trenz) o `tgc_readuplink_cli` | Nombre UIO y mapa confirmados. |
| Leer otro UIO con offsets a mano | `readuio` | Cuál de las dos variantes es; ambas usan `NOMBRE OFFSET...`. |
| Ver la configuración del chip | `lpGbtRegister` o una exportación de PiGBT | Es una operación IC activa; queda fuera del inventario. |
| Generar patrones en la FPGA | `readprbs_cli`, scripts `devmem` | Son pruebas internas que escriben. No sirven para P0. |

## `tgc_readuplink_cli` y `TgcReadUplink`

Fuente: backup `read_all_lpgbt/{tgc_readuplink_cli.cpp,TgcReadUplink.cpp,TgcReadUplink.hpp}`. Otro script menciona `puzzled_getData/tgc_readuplink_cli`, pero nada indica que sean el mismo binario.

- Parámetros: ninguno; `main()` ignora `argv`. `--help`, `--id` o `--by-name` no cambian nada y la lectura se hace igual.
- Bibliotecas: `libuio` y el runtime de C++. Sin el ELF ni la receta de enlace no se sabe la lista exacta, y puede estar enlazado de distintas formas.
- Dispositivo y mapa: nombre fijo `tgc_readUplink_regs`, map0, offsets 0, 4, …, 44. La clase también acepta un número de UIO, pero la CLI no lo usa.
- Qué hace: abre y mapea en lectura y escritura; lee `magic`, los nueve grupos, header y threshold, e imprime el threshold dos veces. Este `main()` no escribe el threshold.
- Salida: valores crudos, sin hora de captura, eventos, formato del FE ni validación del header.
- Errores: no encuentra el nombre, `uio_open failed`, error de runtime o `SIGBUS`. Los últimos no siempre pasan por el `catch(std::exception)`.
- Compatibilidad: los offsets coinciden con el JSON de nueve grupos, revisión 27, pero eso no comprueba ni el RTL ni el bitstream. La clase de `puzzledWizards/output_tgc_readuplink_1002` tiene un solo registro `data_groups` con setter: es otra versión.

Vale la pena reutilizarlo si el periférico coincide. Si solo cambia el nombre, mira primero el `readuio` instalado antes de compilar o adaptar nada.

## `readuio`: dos fuentes con la misma sintaxis

Fuentes backup: `test_uio/readuio.c:6–35` y `libuio/readuio.c:50–100`.

Las dos aceptan `readuio NOMBRE_UIO OFFSET [OFFSET...]`, convierten los offsets con `strtoul(...,0)` y leen palabras de 32 bits en map0, usando `libuio`. La de `libuio` además usa macros e internacionalización del proyecto. La diferencia que importa: `test_uio` imprime en hexadecimal y `libuio` en decimal con `%d`, así que un valor con el bit alto puede salir negativo. Mira cuál es antes de comparar logs.

Ejemplo, con la variante y el nombre ya confirmados, para leer la firma y el grupo 0 de un lector con el mapa de F1:

```bash
: "${READUIO:?Ruta absoluta de la variante identificada}"
: "${UIO_PAYLOAD:?Nombre unico de un lector cuyo mapa fue validado}"
"$READUIO" "$UIO_PAYLOAD" 0x00 0x04
```

No lo uses con un periférico de otro mapa. No comprueba offsets, rango ni alineación antes de llamar a `uio_read32`. Que salga bien no significa que la captura sea nueva, y no hace snapshots.

`test_uio/uio_peek.c` tiene fijos `/dev/uio4`, longitud `0x4000` y offset 0, y no comprueba `open` ni `mmap`. `test_open.c` tiene fijo uio0. No sirven fuera de esa máquina.

## `fwMonitor`: el ejecutable sale de `fwStatus.cpp`

Fuentes backup: `emp-tools/empTools/fwStatus/`, `src/fwMonitor/`, `src/axiBackend/`, `include/axiBackend/`.

| Elemento | Qué hace |
|---|---|
| Parámetros | `-h/--help` y `--id N` (por defecto -1, que muestra la tabla 0..12). Usa `--id`: el alias corto está declarado con espacios. |
| Construcción | `add_executable(fwMonitor fwStatus.cpp ...)`; sale en `bin_${BUILD_FOR}`. |
| Dependencias | Boost, pthread, objetos LogIt/fwMonitorSw y `libuio` si hay `HAVE_UIO`. Las dependencias finales las dice el ELF. |
| UIO | `empfw_debughub`, fijo en el constructor. Esta copia no permite elegir dirección. |
| Lecturas | Tres registros de estado y siete getters. También lee campos de reloj que no muestra. |
| Escrituras | Ninguna en este `main()`. El backend tiene métodos de reset, pero aquí no se llaman. |
| Salida | Tabla con `RX locked`, `TX ready`, `TX aligned` y `XCVR Ready`. No devuelve payload. |
| Errores | Sin UIO, fallo al abrir, runtime o SIGBUS. `initUio()` anota el error y sigue, y la limpieza puede fallar con un puntero nulo. Si aborta, no culpes al enlace. |

XCVR es el AND de TXREADY y RXREADY, sin separarlos. La ayuda devuelve 1 antes de tocar el hardware. Un `--id` fuera de rango puede imprimir solo la cabecera, sin avisar de que el canal no existe.

## `lsuio` y `libuio`

Fuente backup: `libuio/lsuio.c`, `base.c`, `helper.c`, `mem.c`, `irq.c`, `CMakeLists.txt`.

`lsuio -v` lista atributos y mapas; `-a/--access` además intenta `uio_open/uio_close`. Sin `-a` no hay lecturas MMIO, pero tiene un error: avanza `uio_list` mientras recorre y al final libera el puntero ya movido. La nota `0930` registra justo ese `free(): invalid pointer`. Fuente y nota encajan, aunque eso no prueba que aquel ELF saliera de esta copia.

En estas fuentes `libuio` usa GLib. El gitingest de `missinglinkelectronics-libuio` coincide en `base.c` y `mem.c`, salvo líneas vacías al final. El respaldo usa CMake y el gitingest Autotools, así que no supongas el mismo build ni un commit upstream concreto.

`uio_read32()` lee memoria volatile sin comprobar límites. `uio_irqwait_timeout()` es para el control IC, no para la CLI de payload. Abrir el UIO no deja lista toda la cadena experimental.

## `loadFirmare.sh`

Se llama `loadFirmare`, sin la segunda «w» de Firmware. Fuente backup: `epos/etools/loadFirmare.sh`; también hay `atlas_epos/etools/loadFirmare.sh` en GitHub.

`-l` lista los `.dtbo` de `/lib/firmware` y `-h` imprime el uso. La ayuda anuncia `--list/--help`, pero el `getopts ":lh"` las rechaza antes; se comprobó con un trozo aislado del parser, sin correr el cargador. La copia del backup añade la fecha con `stat`, `cut` y `sort`, con el comentario `251210`: se editó después de varias pruebas, pero eso no dice cuándo se desplegó. La copia de GitHub lista distinto; no las intercambies sin saber cuál es cuál.

Con un archivo de firmware, comprueba extensión y lectura, crea y monta configfs si hace falta, quita el overlay `emp-firmware`, crea otro y escribe su `path`. Usa Bash y utilidades del sistema y necesita permisos. El mensaje final solo dice que se escribió `path` sin error; no prueba que funcione ni permite volver atrás. Si la carga falla después de quitar el overlay, el sistema se queda sin el anterior. Este modo queda fuera de P0.

## `lpGbtRegister`, `LpGbtSw` y `lpGbtConfiguration`

Fuentes backup: `LpGbtSw/Demonstrators/`, `LpGbtUioBackend/` e `include/`.

| Programa | Opciones en la fuente | Qué devuelve | Qué cambia en el hardware |
|---|---|---|---|
| `lpGbtRegister` | `-a DIRECCION`, `-r REG`, `-w REG:VAL`, `-h` | Un byte de un registro del chip, o lo escribe | Incluso `-r` inicializa el controlador, mueve dirección, control e IRQ y vacía la FIFO. `-w` además escribe en el chip. |
| `lpGbtConfiguration` | `-a DIRECCION`, `-r`, `-w ARCHIVO`, `-h`, `-v` | Lectura completa y exportación `.cnf`, o aplica una configuración | `-r` hace transacciones IC; `-w` programa muchos registros. Pasa siempre la acción: `isRead` no arranca en un modo seguro. |
| `LpGbtSw` | Biblioteca de clases, no un comando | Backend UIO o simulador según la URI | Depende del método y del constructor. |

CMake enlaza Boost, pthread, objetos de LpGbtSw y LogIt, y `libuio` con `HAVE_UIO`. `build.sh` borra `build` y configura V1 (`USE_LPGBT_V0=OFF`) y UIO. No lo corras para inspeccionar una instalación: borraría lo que haya en esa carpeta. Las fuentes curadas tampoco garantizan un proyecto que compile.

El gitingest `fbientrigo-lpgbtsw` trae además `Demonstrators/TrigoLpGbt/test.cpp`, registros, configuraciones y más dependencias. Que esté ahí no prueba que se instalara ni que leyera el FE. En las dos fuentes comparadas, `LpGbtUioBackend.cpp` y `lpGbtRegister.cpp` coinciden salvo líneas vacías al final. Ese gitingest no trae commit ni fecha.

El mapa V0 o V1 se elige al compilar. Las direcciones simbólicas V1 de `ULDATASOURCE*` y `EPRXPRBS*` no dicen qué bits habilitan el FE. No apliques una configuración V1 sin saber la revisión del chip.

## `readprbs_cli` y variantes PuzzledWizard

Fuentes backup: `puzzled_working/{readprbs_cli.cpp,readprbs_cli_minimal.cpp,ReadPRBS.cpp,Read_PRBS.c,Makefile}`; `puzzled_writePRBS/{readprbs_cli.cpp,ReadPRBS.cpp,patch_bits.py}`.

La CLI completa tiene `--by-name`, `--by-num`, `--read-magic`, `--read-status`, `--read-data`, `--write-data`, `--write-control`, `--write-sequence`, `--selftest`, `--repeat`, `--sleep-ms`, `--json`, `--verbose` y ayuda. Su mapa es `magic +0`, `control +4`, `status +8`, `data_prbs +0xC`, distinto del de payload.

El Makefile genera bibliotecas C/C++ compartidas y estáticas, y enlaza la CLI con `libReadPRBS.a` y `libuio`. Por eso no necesita `libReadPRBS.so` al ejecutarse, aunque sí las demás dependencias de su ELF. Esto no se aplica a `TgcReadUplink` sin ver su build.

Identifica cada variante (minimal, writePRBS) antes de usar opciones. En las dos CLI completas revisadas, `--selftest` lee magic y status y cinco veces data, e imprime OK sin comparar nada. Las secuencias de escritura y los setters sí cambian el bloque. Pide la ayuda solo si sabes que el parser sale antes de abrir el dispositivo; eso no vale para todas las CLI.

## Scripts antiguos y qué valen sus resultados

| Archivo | Qué hace | Problemas que se ven en el código |
|---|---|---|
| `sweep_clock.sh` | Escribe `0xA00E002C`, lee `0xA00E0004` y guarda un log | `READER` no se usa; `devmem` sin ancho; una salida vacía se guarda como cero; borra el log anterior. Un error y un cero quedan iguales. |
| `test_saturation.sh VAL` | Escribe `0xA00D000C` y lee el offset 4 de trece bases | No mide saturación, throughput ni coherencia. Al menos registra si la lectura falló. |
| `1024/send_and_read.sh VAL` | Escribe threshold `0xE` y un patrón, y lee una lista de offsets | Se salta `+0x18` e incluye `+0x28`, así que nueve líneas no son nueve grupos. El `[OK]` final no valida las lecturas. |
| `watch_devmem.sh [INTERVAL]` | Repite la lectura de esa misma lista | `sleep` comentado, stderr oculto, sin fin y sin comprobar el firmware. |
| `read_lpgbt10.sh` | Lee el byte bajo del lector 0 y espera a que cambie | El «10» del nombre no elige la instancia 10. Junta observaciones distintas sin framing. |

Estos scripts muestran qué se intentaba, pero sus logs no prueban eventos del FE completos. Ninguno sustituye la prueba externa de P0.
