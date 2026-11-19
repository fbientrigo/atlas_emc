# Captura de registros EMP

[Guía de operación en GitHub Pages](https://fbientrigo.github.io/atlas_emc/) · [Descargar emp-capture.tar.gz](https://fbientrigo.github.io/atlas_emc/emp-capture.tar.gz)

Desde la cuenta que hará la adquisición, copiar `emp-capture.tar.gz` al home de la Trenz y extraerlo. Se necesita Linux y Python 3.7 o superior (AlmaLinux 9 trae Python 3.9). Para acceder al hardware se usa la `libuio.so` de la placa. El manifiesto archivado la ubica en `/usr/lib64/libuio.so`. La simulación usa sólo la biblioteca estándar de Python.

```bash
cd ~
tar -xzf emp-capture.tar.gz
cd ~/capture
python3 test_capture.py
sudo ./emp doctor
sudo ./emp read
```

## Para mirar los registros

```bash
sudo ./raw.sh                        # busybox devmem 0xA00E0004 32
sudo ./raw.sh 0xA00E0004 0xA00E0008 # data_group_0 y data_group_1 del primer banco
sudo ./emp watch                     # hasta Ctrl+C
sudo ./emp watch | tee cambios.log
sudo ./emp watch --all --count 100   # imprime 100 observaciones consecutivas
```

`raw.sh` recibe direcciones físicas. La dirección por defecto corresponde a `data_group_0` cuando el banco está en `0xA00E0000`. Para contrastar `raw.sh` con `emp read`, usar un patrón constante y comparar la misma palabra. Con datos variables son dos lecturas en instantes distintos.

`watch` abre el banco una vez. Imprime la primera observación y luego cada transición en las palabras de `compare`, incluido el retorno a cero. Por ejemplo, para A, A, B, A aparecen las muestras 1, 3 y 4. Por defecto compara las palabras crudas `data_group_0` a `data_group_7` completas. Un cambio aislado en `data_group_8`, `data_header` o `clk_thresh` queda fuera del disparo. La salida muestra todas las palabras configuradas. El índice cuenta sondeos. Sin `--interval-ms` el bucle corre sin pausa intencional. Imprimir en consola también consume tiempo.

## Para dejarlo una noche

```bash
cd ~/capture
sudo ./emp start --delay-min 10 --bursts 96 --every-min 5 --count 10000 --interval-ms 1
./emp status
./emp stop                            # sólo para terminar antes
```

La primera ráfaga empieza en 10 minutos. Las siguientes empiezan cada 5 minutos desde el primer inicio programado. Cada ráfaga guarda **todas** las observaciones, incluso iguales. Son 960.000 filas. Con la cadencia solicitada, la última muestra cae aproximadamente **8 h 05 min 10 s** después del comando. Sin espera inicial son **7 h 55 min 10 s**. El presupuesto inicial del CSV con las 12 palabras es unos **158 MiB**. Al avanzar, la estimación usa los bytes por fila medidos. Para una sola ráfaga usar `--bursts 1`.

`start` deja el lector en una sesión independiente de la terminal. Se puede cerrar SSH; un reinicio del EMP interrumpe la captura. Si el usuario ya tiene acceso UIO, se puede omitir `sudo`. Con `sudo ./emp start` el programa abre UIO y vuelve al UID y GID del operador antes de crear los datos. Ejecutar los comandos desde la misma instalación. El bloqueo evita dos capturas nocturnas de esa instalación.

`status` muestra ráfaga, filas volcadas al CSV, bytes actuales, proyección para el plan completo, hora local de término y ruta absoluta. Se actualiza aproximadamente cada segundo durante una ráfaga y al cambiar de estado. En una espera larga la marca de actualización queda en el inicio de la espera. `stop` conserva la última ráfaga parcial. Si el lector murió sin cerrar, `status` lo indica. Consultar `worker.log` y el CSV de esa corrida.

Los datos quedan en **`~/capture/runs/<corrida>/data.csv`**. Cada fila lleva número de ráfaga, muestra dentro de la ráfaga, tiempo Unix en ns al comenzar la lectura, duración de la lectura en ns y las palabras hexadecimales. `plan.json` conserva una copia del mapa usado, el backend y los parámetros. `status.json` conserva el último avance. `runs/latest` contiene el nombre de la corrida más reciente.

El intervalo de 1 ms se solicita al planificador de Linux. El programa usa un reloj monótono, conserva la cantidad de muestras y, si se atrasa, evita acumular lecturas de recuperación dentro de la ráfaga. Para medir la cadencia efectiva, restar los `unix_ns` de filas sucesivas **de la misma ráfaga**, teniendo en cuenta posibles ajustes del reloj del sistema. Si la carga prolonga una ráfaga más allá del siguiente inicio, la siguiente empezará al acabar la anterior.

## Cambiar lo que se lee

Editar **`registers.json`** o pasar una copia mediante `--config`. Ejemplo para observar sólo la primera palabra de otro banco que aparece en el inventario FDR. Guardar el ejemplo como `banco1.json` y ejecutar `sudo ./emp read --config banco1.json`. El mismo argumento funciona con `watch`, `start` y `doctor`.

```json
{
  "device": "tgc_readUplink_regs_1",
  "expected_base": "0xA00F0000",
  "registers": {"data_group_0": "0x04"},
  "compare": ["data_group_0"]
}
```

`device` es el nombre publicado en sysfs. `expected_base` comprueba el mapa contra el hardware enumerado. Los valores de `registers` son **offsets en bytes**, alineados a cuatro. El orden del JSON fija el de lectura y el de las columnas. Al quitar una palabra, quitarla también de `compare` si estaba allí. En el mapa entregado, `magic` está en +0x00, los grupos 0–8 en +0x04…+0x24, `data_header` en +0x28 y `clk_thresh` en +0x2C.

Cada observación reúne varias transacciones MMIO. El FPGA puede actualizar los registros entre dos lecturas, y pueden pasar frames entre sondeos. Para demostrar coherencia de un evento hay que usar el protocolo del bloque FIFO. El banco `cmb_event_regs_0` aparece en el inventario. Su [mapa AirHDL rev29](../airhdl/) está en el repositorio. `emp` lee los bancos de observación. Mantener estable el firmware durante la lectura.

## Diagnóstico en la placa

| Comando | Qué comprueba |
|---|---|
| `sudo ./emp doctor` | Enumera las interfaces IC y los bancos publicados. Lee ocho veces cada palabra configurada del banco seleccionado y muestra cuáles variaron. |
| `sudo ./emp doctor --all` | Repite la prueba en cada banco `tgc_readUplink_regs*` reconocido del despliegue, en procesos separados. Un banco que termina con SIGBUS queda identificado. |
| `sudo ./emp doctor --probe 10` | Además pide a `lpGbtRegister` leer 0x1D7 por `emp_lpgbt_10`. |
| `sudo ./emp doctor --probe all` | Prueba secuencialmente cada interfaz IC enumerada. Informa cada respuesta y cada fallo; el barrido IC tiene éxito si al menos una responde. |
| `./emp doctor --mock` | Prueba el lector simulado sin acceso a la placa. |

El diagnóstico por banco sólo llama a lecturas de registros. `--probe` hace una **transacción activa**. Usarlo cuando el canal IC esté libre. El backend existente configura registros AXI de control e IRQ y consume la FIFO de respuesta. La ruta al ejecutable está en `lpGbtRegister` dentro del JSON. La comprobación exige salida exitosa, traza de respuesta con al menos siete palabras y coincidencia del byte que devuelve la CLI archivada. Una revisión del ejecutable que imprima otra traza se informa como respuesta sin verificar.

Un banco constante puede estar recibiendo un patrón constante. Para comprobar la ruta física, aplicar dos patrones conocidos en el front-end y observar qué banco los sigue. El número del banco de lectura y el índice de `emp_lpgbt_N` pertenecen a bloques distintos; su correspondencia depende del cableado en el diseño de Vivado. Un timeout IC tampoco distingue por sí solo un problema de enlace de uno de IRQ.

## Dónde estaba cada cosa

Las rutas con `~` corresponden a `/home/tgc_cms` en los inventarios recibidos.

| Material recibido | Ruta en la Trenz | Evidencia |
|---|---|---|
| `tree(1).txt` | `~/leeradc_alpha/leer_adc.sh`, `~/scripts/sweep_clock.sh`, `~/scripts/watch_devmem.sh` | Ubica los scripts y sus logs. El listado no contiene sus cuerpos. |
| `read.tar(3).gz` | `~/read_all_lpgbt/` | CLI, binario y clase generada `TgcReadUplink`. Los tres fuentes activos son idénticos a los de la inspección. |
| `emp-uplink.tar(4).gz` | `~/emp-uplink-acquisition/` | Copia más completa del lector anterior. El mapa está en `src/core.*` y `src/backend.cpp`. Los `configs/*.cfg` definen cómo interpretar los e-links. Incluye `tools/operate.py`, wrappers, pruebas y ejemplos. Los 19 archivos comunes con la inspección son idénticos byte a byte. |
| `emp-inspection.V1JLCn6V.tar(2).gz` | `~/bursts.sh`, `~/bursts_finde.sh`, `~/init_emp.sh`, `~/libuio/` | Scripts y fuentes dentro de `files/`. El primer script programa 96 ráfagas de 10.000 lecturas a 1 ms cada 5 min. El segundo agrega telemetría y compresión. La inicialización de firmware y reloj vive en `init_emp.sh`. |
| `emp-firmware-comparison.tar(2).gz` | Imágenes para comparar con las desplegadas en `/lib/firmware/` | Dos pares de bitstream y overlay, `reading_1006` y `emp`. El par `reading_1006` es idéntico al de la inspección. |
| `emp_fdr_inventory.tar(1).gz` | `~/emp-deploy-final-1117/read-config.json`, `software/cmb_event_regs.json` y `software/coherent-capture/` dentro de ese despliegue | Inventarios de rutas y mapas. Ahí figuran `emp_acq_capture.cpp` y `uplink_capture_regs.cpp`. El JSON y las fuentes de captura del 17-11 están en [airhdl](../airhdl/). |
| `lpgbt.tar.gz` dentro de `emp-uplink.tar(4).gz` | `~/LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister` | El paquete anidado contiene LpGbtSw. La ruta del ejecutable está confirmada por `deployed_artifacts.txt`. |

Con `reading_1006.dtbo`, la inspección registró `tgc_readUplink_regs` en `uio18`, base `0xA00E0000`. El inventario FDR registró ese mismo banco en `uio19` y `emp_lpgbt_9` en `uio18`. También registró 13 bancos de lectura entre `0xA00E0000` y `0xA01A0000`, e incrementos de `0x10000`. El bloque `cmb_event_regs_0` figura en `0xA01B0000`.

## Referencia del 19-11-2026

En la Trenz, `doctor`, `read`, `raw.sh` y `watch` leyeron el banco por defecto. Variaba `data_group_8` y los grupos 0…7 estaban en cero, por lo que el monitor por cambios mostró solo la primera fila. En la prueba IC sólo respondió `emp_lpgbt_10` con `0xAE` para `0x1D7`. La captura nocturna y la procedencia del payload requieren su propia prueba en placa.

## Archivos que se mantienen

| Archivo | Función |
|---|---|
| `emp` | Comandos del operador, lectura única y monitor de cambios. |
| `raw.sh` | Lectura física con BusyBox, independiente de Python, JSON y libuio. |
| `registers.json` | Banco, direcciones relativas y comparación. |
| `registers.py` | Valida el mapa, abre libuio una vez y usa `uio_read32` por palabra, como la clase C++ anterior. Incluye el lector simulado. |
| `night.py` | Ráfagas, sesión en segundo plano, archivos, avance y parada. |
| `doctor.py` | Lecturas por banco y prueba IC opcional. |
| `test_capture.py` | Pruebas reproducibles en copia temporal. |

Esta herramienta genera un CSV crudo con su propio encabezado. Los decodificadores y las corridas antiguas siguen en `~/emp-uplink-acquisition/` y `~/acquisitions/`, respectivamente. La inicialización, compresión y telemetría del sistema siguen disponibles en las herramientas anteriores.
