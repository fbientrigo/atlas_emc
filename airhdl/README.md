# AirHDL y captura coherente

| Carpeta | Contenido |
|---|---|
| [cmb_event_regs_rev29](cmb_event_regs_rev29/) | Export original AirHDL del 17-11-2026. Incluye JSON, RTL, headers C/C++ y documentación generada. |
| [fifo-acquisition](fifo-acquisition/) | Lectura y guardado de bloques FIFO → RAM del uplink 10 mediante el banco CMB. |
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

Para terminar la última corrida antes del plazo, usa `bash captura10.sh stop`. El capturador cierra el CSV y el comando muestra el código de salida. Si necesitas detener otra corrida, añade la ruta de su carpeta.

## Ver g0/c0 y g1/c0 en vivo

Desde la raíz de la copia Git en la EMP, con el capturador libre:

```bash
git pull --ff-only
./airhdl/coherent-capture/quick_watch.sh
```

El script compila `emp_acq_capture` si hace falta, pide `sudo` y abre una lectura en vivo. Los datos pasan al visor sin guardar un CSV. Con Ctrl+C se cierra esta lectura.

Si vuelve al prompt sin mostrar frames, revisa el mensaje de `emp_acq_capture`. Para probar el visor con datos simulados y comprobar la lectura del FPGA por separado, ejecuta desde la raíz del repo:

```bash
./airhdl/coherent-capture/quick_watch.sh --simulate
sudo ./airhdl/coherent-capture/emp_acq_capture --check --check-seconds 3
```

La vista muestra `a0`, `b0`, `d0`, `a1`, `b1` y `d1` en hexadecimal. Las palabras `a` y `b` corresponden a los frames A y B. Las palabras `d` empaquetan los cuatro bytes de c0, que se muestran también por separado, de N a N+3. El visor cuenta las ventanas con desvíos y los bytes distintos en los **últimos 60 segundos** según el reloj de captura. Una ventana con dos bytes distintos suma un desvío y dos bytes. BABA exacto se cuenta aparte. El visor conserva las referencias históricas `--g0 18:80 --g1 40:0C`. Para el patrón actual usa `quick_watch.sh --g0 C4:00 --g1 0C:40`.

Si ya hay una captura guardando un CSV, se puede seguir su salida sin abrir un lector adicional. Desde `airhdl/coherent-capture`:

```bash
bash captura10.sh watch
```

`watch` usa el CSV de la última corrida. Puedes indicar otra carpeta como argumento. Ctrl+C cierra el visor y la captura sigue guardando datos.

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

Los PNG, tablas CSV y resumen quedan en `graficos/`, junto al archivo de entrada. Los valores se muestran tal como vienen del CSV.

Para ejecutar los tres análisis en Windows PowerShell desde la raíz del repo:

```powershell
git pull --ff-only
py -3 -m pip install "matplotlib>=3.6" numpy
py -3 .\airhdl\coherent-capture\analizar10.py "C:\Users\Asus\Desktop\datos_1124\data.csv" --g0 C4:00 --g1 0C:40
```

Se generan carpetas `graficos/`, `resultados_ruido/` y `resultados_crosstalk/`. Las figuras se actualizan al repetir el comando. Los archivos ZIP de ejecuciones anteriores pueden contener figuras antiguas.

## Vecinos y posibles acoplamientos

`crosstalk10.py` estudia g0/c1..c3 y g1/c1..c3. Asume el mapa de 320 Mb/s, con c0 en bits 7:0, c1 en 15:8, c2 en 23:16 y c3 en 31:24 de cada palabra A/B. Cada vecino dispone de dos frames por snapshot. El código excluye READY incompleto y discrepancias entre el c0 de A/B y los primeros bytes de d0/d1.

- `01_vecinos_histogramas.png` compara la distribución del vecino para cada valor de c0.
- `02_asociacion_bits.png` muestra la diferencia de ocupación de cada bit en puntos porcentuales, con escala fija de −100 a +100.
- `03_vecinos_tiempo.png` muestra estabilidad respecto a la moda de cada fase A/B y distancia entre distribuciones por minuto.
- `04_saltos_seq.png` localiza cada salto y muestra cuánto tiempo transcurre entre ellos. `saltos_seq.csv` conserva tiempos UTC y conteos exactos.

La distancia de variación total es 0.5 × suma de diferencias absolutas de probabilidades. Vale cero para distribuciones idénticas y uno para distribuciones sin soporte común. Los CSV conservan histogramas por minuto, fase A/B y estado de c0, con sus denominadores. El estado “otro” conserva los frames cuyo c0 difiere de ambas referencias.

Estos resultados describen asociación. Un patrón alternante puede confundir estado de c0 con fase A/B. Para atribuir un efecto a crosstalk hace falta una captura de control con c0 fijo y otra alternante, manteniendo los patrones vecinos y la configuración. Las modas se estiman de esta corrida y describen variación. Para contar errores físicos hacen falta referencias transmitidas independientes. La dependencia temporal entre frames requiere considerar bloques antes de realizar inferencia estadística.

## Desvíos del patrón en g0/c0 y g1/c0

`ruido10.py` usa el mismo entorno de Python y Matplotlib:

```bash
"$HOME/.venvs/emp-plot/bin/python" ruido10.py /RUTA/A/LA/CORRIDA --g0 C4:00 --g1 0C:40
```

Las referencias son los dos bytes crudos observados con mayor frecuencia, en orden temporal. Los resultados se guardan en `resultados_ruido/`, junto al CSV. Usa `--intervalo 5` para una prueba corta.

- `histograma_valores.png`, `fig4_hist_eje0.png` y `fig4_hist_pct.png` muestran el histograma logarítmico, lineal desde cero y porcentual.
- `fig1A_composicion_apilada.png` y `fig1B_valor_vs_hora.png` muestran la composición y los valores por intervalo. Los porcentajes se calculan con los bytes de las ventanas válidas del intervalo.
- `fig2_bloques.png` muestra el byte crudo y con reverse alrededor del primer desvío. Si la corrida no tiene desvíos, muestra las últimas ventanas válidas.
- `fig3_tiempos.png` muestra el mayor intervalo entre snapshots guardados y las oportunidades omitidas según SEQ.
- `ruido_g0_g1.png` mantiene el análisis de desvíos, fases y coincidencias.

Cada ventana válida aporta cuatro bytes por canal. Las figuras usan los bytes del CSV directamente, incluidos C4, 00, 0C y 40. `histograma_valores.csv` conserva los conteos por posición de frame de N a N+3. El histograma agrupa bytes, de modo que un patrón alternante perfecto aporta 50 % de cada valor. Las referencias por defecto de los análisis son C4:00 y 0C:40, correspondientes a la corrida del 23–24 de noviembre. Para corridas anteriores hay que pasar su patrón explícitamente. Los máximos de tiempo se refieren a la separación entre snapshots guardados. El archivo actual carece del registro diagnóstico g8 y de tiempos individuales de lectura.

Un ABAB con la fase opuesta exacta se cuenta aparte. Un desvío de ambos canales en la misma ventana puede afectar frames distintos. El conteo de mismo frame incluye sólo las ventanas donde la fase más cercana es única en ambos canales. Para evaluar coincidencias se compara con el número esperado por independencia dentro de cada intervalo. Esta comparación es descriptiva y los cuatro frames de cada ventana no cubren todo el enlace.

Las figuras usan etiquetas de unidades, ejes comparables y colores accesibles siguiendo las recomendaciones de [Nature sobre preparación de figuras](https://research-figure-guide.nature.com/figures/preparing-figures-our-specifications/).
