# Guía de campo: comprobar recepción real del front-end

Fecha de investigación: 24 de octubre de 2026. **Validación estática; sin ejecución en la Trenz.** Esta guía puede utilizarse sin leer los demás documentos.

## Decisión inicial

**Existe software para consultar registros de payload FPGA: `tgc_readuplink_cli`. No está demostrada la recepción íntegra del front-end ni su compatibilidad con el hardware actual.** Primero se identifica el diseño activo. Después se decide si procede una lectura MMIO.

Se puede ejecutar ahora el inventario de la etapa A. Las etapas B y C requieren confirmar el firmware, su mapa y la semántica de lectura. La etapa D requiere además identificar la configuración física y un estímulo externo reproducible. No cargar firmware, escribir registros ni cambiar conexiones durante A.

La revisión consultada de `atlas_emc/main` es `c02a33b645dc70fb4076add25b78c5246589676e`; coincidía con la referencia del paquete al consultar GitHub. El ZIP contiene 77 archivos de fuentes seleccionadas del respaldo, no los binarios, overlays o el sistema completo. Los 77 hashes coinciden con su `MANIFEST.json`. No se ha inspeccionado directamente el `.tar.gz` completo.

### Cómo interpretar la evidencia

| Marca | Significado |
|---|---|
| VERIFICADO / estática | El archivo citado contiene esa implementación o declaración. No certifica el hardware. |
| VERIFICADO / histórica | Una nota o salida registra ese resultado bajo su configuración histórica. No confirma su interpretación causal. |
| INFERIDO | Explicación razonable pendiente de prueba. |
| DESCONOCIDO | Faltan fuentes o mediciones. |
| CONTRADICTORIO | Fuentes que no pueden utilizarse como un único mapa o versión. |

**No hay validación actual en hardware en este documento.** Todos los comandos de inventario marcados PROPUESTA son instrucciones Linux propuestas y revisadas estáticamente; no son resultados de ejecución. Los comandos de herramientas se respaldan en las fuentes F1–F12 del final.

### Qué tipo de dato estamos observando

| Caso | Recorrido o acceso | Qué demuestra |
|---|---|---|
| Front-end real | FE → entrada e-link → lpGBT → uplink óptico → EMP → captura → Linux | Solo una respuesta repetible a un estímulo FE, con fuentes internas excluidas, permite atribuir el dato al FE. |
| Loopback interno | Fuente interna del chip o retorno del downlink dentro del lpGBT | Prueba parcial; evita parte o toda la entrada externa. |
| Loopback físico e-link | Salida hacia FE conectada de vuelta a entrada con un cable | Incluye cable/puertos; no demuestra que el FE origine datos. |
| PRBS / constante | Generador interno o palabra escrita desde PS a la lógica de envío | Patrón de prueba, incluso si atraviesa la óptica. |
| Control IC | `lpGbtRegister` consulta registros del chip mediante `emp_lpgbt_N` | Configuración/control, no extracción de payload FE. Su lectura implica escrituras en el controlador FPGA. |
| Payload FPGA | `TgcReadUplink` consulta `data_group_0..8` | Valores expuestos por un periférico. La procedencia, novedad y coherencia deben verificarse aparte. |

## Etapa A1 — Inventario de Linux, Device Tree y firmware

**Objetivo.** Identificar el sistema y sus mapas sin abrir `/dev/uio*` ni `/dev/mem`.

**Condiciones previas.** Terminal Bash en la Trenz, cuenta autorizada y espacio para guardar una transcripción local. No ejecutar estos comandos en el PC remoto y confundir sus salidas con la Trenz.

**Comandos exactos — PROPUESTA, inspección de archivos/estado del sistema:**

```bash
date -Is
uname -a
uname -m
cat /etc/os-release
id
for f in /proc/device-tree/model /proc/device-tree/compatible; do
  if [ -r "$f" ]; then
    printf '\n%s\n' "$f"
    tr '\000' '\n' < "$f"
  fi
done
ls -ld /sys/class/uio /dev/uio* 2>&1
for d in /sys/class/uio/uio*; do
  [ -d "$d" ] || continue
  printf '\n%s\n' "$d"
  for f in name version dev; do
    if [ -r "$d/$f" ]; then printf '%s=' "$f"; cat "$d/$f"; fi
  done
  readlink -f "$d/device/driver"
  readlink -f "$d/device/of_node"
  for m in "$d"/maps/map*; do
    [ -d "$m" ] || continue
    for f in name addr size offset; do
      if [ -r "$m/$f" ]; then printf '%s/%s=' "$m" "$f"; cat "$m/$f"; fi
    done
  done
  if [ -r "$d/device/of_node/reg" ]; then
    od -An -tx1 "$d/device/of_node/reg"
  fi
done
ls -l /lib/firmware/*.dtbo 2>&1
for f in /lib/firmware/*.dtbo; do
  [ -f "$f" ] && sha256sum "$f"
done
for root in /configfs/device-tree/overlays /sys/kernel/config/device-tree/overlays; do
  [ -d "$root" ] || continue
  for o in "$root"/*; do
    [ -d "$o" ] || continue
    for f in path status; do
      if [ -r "$o/$f" ]; then printf '%s/%s=' "$o" "$f"; cat "$o/$f"; fi
    done
  done
done
cat /proc/cmdline
```

**Qué hacen realmente.** Consultan metadatos Linux, propiedades del Device Tree y archivos de firmware. `reg` se muestra en bytes: sus celdas son big-endian y deben interpretarse con `#address-cells`, `#size-cells` y `ranges` de los ancestros; no convertirlo a dirección física suponiendo siempre cuatro celdas. No montan configfs ni acceden directamente a MMIO.

**Resultado esperado y fundamento.** Una lista que asocie nombre UIO, nodo `/dev/uioN`, base, tamaño, offset de cada mapa y controlador. Buscar por separado `emp_lpgbt_N` —control IC—, `empfw_debughub` —monitor— y nombres `tgc_readUplink...` —captura de payload—. Las fuentes F1, F3 y F4 usan nombres diferentes para funciones distintas. El número `uioN` depende de enumeración; no identifica el canal óptico.

**Resultados alternativos.** Si no hay UIO, pasar a E; no cargar un overlay por intuición. Si configfs no existe o falta `path`, registrar la ausencia: no demuestra que el PL esté vacío. Si hay un `.dtbo`, es firmware disponible, no evidencia suficiente del firmware activo. El nombre del overlay tampoco certifica qué bitstream fue realmente programado.

**Riesgos.** Se leen archivos y atributos de configuración del kernel; no es una prueba funcional AXI. La transcripción puede contener datos del sistema: compartir solo lo pertinente. Un nombre UIO correcto puede convivir con un slave AXI ausente o bloqueado.

**Siguiente decisión.** Obtener el `.dtbo` identificado, el archivo de bitstream referenciado y su procedencia de build; relacionarlos con el diseño exportado. Si no existe esa relación, terminar A con inventario y bloqueo documentado. No avanzar a MMIO.

**Intento de refutación.** La nota `1001-creando un uio.md` registra un UIO visible con base y tamaño plausibles que produce `Bus error`. Por ello, ver el dispositivo no prueba ni reloj, ni reset, ni conectividad AXI. [F9]

## Etapa A2 — Localizar y distinguir ejecutables

**Objetivo.** Encontrar lo instalado y sus dependencias sin ejecutar las aplicaciones de hardware.

**Condiciones previas.** A1 completada. Las rutas del respaldo son orientativas; confirmar las rutas en esta máquina.

**Comandos exactos — PROPUESTA, inspección de archivos:**

```bash
for t in tgc_readuplink_cli fwMonitor lsuio lpGbtRegister loadFirmare.sh readuio clkProgrammer; do
  command -v "$t" || true
done
find "$HOME" /usr/local/bin /usr/bin /opt -xdev -type f \
  \( -name 'tgc_readuplink_cli' -o -name 'fwMonitor' -o -name 'lsuio' \
     -o -name 'lpGbtRegister' -o -name 'loadFirmare.sh' -o -name 'readuio' \
     -o -name 'clkProgrammer' \) -print 2>/dev/null
```

Asignar `BINARIO` a **una ruta absoluta devuelta arriba**, sin elegir por fecha solamente. Después:

```bash
: "${BINARIO:?Definir la ruta absoluta del archivo encontrado}"
test -f "$BINARIO" || exit 1
ls -l "$BINARIO"
file "$BINARIO"
sha256sum "$BINARIO"
if command -v readelf >/dev/null 2>&1; then
  readelf -h "$BINARIO"
  readelf -l "$BINARIO"
  readelf -d "$BINARIO"
  readelf -n "$BINARIO"
fi
```

**Qué hacen realmente.** `file` y `readelf` inspeccionan bytes del archivo. `readelf -h` identifica arquitectura; `-l`, intérprete; `-d`, `NEEDED` y RPATH/RUNPATH; `-n`, notas como Build ID. En scripts, los errores de `readelf` son esperables. No utilizar `ldd` sobre binarios no confiables. En un binario local de confianza, `ldd "$BINARIO"` es una comprobación adicional condicionada para resolver bibliotecas; no es parte del inventario mínimo.

**Resultado esperado y fundamento.** Rutas y hashes de todas las variantes, arquitectura compatible con `uname -m`, e intérprete/bibliotecas identificados. La CLI requiere `libuio` y runtime C++; el enlace dinámico exacto es DESCONOCIDO sin el ELF. `fwMonitor` se construye desde `fwStatus.cpp` y usa Boost, LogIt y `libuio` según CMake. [F1, F3]

**Resultados alternativos.** `Exec format error`: arquitectura/intérprete, antes de analizar AXI. `error while loading shared libraries`: resolver la dependencia de esa build; no copiar bibliotecas arbitrarias entre variantes. Un archivo sin RPATH puede depender de configuración del cargador. Si falta el binario, recuperar la build correspondiente del respaldo completo antes de desarrollar un lector nuevo.

**Riesgos.** No usar una ayuda genérica para explorar ejecutables: **`tgc_readuplink_cli` tiene `int main()` sin parser; pasar `--help` no evita MMIO** en esa implementación. `lsuio -a` abre/mapea UIO. En el `lsuio` recuperado hay además un `free(uio_list)` tras avanzar el puntero: puede abortar al terminar; preferir A1. [F1, F2]

**Siguiente decisión.** Elegir una variante solo si hay evidencia de correspondencia entre fuente, build y periférico. Anotar las diferencias restantes; un hash identifica bytes, no demuestra por sí solo de qué fuente se compilaron.

**Intento de refutación.** El repositorio contiene una variante `output_tgc_readuplink_1002/TgcReadUplink.cpp` con un único `data_groups` en `+0x04`, incluso con escritura. No es intercambiable con la copia del respaldo de nueve grupos. [F6]

## Punto de parada obligatorio antes de B y C

El responsable local debe verificar y autorizar las condiciones de la lectura. Esta guía no autoriza una operación sobre un diseño desconocido.

1. Overlay y bitstream activos relacionados con un diseño identificable; no basta con listar archivos.
2. El RTL de esa build implementa el periférico esperado y permite leer esos offsets sin consumir FIFO, limpiar flags ni producir otras acciones no previstas.
3. Base y tamaño reales obtenidos del sistema, incluidos offset del mapa y límites. Para la CLI: ventana útil desde el inicio del periférico de al menos `0x30` bytes. Para `fwMonitor`: al menos `0x14`.
4. Reloj/reset e interconexión de ese slave comprobados en la build. No se puede deducir esto de sysfs.
5. Nombre UIO inequívoco. Si varias instancias comparten nombre, la búsqueda por nombre devuelve el primer candidato: detenerse. [F2]
6. Binario y bibliotecas identificados; ningún otro proceso reconfigura el diseño o el chip durante la prueba.

**Bloqueo de esta investigación:** el Block Design recuperado no contiene `tgc_readUplink_regs` ni `Read_PRBS_regs`; tampoco se encontró el RTL de captura en el árbol de la revisión consultada. El JSON declara registros de lectura, pero no demuestra su implementación. Se necesita la exportación del diseño que generó el firmware de lectura. [F6, F7]

## Etapa B — Diagnosticar el enlace

**Objetivo.** Separar transporte óptico/alineación de procedencia y calidad del payload.

**Condiciones previas.** Punto de parada resuelto para `empfw_debughub`; variante de `fwMonitor` confirmada; pipeline físico identificado. `PIPELINE` debe ser un entero confirmado de 0 a 12 y `MONITOR` la ruta absoluta del binario compatible.

**Comandos exactos — herramienta existente, lectura MMIO condicionada:**

```bash
: "${MONITOR:?Definir ruta absoluta del fwMonitor validado}"
: "${PIPELINE:?Definir pipeline fisico confirmado, de 0 a 12}"
case "$PIPELINE" in 0|1|2|3|4|5|6|7|8|9|10|11|12) ;; *) exit 1 ;; esac
"$MONITOR" --id "$PIPELINE"
```

Si la cuenta carece de permisos, el operador puede usar `sudo "$MONITOR" --id "$PIPELINE"` únicamente bajo las mismas condiciones. `--help` de esta fuente sale antes de construir el backend y retorna 1; ese retorno no es un fallo del enlace. [F3]

**Qué hace realmente.** Abre por nombre `empfw_debughub`. Hace siete lecturas de campos, algunas del mismo registro en instantes distintos, y construye una tabla. No llama a `reset()`. El mapa del software usa `+0x08`, `+0x0C` y `+0x10`; no imponer su base histórica `0xB0000000` al sistema actual. [F3]

| Indicador | Significado trazado en el RTL recuperado | Límite |
|---|---|---|
| `RX locked` | `rx_header_locked_o` → `status_emp_lpgbt_N(0)` → `status_reg_3`, bit N | Alineación de cabecera en el receptor FPGA; no estado directo del e-link del FE ni del receptor downlink del chip. |
| `TX ready` | `downlinkReady_o` → `status_emp_lpgbt_N(1)` | Disponibilidad del camino FPGA de transmisión; no dato FE válido. |
| `TX aligned` | Alineación de TX del MGT expuesta al debughub | No es alineación de palabras del FE. |
| `XCVR Ready` | AND por canal de `MGT_TXREADY` y `MGT_RXREADY` | Un guion no distingue cuál de las dos señales falta. |
| Relojes de lógica | El backend lee campos `LogicClkDomain1/2` | Esta tabla CLI no los imprime; no inferir su salud a partir de la tabla. |
| Integridad FEC | Hay señales de corrección en el core; en `emp_lpgbt.vhd` la salida latched está `open` | No hay BER, contador de errores ni criterio de integridad disponible en esta CLI. |
| Datos nuevos/coherencia | No expuestos por esta CLI ni por la CLI de payload | No hay comprobación de número de frame o snapshot en el software recuperado. |

Las conexiones de la tabla están VERIFICADAS / estáticas para el RTL recuperado, cuya identidad con el bitstream activo es DESCONOCIDA. [F7, F8]

**Resultado esperado y fundamento.** Estados repetibles del pipeline correcto. Los `ok` justifican seguir investigando el payload, nunca declarar recepción FE.

**Resultados alternativos.** UIO ausente: revisar overlay/driver y nombre, no lanzar `fwReset`. `RX locked` ausente: comprobar configuración óptica, tasa/FEC y referencia de reloj en el diseño y el chip. El monitor no mide por sí solo potencia óptica ni integridad e-link. Para SI5345, `clkProgrammer -i` tiene uso histórico; su implementación no está en el paquete y no se autoriza aquí como inspección inocua. Solicitar estados LOS/LOL mediante un método local ya validado. [F10]

**Riesgos.** MMIO puede provocar `SIGBUS` o lecturas con efectos en otras versiones. Si ocurre un error, detenerse y guardar salida y mensajes pertinentes de kernel; no repetir indefinidamente.

**Siguiente decisión.** Con transporte estable, C. Sin él, E y mediciones locales de reloj/óptica. Un MGT disponible y un header bloqueado aún permiten que la fuente sea un loopback.

**Intento de refutación.** `uplinkReady_o` en este wrapper viene de `cdc_rx_ready`, mientras `RX locked` viene de otro camino. No son sinónimos. Además, el nombre `TX ready` en la tabla no es directamente el TXREADY del MGT. [F7, F8]

## Etapa C — Consultar los datos expuestos por la FPGA

**Objetivo.** Obtener observaciones crudas reproducibles con tooling existente; todavía no decodificar eventos FE.

**Condiciones previas.** Punto de parada resuelto para el lector. La fuente de la build coincide con F1. `READER` contiene la ruta absoluta encontrada. El nombre UIO es exactamente `tgc_readUplink_regs`, único; si difiere, esta CLI no ofrece cómo seleccionarlo.

**Comando exacto — herramienta existente, lectura MMIO condicionada:**

```bash
: "${READER:?Definir ruta absoluta del tgc_readuplink_cli validado}"
"$READER"
```

**Qué hace realmente.** Construye `TgcReadUplink("tgc_readUplink_regs")`, abre y mapea UIO con permisos de lectura/escritura, aunque este `main()` solo efectúa lecturas de registros. Lee secuencialmente:

| Offset relativo | Campo | Qué está demostrado |
|---|---|---|
| `0x00` | `magic` | Identificador previsto; valor esperado en RTL DESCONOCIDO. El reset 0 del JSON no es firma de firmware. |
| `0x04 + 4g`, g=0..8 | `data_group_g` | Nueve palabras leídas, 32 bits cada una. Asignación a bits del uplink y canales FE DESCONOCIDA. |
| `0x28` | `data_header` | El software imprime 32 bits. No comprueba su valor ni validez. No se ha demostrado que sea la cabecera física lpGBT. |
| `0x2C` | `clk_thresh` | Registro leído y con setter en la clase; este `main()` no lo escribe. La nota lo vincula al retardo tras un envío de prueba. |

La última línea decimal repite `clk_thresh`: no es otro dato. No hay parámetros, selección de grupo, espera por evento ni adquisición continua. [F1, F6, F11]

**Resultado esperado y fundamento.** Etiquetas `magic`, nueve `data_group_N`, `data_header`, `clk_thresh` y la repetición decimal. No predecir valores hexadecimales. Guardar stdout, stderr, retorno y configuración de cada observación.

Si una primera lectura fue autorizada y terminó bien, se propone esta serie **acotada**. No es una función nueva de la CLI; Bash repite el ejecutable existente. Se ejecuta por separado en cada estado estable A/B/A de D:

```bash
for n in 1 2 3 4 5 6 7 8 9 10; do
  date -Is
  "$READER"
  rc=$?
  printf 'retorno=%s\n' "$rc"
  [ "$rc" -eq 0 ] || break
  sleep 1
done
```

**Resultados alternativos.** Ceros: compatibles con ausencia, falta de captura, reset, enmascarado o un valor válido cero. Constantes: compatibles con FE estable, generador, captura detenida o registro que no se actualiza. Cambios: compatibles con FE o pruebas internas; no demuestran frames nuevos. `Bus error` no es una excepción C++ necesariamente capturable por el `catch` de la CLI. [F1, F2]

**Riesgos.** Lecturas no atómicas: cada acceso AXI ocurre en otro instante. Nueve palabras no equivalen a un snapshot de 288 bits ni a un evento. No concatenarlas como frame; tampoco asumir 230 bits útiles, orden de bytes, huecos o mapeo e-link sin el RTL de captura. `volatile` obliga al acceso del compilador; no aporta coherencia de frames. [F1, F2]

**Siguiente decisión.** Si el nombre no coincide, identificar un lector existente que admita el nombre real. La variante `test_uio/readuio.c` admite `readuio NOMBRE_UIO OFFSET...` y accede a map0; la de `libuio/readuio.c` es otro programa: no intercambiar opciones por nombre de archivo. Utilizar la primera solo si se identifica su ejecutable y se verifican offsets y efectos del diseño. No se requiere escribir un lector nuevo. [F12]

**Intento de refutación.** Trece bases históricas `0xA00E0000 + N*0x10000` son trece instancias, no trece palabras de esta CLI. La nota `Memory Directions` mezcla esa familia con `control/status/data prbs` en `+4/+8/+C`, incompatible con F1. No usar esos offsets como control del lector. [F5, F11]

## Etapa D — Prueba externa A/B/A

**Objetivo.** Atribuir cambios observados a una fuente FE real y distinguirlos de inyección interna. Es una prueba propuesta, pendiente de las condiciones siguientes; no un ensayo ejecutado.

**Condiciones previas.** B y C completadas. Registrar la conexión FE–e-link–lpGBT–óptica–pipeline–instancia UIO, versión del chip, tasa e-link, tasa uplink y FEC. Confirmar, mediante configuración vigente y su documentación, que:

- `Uplink Serializer Data Source` utiliza el funcionamiento normal y no `Loopback Downlink Frame @ 10G24` ni PRBS/constantes.
- El grupo/canal e-link de recepción correcto está habilitado y sus opciones de fuente no lo sustituyen por patrones de prueba.
- No hay retorno físico TX→RX ni un mux de pruebas FPGA que sustituya la entrada.
- La lógica de captura puede actualizarse sin depender exclusivamente del disparo de envío PRBS/downlink. Si depende de él, documentar ese disparo y validar su uso en una prueba separada antes de continuar.

La nota `1013` propone *Simplex Transmitter*; no prueba que ese modo se programara ni que sea la selección correcta para toda configuración actual. La nota `1028` habla de Serializer normal para loopback físico; normal por sí solo no excluye el cable de retorno. Los mapas V1 enumeran `ULDATASOURCE0..5` y `EPRXPRBS0..3`, pero no aportan aquí la codificación completa de los campos. **No hay evidencia suficiente para dar un comando exacto que seleccione FE real.** [F4, F5, F11]

**Comandos exactos.** Utilizar únicamente la lectura validada de C y el monitor de B en cada estado. **Comando de estímulo FE: DESCONOCIDO. Comando de selección de fuente: DESCONOCIDO.** No reemplazarlos por `devmem` al generador. El ingeniero debe aportar el método FE existente —firmware, interfaz y orden exacta— y el pinout aprobado antes de cambiar el estado del hardware.

**Qué hacer realmente, una vez validados y autorizados esos cambios:**

| Paso | Acción local | Registro necesario |
|---|---|---|
| A1 | FE emitiendo un patrón externo conocido P, sostenido el tiempo suficiente para la captura | Patrón medido en el par de datos FE, reloj, fuente seleccionada; diez lecturas C y estado B. |
| B | Cambiar solo el estímulo FE a Q, distinguible de P y de sus posibles desplazamientos de bits | Mismas lecturas; confirmar físicamente Q y que no se pierde la referencia de reloj. |
| A2 | Volver a P sin tocar firmware, `clk_thresh` ni fuentes internas | Retorno reproducible a la observación de A1. |
| Repetición | Repetir A/B/A al menos tres veces | Etiquetas y tiempos; misma relación entre estímulo y bits observados. |

Preferir patrones sostenidos con identificación externa y un mapeo documentado. Apagar el FE o quitar fibra no es un primer contraste limpio: puede perderse reloj/lock y quedar datos retenidos. Una prueba de aislamiento eléctrico adicional requiere aprobación de pinout, niveles y alimentación; no es hot-plug recomendado.

**Resultado esperado y fundamento.** El cambio P→Q→P aparece repetiblemente en los bits/grupos previstos, mientras el transporte permanece estable y las fuentes internas están excluidas. Antes de mirar resultados se debe fijar la máscara de bits esperada a partir del RTL/pinout; no elegir a posteriori cualquier palabra que cambie. Si solo hay correlación sin mapeo, clasificarla como evidencia de propagación externa pendiente de decodificación, no integridad FE completa.

**Resultados que invalidan una atribución de recepción FE.** La salida sigue la palabra del generador PS; P y Q producen la misma captura sin evidencia de actualización; funciona únicamente con loopback; el estímulo no se confirma en el par FE; cambian simultáneamente fuentes/tasas/threshold; el resultado exige barridos distintos en cada intento; el mapeo no predice la respuesta. Una lectura estable durante B podría ser simplemente una captura antigua.

**Riesgos.** Seleccionar fuentes o estímulos sí modifica hardware y exige autorización local específica. Las notas registran problemas de cableado, posibles desfases y capturas detenidas; no trasladar sus arreglos como receta universal. [F5]

**Siguiente decisión.** Con correlación y mapeo reproducibles, declarar únicamente el alcance probado: canal, configuración y patrón. Sin ello, devolver los siete datos de E. Aun superada A/B/A, la captura de eventos transitorios sin pérdida y la atomicidad multirregistro siguen sin estar demostradas.

**Intento de refutación.** `1028-1031-Testing` incluye una prueba FE de `0x03` con valores como `0xEE6EEEEE` y barridos variables. Es evidencia histórica de pruebas, no una demostración de fidelidad del patrón. La explicación de desfase y la anotación de reinicio requerido no identifican una causa única. [F5]

## Etapa E — Diagnóstico remoto

**Objetivo.** Elegir una prueba que distinga causas; no reparar por ensayo ciego.

**Condiciones previas.** Conservar inventario, configuración, salida completa y retorno del primer fallo. Ningún reset, recarga o barrido antes de conservar el estado.

**Comandos exactos — PROPUESTA, solo consulta de registros del sistema Linux:**

```bash
dmesg | tail -n 100
ls -l /dev/uio* 2>&1
```

Si `dmesg` está restringido, solicitar al administrador las líneas del instante del error; no ampliar permisos globalmente. Para el resto, repetir solo el bloque pertinente de A. Las pruebas de B/C de la tabla heredan sus condiciones previas, no se autorizan automáticamente.

| Síntoma | Causas a distinguir | Prueba discriminante y siguiente decisión |
|---|---|---|
| No aparece UIO | Overlay ausente/inaplicable; nodo deshabilitado; `compatible`/driver; diseño sin ese IP | A1: nodo DT, `status`, `compatible`, enlace driver y logs. Si falta el nodo, revisar artefacto; si hay nodo sin driver, revisar binding. No resolver inventando `/dev/uioN`. |
| UIO aparece; `Bus error` | Mapa distinto del bitstream; slave sin reloj/reset; interconnect o acceso inválido | Detener MMIO. Correlacionar DT, exportación BD/Address Editor y artefactos; inspeccionar reloj/reset. Un mapa de 16 KiB plausible no elimina estas causas. |
| Error al abrir | Permisos, nombre distinto, duplicado o nodo inexistente | A1/A2 y stderr. Resolver identidad y permisos antes de investigar la señal óptica. |
| `magic=0` o todo cero | Firma cero, enmascarado software, reset, capture no disparada, entrada cero | Comparar implementación de `magic` y máscara del binario con RTL. Después comprobar transporte y condición de captura. Cero aislado no discrimina. |
| Datos constantes | Patrón FE estable, generador, snapshot retenido, no actualización | Confirmar origen/configuración y aplicar A/B/A autorizado. Sin contador o mecanismo de captura no concluir ausencia de eventos. |
| Solo hay datos con loopback | Entrada FE no conectada/habilitada; fuente seleccionada; tasa/fase eléctrica; lector disparado por envío interno | Registrar modo normal y cableado real; medir datos/reloj del FE; recuperar enable/tasa y lógica de captura. El transporte óptico que pasa loopback reduce algunas causas, no valida el FE. |
| `XCVR Ready` no está `ok` | TX o RX no listos; referencia/reset/óptica/configuración | La CLI muestra AND. Recuperar los campos separados o ILA por un método validado; verificar referencias y configuración MGT. No confundir con error de decodificación FE. |
| `XCVR Ready=ok`, `RX locked=-` | Tasa/FEC/header, fuente óptica, reset/alineador | Confirmar configuración de ambos extremos y estados del core. No ajustar `clk_thresh` del capturador como sustituto de alinear el enlace óptico. |
| Datos desfasados | Fase e-link, bitslip, empaquetado, cable, sampling o comparación de instantes distintos | Patrón externo sostenido, osciloscopio/ILA y mapeo RTL. Comparar predicción de bit/byte antes de inferir ruido. |
| Canal inesperado | Pipeline óptico, instancia AXI, grupo y canal e-link confundidos | Reconstruir la cadena de índices físicamente y en BD; variar solo un FE/canal autorizado. `emp_lpgbt_10` no equivale a `/dev/uio10` ni a `data_group_10`. |
| `fwMonitor` aborta sin UIO | Nombre del debughub distinto o build incompatible; limpieza defectuosa en software | A1/A2. No convertir el fallo del monitor en diagnóstico de MGT. Fallo histórico documentado en la rama master. |
| `lpGbtRegister` espera IRQ | Control IC, interrupción/ruta de respuesta o compatibilidad, no necesariamente payload | No ejecutarlo durante inventario. Verificar mapa IC, IRQ y enlace mediante fuentes; la espera es de 1 ms en esta fuente y la FIFO no valida longitud antes de `[6]`. |
| `lsuio -v` imprime y aborta | Defecto de memoria del enumerador | Usar sysfs A1. No diagnosticar placa averiada por el `free(): invalid pointer` histórico. |

**Qué hacen realmente / fundamento.** A registra el contrato declarado por Linux; B observa estados; C observa palabras; D atribuye causalidad bajo controles. Ninguna de estas pruebas aislada cubre las otras capas.

**Resultados alternativos.** Si no se puede distinguir entre dos causas con la instrumentación existente, registrar ambas como INFERIDAS y pedir la medición que falta. No seleccionar una por frecuencia aparente.

**Riesgos.** Un retry MMIO puede bloquear o volver a fallar. No ejecutar `sweep_clock.sh`, `test_saturation.sh`, `1024/send_and_read.sh`, `fwReset`, `clkProgrammer -c`, `lpGbtConfiguration -w` ni `loadFirmare.sh ARCHIVO.dtbo` para producir el inventario. Son cambios de estado. [F3–F5, F10–F12]

**Siguiente decisión: devolver como máximo estos siete conjuntos de datos.**

1. Salida A1: Linux/modelo, UIO con nombre/base/tamaño/offset y driver; errores completos.
2. Identidad de firmware activo: overlay, hashes de DTBO y bitstream referenciado; cómo/cuándo se cargó; procedencia del build.
3. BD/Address Editor y RTL de `tgc_readUplink_regs` de esa build, incluida captura, `magic`, `header`, `clk_thresh`, CDC y conexión al pipeline.
4. Rutas/hashes/arquitectura/dependencias A2 de los lectores y monitor realmente instalados; fuentes/build disponibles.
5. Mapa físico con modelos de placas/chip, canal óptico, pinout aprobado del cable FE, reloj, datos y canal/grupo e-link.
6. Exportación de la configuración vigente del lpGBT y FE: versión, Serializer Data Source, fuentes por grupo, enables, tasas, FEC y modos de loopback. No cambiarla para obtener una captura más bonita.
7. Estado de reloj/enlace y lecturas C, si se autorizaron; método exacto de estímulo externo y resultados A/B/A, o bloqueo preciso que impidió hacerlo.

## Herramientas: hoja rápida independiente

| Herramienta / ubicación histórica relativa | Invocación respaldada | Efecto real y límites |
|---|---|---|
| `read_all_lpgbt/tgc_readuplink_cli` | Sin argumentos, C | Lecturas map0 `0x00..0x2C`; nombre fijo; no novedades/coherencia/selección de canales. ELF no incluido. [F1] |
| `TgcReadUplink` | Clase C++, no ejecutable | Constructores por nombre o número; nueve getters, header, threshold y setter threshold. No confundir capacidad de clase con opciones de CLI. [F1] |
| `emp-tools/bin_EMP/fwMonitor`, `bin_TRENZ` o PATH | `fwMonitor --id N` | Lee debughub por nombre fijo. `fwStatus.cpp` es su fuente, no otro ejecutable requerido. Librerías exactas pendientes del ELF. [F3] |
| `libuio/lsuio` | `lsuio -v` | Enumera sysfs; `-a` abre/mapea. Variante con posible abort al liberar; usar A1. [F2] |
| `epos/etools/loadFirmare.sh` | `bash "$HOME/epos/etools/loadFirmare.sh" -l`, solo si el archivo corresponde a F10 | `-l` lista y sale antes de montar/retirar overlay. Con argumento `.dtbo` retira overlay previo y carga; sin rollback automático. No ejecutar carga. |
| `LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister` —confirmar build real— | `-a lpgbt-uio://emp_lpgbt_N -r REG`; `-w REG:VAL` para escritura | Incluso `-r` escribe en controlador IC, modifica IRQ y consume FIFO. Devuelve un byte, no payload FE. `--help` sale antes del backend en F4. |
| `test_uio/readuio` | `readuio NOMBRE_UIO OFFSET...` | Variante de map0 con lecturas de 32 bits, sin comprobación de límites en esa fuente; validar ejecutable primero. [F12] |
| `busybox devmem` | Históricos con dirección y ancho 32; no receta de esta guía | Lectura física evita lookup UIO pero no valida direccionamiento ni semántica. Con tercer argumento escribe. No fallback ante `Bus error`. |
| `read_lpgbt10.sh` | No recomendado para P0 | Lee byte bajo de `0xA00E0004`, espera un cambio y concatena dos lecturas; no demuestra dos bytes del mismo evento. [F12] |
| `watch_devmem.sh` | No recomendado para P0 | Direcciones históricas, omite `+0x18`, `sleep` comentado. [F12] |
| `sweep_clock.sh`, `test_saturation.sh`, `1024/send_and_read.sh` | Solo análisis histórico | Escriben threshold o patrones; no son lectores pasivos ni pruebas FE. [F12] |

## Fuentes identificables de esta guía

En las referencias **backup**, el prefijo es `TRG_EMP_Work_P0/fuentes_backup/` dentro de `Trenz_EMP_lpGBT_Work_P0_curado.zip`. Son textos, no ejecutables desplegables. Sus hashes completos están en el `MANIFEST.json` del mismo ZIP.

- **F1 — backup:** `read_all_lpgbt/tgc_readuplink_cli.cpp:18–62`; `TgcReadUplink.cpp:25–37,45–311`. CLI SHA-256 `03cb6c414059ab55e2fcdcb162faed1287d00c8afd0b5cac434acf1836c098d3`; clase `0bbd3f71777adcaa7b7400dd2fca5987e1faebc1088509cf3a45a28d341db7dd`.
- **F2 — backup:** `libuio/base.c:246–271,344–388`; `mem.c:209–221`; `lsuio.c:77–149,153–169`. Lookup, permisos de mmap, acceso volatile y defecto de limpieza.
- **F3 — backup:** `emp-tools/empTools/fwStatus/fwStatus.cpp:17–50,84–115`; su `CMakeLists.txt:1–6`; `include/fwMonitor/fwMonitor.hpp:15`; `src/fwMonitor/fwMonitor.cpp:35–45`; `src/axiBackend/uioFunctions.cpp:17–40,93–176`; `include/axiBackend/axiRegisterMap.hpp:8–68`.
- **F4 — backup:** `LpGbtSw/Demonstrators/LpGbtRegister/lpGbtRegister.cpp:28–128`; `LpGbtUioBackend/LpGbtUioBackend.cpp:16–63`; `LpGbtUioFunctions.cpp:60–70,99–126,140–155,172–230`; `include/LpGbt/LpgbtRegisterMapV1.h:317–330`. No hay bitfields suficientes para seleccionar fuente FE.
- **F5 — notas:** [1028-1031-Testing](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1028-1031-Testing.md#physical-reading-and-fe-tests), secciones loopback, FE y 1031; [1013-GettingData elinks](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1013-GettingData%20elinks.md); [1007-multipleLPGBT](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1007-multipleLPGBT.md).
- **F6 — código/mapa:** [JSON de nueve grupos, revisión 27](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/tgc_readUplink_regs.json); [variante de un grupo](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp#L64).
- **F7 — RTL/BD recuperados:** [emp_lpgbt.vhd, CDC y división de campos](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd#L473); [estados y FEC](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd#L590); [Block Design](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp-firmware-2023.2/emp-firmware-2023.2.srcs/sources_1/bd/emp_fw_TE0807/emp_fw_TE0807.bd), sin instancias del lector ni generador de las notas.
- **F8 — debughub:** [empfw_debughub.vhd:212–246](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/empfw_debughub/src/empfw_debughub.vhd#L212); [nota histórica sobre `uplinkReady`](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1006-UnderstandSignal_UplinkReady.md), contrastada con RTL.
- **F9 — fallos históricos:** [1001-creando un uio](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1001-creando%20un%20uio.md); [0930-LibUIO Implementation](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0930-LibUIO%20Implementation.md).
- **F10 — carga/estado:** backup `epos/etools/loadFirmare.sh:19–63,79–115`; [0923-Testing Master branch firmware](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0923-Testing%20Master%20branch%20firmware.md), salidas fechadas 2025-09-23.
- **F11 — semántica y contradicciones:** [Memory Directions](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/Memory%20Directions.md); [pruebas de constantes](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1028-Pruebas%20de%20envio%20de%20constante.md); [1006-Tenemos lectura](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1006-Tenemos%20lectura.md), explícitamente loopback.
- **F12 — scripts/variantes backup:** `test_uio/readuio.c:6–35`; `test_uio/uio_peek.c:6–10`; `read_lpgbt10.sh:1–17`; `watch_devmem.sh`; `sweep_clock.sh`; `test_saturation.sh`; `1024/send_and_read.sh`. Comparar con `libuio/readuio.c` antes de invocar un binario llamado `readuio`.

## Criterio para cerrar esta sesión de campo

El inventario puede completarse ahora. La lectura MMIO solo procede tras cerrar la identificación del diseño y del lector. La recepción real FE solo se declara para una configuración que supera una prueba externa reproducible con fuentes internas excluidas. Si falta cualquiera de esas pruebas, el resultado útil es el bloqueo preciso y la evidencia conservada, no una afirmación de adquisición funcional.
