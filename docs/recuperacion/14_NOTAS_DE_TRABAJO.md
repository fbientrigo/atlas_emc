# Retomar la lectura del front-end

Herramientas, rutas y notas para volver a trabajar con la Trenz. Uso `~` como el home de la placa: por ejemplo, `~/read_all_lpgbt/`. Las rutas `atlas_emc/...` son del repositorio. Si una carpeta se movió, ajustar esa parte.

Tenemos los programas y las notas de las pruebas anteriores. Falta revisar qué quedó cargado y recuperar la configuración que se estaba usando. Los ejemplos de hardware se ejecutan en la placa, después de confirmar el mapa y los efectos de los registros. La web solo muestra texto.

## Orden de trabajo

Si hay una configuración funcionando, primero anotarla; no hace falta recargar todo.

| Paso | Qué haríamos | Programa / archivo |
|---|---|---|
| 1. Firmware | Buscar qué está cargado y qué archivos hay. Para retomar las pruebas de octubre, buscaría `reading_1006.dtbo`: aparece en la nota 1028. `emp_read_fixed_1003.dtbo` es anterior, de 1002. Falta vincular esos nombres con un bitstream y mapa comprobados. | `~/epos/etools/loadFirmare.sh -l`; `/lib/firmware/` |
| 2. Reloj | Revisar si el servicio de arranque ya programó el Si5345. Si hay que programarlo, las notas usan `sudo clkProgrammer -c`. Confirmar variante y configuración antes de repetirlo. | `/usr/bin/clkProgrammer`; `systemd-programclock.service` |
| 3. lpGBT | Recuperar la configuración de PiGBT o el `.cnf` usado. Confirmar canal, tasas y fuente del Serializer. En las notas se usa **Loopback Downlink Frame @ 10G24** para loopback y funcionamiento normal para FE. No quedó identificado un `.cnf` definitivo. | PiGBT o `~/LpGbtSw/build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration` |
| 4. Enlace | Consultar el pipeline conectado. El canal 10 funcionó en notas de septiembre; algunos XSA de otra versión conectan la interfaz e-link al 11. Confirmar la conexión de hoy. | `fwMonitor --id N` |
| 5. Lectura | Con el mapa TGC confirmado, guardar unas lecturas completas. `readprbs_cli` se usa para generar un patrón de prueba; no es un paso necesario para leer el FE. | `~/read_all_lpgbt/tgc_readuplink_cli` |
| 6. Comparación | Cambiar una señal conocida del FE y volver al estado anterior. Mirar qué palabras responden. Si se queda pegado, guardar lo último antes de reiniciar. | [Comparador de capturas](#comparar); [registros pegados](14_NOTAS_DE_TRABAJO.md#si-los-registros-se-quedan-pegados) |

Para empezar, estas órdenes solo consultan archivos y metadatos:

```bash
uname -a
cat /etc/os-release
bash ~/epos/etools/loadFirmare.sh -l
ls /lib/firmware/
systemctl cat systemd-programclock.service
for u in /sys/class/uio/uio*; do
  [ -d "$u" ] || continue
  printf '%s\n' "$u"
  cat "$u/name" "$u"/maps/map0/{addr,size,offset}
done
```

Ejemplos de carga y configuración, **comentados**. Primero hay que elegir los archivos correctos; cambian el equipo:

```bash
# sudo ~/epos/etools/loadFirmare.sh FIRMWARE_ELEGIDO.dtbo
# cd ~/LpGbtSw/build/Demonstrators/LpGbtConfiguration
# sudo ./lpGbtConfiguration -a lpgbt-uio://emp_lpgbt_10 -w CONFIG.cnf
```

Referencias en `atlas_emc/ChargeMonitoringSystem_obsidian/30_Notes/`: `1002-Programa de envios.md`, `1028-Pruebas de envio de constante.md`, `0922-Conectando a LPGBT.md` y `1028-1031-Testing.md`. Son notas de ensayos anteriores, no un registro de lo que está cargado hoy.

## Tabla de herramientas

| Quiero revisar | Programa | Qué devuelve | Dónde está |
|---|---|---|---|
| Palabras del capturador | `tgc_readuplink_cli` | magic, nueve grupos, header y threshold | `~/read_all_lpgbt/` |
| Un registro por nombre y offset | `readuio` / `libuio` | Palabras de 32 bits | `~/test_uio/`; `~/libuio/` |
| Estado del enlace | `fwMonitor` | RX locked, TX ready/aligned y XCVR Ready | `~/EMPToolsArtifacts/bin_TRENZ/` |
| Patrón de prueba | `readprbs_cli` | Lecturas o escrituras del bloque PRBS | `~/puzzled_working/` |
| Registro interno del chip | `lpGbtRegister` | Un byte del lpGBT mediante IC | `~/LpGbtSw/build/Demonstrators/LpGbtRegister/` |
| Configuración, ADC o GPIO | Familia `LpGbtSw` | Configuración y periféricos del chip | `~/LpGbtSw/build/Demonstrators/` |
| Reloj Si5345 | `clkProgrammer` | Monitorización o programación por I2C | `~/EMPToolsArtifacts/bin_TRENZ/`; ruta instalada histórica `/usr/bin/` |
| Firmware y pruebas antiguas | `loadFirmare.sh`, scripts `devmem` | Carga de overlay o accesos físicos | `~/epos/etools/`; scripts en `~` |
| Guardar la sesión | `atlas_diagnostico.py` | Inventario, captura supervisada e informe | `atlas_emc/docs/recuperacion/diagnostico/` |

## tgc_readuplink_cli

Es el lector de los nueve grupos TGC. No tiene opciones para elegir canal: abre directamente el UIO llamado `tgc_readUplink_regs`. **`--help` también lee hardware**; `main()` no procesa argumentos.

Fuentes: `~/read_all_lpgbt/tgc_readuplink_cli.cpp` y `TgcReadUplink.cpp`. La función que termina leyendo memoria es `uio_read32()`, en `~/libuio/mem.c:209–221`.

Con firmware, mapa y efectos de lectura confirmados, una ejecución se guarda así:

```bash
~/read_all_lpgbt/tgc_readuplink_cli > tgc_01.out 2> tgc_01.err
RC=$?
printf '%s\n' "$RC" > tgc_01.rc
```

La salida contiene doce registros: `magic`, `data_group_0…8`, `data_header` y `clk_thresh`. La línea decimal final repite threshold. El mensaje del constructor no es payload.

Son lecturas independientes. Falta confirmar el packing y si pertenecen al mismo evento. Un valor legible puede ser el último que quedó guardado. Para repetir lecturas, usar el supervisor con el plan revisado.

## readuio y libuio

`libuio` es la biblioteca, no una CLI. Busca UIO, abre/mapea el dispositivo y hace las cargas de memoria. Archivos: `~/libuio/libuio.so`, `base.c` y `mem.c`.

La utilidad que nos interesa está en `~/test_uio/readuio`; su fuente es `~/test_uio/readuio.c`. Recibe **nombre UIO y offsets en bytes**. Solo para el mapa TGC ya confirmado:

```bash
~/test_uio/readuio tgc_readUplink_regs 0x0 0x4 0x18 \
  > readuio_01.out 2> readuio_01.err
```

En ese mapa: `0x0` es magic, `0x4` es grupo 0 y `0x18` —24 bytes— es grupo 5. No son índices de un array.

La copia `test_uio/readuio` imprime hexadecimal; `~/libuio/readuio.c` imprime decimal. No mezclar los formatos al analizar. `uio_read32()` no comprueba límites: confirmar rango y alineación antes de leer. Un `read()` normal de `/dev/uioN` atiende notificaciones IRQ, no reemplaza el mmap del payload.

`uio_peek` y `test_open` fijan números UIO históricos. Para inventario, preferir sysfs; la fuente de `lsuio` tiene además un problema de liberación de memoria.

## fwMonitor

Consulta el debughub de la FPGA. El índice es el pipeline `emp_lpgbt`, no el número `/dev/uioN` ni automáticamente el e-link del FE.

Ejecutable: `~/EMPToolsArtifacts/bin_TRENZ/fwMonitor`. Fuente CLI: `~/emp-tools/empTools/fwStatus/fwStatus.cpp`; backend: `~/emp-tools/src/fwMonitor/fwMonitor.cpp`.

Hay otras copias en `bin_EMP` y en `~/clk_files/EMPToolsArtifacts/`; los cuatro ELF son distintos. Confirmar cuál corresponde al equipo y sus bibliotecas. Con el mapa del debughub validado:

```bash
printf 'Pipeline confirmado para esta conexión: '
read -r CANAL
~/EMPToolsArtifacts/bin_TRENZ/fwMonitor --id "$CANAL" \
  > enlace_01.out 2> enlace_01.err
printf '%s\n' "$?" > enlace_01.rc
```

| Campo | Cómo leerlo |
|---|---|
| RX locked | Alineación de cabecera según el RTL revisado; no demuestra datos nuevos. |
| TX ready / TX aligned | Disponibilidad y alineación TX de esa implementación. |
| XCVR Ready | AND de estados ready del transceptor. |

Sin `--id`, la fuente recorre canales 0…12. La tabla no muestra un identificador de build ni todos los campos de reloj que lee el backend. Si hay errores de apertura UIO o un crash, revisar el acceso antes de concluir que falló la fibra.

## readprbs_cli

Controla un bloque de prueba: magic `+0`, control `+4`, status `+8`, data_prbs `+0xC`. No es el mapa TGC.

Ejecutable y fuentes: `~/puzzled_working/{readprbs_cli,readprbs_cli.cpp,ReadPRBS.cpp}`. En `~/puzzled_writePRBS/` hay otra copia: las fuentes CLI coinciden por bytes, pero los ejecutables son distintos.

Lecturas, solo con ese bloque y sus efectos confirmados:

```bash
printf 'Nombre UIO del bloque PRBS confirmado: '
read -r UIO_PRBS
~/puzzled_working/readprbs_cli --by-name "$UIO_PRBS" \
  --read-magic --read-status --read-data \
  > prbs_01.out 2> prbs_01.err
```

| Opción | Uso |
|---|---|
| `--repeat N`, `--sleep-ms MS` | Repetir acciones, con espera entre repeticiones. |
| `--selftest` | Lee magic/status y cinco veces data. Imprime OK sin comparar contenido. La opción sola no escribe. |
| `--json` | Líneas JSON precedidas por el mensaje del constructor; no es un documento JSON único limpio. |
| `--write-data VAL`, `--write-control VAL` | Escrituras: confirmar significado del valor y efectos. |
| `--write-sequence FILE` | Escribe valores del archivo, uno por línea. |

En los overlays aparece el nombre `Read_PRBS_regs`. No asumirlo sin revisar sysfs. Elegir acciones explícitas: con dispositivo seleccionado y sin acción, la CLI usa selftest.

Ejemplo de escritura, comentado hasta elegir el patrón y confirmar la IP:

```bash
# ~/puzzled_working/readprbs_cli --by-name Read_PRBS_regs --write-data 0xEECCCC11
```

## lpGbtRegister

Lee o escribe registros internos del lpGBT mediante IC. Incluso `--read` escribe el controlador FPGA para enviar la transacción. No devuelve el payload TGC.

Ejecutable: `~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister`. Fuente: `~/LpGbtSw/Demonstrators/LpGbtRegister/lpGbtRegister.cpp`.

Sintaxis leída en el gitingest adjunto: `--address URI`, `--read REG`, `--write REG:VAL`. Cotejar con la fuente y ELF del equipo; no adoptar su canal por defecto.

```bash
printf 'URI IC confirmada, lpgbt-uio://emp_lpgbt_N: '
read -r URI
printf 'Registro del chip elegido, en hexadecimal: '
read -r REG
~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister \
  --address "$URI" --read "$REG" > registro_01.out 2> registro_01.err
```

La fuente imprime dirección y valor hexadecimal del byte. Un registro del chip y un offset AXI son espacios distintos: no sumar la dirección del registro lpGBT a A00E0000.

Ejemplo de sintaxis con **simulador**, sin medir un chip:

```bash
~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister \
  --address lpgbt-simulator://emp_lpgbt_9 --read 0x000
```

El backend conserva bucles sin límite en clearIntr y drenaje FIFO; el timeout IRQ no limita toda la operación. La build guardada usa mapas V1; confirmar la versión física del chip.

## Configuración, ADC y GPIO

Las fuentes están en `~/LpGbtSw/Demonstrators/`; los ejecutables, en `~/LpGbtSw/build/Demonstrators/`. Opciones tomadas del gitingest: contrastar con la versión instalada.

| Programa | Qué hace |
|---|---|
| `LpGbtConfiguration/lpGbtConfiguration` | `--read` lee registros y crea un `.cnf` en la carpeta actual. `--write FILE` carga configuración. Usar carpeta nueva para guardar. |
| `LpGbtAdc/lpGbtAdc` | `--frequency F --iterations N`: cada iteración convierte ocho canales ADC internos. No mide el ADC del front-end. |
| `LpGbtGpio/lpGbtGpio` | `--pin 0…15 --read`; también `--write low/high`, `--direction input/output`. Confirmar pinout antes de modificar niveles o dirección. |
| `RegisterTranslator/registerTranslator` | Ejemplo/benchmark de traducción de nombres y direcciones; en la fuente adjunta trabaja localmente. No verifica comunicación IC. |

Ejemplos **independientes**, con URI y pin ya elegidos. Los tres primeros generan actividad en el chip; no copiar el bloque entero como inicialización:

```bash
cd ~/LpGbtSw/build/Demonstrators
./LpGbtConfiguration/lpGbtConfiguration --address "$URI" --read
./LpGbtAdc/lpGbtAdc --address "$URI" --frequency 1 --iterations 1
./LpGbtGpio/lpGbtGpio --address "$URI" --pin "$PIN" --read
# Carga de configuración, solo después de elegir el archivo:
# ./LpGbtConfiguration/lpGbtConfiguration --address "$URI" --write CONFIG.cnf
# Benchmark local de traducción en la fuente adjunta:
# ./RegisterTranslator/registerTranslator --iterations 1
```

En `0922-Conectando a LPGBT.md` hay lecturas con `emp_lpgbt_10`, firmware 0.2v y PiGBT. La nota `0919-PostReunionEMP_team.md` registra errores al usar el canal por defecto o pasar la URI como argumento posicional: usar `-a` / `--address`. No copiar configuraciones por su fecha sin revisar a qué montaje pertenecen.

## clkProgrammer

Ejecutable: `~/EMPToolsArtifacts/bin_TRENZ/clkProgrammer`; ruta instalada histórica: `/usr/bin/clkProgrammer`. Fuente CLI: `~/emp-tools/empTools/si5345_i2c/main_si5345.cpp`; driver: `~/emp-tools/src/i2cDevices/si5345.cpp`.

| Opción | Efecto |
|---|---|
| `-i`, `--read_mon_info` | Consulta revisión y estados LOS, OOF, LOL y flags por I2C. |
| `-c`, `--configure` | Programa la configuración Si5345 compilada en el ejecutable. |

Elegir solo una acción. La fuente usa i2c-13 para TRENZ e i2c-1 para EMP, dirección 0x69. Comprobar el bus actual.

```bash
# Consultar la unidad no inicia el programador:
systemctl cat systemd-programclock.service
# Consulta I2C activa: solo con bus y página comprobados.
# sudo /usr/bin/clkProgrammer -i > reloj_01.out 2> reloj_01.err
# Programación: solo con configuración y alcance aprobados.
# sudo /usr/bin/clkProgrammer -c
```

Hay un detalle en la fuente: `readRegister` no selecciona página; `writeRegister` sí. El postámbulo termina en página 0B. La lectura de estado puede ser incorrecta si quedó otra página seleccionada. Además, una excepción capturada puede acabar con retorno 0: revisar logs, no solo `$?`.

## Firmware y scripts

Descripciones XSA: `~/epos/hw-description/`. BSP: `~/epos/epos-bsp/`. Cargador: `~/epos/etools/loadFirmare.sh` —se escribe así—. Copia en repo: `atlas_emc/atlas_epos/etools/loadFirmare.sh`.

Para listar archivos en la placa, `bash ~/epos/etools/loadFirmare.sh -l`. Usar `-l` y `-h`; el `getopts` de esta versión impide asumir que funcionan las opciones largas. Cargar retira el overlay previo y no aporta rollback automático.

En el repo hay tres parejas DTBO/bit.bin bajo `atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/out_lpgbt_10_{cd,dd,direct}/`. Describen PRBS en A00D y TGC en A00E. No se ha demostrado qué relación tienen con `reading_1006.dtbo`.

| Script en `~` | Qué conviene saber |
|---|---|
| `read_lpgbt10.sh` | Espera indefinidamente un cambio del byte bajo. La palabra completa puede estar cambiando. |
| `watch_devmem.sh` | Omite +0x18, incluye header y oculta stderr; no son nueve grupos completos. |
| `sweep_clock.sh` | Escribe clk_thresh; no programa el Si5345. Puede convertir un fallo de lectura en cero. |
| `test_saturation.sh`, `1024/send_and_read.sh` | Escriben patrones y usan direcciones históricas; su nombre no convierte el resultado en una medida de tasa o BER. |

## Mapas y versiones

Las direcciones siguientes comparan archivos; no autorizan accesos:

| Diseño | A00D0000 | A00E0000 |
|---|---|---|
| BD `emp_fw_TE0807`, Vivado 2023.2 | `axi_intc_1` | `axi_intc_2` |
| XSA xV23 Trenz / EMP del home | Interfaz e-link | Sin MEMRANGE declarado allí |
| Overlays `out_lpgbt_10_*` del repo | `Read_PRBS_regs` | `tgc_readUplink_regs` |

Para el lector TGC de nueve grupos: magic `0x00`; grupo g en `0x04+4g`; header `0x28`; threshold `0x2C`. Todavía falta el RTL del capturador activo para entender packing, rearme, retención y coherencia. No asumir que nueve palabras son una trama ni que threshold está expresado en Hz.

## Guardar una lectura

El supervisor ya existe en `atlas_emc/docs/recuperacion/diagnostico/atlas_diagnostico.py`. Desde la raíz del repo en la placa:

```bash
DIAG="$PWD/docs/recuperacion/diagnostico/atlas_diagnostico.py"
python3 "$DIAG" inventario --lector ~/read_all_lpgbt/tgc_readuplink_cli \
  --salida inventario_01.json
python3 "$DIAG" preparar --inventario inventario_01.json --salida plan_01.json
```

Esto solo inspecciona archivos/metadatos. El plan nace bloqueado: completar las evidencias de `validation` y las identidades de las bibliotecas en `libraries`. Revisar build/mapa, ELF/dependencias, efectos de lectura, operador único y responsable de la operación. El script no demuestra esas condiciones por sí solo. [Detalle del plan](12_SCRIPT_DIAGNOSTICO.md#4-procedimiento-s1--plan-de-lectura-revisable).

Solo después de esa revisión, la captura ejecuta hardware:

```bash
python3 "$DIAG" capturar --plan plan_01.json --salida sesion_01 \
  --fase inicial --muestras 3 --intervalo 5 --timeout 3 --autorizar-lecturas
python3 "$DIAG" informe --sesion sesion_01 --salida informe_01.md
```

Guardar toda la sesión, incluidos errores y retorno. Un timeout no garantiza abortar una transacción AXI. No borrar el lock para saltar un fallo ni abrir otro lector sobre un acceso pendiente. El informe es offline; para [comparar A y B](#comparar), cargar los `.out` de fases conocidas, lejos de las transiciones.

## Si los registros se quedan pegados

| Qué pasa | Qué mirar primero |
|---|---|
| El programa termina, pero devuelve lo mismo | Comparar los 32 bits y cambiar una señal conocida del FE. Puede ser dato constante, retenido o canal equivocado. |
| El script sigue vivo y el byte bajo no cambia | Revisar `& 0xff`; mirar la palabra completa. |
| No vuelve al prompt, Linux responde | Conservar PID, estado, wchan, mapeos y salida; no iniciar otro lector. |
| Se atasca `lpGbtRegister` | Revisar la ruta IC y sus esperas. La CLI TGC no espera IRQ: no trasladar automáticamente esa causa. |
| UserData cambia pero AXI queda fijo | Revisar captura/rearme, siempre que ambas observaciones sean del mismo canal y build. Hace falta instrumentación: la CLI no ve UserData. |

Antes de reset: última buena, primera mala, firmware/mapa, configuración, estímulo, PID, sesión/lock y estados disponibles. Anotar qué se reinició exactamente. Si vuelve a funcionar, no alcanza para concluir que era una FIFO; el arranque también puede reprogramar el reloj.

## Qué falta confirmar

- Firmware cargado y vínculo entre nombre, DTBO, bitstream y mapa.
- Configuración PiGBT/`.cnf` realmente usada; canal y fuente del Serializer.
- Packing FE → e-link → grupos; trigger, rearme y efectos de lectura.
- Si el fallo original era un proceso bloqueado o valores repetidos.

Esta actualización usa los archivos completos del sistema y las notas del repo. Corrige el alcance del catálogo anterior: hay varias familias de mapa y copias de ejecutables. El estado actual del hardware sigue pendiente de comprobar.
