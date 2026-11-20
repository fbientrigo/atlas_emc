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

## Ver g0/c0 y g1/c0 en vivo

Desde la raíz de la copia Git en la EMP, con el capturador libre:

```bash
git pull --ff-only
./airhdl/coherent-capture/quick_watch.sh
```

El script compila `emp_acq_capture` si hace falta, pide `sudo` y abre una lectura en vivo. Los datos pasan al visor sin guardar un CSV. Con Ctrl+C se cierra esta lectura.

La vista muestra N a N+3 en crudo. Cuenta las ventanas con desvíos y los bytes distintos en los **últimos 60 segundos** según el reloj de captura. Una ventana con dos bytes distintos suma un desvío y dos bytes. BABA exacto se cuenta aparte. Los contadores recientes expiran incluso si dejan de llegar datos. Las referencias por defecto son `--g0 18:80 --g1 40:0C`. Se pueden pasar otros valores al script.

Si ya hay una captura guardando un CSV, se puede seguir su salida sin abrir un lector adicional. Desde `airhdl/coherent-capture`:

```bash
corrida=$(cat "$HOME/capturas/uplink10/ultima")
tail -n 0 -F "$corrida/data.csv" | python3 ver10.py --segundos 60
```

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

Las referencias son los dos bytes crudos observados con mayor frecuencia, en orden temporal. Los resultados se guardan en `resultados_ruido/`, junto al CSV. Usa `--intervalo 5` para una prueba corta.

- `histograma_valores.png`, `fig4_hist_eje0.png` y `fig4_hist_pct.png` muestran el histograma logarítmico, lineal desde cero y porcentual.
- `fig1A_composicion_apilada.png` y `fig1B_valor_vs_hora.png` muestran la composición y los valores por intervalo. Los porcentajes se calculan con los bytes de las ventanas válidas del intervalo.
- `fig2_bloques.png` muestra el byte crudo y con reverse alrededor del primer desvío. Si la corrida no tiene desvíos, muestra las últimas ventanas válidas.
- `fig3_tiempos.png` muestra el mayor intervalo entre snapshots guardados y las oportunidades omitidas según SEQ.
- `ruido_g0_g1.png` mantiene el análisis de desvíos, fases y coincidencias.

Cada ventana válida aporta cuatro bytes por canal. Las figuras de valores aplican reverse dentro de cada byte, de MSB a LSB. `histograma_valores.csv` conserva ambas representaciones y los conteos por posición de frame de N a N+3. Los máximos de tiempo se refieren a la separación entre snapshots guardados. El archivo actual carece del registro diagnóstico g8 y de tiempos individuales de lectura.

Un ABAB con la fase opuesta exacta se cuenta aparte. Un desvío de ambos canales en la misma ventana puede afectar frames distintos. El conteo de mismo frame incluye sólo las ventanas donde la fase más cercana es única en ambos canales. Para evaluar coincidencias se compara con el número esperado por independencia dentro de cada intervalo. Esta comparación es descriptiva y los cuatro frames de cada ventana no cubren todo el enlace.
