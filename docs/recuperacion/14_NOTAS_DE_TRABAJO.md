# Retomar la lectura del front-end

Herramientas, rutas y notas para volver a trabajar con la Trenz. `~` es el home de la placa, por ejemplo `~/read_all_lpgbt/`. Las rutas `atlas_emc/...` son del repositorio. Si una carpeta se movió, ajusta esa parte.

Para operar la Trenz con el mapa de noviembre, empieza por [emp y la captura CSV](15_OPERAR_EMP.md). Aquí quedan las rutas de firmware, reloj y herramientas de los ensayos anteriores.

## Orden de trabajo

Si algo ya funciona, anótalo primero. No hace falta recargar todo.

| Paso | Qué hacer | Programa / archivo |
|---|---|---|
| 1. Firmware | Con la placa operativa, revisa el mapa con `emp doctor`. `reading_1006.dtbo` es de los ensayos de octubre. | `~/capture/emp`, `~/epos/etools/loadFirmare.sh -l` |
| 2. Reloj | Mira si el servicio de arranque programó el Si5345. Confirma la variante y el bus I²C antes de repetir una configuración. | `/usr/bin/clkProgrammer`, `systemd-programclock.service` |
| 3. lpGBT | Confirma canal, tasas y fuente del serializer en PiGBT o en el `.cnf`. | PiGBT o `~/LpGbtSw/build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration` |
| 4. Enlace | En noviembre, `emp doctor --probe 10` confirmó respuesta IC. Usa `fwMonitor --id N` para ver los estados del pipeline elegido. | `~/capture/emp`, `fwMonitor` |
| 5. Lectura | Guarda las palabras crudas del banco validado. | [`emp read`, `watch` y `start`](15_OPERAR_EMP.md) |
| 6. Comparación | Aplica un patrón conocido y vuelve al estado anterior. Guarda las tres lecturas. | [Comparador de capturas](#comparar), [prueba A/B/A](00_GUIA_CAMPO.md#etapa-d-prueba-externa-aba) |

Para empezar, estas órdenes solo miran archivos y metadatos:

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

Ejemplos de carga y configuración. Están comentados a propósito porque cambian el equipo. Elige antes los archivos correctos:

```bash
# sudo ~/epos/etools/loadFirmare.sh FIRMWARE_ELEGIDO.dtbo
# cd ~/LpGbtSw/build/Demonstrators/LpGbtConfiguration
# sudo ./lpGbtConfiguration -a lpgbt-uio://emp_lpgbt_10 -w CONFIG.cnf
```

Notas relacionadas en `atlas_emc/ChargeMonitoringSystem_obsidian/30_Notes/`: `1002-Programa de envios.md`, `1028-Pruebas de envio de constante.md`, `0922-Conectando a LPGBT.md` y `1028-1031-Testing.md`. Son de ensayos anteriores; no dicen qué está cargado hoy.

## Tabla de herramientas

| Quiero revisar | Programa | Qué devuelve | Dónde está |
|---|---|---|---|
| Leer, vigilar o guardar CSV | [`emp` y `raw.sh`](15_OPERAR_EMP.md) | Sondeos de registros y diagnóstico | `~/capture/` |
| Palabras del capturador (CLI anterior) | `tgc_readuplink_cli` | magic, nueve grupos, header y threshold | `~/read_all_lpgbt/` |
| Un registro por nombre y offset | `readuio` / `libuio` | Palabras de 32 bits | `~/test_uio/`; `~/libuio/` |
| Estado del enlace | `fwMonitor` | RX locked, TX ready/aligned y XCVR Ready | `~/EMPToolsArtifacts/bin_TRENZ/` |
| Patrón de prueba | `readprbs_cli` | Lecturas o escrituras del bloque PRBS | `~/puzzled_working/` |
| Registro interno del chip | `lpGbtRegister` | Un byte del lpGBT por IC | `~/LpGbtSw/build/Demonstrators/LpGbtRegister/` |
| Configuración, ADC o GPIO | Familia `LpGbtSw` | Configuración y periféricos del chip | `~/LpGbtSw/build/Demonstrators/` |
| Reloj Si5345 | `clkProgrammer` | Estado o programación por I2C | `~/EMPToolsArtifacts/bin_TRENZ/`; antes también en `/usr/bin/` |
| Firmware y pruebas antiguas | `loadFirmare.sh`, scripts `devmem` | Carga de overlay o accesos físicos | `~/epos/etools/`; scripts en `~` |
| Guardar la sesión | `atlas_diagnostico.py` | Inventario, captura supervisada e informe | `atlas_emc/docs/recuperacion/diagnostico/` |

## tgc_readuplink_cli

Es el lector de los nueve grupos TGC. No permite elegir canal: abre siempre el UIO llamado `tgc_readUplink_regs`. Como `main()` no lee argumentos, `--help` también lee el hardware.

Fuentes: `~/read_all_lpgbt/tgc_readuplink_cli.cpp` y `TgcReadUplink.cpp`. La función que al final lee memoria es `uio_read32()`, en `~/libuio/mem.c:209–221`.

Con el firmware, el mapa y los efectos de la lectura confirmados, una ejecución se guarda así:

```bash
~/read_all_lpgbt/tgc_readuplink_cli > tgc_01.out 2> tgc_01.err
RC=$?
printf '%s\n' "$RC" > tgc_01.rc
```

La salida tiene doce registros: `magic`, `data_group_0…8`, `data_header` y `clk_thresh`. La línea decimal del final repite el threshold. El mensaje del constructor no es payload.

Cada registro se lee por separado. Falta confirmar el packing y si las palabras son del mismo evento. Un valor legible puede ser simplemente el último que quedó guardado. Para repetir lecturas, usa el supervisor con el plan revisado.

## readuio y libuio

`libuio` es una biblioteca. Busca el UIO, abre y mapea el dispositivo y hace las lecturas de memoria. Archivos: `~/libuio/libuio.so`, `base.c` y `mem.c`.

La utilidad que nos sirve es `~/test_uio/readuio` (fuente: `~/test_uio/readuio.c`). Recibe el nombre UIO y offsets en bytes. Úsala solo con el mapa TGC ya confirmado:

```bash
~/test_uio/readuio tgc_readUplink_regs 0x0 0x4 0x18 \
  > readuio_01.out 2> readuio_01.err
```

En ese mapa, `0x0` es magic, `0x4` es el grupo 0 y `0x18` (24 bytes) es el grupo 5. Son bytes, no índices de un array.

`test_uio/readuio` imprime en hexadecimal y `~/libuio/readuio.c` en decimal; cuidado al comparar. `uio_read32()` no comprueba límites, así que confirma rango y alineación antes de leer. Un `read()` sobre `/dev/uioN` espera una IRQ; para el payload hace falta el mmap.

`uio_peek` y `test_open` tienen números UIO antiguos escritos en el código. Para el inventario usa sysfs; `lsuio` además libera mal la memoria.

## fwMonitor

Consulta el debughub de la FPGA. El índice es el pipeline `emp_lpgbt`. No es el número de `/dev/uioN`, y tampoco tiene por qué coincidir con el e-link del FE.

Ejecutable: `~/EMPToolsArtifacts/bin_TRENZ/fwMonitor`. Fuente de la CLI: `~/emp-tools/empTools/fwStatus/fwStatus.cpp`; backend: `~/emp-tools/src/fwMonitor/fwMonitor.cpp`.

Hay otras copias en `bin_EMP` y en `~/clk_files/EMPToolsArtifacts/`, y los cuatro ELF son distintos. Confirma cuál corresponde al equipo y a sus bibliotecas. Con el mapa del debughub validado:

```bash
printf 'Pipeline confirmado para esta conexión: '
read -r CANAL
~/EMPToolsArtifacts/bin_TRENZ/fwMonitor --id "$CANAL" \
  > enlace_01.out 2> enlace_01.err
printf '%s\n' "$?" > enlace_01.rc
```

| Campo | Cómo leerlo |
|---|---|
| RX locked | La cabecera está alineada, según el RTL revisado. No dice si hay datos nuevos. |
| TX ready / TX aligned | TX disponible y alineado en esa implementación. |
| XCVR Ready | AND de los ready del transceptor. |

Sin `--id` recorre los canales 0…12. La tabla no muestra qué build hay ni todos los campos de reloj que lee el backend. Si falla al abrir el UIO o se cae, revisa el acceso antes de culpar a la fibra.

## readprbs_cli

Controla un bloque de prueba con su propio mapa: magic `+0`, control `+4`, status `+8`, data_prbs `+0xC`. El mapa TGC es otro.

Ejecutable y fuentes: `~/puzzled_working/{readprbs_cli,readprbs_cli.cpp,ReadPRBS.cpp}`. En `~/puzzled_writePRBS/` hay otra copia: las fuentes de la CLI son idénticas, pero los ejecutables no.

Para leer, solo con ese bloque y sus efectos confirmados:

```bash
printf 'Nombre UIO del bloque PRBS confirmado: '
read -r UIO_PRBS
~/puzzled_working/readprbs_cli --by-name "$UIO_PRBS" \
  --read-magic --read-status --read-data \
  > prbs_01.out 2> prbs_01.err
```

| Opción | Uso |
|---|---|
| `--repeat N`, `--sleep-ms MS` | Repite las acciones, con una pausa entre cada vuelta. |
| `--selftest` | Lee magic y status, y cinco veces data. Imprime OK sin comparar nada. Sola no escribe. |
| `--json` | Líneas JSON, con el mensaje del constructor delante. El conjunto no es un JSON válido. |
| `--write-data VAL`, `--write-control VAL` | Escriben. Confirma qué significa el valor y qué efecto tiene. |
| `--write-sequence FILE` | Escribe los valores del archivo, uno por línea. |

En los overlays aparece el nombre `Read_PRBS_regs`; revisa sysfs antes de darlo por hecho. Pide siempre una acción: si eliges dispositivo y no das acción, la CLI corre selftest.

Ejemplo de escritura, comentado hasta elegir el patrón y confirmar la IP:

```bash
# ~/puzzled_working/readprbs_cli --by-name Read_PRBS_regs --write-data 0xEECCCC11
```

## lpGbtRegister

Lee o escribe registros internos del lpGBT por IC. Incluso `--read` escribe en el controlador de la FPGA para mandar la transacción. Devuelve registros del chip, nunca el payload TGC.

Ejecutable: `~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister`. Fuente: `~/LpGbtSw/Demonstrators/LpGbtRegister/lpGbtRegister.cpp`.

Sintaxis según el gitingest adjunto: `--address URI`, `--read REG`, `--write REG:VAL`. Compárala con la fuente y el ELF del equipo, y pasa siempre el canal, porque el de por defecto no es el nuestro.

```bash
printf 'URI IC confirmada, lpgbt-uio://emp_lpgbt_N: '
read -r URI
printf 'Registro del chip elegido, en hexadecimal: '
read -r REG
~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister \
  --address "$URI" --read "$REG" > registro_01.out 2> registro_01.err
```

Imprime la dirección y el byte en hexadecimal. Un registro del chip y un offset AXI son espacios distintos: no sumes la dirección de un registro lpGBT a A00E0000.

Ejemplo con el simulador, sin chip real:

```bash
~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister \
  --address lpgbt-simulator://emp_lpgbt_9 --read 0x000
```

El backend tiene bucles sin límite en clearIntr y al vaciar la FIFO, y el timeout de IRQ no los corta. La build guardada usa mapas V1; confirma qué versión de chip hay.

## Configuración, ADC y GPIO

Fuentes en `~/LpGbtSw/Demonstrators/` y ejecutables en `~/LpGbtSw/build/Demonstrators/`. Las opciones salen del gitingest; compáralas con la versión instalada.

| Programa | Qué hace |
|---|---|
| `LpGbtConfiguration/lpGbtConfiguration` | `--read` lee registros y crea un `.cnf` en la carpeta actual (hazlo en una carpeta nueva). `--write FILE` carga una configuración. |
| `LpGbtAdc/lpGbtAdc` | `--frequency F --iterations N`. Cada iteración convierte los ocho canales ADC internos del lpGBT; el ADC del front-end es otro. |
| `LpGbtGpio/lpGbtGpio` | `--pin 0…15 --read`; también `--write low/high` y `--direction input/output`. Confirma el pinout antes de cambiar niveles o dirección. |
| `RegisterTranslator/registerTranslator` | Ejemplo y benchmark que traduce nombres a direcciones. En la fuente adjunta corre en local, sin hablar con el chip. |

Ejemplos sueltos, con URI y pin ya elegidos. Los tres primeros mueven el chip, así que no pegues el bloque entero como si fuera una inicialización:

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

En `0922-Conectando a LPGBT.md` hay lecturas con `emp_lpgbt_10`, firmware 0.2v y PiGBT. La nota `0919-PostReunionEMP_team.md` cuenta errores al usar el canal por defecto o al pasar la URI sin opción; usa `-a` o `--address`. Antes de copiar una configuración, mira de qué montaje era.

## clkProgrammer

Ejecutable: `~/EMPToolsArtifacts/bin_TRENZ/clkProgrammer`; antes estaba instalado en `/usr/bin/clkProgrammer`. Fuente de la CLI: `~/emp-tools/empTools/si5345_i2c/main_si5345.cpp`; driver: `~/emp-tools/src/i2cDevices/si5345.cpp`.

| Opción | Efecto |
|---|---|
| `-i`, `--read_mon_info` | Lee por I2C la revisión y los estados LOS, OOF, LOL y flags. |
| `-c`, `--configure` | Programa la configuración Si5345 compilada dentro del ejecutable. |

Elige una sola acción. La fuente usa i2c-13 para TRENZ e i2c-1 para EMP, dirección 0x69. Comprueba el bus actual.

```bash
# Consultar la unidad no inicia el programador:
systemctl cat systemd-programclock.service
# Consulta I2C activa: solo con bus y página comprobados.
# sudo /usr/bin/clkProgrammer -i > reloj_01.out 2> reloj_01.err
# Programación: solo con configuración y alcance aprobados.
# sudo /usr/bin/clkProgrammer -c
```

Ojo con la fuente: `writeRegister` selecciona página y `readRegister` no. El postámbulo termina en la página 0B, así que la lectura de estado puede salir mal si quedó otra página puesta. Además, una excepción capturada puede terminar con retorno 0; revisa los logs, no solo `$?`.

## Firmware y scripts

Descripciones XSA: `~/epos/hw-description/`. BSP: `~/epos/epos-bsp/`. Cargador: `~/epos/etools/loadFirmare.sh` (sí, se escribe así). Copia en el repo: `atlas_emc/atlas_epos/etools/loadFirmare.sh`.

Para listar archivos en la placa: `bash ~/epos/etools/loadFirmare.sh -l`. Usa `-l` y `-h`; en esta versión el `getopts` rechaza las opciones largas. Cargar quita el overlay anterior y no hay vuelta atrás automática.

En el repo hay tres parejas DTBO/bit.bin en `atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/out_lpgbt_10_{cd,dd,direct}/`. Ponen PRBS en A00D y TGC en A00E. No sabemos qué relación tienen con `reading_1006.dtbo`.

| Script en `~` | Qué conviene saber |
|---|---|
| `read_lpgbt10.sh` | Espera sin límite a que cambie el byte bajo, aunque el resto de la palabra ya esté cambiando. |
| `watch_devmem.sh` | Se salta +0x18, incluye el header y oculta stderr. No lee los nueve grupos. |
| `sweep_clock.sh` | Escribe clk_thresh; el Si5345 no lo toca. Un fallo de lectura puede salir como cero. |
| `test_saturation.sh`, `1024/send_and_read.sh` | Escriben patrones en direcciones antiguas. A pesar del nombre, no miden tasa ni BER. |

## Mapas y versiones

El [mapa UIO de noviembre](15_OPERAR_EMP.md#bancos-y-mapa) tiene trece bancos de lectura y el bloque CMB. Esta tabla resume las variantes anteriores. Sirve para comparar archivos, no para elegir qué leer:

| Diseño | A00D0000 | A00E0000 |
|---|---|---|
| BD `emp_fw_TE0807`, Vivado 2023.2 | `axi_intc_1` | `axi_intc_2` |
| XSA xV23 Trenz / EMP del home | Interfaz e-link | Sin MEMRANGE declarado allí |
| Overlays `out_lpgbt_10_*` del repo | `Read_PRBS_regs` | `tgc_readUplink_regs` |

Para el lector TGC de nueve grupos: magic `0x00`, grupo g en `0x04+4g`, header `0x28` y threshold `0x2C`. Sin el RTL del capturador cargado no sabemos el packing, el rearme, la retención ni la coherencia. Nueve palabras no son necesariamente una trama, y nada indica que threshold esté en Hz.

## Guardar una lectura

Para guardar datos hoy, usa la [captura CSV con emp](15_OPERAR_EMP.md#guardar-una-captura). Lo de abajo usa la CLI anterior y guarda también stderr y el código de salida.

El supervisor está en `atlas_emc/docs/recuperacion/diagnostico/atlas_diagnostico.py`. Desde la raíz del repo en la placa:

```bash
DIAG="$PWD/docs/recuperacion/diagnostico/atlas_diagnostico.py"
python3 "$DIAG" inventario --lector ~/read_all_lpgbt/tgc_readuplink_cli \
  --salida inventario_01.json
python3 "$DIAG" preparar --inventario inventario_01.json --salida plan_01.json
```

Esto solo mira archivos y metadatos. El plan sale bloqueado: hay que llenar las pruebas en `validation` y las bibliotecas en `libraries`. Revisa build y mapa, ELF y dependencias, efectos de la lectura, que haya un solo operador y quién responde por la operación. El script no comprueba eso por ti. [Detalle del plan](12_SCRIPT_DIAGNOSTICO.md#4-s1-plan-de-lectura-revisable).

Después de esa revisión, la captura sí toca el hardware:

```bash
python3 "$DIAG" capturar --plan plan_01.json --salida sesion_01 \
  --fase inicial --muestras 3 --intervalo 5 --timeout 3 --autorizar-lecturas
python3 "$DIAG" informe --sesion sesion_01 --salida informe_01.md
```

Guarda toda la sesión, con errores y retornos. Un timeout no asegura que se corte una transacción AXI. No borres el lock para saltarte un fallo ni abras otro lector con un acceso pendiente. El informe se hace sin la placa. Para [comparar A y B](#comparar), carga los `.out` de fases conocidas, lejos de los cambios.

## Si los registros se quedan pegados

| Qué pasa | Qué mirar primero |
|---|---|
| El programa termina, pero devuelve lo mismo | Compara los 32 bits y cambia una señal conocida del FE. Puede ser un dato constante, uno retenido o el canal equivocado. |
| El script sigue vivo y el byte bajo no cambia | Revisa el `& 0xff` y mira la palabra completa. |
| No vuelve al prompt, pero Linux responde | Guarda PID, estado, wchan, mapeos y salida. No abras otro lector. |
| Se atasca `lpGbtRegister` | Revisa la ruta IC y sus esperas. La CLI TGC no espera IRQ, así que esa causa no le aplica. |
| UserData cambia pero AXI queda fijo | Revisa captura y rearme, si las dos cosas son del mismo canal y build. Para ver UserData hace falta instrumentación; la CLI no llega. |

Antes del reset guarda la última lectura buena, la primera mala, firmware y mapa, configuración, estímulo, PID, sesión y lock, y los estados que tengas. Anota qué se reinició exactamente. Que vuelva a funcionar no prueba que fuera una FIFO: el arranque también puede reprogramar el reloj.

## Qué falta confirmar

- Qué firmware está cargado y cómo se relacionan nombre, DTBO, bitstream y mapa.
- Qué configuración PiGBT o `.cnf` se usó de verdad, y el canal y la fuente del Serializer.
- Packing FE → e-link → grupos; trigger, rearme y efectos de la lectura.
- Si el fallo original era un proceso bloqueado o valores repetidos.

Hay varias familias de mapas y varias copias de cada ejecutable. El estado actual del hardware sigue sin comprobar.
