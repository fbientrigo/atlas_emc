# Leer y guardar datos del EMP

## Leer en la Trenz

Con el firmware cargado y `capture/` en el home de la Trenz:

```bash
cd ~/capture
sudo ./emp doctor
sudo ./emp read
sudo ./emp watch --all --count 20 --interval-ms 100
```

`doctor` lista los UIO y hace ocho lecturas del banco elegido. `read` muestra una observación completa. `watch` muestra 20 observaciones, aunque se repitan. Corre los comandos de a uno para revisar cada salida.

Para instalar la herramienta, descarga [emp-capture.tar.gz](https://fbientrigo.github.io/atlas_emc/emp-capture.tar.gz) y cópialo al home de la Trenz. Si ya tienes `~/capture`, extrae el paquete en otra carpeta para no perder tu configuración ni tus corridas. Necesita Python 3.7 o más y la `libuio.so` de la placa.

```bash
cd ~
tar -xzf emp-capture.tar.gz
cd capture
python3 test_capture.py
```

## Guardar una captura

Prueba primero con una ráfaga corta. Cuando termine, usa el segundo `start` para dejar una corrida nocturna.

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

Los datos quedan en `~/capture/runs/<corrida>/data.csv`. `./emp status` muestra la ruta completa y cuántas filas lleva. La corrida sigue aunque cierres SSH. `stop` conserva lo escrito, incluida la última ráfaga a medias.

El plan nocturno escribe 960.000 filas, unos 158 MiB, y dura cerca de 8 h 05 min si se cumple la cadencia pedida. Cada fila tiene las palabras crudas, el tiempo Unix en ns y lo que tardó la lectura. El intervalo real lo decide Linux. Como cada palabra se lee por separado, el CSV es un registro de sondeos MMIO.

## Diagnosticar lo que ves

| Qué ves o qué quieres saber | Qué hacer |
|---|---|
| `watch` muestra una sola línea | Por defecto imprime la primera observación y después solo los cambios en `data_group_0…7`. Usa `watch --all --count 20 --interval-ms 100` para ver también `data_group_8` y las muestras repetidas. |
| Guardar los cambios de 0…7 | `sudo ./emp watch \| tee cambios.log`. Se corta con Ctrl+C. |
| Comparar `data_group_0` leyendo la dirección física | `sudo ./raw.sh 0xA00E0004` con el mapa por defecto. Con un patrón estable, compáralo con `sudo ./emp read`. |
| Saber qué bancos cambian | `sudo ./emp doctor --all` revisa todos los bancos. Para usar uno con `read`, `watch` o `start`, pon su nombre, base y offsets en un JSON y pásalo con `--config`. |
| Saber si el chip responde por IC | `sudo ./emp doctor --probe 10`. Hace una transacción de control con IRQ, así que úsalo con el canal IC libre. |
| Los grupos 0…7 siguen en cero | Aplica un patrón A/B/A conocido desde el front-end, lee el banco que siga ese estímulo y revisa el cableado en Vivado. |

En la Trenz, el 19 de noviembre de 2026, aparecieron 13 interfaces IC y 13 bancos de observación. En `tgc_readUplink_regs` (`0xA00E0000`), entre ocho lecturas solo cambió `data_group_8`. Los grupos 0…7, el header y magic dieron cero, y `raw.sh` también dio cero para el grupo 0. `clk_thresh` leyó `0xB0` en ese montaje.

Con `doctor --probe all`, solo `emp_lpgbt_10` devolvió un byte comprobable: `0xAE` en `0x1D7`. Las otras 12 consultas terminaron en `waitIntr` con `rc=-6`. O sea, el enlace 10 responde por IC. Falta saber qué banco de datos le corresponde y si llegan datos del front-end; eso lo dice el estímulo A/B/A.

[Comparar dos salidas de emp read](#comparar) · [Investigar registros pegados](10_BLOQUEO_LECTURAS.md)

## Bancos y mapa

| Bloque | Nombre UIO | Base física |
|---|---|---|
| Banco por defecto | `tgc_readUplink_regs` | `0xA00E0000` |
| Bancos 1 a 12 | `tgc_readUplink_regs_N` | `0xA00E0000 + N × 0x10000` |
| Banco 10 | `tgc_readUplink_regs_10` | `0xA0180000` |
| Captura de eventos CMB | `cmb_event_regs_0` | `0xA01B0000` |

El número de `/dev/uioN` puede cambiar con el overlay, por eso el lector busca por nombre y comprueba la base. Ojo con los nombres: `emp_lpgbt_10` es el controlador IC y `tgc_readUplink_regs_10` es un banco MMIO.

En el mapa por defecto, los offsets en bytes son: `magic +0x00`, grupos 0…8 en `+0x04…+0x24`, `data_header +0x28` y `clk_thresh +0x2C`. El valor de `clk_thresh` de la sesión solo quedó anotado.

El banco CMB apareció en la sesión. Su mapa AirHDL rev29 define el control y la memoria de eventos. Para probar esa ruta en la placa hay que ver cómo se publica un evento (estado y `event_id`) y leer su memoria con el protocolo del diseño.

## Código y mapas

| Qué necesitas | Carpeta |
|---|---|
| CLI `emp`, `raw.sh`, JSON y pruebas | [capture](https://github.com/fbientrigo/atlas_emc/tree/main/capture) |
| Export AirHDL rev29 y lector de snapshot uplink | [airhdl](https://github.com/fbientrigo/atlas_emc/tree/main/airhdl) |
| Fuentes de `tgc_readuplink_cli` y `readprbs_cli` para recompilar | [puzzledWizards/compilados](https://github.com/fbientrigo/atlas_emc/tree/main/puzzledWizards/compilados) |

[Notas de firmware, reloj y herramientas](14_NOTAS_DE_TRABAJO.md) · [Prueba de recepción del front-end](00_GUIA_CAMPO.md)
