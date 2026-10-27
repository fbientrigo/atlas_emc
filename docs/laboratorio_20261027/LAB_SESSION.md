# Laboratorio: 120 minutos con puertas de validación

[Inicio](START_HERE.md) · [Briefing](ENGINEER_BRIEFING.md) · [Referencia rápida](QUICK_REFERENCE.md)

**Resultado buscado:** una captura trazable y una prueba de respuesta al FE. Si falta la identidad o la semántica de lectura, el resultado válido es un bloqueo localizado con la evidencia necesaria para resolverlo. No se ha probado este procedimiento en el equipo.

## Preparación y reglas comunes

Un operador controla hardware; el otro registra predicciones, tiempos y evidencia. Abrir estos documentos y el respaldo en el ordenador de trabajo. Los comandos Linux de A–F se ejecutan **en el dispositivo**, salvo indicación offline. Las rutas B del [atlas](TOOL_AND_PATH_ATLAS.md) no son rutas instaladas.

| Etiqueta | Alcance |
|---|---|
| **LECTURA PASIVA** | Archivos, sysfs, `/proc` o análisis offline; puede crear archivos de evidencia, no inicia transacciones MMIO |
| **MMIO DE SOLO LECTURA VERIFICADA** | Solo después de confirmar mapa, build y efectos de lectura para esa IP; no basta que el código no llame a un setter |
| **ACCIÓN CON EFECTOS** | Configuración, estímulo, escritura, reset, programación, transacción IC/I2C o MMIO cuyo efecto no está demostrado. Requiere procedimiento específico del equipo |

No iniciar dos lectores. No ejecutar scripts históricos ni `tgc_readuplink_cli --help`. Un `timeout` de usuario no garantiza abortar una transacción AXI ni recuperar Linux. Si hay un proceso hardware bloqueado, conservarlo e inspeccionarlo; no lanzar otro para comparar.

Variables de sesión, una vez localizado el repositorio y el lector:

```bash
# LECTURA PASIVA / preparación local. Desde la raíz de atlas_emc.
DIAG="$PWD/docs/recuperacion/diagnostico/atlas_diagnostico.py"
printf 'Ruta absoluta del lector TGC localizado, sin ejecutarlo: '
read -r LECTOR
```

Usar nombres nuevos de archivos/carpetas en cada intento. Las órdenes siguientes son **pendientes de ejecución en laboratorio**, no resultados obtenidos durante esta investigación.

## Etapa A — Identidad (0–25 min)

**Objetivo:** identificar plataforma, instalación y procesos existentes. Conocimiento mínimo: Linux corre en el PS; el PL y su Device Tree pueden pertenecer a builds distintas. Abrir [matriz de versiones](SYSTEM_MAP.md#versiones-incompatibles), [B09/X01–X04/R06](TOOL_AND_PATH_ATLAS.md#b09) y [procedimiento del inventario](../recuperacion/12_SCRIPT_DIAGNOSTICO.md).

1. Fotografiar etiqueta de placa/SoC y cableado autorizado; anotar fibra, canal y e-link. Registrar alimentación, cambios recientes y significado exacto de «reinicio».
2. Ejecutar el inventario pasivo. Si el lector aún no está localizado, omitir `--lector` y repetir luego en un archivo nuevo.

```bash
# LECTURA PASIVA; no ejecuta el archivo indicado por --lector.
python3 "$DIAG" inventario --lector "$LECTOR" --salida inventario_lector_01.json
```

**Alternativa sin Python:** guardar la salida de estas órdenes con el mecanismo de registro disponible. Errores de permiso o archivos ausentes también son evidencia; no sustituirlos por valores imaginados.

```bash
# LECTURA PASIVA; no abre /dev/uioN ni /dev/mem.
date -u
uname -a
cat /etc/os-release
tr '\000' '\n' < /sys/firmware/devicetree/base/model
tr '\000' '\n' < /sys/firmware/devicetree/base/compatible
for u in /sys/class/uio/uio*; do
  [ -d "$u" ] || continue
  printf '\n%s\n' "$u"
  cat "$u/name"
  for m in "$u"/maps/map*; do
    [ -d "$m" ] || continue
    printf '%s\n' "$m"
    for field in name addr size offset; do
      printf '%s: ' "$field"
      cat "$m/$field"
    done
  done
done
ps -eo pid,ppid,stat,wchan:24,comm
```

**Salida esperada, sin inventar valores:** lista de nombres UIO, base/tamaño/offset de sus mapas, arquitectura y versiones. AArch64 es consistente con los ELF recuperados; `armv7l` obliga a buscar otra compilación. Un `model` genérico o un nombre `tgc_readUplink_regs` no identifica el bitstream. Sysfs ausente tampoco prueba ausencia de PL.

**Guardar:** inventario, foto/identidad física, hora y fuente de hora, archivos de arranque/DTBO y hashes seleccionados por el ingeniero, procedimiento de carga, logs pertinentes. Revisar datos internos antes de compartir; no copiar historiales o configuraciones de red completas.

**Puerta A:** conocemos la plataforma y tenemos un candidato de build/DT con procedencia. Si Linux no responde, detener accesos y registrar consola/estado físico mediante el procedimiento existente. Si no se identifica firmware, continuar B solo como inspección de archivos; no avanzar a MMIO. No cargar un XSA/overlay para «hacer coincidir» la documentación.

## Etapa B — Elegir herramientas (25–40 min)

**Objetivo:** fijar un lector y su contrato. Conocimiento mínimo: payload, estado del enlace y control del chip son caminos distintos. Abrir [tabla de herramientas](TOOL_AND_PATH_ATLAS.md#elegir-la-herramienta), B01–B03 y el mapa de registros en [SYSTEM_MAP](SYSTEM_MAP.md#qué-significa-cada-palabra-del-lector-tgc).

```bash
# LECTURA PASIVA de ELF; no usar ldd ni ejecutar --help.
file "$LECTOR"
sha256sum "$LECTOR"
readelf -h -l -d -n "$LECTOR"
python3 "$DIAG" preparar --inventario inventario_lector_01.json --salida plan_lectura_01.json
```

El perfil requiere un solo UIO llamado `tgc_readUplink_regs`, map0 con al menos `0x30` bytes, base alineada y offset sysfs cero. El plan nace bloqueado. Que `preparar` termine no autoriza la captura.

Revisar las cinco claves de `validation` con el ingeniero; cada `confirmed: true` exige un `evidence` concreto:

| Clave | Evidencia necesaria |
|---|---|
| `build_map` | Bitstream/DT/build y mapa del capturador correspondientes al equipo |
| `binary_dependencies` | ELF vinculado a fuente/receta, arquitectura, intérprete y bibliotecas efectivas |
| `read_semantics` | Los doce registros, orden, efectos de lectura/apertura/cierre y ausencia de escrituras en la CLI elegida |
| `exclusive_operator` | Un lector coordinado y ningún acceso hardware pendiente |
| `hardware_authorization` | Operador responsable, condiciones y momento de aprobación de estas lecturas |

Para cada intérprete/biblioteca **ya resuelto** en el dispositivo:

```bash
# LECTURA PASIVA. Repetir para cada archivo efectivamente usado por el loader.
printf 'Ruta absoluta de biblioteca o intérprete identificado: '
read -r BIBLIOTECA
python3 "$DIAG" identidad "$BIBLIOTECA"
```

Añadir los objetos resultantes a `libraries` del plan. El script verifica hashes, no completitud de la lista ni resolución real del loader. Los ELF TGC recuperados requieren libuio, libstdc++, libm, libgcc_s, libc e intérprete AArch64; incluir dependencias transitivas aplicables. RPATH y `LD_LIBRARY_PATH` deben corresponder a la sesión.

**Guardar:** plan, hashes, origen de bibliotecas y mapa documentado; incertidumbres sin marcar como confirmadas. **Riesgo:** un nombre/hash correcto puede acompañar PL distinto; tampoco prueba los efectos del registro. **Puerta B:** cinco confirmaciones sustentadas y dependencias completas. Si falta RTL/ABI del capturador, parar las lecturas y pedir esa pieza. Alternativa: trabajar con una captura histórica etiquetada como tal y realizar las lecciones 2–3; no inventar direcciones.

## Etapa C — Estado del enlace (40–55 min)

**Objetivo:** distinguir transporte disponible de recepción FE demostrada. Conocimiento mínimo: lock, ready y progreso no significan lo mismo. Abrir B05, R03 y [estados del sistema](SYSTEM_MAP.md#estados-que-no-equivalen-a-datos).

Si se valida **por separado** `empfw_debughub`, su lector, mapa y registros de estado, usar el `fwMonitor` correspondiente. No basta el plan TGC: valida otra IP.

```bash
# MMIO DE SOLO LECTURA VERIFICADA: solo con contrato del debughub cerrado.
printf 'Ruta absoluta del fwMonitor validado: '
read -r MONITOR
printf 'Índice de pipeline documentado para el FE: '
read -r CANAL
"$MONITOR" --id "$CANAL" > estado_enlace_01.out 2> estado_enlace_01.err
RC=$?
printf '%s\n' "$RC" > estado_enlace_01.rc
```

**Interpretar:** guardar `RX locked`, `TX ready`, `TX aligned`, `XCVR Ready`, stdout, stderr y retorno. No hay valores predichos aquí sin hardware. Estado alto solo acredita la condición implementada en esa build. Bajo no localiza por sí solo fibra, reloj o configuración. Error/crash por UIO ausente no demuestra fallo óptico; el backend recuperado continúa después de ciertos errores de apertura.

**No usar como lectura pasiva** `lpGbtRegister -r` ni `clkProgrammer -i`: hacen transacciones activas. El primero escribe el controlador IC y tiene esperas sin límite; el segundo necesita bus y página correctos, y la fuente no selecciona página al leer. Revisar configuración guardada/receta y, si hace falta estado efectivo del chip o reloj, emplear el procedimiento de diagnóstico ya validado por el ingeniero, registrando sus efectos.

**Guardar:** estados, identificación del monitor, conexión física, configuración efectiva y pruebas de exclusión de PRBS/loopback. **Puerta C:** sin errores de acceso y con estados coherentes para el ensayo; anotar cualquier campo no observable. Si no se puede validar el monitor, no ejecutarlo: usar evidencia independiente existente o declarar transporte desconocido. No «arreglar» clocks/resets dentro de este paso.

## Etapa D — Captura corta (55–75 min)

**Objetivo:** obtener palabras completas y evidencia de ejecución. Conocimiento mínimo: doce registros leídos en secuencia no forman necesariamente una captura atómica. Abrir B01–B03 y [S2 del supervisor](../recuperacion/12_SCRIPT_DIAGNOSTICO.md#5-procedimiento-s2--ensayo-corto-después-observación-prolongada).

```bash
# MMIO DE SOLO LECTURA VERIFICADA. Solo después de cerrar A/B y revisar C.
python3 "$DIAG" capturar --plan plan_lectura_01.json --salida sesion_inicial_01 \
  --fase inicial --muestras 3 --intervalo 5 --timeout 3 --autorizar-lecturas

# LECTURA PASIVA: análisis de archivos, incluso si la captura falló.
python3 "$DIAG" informe --sesion sesion_inicial_01 --salida informe_inicial_01.md
```

**Esperado:** tres resultados completos con magic, nueve grupos, header y threshold; no se predicen valores. El supervisor conserva constructor y decimal final sin contarlos como registros. Cinco segundos son espera entre ejecuciones, no cadencia exacta. Los timestamps pertenecen al software, no al FE.

Revisar archivos `.out`, `.err`, retorno, duración y resultado parseado. Un resultado «OK»/retorno cero significa ensayo completado, no validez física. Cambio de magic/threshold, stderr, campos ausentes/duplicados, timeout o retorno anómalo detienen el ensayo. Un patrón repetido no basta para declararlo fallo.

**Riesgos:** aperturas repetidas, consumo de registros si la semántica fue mal validada, transacción AXI bloqueada. El supervisor puede terminar sin haber eliminado un hijo no interrumpible. El lock tras anomalía no se borra para continuar: conservarlo y confirmar procesos/accesos pendientes con el ingeniero.

**Guardar:** carpeta completa, plan, inventario, configuración y notas. **Puerta D:** lectura completa y comportamiento de acceso estable. Si falla, ir a F; no ejecutar un lector alternativo sobre el mismo bus pendiente. Si no hay captura permitida, hacer informe offline de evidencia previa o localizar la pieza que bloquea B.

## Etapa E — Prueba física A/B/A (75–100 min)

**Objetivo:** intentar refutar que observamos una fuente interna, un canal distinto o datos retenidos. Conocimiento mínimo: variar cualquier bit no demuestra causalidad. Abrir [lección 4](TEACHING_SESSION.md#lección-4--qué-demuestra-una-captura) y [hipótesis](AUDIT_AND_UNCERTAINTIES.md#hipótesis-de-congelamiento-y-pruebas-discriminantes).

Antes de tocar el FE escribir: canal/e-link, estado A, cambio B, bits/grupos o estadística esperados, latencia y tiempo de retención. El ingeniero determina estímulo, amplitud, duración y límites. Medir por un medio independiente que el cambio llega al punto físico previsto. **Aplicar el estímulo es una ACCIÓN CON EFECTOS**, no una función del supervisor.

1. Mantener A hasta estabilizar y capturar varias muestras.
2. Aplicar B y comprobarlo físicamente. Mantenerlo varias muestras más allá de latencia/retención documentadas.
3. Volver a A, comprobar retorno físico y capturar A2. Repetir el ciclo al menos tres veces si es viable en los 25 minutos. Si no, registrar cuántos ciclos se hicieron.

Comando para **cada fase real**, con identificador nuevo como `c1_A`, `c1_B`, `c1_A2`. Pedir el identificador no cambia el estímulo:

```bash
# MMIO DE SOLO LECTURA VERIFICADA; mantener el estímulo durante la captura.
printf 'Identificador de fase ya aplicada y comprobada físicamente: '
read -r FASE
python3 "$DIAG" capturar --plan plan_lectura_01.json --salida "sesion_${FASE}" \
  --fase "$FASE" --muestras 3 --intervalo 5 --timeout 3 --autorizar-lecturas

# LECTURA PASIVA / anotación: describir lo que ocurrió, no la intención.
printf 'Estímulo, hora real, medición independiente y observaciones: '
read -r NOTA
python3 "$DIAG" anotar --sesion "sesion_${FASE}" --texto "$NOTA"
python3 "$DIAG" informe --sesion "sesion_${FASE}" --salida "informe_${FASE}.md"
```

El informe compara dentro de una sesión. Para A/B usar los `.out` seleccionados en el [comparador local existente](../recuperacion/README.md); comparar los nueve grupos de 32 bits, no solo el byte bajo. Elegir muestras alejadas de transiciones; no tomar la primera/última por conveniencia. Si no se conoce el packing, conservar las palabras crudas y marcar el análisis como sensibilidad al estímulo.

| Observación | Conclusión permitida / decisión |
|---|---|
| Cambio y retorno repetibles en canal/bits previstos; fuente externa medida, PRBS/loopback excluidos | Evidencia de recepción externa actual bajo estas condiciones. No prueba BER, tasa sostenible ni atomicidad |
| Cambio reproducible pero packing/latencia desconocidos | Sensibilidad al estímulo; decodificación y captura de eventos siguen abiertas |
| No cambia pese a B verificado físicamente y una predicción que exige cambio dentro del plazo | Refuta que esta ruta esté entregando ese cambio en ese plazo; investigar selección, canal, captura o interpretación |
| Cambios sin relación con A/B, o solo en loopback | No demuestra recepción del FE; comprobar fuente interna, otro canal o ruido |
| No vuelve en A2 y no conocemos retención/rearme | Inconcluso; no declarar corrupción ni repetir resets |

**Guardar:** predicción anterior a la prueba, datos completos, configuración sin cambios, tiempos de transición, mediciones externas y selección de muestras. **Puerta E:** conclusión acotada con controles negativos. Si el estímulo no puede medirse o aislarse, documentar prueba pendiente y pasar F; no presentar correlación casual como validación.

## Etapa F — Congelamiento (100–120 min)

**Objetivo:** localizar la primera frontera sin progreso. Si no falla hoy, ensayar esta clasificación con una captura previa sin provocarlo. Conocimiento mínimo: bloqueo del proceso, transacción pendiente y datos constantes son fenómenos distintos. Abrir B10, [análisis del fallo](../recuperacion/10_BLOQUEO_LECTURAS.md) y la tabla siguiente.

```bash
# LECTURA PASIVA: solo si existe un proceso fallido, usar su PID real.
printf 'PID del proceso original que sigue bloqueado: '
read -r PID_FALLO
python3 "$DIAG" inventario --pid "$PID_FALLO" --salida inventario_fallo_01.json
```

Si el proceso ya terminó, inventariar sin `--pid` y conservar el retorno/salida de su sesión. No relanzarlo para fabricar un PID.

| Evidencia observable | Hipótesis y siguiente prueba discriminante |
|---|---|
| Script sigue vivo, subprocesos retornan; palabra completa cambia pero byte bajo no | Bucle de `read_lpgbt10.sh`; revisar máscara `& 0xff` y valores completos ya disponibles |
| CLI retorna rápido con doce palabras iguales | No es bloqueo de esa ejecución. Estímulo A/B y observación de UserData/captura/rearme mediante instrumentación existente |
| CLI no retorna; Linux responde | Conservar PID, `stat`, `wchan`, mapeos y errores. Estado D es indicio, no prueba exclusiva de AXI bloqueado; no sumar otro acceso |
| `lpGbtRegister` no retorna | Examinar clearIntr/FIFO/espera IC; no atribuirlo a la ruta TGC, que no espera IRQ |
| UserData cambia pero registro AXI queda fijo | Capturador/rearme/CDC hacia AXI, **si** ambas observaciones corresponden al mismo canal/build |
| UserData tampoco progresa y falta strobe/reloj/lock | Subir hacia core/MGT/reloj/origen; un ready retenido no excluye esta situación |
| Linux/consola no responde | Solo observación externa disponible; evidencia parcial. Recuperación controlada por el ingeniero, sin diagnóstico causal concluyente |

Las señales internas de las dos penúltimas filas **no las mide la CLI**. Pedir ILA existente, contador documentado o instrumentación de una build posterior. No añadir MMIO exploratorio.

**Antes de cualquier recuperación:** conservar última muestra buena, primera mala, tiempos, PID/estado, sesiones y lock, inventario, hashes/build, estados de enlace/reloj disponibles, estímulo/configuración y alcance previsto del reset. Distinguir proceso, capturador, core, MGT, reprogramación PL, reboot PS y alimentación. Reiniciar puede reprogramar el reloj si la unidad `systemd-programclock.service` está activa.

**Recuperar es ACCIÓN CON EFECTOS.** Aquí no hay una orden genérica segura. Tras el procedimiento aprobado, repetir inventario y revisar plan antes de una sesión nueva; no unir muestras pre/post como una serie homogénea. Mejoría después de reset limita hipótesis, pero no identifica el componente culpable.

**Cierre a los 120 min:** completar una frase: «Observamos ___ con build/configuración ___; prueba ___ sostiene/refuta ___; falta ___; próxima medida ___». Guardar el paquete local revisado. Si D/E no fueron posibles, la próxima medida debe resolver la puerta bloqueada, no aumentar la cantidad de lecturas.
