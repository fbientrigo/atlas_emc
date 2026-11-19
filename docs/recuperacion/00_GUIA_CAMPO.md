# Guía de campo: comprobar que llegan datos del front-end

Para leer o capturar con el mapa comprobado en noviembre, usa la [guía de operación con emp](15_OPERAR_EMP.md). Esta guía sirve para otra cosa: demostrar de dónde vienen los datos.

Si los valores dejan de actualizarse, guarda el fallo antes de reiniciar y mira si el comando se quedó detenido o si termina repitiendo la misma muestra. El detalle está en [lecturas congeladas, F0 y F1](10_BLOQUEO_LECTURAS.md).

Hay un [script de diagnóstico con la sesión S0–S4](12_SCRIPT_DIAGNOSTICO.md), añadido el 25-10-2026, que es opcional. Su inventario no ejecuta herramientas de hardware. Su captura usa la misma CLI y pide las mismas comprobaciones que esta guía.

La guía es del 24 de octubre de 2026 y se puede leer sin los demás documentos. Se revisó contra el código; no se probó en la Trenz.

## Decisión inicial

Ya existe un programa para leer los registros de payload de la FPGA: `tgc_readuplink_cli`. Lo que no sabemos es si los datos del front-end llegan completos, ni si ese programa encaja con el hardware actual. Por eso primero hay que identificar el diseño cargado, y solo después decidir si se lee MMIO.

La etapa A, el inventario, se puede hacer ya. Para B y C hay que confirmar el firmware, su mapa y qué hace cada lectura. Para D, además, la configuración física y un estímulo externo repetible. Durante A no cargues firmware, no escribas registros y no cambies conexiones.

Se consultó `atlas_emc/main` en `c02a33b645dc70fb4076add25b78c5246589676e`, que coincidía con la referencia del paquete. El ZIP trae 77 fuentes elegidas del respaldo; no trae binarios, overlays ni el sistema completo. Los 77 hashes coinciden con su `MANIFEST.json`. El `.tar.gz` completo no se revisó.

### Cómo leer las marcas

| Marca | Significado |
|---|---|
| VERIFICADO / estática | El archivo citado contiene ese código o esa declaración. No dice nada del hardware. |
| VERIFICADO / histórica | Una nota o salida registra ese resultado con la configuración de entonces. La explicación puede ser otra. |
| INFERIDO | Explicación razonable, sin probar. |
| DESCONOCIDO | Faltan fuentes o mediciones. |
| CONTRADICTORIO | Fuentes que no encajan en un solo mapa o versión. |

Nada de este documento se probó en el hardware. Los comandos marcados PROPUESTA son órdenes Linux revisadas sobre el papel, no resultados. Los comandos de herramientas se basan en las fuentes F1–F12 del final.

### Qué tipo de dato estamos viendo

| Caso | Recorrido | Qué demuestra |
|---|---|---|
| Front-end real | FE → entrada e-link → lpGBT → uplink óptico → EMP → captura → Linux | Solo una respuesta repetible a un estímulo del FE, con las fuentes internas descartadas, permite decir que el dato viene del FE. |
| Loopback interno | Fuente interna del chip o retorno del downlink dentro del lpGBT | Prueba parcial; se salta parte o toda la entrada externa. |
| Loopback físico e-link | La salida hacia el FE vuelve a la entrada por un cable | Prueba el cable y los puertos, pero el dato no lo genera el FE. |
| PRBS o constante | Generador interno o palabra escrita desde el PS a la lógica de envío | Es un patrón de prueba, aunque pase por la óptica. |
| Control IC | `lpGbtRegister` lee registros del chip por `emp_lpgbt_N` | Es configuración y control. Además, leer escribe en el controlador de la FPGA. |
| Payload FPGA | `TgcReadUplink` lee `data_group_0..8` | Son los valores que expone un periférico. Origen, novedad y coherencia se comprueban aparte. |

## Etapa A1: inventario de Linux, Device Tree y firmware

Se trata de identificar el sistema y sus mapas sin abrir `/dev/uio*` ni `/dev/mem`. Necesitas una terminal Bash en la Trenz, una cuenta autorizada y sitio para guardar la transcripción. Asegúrate de estar en la Trenz y no en el PC remoto, para no mezclar salidas.

Comandos (PROPUESTA, solo leen archivos y estado del sistema):

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

Leen metadatos de Linux, propiedades del Device Tree y los archivos de firmware. No montan configfs ni tocan MMIO. `reg` sale en bytes: sus celdas son big-endian y se interpretan con `#address-cells`, `#size-cells` y `ranges` de los nodos padre. No supongas que siempre son cuatro celdas.

Lo que buscas es una lista con nombre UIO, nodo `/dev/uioN`, base, tamaño y offset de cada mapa, y su driver. Busca por separado `emp_lpgbt_N` (control IC), `empfw_debughub` (monitor) y los `tgc_readUplink...` (captura de payload). F1, F3 y F4 usan esos nombres para funciones distintas. El número `uioN` depende del orden de enumeración y no dice nada del canal óptico.

Si no aparece ningún UIO, pasa a E; no cargues un overlay a ojo. Si no hay configfs o falta `path`, anótalo: eso no significa que el PL esté vacío. Un `.dtbo` en disco es firmware disponible, no necesariamente el cargado, y su nombre tampoco dice qué bitstream se programó.

Solo se leen archivos y atributos del kernel; no se prueba AXI. La transcripción puede tener datos del sistema, así que comparte solo lo necesario. Un nombre UIO correcto puede convivir con un slave AXI ausente o bloqueado. La nota `1001-creando un uio.md` lo muestra: un UIO con base y tamaño razonables que da `Bus error`. Ver el dispositivo no prueba el reloj, el reset ni la conexión AXI. [F9]

Después, consigue el `.dtbo` identificado, el bitstream al que apunta y de qué build salió, y relaciónalos con el diseño exportado. Si no hay forma de relacionarlos, A termina con el inventario y el bloqueo anotado. No pases a MMIO.

## Etapa A2: localizar y distinguir ejecutables

Se trata de encontrar lo instalado y sus dependencias sin ejecutar las aplicaciones de hardware. Requiere A1 terminada. Las rutas del respaldo son orientativas; confírmalas en esta máquina.

Comandos (PROPUESTA, solo leen archivos):

```bash
for t in tgc_readuplink_cli fwMonitor lsuio lpGbtRegister loadFirmare.sh readuio clkProgrammer; do
  command -v "$t" || true
done
find "$HOME" /usr/local/bin /usr/bin /opt -xdev -type f \
  \( -name 'tgc_readuplink_cli' -o -name 'fwMonitor' -o -name 'lsuio' \
     -o -name 'lpGbtRegister' -o -name 'loadFirmare.sh' -o -name 'readuio' \
     -o -name 'clkProgrammer' \) -print 2>/dev/null
```

Pon en `BINARIO` una de las rutas absolutas que salieron arriba. No elijas solo por la fecha. Después:

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

`file` y `readelf` leen el archivo sin ejecutarlo. `readelf -h` da la arquitectura, `-l` el intérprete, `-d` las `NEEDED` y el RPATH/RUNPATH, y `-n` notas como el Build ID. Con scripts, que `readelf` falle es normal. No uses `ldd` sobre binarios de los que no te fías. Con uno local de confianza, `ldd "$BINARIO"` ayuda a ver qué bibliotecas resuelve, pero no hace falta para el inventario.

Al terminar deberías tener rutas y hashes de todas las variantes, una arquitectura que encaje con `uname -m`, y el intérprete y las bibliotecas. La CLI necesita `libuio` y el runtime de C++; sin el ELF no sabemos cómo está enlazada. Según CMake, `fwMonitor` se construye desde `fwStatus.cpp` y usa Boost, LogIt y `libuio`. [F1, F3]

`Exec format error` es un problema de arquitectura o intérprete; resuélvelo antes de mirar AXI. `error while loading shared libraries` pide la dependencia de esa build; no copies bibliotecas al azar entre variantes. Un archivo sin RPATH depende de cómo esté configurado el cargador. Si falta el binario, recupera la build del respaldo completo antes de escribir un lector nuevo.

No uses la ayuda de los programas para explorarlos. `tgc_readuplink_cli` tiene `int main()` sin parser, así que `--help` hace las lecturas MMIO igual. `lsuio -a` abre y mapea los UIO. El `lsuio` recuperado además hace `free(uio_list)` después de mover el puntero y puede abortar al salir; usa A1. [F1, F2]

Elige una variante solo si hay pruebas de que fuente, build y periférico corresponden. Anota las diferencias que queden. Un hash identifica los bytes, pero no de qué fuente salieron.

Cuidado con las variantes: en el repositorio, `output_tgc_readuplink_1002/TgcReadUplink.cpp` tiene un solo `data_groups` en `+0x04`, con escritura incluida. No es intercambiable con la copia de nueve grupos del respaldo. [F6]

## Antes de B y C: confirmar firmware y mapa

El responsable local tiene que comprobar y autorizar estas condiciones. Esta guía no autoriza leer un diseño desconocido.

1. Overlay y bitstream cargados, relacionados con un diseño identificable. Listar archivos no alcanza.
2. El RTL de esa build tiene el periférico esperado, y leer esos offsets no vacía FIFO, no limpia flags y no tiene otros efectos.
3. Base y tamaño reales, sacados del sistema, con el offset del mapa y sus límites. La CLI necesita al menos `0x30` bytes desde el inicio del periférico; `fwMonitor`, al menos `0x14`.
4. Reloj, reset e interconexión de ese slave comprobados en la build. Esto no se puede deducir de sysfs.
5. Un nombre UIO sin ambigüedad. Si varias instancias comparten nombre, la búsqueda devuelve la primera: para ahí. [F2]
6. Binario y bibliotecas identificados, y ningún otro proceso reconfigurando el diseño o el chip durante la prueba.

Esta investigación está bloqueada aquí. El Block Design recuperado no contiene `tgc_readUplink_regs` ni `Read_PRBS_regs`, y en la revisión consultada no aparece el RTL de captura. El JSON declara registros de lectura, pero eso no prueba que estén implementados. Hace falta la exportación del diseño que generó el firmware de lectura. [F6, F7]

Además hay un choque de direcciones. En `design.addressing` de ese BD, `0xA00D0000` es `axi_intc_1` y `0xA00E0000` es `axi_intc_2`, los dos de 64 KiB. Los scripts antiguos usan esas mismas bases para el generador y el lector. Son mapas de diseños distintos: correr esas escrituras sobre el diseño del BD podría tocar un controlador de interrupciones. La vieja regla «usar 0xA, no 0xB» tampoco vale para la plataforma, porque este BD pone el debughub en `0xB0000000`. [F7, F9]

## Etapa B: diagnosticar el enlace

El objetivo es separar el transporte óptico y la alineación del origen y la calidad del payload. Requiere la sección anterior resuelta para `empfw_debughub`, la variante de `fwMonitor` confirmada y el pipeline físico identificado. `PIPELINE` tiene que ser un entero confirmado de 0 a 12, y `MONITOR` la ruta absoluta del binario compatible.

Comando (herramienta existente; lee MMIO, solo con las condiciones cumplidas):

```bash
: "${MONITOR:?Definir ruta absoluta del fwMonitor validado}"
: "${PIPELINE:?Definir pipeline fisico confirmado, de 0 a 12}"
case "$PIPELINE" in 0|1|2|3|4|5|6|7|8|9|10|11|12) ;; *) exit 1 ;; esac
"$MONITOR" --id "$PIPELINE"
```

Si faltan permisos, el operador puede usar `sudo "$MONITOR" --id "$PIPELINE"` con las mismas condiciones. En esta fuente, `--help` sale antes de crear el backend y devuelve 1; ese 1 no es un fallo del enlace. [F3]

El programa abre `empfw_debughub` por nombre, hace siete lecturas de campos (algunas del mismo registro en momentos distintos) y arma una tabla. No llama a `reset()`. El software usa `+0x08`, `+0x0C` y `+0x10`; no le impongas al sistema actual su base antigua `0xB0000000`. [F3]

| Indicador | De dónde sale en el RTL recuperado | Qué no dice |
|---|---|---|
| `RX locked` | `rx_header_locked_o` → `status_emp_lpgbt_N(0)` → `status_reg_3`, bit N | Es la cabecera en el receptor de la FPGA. No es el estado del e-link del FE ni del receptor downlink del chip. |
| `TX ready` | `downlinkReady_o` → `status_emp_lpgbt_N(1)` | El camino de transmisión de la FPGA está listo. No dice nada del dato del FE. |
| `TX aligned` | Alineación TX del MGT expuesta al debughub | No es la alineación de palabras del FE. |
| `XCVR Ready` | AND por canal de `MGT_TXREADY` y `MGT_RXREADY` | Un guion no dice cuál de las dos falta. |
| Relojes de lógica | El backend lee `LogicClkDomain1/2` | La tabla de la CLI no los muestra, así que no dice nada de su estado. |
| Integridad FEC | El core tiene señales de corrección, pero en `emp_lpgbt.vhd` la salida latched queda `open` | Esta CLI no da BER, contador de errores ni criterio de integridad. |
| Datos nuevos y coherencia | Ni esta CLI ni la de payload los exponen | El software recuperado no comprueba número de frame ni snapshot. |

Esas conexiones están comprobadas en el RTL recuperado. No sabemos si ese RTL es el del bitstream cargado. [F7, F8]

Lo esperado son estados repetibles en el pipeline correcto. Con todo en `ok` vale la pena seguir mirando el payload, pero todavía no se puede decir que llegan datos del FE.

Si no aparece el UIO, revisa overlay, driver y nombre; no lances `fwReset`. Si falta `RX locked`, revisa la configuración óptica, la tasa, el FEC y la referencia de reloj en el diseño y en el chip. El monitor no mide potencia óptica ni la integridad del e-link. Para el Si5345, `clkProgrammer -i` se usó en el pasado, pero su código no está en el paquete y aquí no se da por inofensivo. Pide los estados LOS y LOL por un método local ya validado. [F10]

El MMIO puede dar `SIGBUS` o tener efectos en otras versiones. Si hay un error, para, guarda la salida y los mensajes del kernel, y no lo repitas en bucle.

Si el transporte es estable, sigue con C. Si no, ve a E y a medir reloj y óptica en local. Ojo: un MGT disponible con la cabecera enganchada también puede venir de un loopback.

Ojo también con los nombres: `uplinkReady_o` en este wrapper sale de `cdc_rx_ready`, y `RX locked` de otro camino; son señales distintas. Y el `TX ready` de la tabla no es directamente el TXREADY del MGT. [F7, F8]

## Etapa C: leer los datos expuestos por la FPGA

El objetivo es sacar observaciones crudas y repetibles con las herramientas que ya hay, sin decodificar todavía eventos del FE. Requiere la sección de firmware y mapa resuelta para el lector, que la fuente de la build coincida con F1 y que `READER` tenga la ruta absoluta encontrada. El nombre UIO tiene que ser exactamente `tgc_readUplink_regs` y único; si es otro, esta CLI no permite elegirlo.

Comando (herramienta existente; lee MMIO, solo con las condiciones cumplidas):

```bash
: "${READER:?Definir ruta absoluta del tgc_readuplink_cli validado}"
"$READER"
```

El programa crea `TgcReadUplink("tgc_readUplink_regs")` y abre y mapea el UIO con permisos de lectura y escritura, aunque este `main()` solo lee. Lee en orden:

| Offset | Campo | Qué sabemos |
|---|---|---|
| `0x00` | `magic` | Identificador previsto. No conocemos su valor en el RTL. El reset a 0 del JSON no es una firma del firmware. |
| `0x04 + 4g`, g=0..8 | `data_group_g` | Nueve palabras de 32 bits. No sabemos a qué bits del uplink ni a qué canales del FE corresponden. |
| `0x28` | `data_header` | Se imprimen 32 bits sin comprobar nada. No sabemos si es la cabecera física del lpGBT. |
| `0x2C` | `clk_thresh` | La clase lo lee y tiene setter, pero este `main()` no lo escribe. Las notas lo relacionan con el retardo tras un envío de prueba. |

La última línea decimal repite `clk_thresh`. No hay parámetros, selección de grupo, espera de eventos ni adquisición continua. [F1, F6, F11]

Deberían salir las etiquetas `magic`, nueve `data_group_N`, `data_header`, `clk_thresh` y la línea decimal. No intentes adivinar los valores. Guarda stdout, stderr, el código de retorno y la configuración de cada observación.

Si la primera lectura estaba autorizada y salió bien, se propone esta serie corta. Es Bash repitiendo el ejecutable, no una función nueva de la CLI. Córrela por separado en cada estado estable A, B y A de la etapa D:

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

Los ceros pueden venir de que no hay datos, de que no se capturó, de un reset, de una máscara o de un cero válido. Los valores constantes, de un FE estable, de un generador, de una captura detenida o de un registro que no se actualiza. Los cambios pueden venir del FE o de pruebas internas, y no prueban que haya frames nuevos. Un `Bus error` no siempre lo atrapa el `catch` de la CLI. [F1, F2]

Las lecturas no son atómicas: cada acceso AXI ocurre en otro momento. Nueve palabras no son un snapshot de 288 bits ni un evento. No las pegues como un frame, y no supongas 230 bits útiles, orden de bytes, huecos ni mapeo de e-links sin el RTL de captura. `volatile` obliga al compilador a hacer el acceso, pero no hace coherentes los frames. [F1, F2]

Si el nombre no coincide, busca otro lector existente que acepte el nombre real. `test_uio/readuio.c` y `libuio/readuio.c` aceptan `readuio NOMBRE_UIO OFFSET...` y leen map0; el primero imprime en hexadecimal y el segundo en decimal. Úsalos solo con el ejecutable identificado y los offsets y efectos del diseño comprobados. No hace falta escribir un lector nuevo. [F12]

No confundas instancias con palabras. Las trece bases antiguas `0xA00E0000 + N*0x10000` son trece instancias, no trece palabras de esta CLI. La nota `Memory Directions` mezcla esa familia con `control/status/data prbs` en `+4/+8/+C`, que no encaja con F1. Esos offsets no controlan este lector. [F5, F11]

## Etapa D: prueba externa A/B/A

El objetivo es atribuir los cambios a una fuente real del FE y distinguirlos de una inyección interna. Es una prueba propuesta, todavía no hecha, y depende de las condiciones siguientes.

Requiere B y C terminadas. Anota la cadena FE, e-link, lpGBT, óptica, pipeline e instancia UIO, junto con la versión del chip, la tasa del e-link, la tasa del uplink y el FEC. Con la configuración en uso y su documentación, confirma que:

- `Uplink Serializer Data Source` está en funcionamiento normal, no en `Loopback Downlink Frame @ 10G24` ni en PRBS o constantes.
- El grupo y canal e-link correctos están habilitados, y sus opciones de fuente no los reemplazan por patrones de prueba.
- No hay un cable de retorno TX→RX ni un mux de pruebas en la FPGA que reemplace la entrada.
- La captura puede actualizarse sin depender solo del disparo de envío PRBS/downlink. Si depende de él, documenta ese disparo y valida su uso en una prueba aparte antes de seguir.

La nota `1013` propone *Simplex Transmitter*, pero eso no prueba que se programara ni que sirva para la configuración de hoy. La nota `1028` habla de Serializer normal con loopback físico, y el modo normal no descarta un cable de retorno. Los mapas V1 listan `ULDATASOURCE0..5` y `EPRXPRBS0..3`, pero no traen cómo se codifican los campos. Con lo que hay, no se puede dar un comando exacto para elegir el FE real. [F4, F5, F11]

En cada estado, usa solo la lectura validada de C y el monitor de B. No conocemos ni el comando de estímulo del FE ni el de selección de fuente. No los reemplaces por `devmem` al generador. El ingeniero tiene que aportar el método del FE (firmware, interfaz y orden exacta) y el pinout aprobado antes de cambiar el hardware.

Una vez validados y autorizados esos cambios:

| Paso | Qué hacer | Qué anotar |
|---|---|---|
| A1 | El FE emite un patrón externo conocido P, el tiempo suficiente para capturarlo | El patrón medido en el par de datos del FE, el reloj y la fuente seleccionada; diez lecturas de C y el estado de B. |
| B | Cambia solo el estímulo a Q, distinto de P y de sus desplazamientos de bits | Las mismas lecturas; confirma Q en el cable y que no se pierde el reloj. |
| A2 | Vuelve a P sin tocar firmware, `clk_thresh` ni fuentes internas | Que se repite la observación de A1. |
| Repetir | Haz A/B/A al menos tres veces | Etiquetas y tiempos; la misma relación entre estímulo y bits. |

Usa patrones sostenidos, identificables desde fuera y con un mapeo documentado. Apagar el FE o sacar la fibra no es un buen primer contraste: se puede perder el reloj o el lock y quedarse un dato retenido. Una prueba de aislamiento eléctrico necesita aprobar antes pinout, niveles y alimentación; no se recomienda conectar en caliente.

Lo esperado es que P→Q→P aparezca de forma repetible en los bits o grupos previstos, con el transporte estable y las fuentes internas descartadas. Fija la máscara de bits esperada a partir del RTL o el pinout antes de mirar resultados; no vale elegir después la palabra que cambió. Si hay correlación pero no mapeo, anótalo como señal externa que se propaga, pendiente de decodificar, no como FE íntegro.

La prueba no sirve si la salida sigue la palabra del generador del PS; si P y Q dan la misma captura sin señales de actualización; si solo funciona con loopback; si el estímulo no se confirma en el par del FE; si cambian a la vez fuentes, tasas o threshold; si cada intento necesita un barrido distinto; o si el mapeo no predice la respuesta. Una lectura estable durante B puede ser simplemente una captura vieja.

Elegir fuentes o estímulos sí cambia el hardware y necesita una autorización local específica. Las notas cuentan problemas de cableado, posibles desfases y capturas detenidas; sus arreglos no son una receta general. [F5]

Con correlación y mapeo repetibles, declara solo lo que se probó: canal, configuración y patrón. Si no, entrega los siete conjuntos de datos de E. Aunque A/B/A salga bien, seguirá sin probarse que se capturan eventos sueltos sin pérdida ni que la lectura de varios registros sea atómica.

Un antecedente: `1028-1031-Testing` incluye una prueba del FE con `0x03`, valores como `0xEE6EEEEE` y barridos variables. Es un registro de pruebas, no la demostración de que el patrón llegó intacto. La explicación de desfase y la nota de que hacía falta reiniciar no apuntan a una sola causa. [F5]

## Etapa E: diagnóstico remoto

El objetivo es elegir una prueba que distinga causas, en vez de reparar a ciegas. Antes de nada, guarda el inventario, la configuración, la salida completa y el retorno del primer fallo. Ningún reset, recarga o barrido antes de guardar el estado.

Comandos (PROPUESTA, solo leen registros de Linux):

```bash
dmesg | tail -n 100
ls -l /dev/uio* 2>&1
```

Si `dmesg` está restringido, pide al administrador las líneas del momento del error; no abras permisos para todos. Para lo demás, repite solo el bloque de A que haga falta. Las pruebas de B y C de la tabla siguen necesitando sus condiciones; no quedan autorizadas por estar aquí.

| Síntoma | Posibles causas | Cómo distinguirlas y qué hacer |
|---|---|---|
| No aparece el UIO | Overlay ausente o que no aplica; nodo deshabilitado; `compatible` o driver; diseño sin esa IP | A1: nodo DT, `status`, `compatible`, driver y logs. Si falta el nodo, revisa el artefacto; si hay nodo sin driver, revisa el binding. No inventes un `/dev/uioN`. |
| Aparece el UIO y da `Bus error` | Mapa distinto del bitstream; slave sin reloj o reset; interconnect o acceso inválido | Para el MMIO. Cruza DT, la exportación del BD o Address Editor y los artefactos; revisa reloj y reset. Un mapa de 16 KiB razonable no descarta nada de esto. |
| Error al abrir | Permisos, otro nombre, nombre repetido o nodo inexistente | A1, A2 y stderr. Resuelve identidad y permisos antes de mirar la óptica. |
| `magic=0` o todo en cero | Firma cero, máscara en el software, reset, captura sin disparar, entrada en cero | Compara cómo se implementa `magic` y la máscara del binario con el RTL. Después, transporte y condición de captura. Un cero aislado no distingue nada. |
| Datos constantes | Patrón estable del FE, generador, snapshot retenido, registro que no se actualiza | Confirma origen y configuración y haz el A/B/A autorizado. Sin contador ni mecanismo de captura, no concluyas que faltan eventos. |
| Solo hay datos con loopback | Entrada del FE sin conectar o deshabilitada; fuente elegida; tasa o fase eléctrica; lector disparado por el envío interno | Anota el modo normal y el cableado real, mide datos y reloj del FE, y recupera enable, tasa y lógica de captura. Que la óptica pase el loopback descarta algunas causas, pero no valida el FE. |
| `XCVR Ready` no está en `ok` | TX o RX no listos; referencia, reset, óptica o configuración | La CLI muestra un AND. Consigue los campos por separado o un ILA validado, y revisa referencias y configuración del MGT. No es un error de decodificación del FE. |
| `XCVR Ready=ok` y `RX locked=-` | Tasa, FEC o header; fuente óptica; reset o alineador | Confirma la configuración de ambos extremos y los estados del core. Tocar `clk_thresh` del capturador no alinea el enlace óptico. |
| Datos desfasados | Fase del e-link, bitslip, empaquetado, cable, muestreo o comparar instantes distintos | Patrón externo sostenido, osciloscopio o ILA, y mapeo RTL. Compara con la predicción de bits antes de hablar de ruido. |
| Canal inesperado | Se confunden pipeline óptico, instancia AXI, grupo y canal e-link | Reconstruye la cadena de índices en el hardware y en el BD, y cambia solo un FE o canal autorizado. `emp_lpgbt_10` no es `/dev/uio10` ni `data_group_10`. |
| `fwMonitor` aborta sin UIO | Otro nombre de debughub o build incompatible; limpieza defectuosa en el software | A1 y A2. Que falle el monitor no es un diagnóstico del MGT. Ya pasó en la rama master. |
| `lpGbtRegister` espera IRQ | Control IC, ruta de interrupción o respuesta, o compatibilidad; no necesariamente el payload | No lo corras durante el inventario. Revisa mapa IC, IRQ y enlace en las fuentes. En esta fuente la espera es de 1 ms y no se comprueba la longitud de la FIFO antes de leer `[6]`. |
| `lsuio -v` imprime y aborta | Error de memoria del enumerador | Usa sysfs (A1). El `free(): invalid pointer` antiguo no significa que la placa esté rota. |

Cada etapa mira una capa distinta: A lo que declara Linux, B los estados, C las palabras y D la causa, con controles. Ninguna cubre por sí sola a las demás.

Si con los instrumentos que hay no se pueden separar dos causas, anota las dos como INFERIDAS y pide la medición que falta. No elijas una porque parezca más frecuente.

Repetir un MMIO puede volver a fallar o bloquear. Para hacer el inventario no corras `sweep_clock.sh`, `test_saturation.sh`, `1024/send_and_read.sh`, `fwReset`, `clkProgrammer -c`, `lpGbtConfiguration -w` ni `loadFirmare.sh ARCHIVO.dtbo`: todos cambian el estado. [F3–F5, F10–F12]

Para el diagnóstico remoto, entrega como mucho estos siete conjuntos de datos:

1. La salida de A1: Linux y modelo; cada UIO con nombre, base, tamaño, offset y driver; los errores completos.
2. Qué firmware está cargado: overlay, hashes del DTBO y del bitstream al que apunta, cómo y cuándo se cargó, y de qué build viene.
3. El BD o Address Editor y el RTL de `tgc_readUplink_regs` de esa build, con captura, `magic`, `header`, `clk_thresh`, CDC y conexión al pipeline.
4. Rutas, hashes, arquitectura y dependencias (A2) de los lectores y del monitor instalados; fuentes y build si las hay.
5. El mapa físico: modelos de placa y chip, canal óptico, pinout aprobado del cable del FE, reloj, datos y canal o grupo e-link.
6. La configuración en uso del lpGBT y del FE: versión, Serializer Data Source, fuentes por grupo, enables, tasas, FEC y modos de loopback. No la cambies para que la captura salga más bonita.
7. Estado del reloj y del enlace, y las lecturas de C si se autorizaron; el método exacto de estímulo externo y los resultados A/B/A, o qué impidió hacerlos.

## Herramientas: hoja rápida independiente

| Herramienta / ruta antigua | Cómo se llama | Qué hace y límites |
|---|---|---|
| `read_all_lpgbt/tgc_readuplink_cli` | Sin argumentos (C) | Lee map0 `0x00..0x2C` con nombre fijo. No detecta datos nuevos, no comprueba coherencia y no elige canal. El ELF no está incluido. [F1] |
| `TgcReadUplink` | Clase C++, no ejecutable | Constructores por nombre o número; nueve getters, header, threshold y setter de threshold. Lo que puede la clase no son opciones de la CLI. [F1] |
| `emp-tools/bin_EMP/fwMonitor`, `bin_TRENZ` o PATH | `fwMonitor --id N` | Lee el debughub con nombre fijo. `fwStatus.cpp` es su fuente, no otro programa. Faltan las bibliotecas exactas del ELF. [F3] |
| `libuio/lsuio` | `lsuio -v` | Lista sysfs; con `-a` abre y mapea. Puede abortar al liberar memoria; usa A1. [F2] |
| `epos/etools/loadFirmare.sh` | `bash "$HOME/epos/etools/loadFirmare.sh" -l`, solo si el archivo es el de F10 | `-l` lista y sale antes de tocar el overlay. Con un `.dtbo` quita el overlay anterior y carga, sin vuelta atrás. No cargues nada. |
| `LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister` (confirma la build) | `-a lpgbt-uio://emp_lpgbt_N -r REG`; `-w REG:VAL` para escribir | Incluso `-r` escribe en el controlador IC, cambia la IRQ y vacía la FIFO. Devuelve un byte del chip, no payload. En F4, `--help` sale antes del backend. |
| `test_uio/readuio` | `readuio NOMBRE_UIO OFFSET...` | Lecturas de 32 bits en map0, sin comprobar límites. Valida antes el ejecutable. [F12] |
| `busybox devmem` | Usos antiguos con dirección y ancho 32; esta guía no lo usa | Lee la dirección física sin pasar por UIO, pero no valida dirección ni significado. Con un tercer argumento escribe. No es plan B ante un `Bus error`. |
| `read_lpgbt10.sh` | No usar en P0 | Lee el byte bajo de `0xA00E0004`, espera un cambio y junta dos lecturas que pueden ser de eventos distintos. [F12] |
| `watch_devmem.sh` | No usar en P0 | Direcciones antiguas, se salta `+0x18` y tiene el `sleep` comentado. [F12] |
| `sweep_clock.sh`, `test_saturation.sh`, `1024/send_and_read.sh` | Solo para entender el pasado | Escriben threshold o patrones. No son lectores pasivos ni pruebas del FE. [F12] |

## Fuentes identificables de esta guía

En las referencias marcadas backup, el prefijo es `TRG_EMP_Work_P0/fuentes_backup/` dentro de `Trenz_EMP_lpGBT_Work_P0_curado.zip`. Son textos, no ejecutables, y sus hashes están en el `MANIFEST.json` del ZIP.

- **F1, backup:** `read_all_lpgbt/tgc_readuplink_cli.cpp:18–62`; `TgcReadUplink.cpp:25–37,45–311`. CLI SHA-256 `03cb6c414059ab55e2fcdcb162faed1287d00c8afd0b5cac434acf1836c098d3`; clase `0bbd3f71777adcaa7b7400dd2fca5987e1faebc1088509cf3a45a28d341db7dd`.
- **F2, backup:** `libuio/base.c:246–271,344–388`; `mem.c:209–221`; `lsuio.c:77–149,153–169`. Búsqueda, permisos de mmap, acceso volatile y el error de limpieza.
- **F3, backup:** `emp-tools/empTools/fwStatus/fwStatus.cpp:17–50,84–115`; su `CMakeLists.txt:1–6`; `include/fwMonitor/fwMonitor.hpp:15`; `src/fwMonitor/fwMonitor.cpp:35–45`; `src/axiBackend/uioFunctions.cpp:17–40,93–176`; `include/axiBackend/axiRegisterMap.hpp:8–68`.
- **F4, backup:** `LpGbtSw/Demonstrators/LpGbtRegister/lpGbtRegister.cpp:28–128`; `LpGbtUioBackend/LpGbtUioBackend.cpp:16–63`; `LpGbtUioFunctions.cpp:60–70,99–126,140–155,172–230`; `include/LpGbt/LpgbtRegisterMapV1.h:317–330`. Faltan bitfields para elegir la fuente del FE.
- **F5, notas:** [1028-1031-Testing](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1028-1031-Testing.md#physical-reading-and-fe-tests), secciones loopback, FE y 1031; [1013-GettingData elinks](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1013-GettingData%20elinks.md); [1007-multipleLPGBT](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1007-multipleLPGBT.md).
- **F6, código y mapa:** [JSON de nueve grupos, revisión 27](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/tgc_readUplink_regs.json); [variante de un grupo](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/puzzledWizards/output_tgc_readuplink_1002/TgcReadUplink.cpp#L64).
- **F7, RTL y BD recuperados:** [emp_lpgbt.vhd, CDC y división de campos](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd#L473); [estados y FEC](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp_lpgbt/emp_lpgbt.srcs/sources_1/new/emp_lpgbt.vhd#L590); [Block Design](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/emp-firmware-2023.2/emp-firmware-2023.2.srcs/sources_1/bd/emp_fw_TE0807/emp_fw_TE0807.bd), sin el lector ni el generador de las notas.
- **F8, debughub:** [empfw_debughub.vhd:212–246](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/epos-firmware/empfw_debughub/src/empfw_debughub.vhd#L212); [nota antigua sobre `uplinkReady`](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1006-UnderstandSignal_UplinkReady.md), comparada con el RTL.
- **F9, fallos antiguos:** [1001-creando un uio](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1001-creando%20un%20uio.md); [0930-LibUIO Implementation](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0930-LibUIO%20Implementation.md).
- **F10, carga y estado:** backup `epos/etools/loadFirmare.sh:19–63,79–115`; [0923-Testing Master branch firmware](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/0923-Testing%20Master%20branch%20firmware.md), salidas del 2025-09-23.
- **F11, significado y contradicciones:** [Memory Directions](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/quick_guides/Memory%20Directions.md); [pruebas de constantes](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1028-Pruebas%20de%20envio%20de%20constante.md); [1006-Tenemos lectura](https://github.com/fbientrigo/atlas_emc/blob/c02a33b645dc70fb4076add25b78c5246589676e/ChargeMonitoringSystem_obsidian/30_Notes/1006-Tenemos%20lectura.md), que dice que usó loopback.
- **F12, scripts y variantes backup:** `test_uio/readuio.c:6–35`; `test_uio/uio_peek.c:6–10`; `read_lpgbt10.sh:1–17`; `watch_devmem.sh`; `sweep_clock.sh`; `test_saturation.sh`; `1024/send_and_read.sh`. Compáralos con `libuio/readuio.c` antes de correr un binario llamado `readuio`.

## Criterio para cerrar esta sesión de campo

El inventario se puede terminar ya. La lectura MMIO solo procede cuando el diseño y el lector estén identificados. Solo se puede decir que llegan datos del FE para una configuración que pase una prueba externa repetible con las fuentes internas descartadas. Si falta alguna de esas pruebas, lo útil es dejar anotado dónde se bloqueó y guardar la evidencia.
