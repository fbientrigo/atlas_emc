# AirHDL y captura coherente

| Carpeta | Contenido |
|---|---|
| [cmb_event_regs_rev29](cmb_event_regs_rev29/) | Export original AirHDL del 17-11-2026. Incluye JSON, RTL, headers C/C++ y documentación generada. |
| [coherent-capture](coherent-capture/) | Fuentes y Makefile de `emp_acq_capture` y sus pruebas, recuperadas del paquete `emp-deploy-final-1117`. Su protocolo BUSY/SEQ corresponde al banco uplink 10. |
| [CLIs PuzzledLizardWizard](../puzzledWizards/compilados/) | Lector TGC y control PRBS con sus mapas y recetas de compilación. |

El [JSON rev29](cmb_event_regs_rev29/cmb_event_regs.json) coincide byte a byte con el incluido en `emp-deploy-final-1117/software/`. La revisión 29 mueve la base declarada de `0xA00D0000` a `0xA01B0000` y conserva los offsets de la rev28.

| Interfaz | Mapa del paquete del 17-11 |
|---|---|
| Evento CMB | `cmb_event_regs_0`, base `0xA01B0000`, ventana de 64 KiB. Firma esperada `0x454D5001`. La memoria empieza en `+0x1000` y termina antes de `+0xB080`. |
| Snapshot de uplink 10 | `tgc_readUplink_regs_10`, base `0xA0180000`. El lector exige firma `0xCA970003` y comprueba BUSY/SEQ. |

Los headers `cmb_event_regs.h/.hpp` forman parte del export AirHDL. El programa `emp_acq_capture` lee el snapshot del uplink 10. Para compilarlo y probarlo sin placa:

```bash
make -C airhdl/coherent-capture test
```

## Capturar en la Trenz

El banco 10 pasó la prueba del 19-11-2026 con 1001 snapshots coherentes en 10 segundos, sin saltos de SEQ ni inconsistencias. La prueba del controlador de eventos CMB sigue pendiente.

Guarda [captura10.sh](coherent-capture/captura10.sh) junto al ejecutable existente. Desde esa carpeta:

```bash
bash captura10.sh check
bash captura10.sh prueba
bash captura10.sh estado
bash captura10.sh resumen
# Tras verificar que la prueba terminó bien:
bash captura10.sh noche
```

Las corridas quedan en `~/capturas/uplink10/`. Cada CSV contiene dos frames completos consecutivos y los cuatro bytes consecutivos `d0…d6` del canal 0 de cada grupo. Cada ejecución programada del FPGA genera un snapshot a 100 Hz. Para evaluar continuidad entre snapshots, consulta SEQ. Para evaluar alternancia dentro de un snapshot, usa el resumen por grupo. La captura de ocho horas necesita aproximadamente 0,9 GB.

## Graficar una corrida terminada

Usa [graficar10.py](coherent-capture/graficar10.py) con Python 3 y Matplotlib 3.6 o posterior. Se puede instalar en un entorno virtual del usuario:

```bash
python3 -m venv "$HOME/.venvs/emp-plot"
"$HOME/.venvs/emp-plot/bin/python" -m pip install 'matplotlib>=3.6'
```

Pasa la ruta que mostró `captura10.sh estado`:

```bash
"$HOME/.venvs/emp-plot/bin/python" graficar10.py /RUTA/A/LA/CORRIDA
```

El ZIP `graficos.zip` queda junto a `data.csv`. Contiene cuatro PNG (adquisición y saltos, estabilidad AAAA/ABAB en el tiempo, diferencias A/B por palabra y distribución de bytes por fase), tablas CSV y un resumen. Por defecto agrega en intervalos de 60 s. Usa `--intervalo 5` para una prueba corta. El ZIP contiene los resultados derivados y el log, mientras que el CSV crudo queda en la carpeta de la corrida.

## Desvíos del patrón en g0/c0 y g1/c0

`ruido10.py` usa el mismo entorno de Python y Matplotlib:

```bash
"$HOME/.venvs/emp-plot/bin/python" ruido10.py /RUTA/A/LA/CORRIDA --g0 18:80 --g1 40:0C
```

Las dos referencias son los patrones crudos dominantes registrados en la prueba. Si la referencia medida cambia, pasa los dos bytes nuevos en orden temporal. El resultado queda en `ruido_g0_g1.zip`, junto al CSV. Incluye la gráfica temporal, los conteos por intervalo y el resumen. Usa `--intervalo 5` para revisar una prueba corta.

Un ABAB con la fase opuesta exacta se cuenta aparte. Un desvío de ambos canales en la misma ventana puede afectar frames distintos. El conteo de mismo frame incluye sólo las ventanas donde la fase más cercana es única en ambos canales. Para evaluar coincidencias se compara con el número esperado por independencia dentro de cada intervalo. Esta comparación es descriptiva y los cuatro frames de cada ventana no cubren todo el enlace.
