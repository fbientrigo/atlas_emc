# Catálogo operacional de herramientas existentes

Para ejecutar, seguir primero [las condiciones y comandos de campo](00_GUIA_CAMPO.md). Este catálogo describe implementación estática, no disponibilidad actual. Las ubicaciones son relativas al entorno histórico; ningún ELF está incluido en el ZIP curado.

## Elegir por tarea

| Necesidad | Herramienta existente | Primera comprobación |
|---|---|---|
| Identificar dispositivos | sysfs; opcional `lsuio -v` | A1, sin `-a`; el enumerador recuperado tiene un defecto de liberación. |
| Ver disponibilidad de artefactos | `loadFirmare.sh -l` | Leer la copia local antes; no pasar un nombre de firmware. |
| Diagnosticar transporte | `fwMonitor --id N` | Identificar `empfw_debughub` y su mapa. |
| Ver grupos de payload | `tgc_readuplink_cli` | Nombre fijo único y firmware con mapa de nueve grupos. |
| Consultar otro nombre UIO con offsets explícitos | `readuio` existente | Identificar la variante; ambas fuentes recuperadas usan `NOMBRE OFFSET...`. |
| Consultar configuración del chip | `lpGbtRegister` o exportación PiGBT existente | Operación IC activa, fuera del inventario pasivo. |
| Estimular patrones FPGA | `readprbs_cli`, scripts `devmem` | Pruebas internas que escriben, no recepción FE. No ejecutar como P0. |

## `tgc_readuplink_cli` y `TgcReadUplink`

**Fuente:** backup `read_all_lpgbt/{tgc_readuplink_cli.cpp,TgcReadUplink.cpp,TgcReadUplink.hpp}`. Otro script menciona `puzzled_getData/tgc_readuplink_cli`; no hay prueba de que ambos binarios fueran idénticos.

- **Ejecutable y parámetros:** `tgc_readuplink_cli`, ninguno implementado; `main()` no procesa `argv`. `--help`, `--id` o `--by-name` no seleccionan nada y no evitan el acceso.
- **Bibliotecas:** `libuio` y runtime C++; no consta en el ZIP la receta de enlace ni el ELF para establecer la lista dinámica exacta. Puede estar enlazada de formas diferentes.
- **Dispositivo y mapa:** nombre fijo `tgc_readUplink_regs`; map0, offsets 0,4,…,44. La clase admite también constructor por número, pero la CLI no lo expone.
- **Acciones:** abre/mapea lectura/escritura; lee `magic`, nueve grupos, header y threshold; imprime threshold dos veces. No escribe threshold desde ese `main()`.
- **Salida:** valores crudos; no timestamps de captura, eventos, formato FE ni validación de header.
- **Errores:** búsqueda por nombre fallida, `uio_open failed`, error de runtime, `SIGBUS`; los últimos no necesariamente pasan por el `catch(std::exception)`.
- **Compatibilidad:** JSON de nueve grupos revisión 27 concuerda en offsets; no verifica RTL ni bitstream. La clase de `puzzledWizards/output_tgc_readuplink_1002` tiene un solo registro `data_groups` y setter, por tanto es otra versión.

**Prioridad de reutilización:** alta, si coincide el periférico. Si solo cambia el nombre, investigar primero `readuio` instalado antes de compilar o adaptar.

## `readuio`: dos fuentes con la misma sintaxis

**Fuentes backup:** `test_uio/readuio.c:6–35` y `libuio/readuio.c:50–100`.

Ambas aceptan `readuio NOMBRE_UIO OFFSET [OFFSET...]`, convierten offsets mediante `strtoul(...,0)` y leen palabras de 32 bits en map0. Ambas dependen de `libuio`; la fuente `libuio` además usa macros/internacionalización del proyecto. La variante `test_uio` imprime hexadecimal y la de `libuio` imprime decimal, con `%d` para la palabra, lo que puede mostrar valores con bit alto como negativos en entornos habituales. Identificar el formato antes de comparar logs.

Ejemplo **condicionado**, usando la variante y nombre ya confirmados, para leer la firma y grupo 0 de un lector con mapa de F1:

```bash
: "${READUIO:?Ruta absoluta de la variante identificada}"
: "${UIO_PAYLOAD:?Nombre unico de un lector cuyo mapa fue validado}"
"$READUIO" "$UIO_PAYLOAD" 0x00 0x04
```

No utilizar el ejemplo sobre un periférico con otro mapa. No valida offsets, rango ni alineación antes de llamar a `uio_read32`. Una salida exitosa no comprueba captura nueva. No añade capacidad de snapshot.

`test_uio/uio_peek.c` fija `/dev/uio4`, longitud `0x4000` y lee offset 0 sin comprobar `open/mmap`; `test_open.c` fija uio0. No son alternativas portables para P0.

## `fwMonitor`: el ejecutable procede de `fwStatus.cpp`

**Fuentes backup:** `emp-tools/empTools/fwStatus/`, `src/fwMonitor/`, `src/axiBackend/`, `include/axiBackend/`.

| Elemento | Implementación |
|---|---|
| Parámetros | `-h/--help`, `--id N` con default -1 para tabla 0..12. Preferir `--id`, pues la declaración de alias corto contiene espacios. |
| Construcción | `add_executable(fwMonitor fwStatus.cpp ...)`; salida `bin_${BUILD_FOR}`. |
| Dependencias | Boost, pthread, objetos LogIt/fwMonitorSw y `libuio` si `HAVE_UIO`. El ELF determina dependencias dinámicas finales. |
| UIO | `empfw_debughub`, fijo en constructor por defecto. No existe opción CLI de dirección en esta copia. |
| Lecturas | Tres registros de estado, siete getters; campos de reloj también leídos pero omitidos de la tabla. |
| Escrituras | Ninguna explícita en el recorrido de este `main()`. El mismo backend tiene métodos de reset que aquí no se llaman. |
| Salida | Tabla de `RX locked`, `TX ready`, `TX aligned`, `XCVR Ready`. No devuelve payload. |
| Errores | Ausencia de UIO, fallo al abrir, runtime/SIGBUS; `initUio()` registra errores pero continúa; limpieza puede fallar con puntero nulo. No atribuir su abort al enlace. |

La tabla aplica AND de TXREADY/RXREADY para XCVR y no separa ambos. La ayuda retorna 1 antes de abrir hardware. Una petición `--id` fuera de rango puede producir solo cabecera, no un diagnóstico explícito de canal inválido.

## `lsuio` y `libuio`

**Fuente backup:** `libuio/lsuio.c`, `base.c`, `helper.c`, `mem.c`, `irq.c`, `CMakeLists.txt`.

`lsuio -v` enumera atributos/mapas; `-a/--access` intenta `uio_open/uio_close`. No hay reads MMIO explícitas en el recorrido sin `-a`, pero hay un defecto confirmado estáticamente: se incrementa `uio_list` al iterar y se libera el puntero desplazado al final. La nota `0930` registra `free(): invalid pointer`. Es coincidencia coherente entre fuente y observación, no prueba de que ese ELF concreto se construyera desde esta copia.

`libuio` utiliza GLib en estas fuentes. El gitingest de `missinglinkelectronics-libuio` concuerda en `base.c` y `mem.c` salvo líneas vacías finales del contenedor textual. El respaldo tiene CMake, mientras el gitingest trae Autotools. No asumir el mismo procedimiento de build ni un commit upstream identificado.

`uio_read32()` usa memoria volatile sin verificar límites; `uio_irqwait_timeout()` sirve al control IC, no a la CLI de payload. Abrir UIO no implica habilitar correctamente toda la cadena experimental.

## `loadFirmare.sh`

**Nombre exacto:** `loadFirmare`, sin la segunda «w» de Firmware. Fuente backup `epos/etools/loadFirmare.sh`; también existe `atlas_epos/etools/loadFirmare.sh` en GitHub.

Usar `-l` para listar `.dtbo` de `/lib/firmware` y `-h` para imprimir uso. Aunque el texto de ayuda anuncia `--list/--help`, el `getopts ":lh"` anterior a su comprobación las rechaza en esta implementación; se reprodujo esa ruta con un fragmento de parser aislado, sin ejecutar el cargador. La copia backup añade fecha mediante `stat`, `cut`, `sort`, con comentario `251210`; esa anotación es evidencia de edición posterior a varias pruebas, no prueba de fecha de despliegue. La copia GitHub difiere en esa función de listado; no sustituir una por otra sin identificarla.

Con argumento de firmware verifica extensión/lectura, crea y monta configfs si hace falta, retira el overlay `emp-firmware`, crea otro y escribe su `path`. Depende de Bash y utilidades del sistema; precisa permisos de modificación. El mensaje final indica que la escritura de `path` terminó sin error, no una prueba funcional ni rollback. Una carga fallida después de retirar el overlay puede dejar el sistema sin el anterior. Este modo queda fuera de P0.

## `lpGbtRegister`, `LpGbtSw` y `lpGbtConfiguration`

**Fuentes backup:** `LpGbtSw/Demonstrators/`, `LpGbtUioBackend/` e `include/`.

| Programa | Opciones en la fuente | Resultado | Modificación del hardware |
|---|---|---|---|
| `lpGbtRegister` | `-a DIRECCION`, `-r REG`, `-w REG:VAL`, `-h` | Un byte de registro del chip o escritura | Incluso `-r` inicializa controlador, mueve direcciones/control/IRQ y consume FIFO. `-w` además escribe chip. |
| `lpGbtConfiguration` | `-a DIRECCION`, `-r`, `-w ARCHIVO`, `-h`, `-v` | Lectura masiva/exportación `.cnf` o aplicación de configuración | `-r` hace transacciones IC activas; `-w` programa muchos registros. No omitir la acción: `isRead` no se inicializa como modo seguro por defecto. |
| `LpGbtSw` | Biblioteca/clases, no comando único | Backend UIO o simulador seleccionado por URI | Depende del método invocado y de constructores. |

CMake enlaza Boost/pthread y objetos LpGbtSw/LogIt; `libuio` con `HAVE_UIO`. La receta `build.sh` borra `build` y configura V1 (`USE_LPGBT_V0=OFF`) y UIO. No ejecutarla para «inspeccionar» una instalación; destruiría artefactos existentes de esa carpeta. Las fuentes curadas no son un proyecto de build completo garantizado.

El gitingest `fbientrigo-lpgbtsw` incluye además `Demonstrators/TrigoLpGbt/test.cpp`, registros/configuraciones y más dependencias. Su presencia no demuestra instalación ni éxito de una lectura FE. En las dos fuentes comparadas, `LpGbtUioBackend.cpp` y `lpGbtRegister.cpp` concuerdan salvo líneas vacías finales. No se recibió commit/fecha que identifique ese gitingest.

El mapa V0/V1 se selecciona en compilación. Direcciones simbólicas de V1 para `ULDATASOURCE*`/`EPRXPRBS*` no determinan por sí solas qué bits habilitan FE. No aplicar configuración V1 a un chip sin identificar su revisión.

## `readprbs_cli` y variantes PuzzledWizard

**Fuentes backup:** `puzzled_working/{readprbs_cli.cpp,readprbs_cli_minimal.cpp,ReadPRBS.cpp,Read_PRBS.c,Makefile}`; `puzzled_writePRBS/{readprbs_cli.cpp,ReadPRBS.cpp,patch_bits.py}`.

La CLI completa ofrece `--by-name`, `--by-num`, `--read-magic`, `--read-status`, `--read-data`, `--write-data`, `--write-control`, `--write-sequence`, `--selftest`, `--repeat`, `--sleep-ms`, `--json`, `--verbose` y ayuda. El mapa de ReadPRBS usa `magic +0`, `control +4`, `status +8`, `data_prbs +0xC`. No es el mapa de payload.

El Makefile construye bibliotecas C/C++ compartidas y estáticas, y enlaza la CLI con `libReadPRBS.a` más `libuio`. Por ello no requiere necesariamente `libReadPRBS.so` en runtime, pero aún requiere las dependencias dinámicas de su ELF. No extender ese detalle a `TgcReadUplink` sin su build.

Las variantes minimal y writePRBS deben identificarse individualmente antes de usar opciones. En las dos fuentes CLI completas revisadas, `--selftest` solo lee magic/status y cinco veces data; imprime OK sin comparar contenido. Las escrituras de secuencia y setters sí modifican el bloque. Solo consultar ayuda del ejecutable si está confirmado que su parser sale antes de abrir; no trasladar esa propiedad a todas las CLIs.

## Scripts históricos y calidad de sus resultados

| Archivo | Qué hace | Fallo o límite observado estáticamente |
|---|---|---|
| `sweep_clock.sh` | Escribe `0xA00E002C`, lee `0xA00E0004`, guarda log | Variable `READER` no usada; read devmem sin ancho explícito; salida vacía convertida a cero; log previo truncado. No conserva distinción error/cero. |
| `test_saturation.sh VAL` | Escribe `0xA00D000C`; lee offset 4 de trece bases | No mide por sí solo saturación/throughput ni coherencia. Al menos registra error de read por retorno. |
| `1024/send_and_read.sh VAL` | Escribe threshold `0xE` y patrón; lee una lista de offsets | Omite `+0x18`, incluye `+0x28`; nueve líneas no equivalen a nueve grupos. Mensaje final `[OK]` no valida lecturas. |
| `watch_devmem.sh [INTERVAL]` | Bucle de lectura de la misma lista | `sleep` comentado, stderr oculto, sin terminación ni verificación del firmware. |
| `read_lpgbt10.sh` | Lee byte bajo de base de lector 0 y espera cambio | Su nombre «10» no selecciona la base de instancia 10; concatena observaciones distintas sin framing. |

La presencia de estos scripts prueba herramientas e intención experimental. Sus logs no son pruebas de eventos FE íntegros. No ejecutar ninguno para sustituir la prueba externa de P0.
