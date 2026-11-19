# Leer y guardar datos del EMP

## Leer en la Trenz

Con el firmware ya cargado y `capture/` en el home de la Trenz:

```bash
cd ~/capture
sudo ./emp doctor
sudo ./emp read
sudo ./emp watch --all --count 20 --interval-ms 100
```

`doctor` enumera los UIO y hace ocho lecturas del banco elegido. `read` muestra una observación completa. El último comando muestra 20 observaciones, aunque sean iguales. Correr los comandos por separado permite revisar cada salida.

Para instalar la herramienta, descarga [emp-capture.tar.gz](https://fbientrigo.github.io/atlas_emc/emp-capture.tar.gz) y copia el archivo al home en la Trenz. Si ya tienes `~/capture`, extrae el paquete en otro directorio para conservar tu configuración y tus corridas. Requiere Python 3.7+ y la `libuio.so` de la placa.

```bash
cd ~
tar -xzf emp-capture.tar.gz
cd capture
python3 test_capture.py
```

## Guardar una captura

Primero prueba una ráfaga corta. Usa el segundo `start` cuando termine la primera y quieras dejar una corrida nocturna.

```bash
cd ~/capture
sudo ./emp start --bursts 1 --count 1000 --interval-ms 1
./emp status
```

```bash
sudo ./emp start --delay-min 10 --bursts 96 --every-min 5 --count 10000 --interval-ms 1
./emp status
# Para terminar antes:
# ./emp stop
```

Los datos quedan en **`~/capture/runs/<corrida>/data.csv`**. `./emp status` muestra la ruta absoluta y el número de filas guardadas. La sesión sigue al cerrar SSH. `stop` conserva las filas escritas, incluida la última ráfaga parcial.

El plan nocturno escribe 960.000 filas, estima 158 MiB y dura unas 8 h 05 min si cumple la cadencia solicitada. Cada fila guarda las palabras crudas, tiempo Unix en ns y duración de la lectura. Linux determina el intervalo efectivo. Cada palabra se lee por separado, así que el CSV es un registro de sondeos MMIO.

## Diagnosticar lo que ves

| Síntoma o pregunta | Comando o comprobación |
|---|---|
| `watch` muestra una sola línea | De fábrica imprime la primera observación y luego cambios en `data_group_0…7`. Usa `watch --all --count 20 --interval-ms 100` para ver también cambios aislados en `data_group_8` y muestras repetidas. |
| Quiero guardar las transiciones 0…7 | `sudo ./emp watch \| tee cambios.log`. Se detiene con Ctrl+C. |
| Quiero contrastar `data_group_0` por dirección física | `sudo ./raw.sh 0xA00E0004` en el mapa por defecto. Con un patrón estable, compara con `sudo ./emp read`. |
| Quiero saber qué bancos cambian | `sudo ./emp doctor --all` comprueba los bancos de observación enumerados. Para leer uno con `read`, `watch` o `start`, configura su nombre, base y offsets en un JSON y pásalo con `--config`. |
| Quiero comprobar que el chip responde por IC | `sudo ./emp doctor --probe 10`. Es una transacción activa de control e IRQ. Úsala con el canal IC libre. |
| Los grupos 0…7 siguen en cero | Aplica un patrón A/B/A conocido desde el front-end. Lee el banco que sigue ese estímulo y verifica el cableado en Vivado. |

**En la Trenz, el 19 de noviembre de 2026**, se enumeraron 13 interfaces IC y 13 bancos de observación. En `tgc_readUplink_regs` (`0xA00E0000`), sólo cambió `data_group_8` entre ocho lecturas. Los grupos 0…7, el header y magic salieron en cero. `raw.sh` también devolvió cero para el grupo 0. `clk_thresh` leyó `0xB0` en ese montaje.

En `doctor --probe all`, sólo `emp_lpgbt_10` devolvió un byte verificable, `0xAE` para `0x1D7`. Las otras 12 consultas terminaron en `waitIntr` con `rc=-6`. Esto confirma una respuesta de control por IC en el enlace 10. La correspondencia con un banco de datos y la recepción del front-end se comprueban con el estímulo A/B/A.

[Comparar dos salidas de emp read](#comparar) · [Investigar registros pegados](10_BLOQUEO_LECTURAS.md)

## Bancos y mapa

| Bloque | Nombre UIO | Base física |
|---|---|---|
| Banco por defecto | `tgc_readUplink_regs` | `0xA00E0000` |
| Bancos 1 a 12 | `tgc_readUplink_regs_N` | `0xA00E0000 + N × 0x10000` |
| Banco 10 | `tgc_readUplink_regs_10` | `0xA0180000` |
| Captura de eventos CMB | `cmb_event_regs_0` | `0xA01B0000` |

El número `/dev/uioN` puede cambiar con el overlay. El lector busca por nombre y comprueba la base. `emp_lpgbt_10` identifica el controlador IC, mientras que `tgc_readUplink_regs_10` identifica un banco MMIO.

En el mapa por defecto, los offsets en bytes son `magic +0x00`, grupos 0…8 en `+0x04…+0x24`, `data_header +0x28` y `clk_thresh +0x2C`. La lectura de `clk_thresh` en la sesión sólo registra el valor observado.

El banco CMB se enumeró en la sesión. Su mapa AirHDL rev29 define el control y la memoria de eventos. Para validar esa ruta en placa se necesita observar la publicación de un evento (estado y `event_id`) y leer su memoria con el protocolo del diseño.

## Código y mapas

| Qué necesitas | Carpeta |
|---|---|
| CLI `emp`, `raw.sh`, JSON y pruebas | [capture](https://github.com/fbientrigo/atlas_emc/tree/main/capture) |
| Export AirHDL rev29 y lector de snapshot uplink | [airhdl](https://github.com/fbientrigo/atlas_emc/tree/main/airhdl) |
| Fuentes recompilables de `tgc_readuplink_cli` y `readprbs_cli` | [puzzledWizards/compilados](https://github.com/fbientrigo/atlas_emc/tree/main/puzzledWizards/compilados) |

[Notas de firmware, reloj y herramientas](14_NOTAS_DE_TRABAJO.md) · [Prueba de recepción del front-end](00_GUIA_CAMPO.md)
