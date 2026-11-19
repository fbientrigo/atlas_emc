# Script de diagnóstico: guardar el bloqueo y separar sus causas

Este script es del 25-10-2026. Pasa sus pruebas locales, pero no se ha probado en la Trenz. `diagnostico/atlas_diagnostico.py` acompaña a las herramientas que ya existen. Por sí mismo no hace MMIO, no escribe registros, no programa el lpGBT, no cambia el estímulo y no reinicia nada. En modo `capturar` sí ejecuta la CLI existente, que lee el hardware y puede tener efectos si el mapa no corresponde.

La pregunta que intenta responder es qué dejó de avanzar, cuándo y en qué condiciones. Sin señales de progreso visibles no puede encontrar una causa dentro de la FPGA. La causa del bloqueo original sigue sin conocerse.

## 1. Qué se puede aprender

| Qué guarda | Qué ayuda a responder | Límite |
|---|---|---|
| El intento antes de lanzar la CLI, y el resultado y la duración después | ¿Terminó el comando o quedó un intento sin resultado? | Si se cuelga Linux, puede que no se guarde todo ni se sepa en qué instrucción paró |
| stdout, stderr, código de salida y estado del proceso al fallar | ¿Fue un valor repetido, un error, una señal o una espera? | Un timeout no prueba un fallo de AXI; el buffering puede esconder lo que se imprimió justo antes |
| Los nueve grupos completos, el XOR y los bits que cambian | ¿Parecía quieto solo porque se miraba el byte bajo? | Las nueve lecturas son independientes y no forman un snapshot |
| `magic` y `clk_thresh` | ¿Cambió la identidad aparente o la configuración durante la prueba? | No sabemos qué `magic` esperar en la build cargada, y no es una identificación segura |
| sysfs del UIO, hashes del lector y dependencias declaradas | ¿Estamos mezclando mapa, binario o biblioteca? | sysfs no prueba que el PL cargado tenga ese mapa, y el enlazado dinámico no se resuelve solo |
| Hora UTC, tiempo monotónico, boot ID y notas del operador | ¿Cuánto pasó hasta el fallo y qué cambió antes? | La hora es la del software, no la de llegada del frame |
| Estímulo A/B/A anotado a mano | ¿Los cambios siguen de forma repetible a una causa externa? | La correlación no prueba la ruta ni descarta un loopback |

El script distingue una muestra incompleta de un cero. Si el payload se repite, lo informa como repetición, no como «receptor congelado». No interpreta `data_header` como número de evento porque no se sabe qué significa.

## 2. Requisitos y alcance

Linux, Python 3.7 o más con su biblioteca estándar, y una carpeta local con espacio libre. No instala nada de Internet ni usa `sudo` por su cuenta. Comprueba primero:

```bash
python3 --version
# Desde la raíz de la copia de atlas_emc:
cd docs/recuperacion
python3 diagnostico/atlas_diagnostico.py --help
```

Estos comandos son nuevos y se probaron en local. El `--help` es de nuestro script y no toca el hardware. No corras `tgc_readuplink_cli --help`: la CLI recuperada ignora las opciones y haría sus lecturas [B01].

Modos: `inventario`, `identidad`, `preparar`, `capturar`, `anotar` e `informe`. Solo `capturar` ejecuta un proceso de hardware. No hay un modo genérico para meter `devmem`, `lpGbtRegister`, un script de pruebas o un reset. El perfil sirve solo para la variante de nueve grupos de `tgc_readuplink_cli`.

Riesgos que quedan: CPU, disco y sondeos pueden cambiar los tiempos, y una lectura con efectos puede borrar o cambiar datos. El timeout es del supervisor: no cancela de forma fiable una transacción AXI ni garantiza que desaparezca un proceso en estado no interrumpible. Si se cuelga todo el sistema, el script también puede pararse.

## 3. S0: inventario sin lecturas MMIO

Objetivo: tener contexto y, si el fallo ya está pasando, guardar el estado del proceso antes de reiniciar.

Necesitas que Linux responda y una carpeta donde escribir. No hace falta tener el mapa de la FPGA cerrado. No lances otra aplicación de hardware para este paso.

```bash
python3 diagnostico/atlas_diagnostico.py inventario --salida inventario_01.json
```

Si ya sabes la ruta absoluta del ejecutable, añade su identidad sin ejecutarlo:

```bash
printf 'Ruta absoluta del tgc_readuplink_cli identificado: '
read -r LECTOR
python3 diagnostico/atlas_diagnostico.py inventario \
  --lector "$LECTOR" --salida inventario_lector_01.json
```

Si el programa original está atascado ahora, inspecciona su PID en vez de lanzar `capturar`:

```bash
printf 'PID del proceso que ya está fallando: '
read -r PID_FALLO
python3 diagnostico/atlas_diagnostico.py inventario \
  --pid "$PID_FALLO" --salida inventario_fallo_01.json
```

Lee archivos concretos de `/proc` y metadatos de `/sys/class/uio`, del Device Tree, del FPGA manager y de los overlays. Si le das un archivo, lee su cabecera ELF y su SHA-256. Busca posibles lectores por nombre, descriptores y mapeos. No abre `/dev/uioN` ni `/dev/mem`, y no ejecuta `lsuio`, `ldd`, scripts ni binarios de hardware. No guarda todo el entorno ni contraseñas, pero los mapas, las rutas y algunas variables `LD_*` pueden tener información interna.

Sale un JSON con los UIO y mapas disponibles, y con los errores de permisos o atributos que no existen. Un mapa vacío o un FPGA manager sin `firmware` no es un fallo del script ni prueba que el PL esté vacío. Estos metadatos no identifican el bitstream cargado.

`possible_readers.candidates` es una pista: nombres cortados, permisos y carreras impiden garantizar que no haya otro lector. `unreadable_maps` dice qué no pudo mirar. El script no mata procesos de otros. Si no hay Python, usa F0 de [Lecturas congeladas](10_BLOQUEO_LECTURAS.md); no lo instales en mitad de un fallo si eso borra la evidencia.

Consume algo de CPU y disco, puede quedarse corto y el archivo tiene datos internos. Después: si el proceso original no terminó, guarda el inventario y estudia por dónde va. Si la CLI está identificada pero faltan mapa y permisos, sigue con S1. No saltes directo a capturar.

## 4. S1: plan de lectura revisable

Objetivo: fijar qué ELF, bibliotecas y mapa se permiten en la sesión. La plantilla empieza bloqueada.

Necesitas un S0 con `--lector`, un solo UIO llamado `tgc_readUplink_regs`, y un `map0` de al menos `0x30` bytes, con base alineada y offset sysfs cero. Si algo de esto falla, el perfil no se arregla probando otras direcciones.

```bash
python3 diagnostico/atlas_diagnostico.py preparar \
  --inventario inventario_lector_01.json --salida plan_lectura_01.json
```

Copia la identidad del lector y los mapas del inventario, sin ejecutar la CLI. Crea `validation` con cinco confirmaciones en falso y `libraries` vacío. No elige ninguna dirección antigua como buena.

Revisa A2 y el punto de control antes de MMIO en la [guía de campo](00_GUIA_CAMPO.md). Averigua el intérprete y las bibliotecas que se usan de verdad, mirando el ELF, la receta de compilación y la configuración del cargador. Para cada archivo:

```bash
printf 'Ruta absoluta de biblioteca o intérprete ya identificado: '
read -r BIBLIOTECA
python3 diagnostico/atlas_diagnostico.py identidad "$BIBLIOTECA"
```

Añade cada JSON que salga a la lista `libraries` del plan: intérprete, `libuio`, runtime de C++ y el resto de dependencias del ELF. El script comprueba esos hashes, pero no que la lista esté completa ni que el cargador use esos archivos. Si el binario es estático o no es esta variante, para y adapta el perfil después de investigar. No inventes una biblioteca para pasar la comprobación.

Completa las cinco filas de `validation`. Pon `confirmed: true` solo después de escribir la prueba concreta en `evidence`:

| Clave | Qué tiene que anotar el ingeniero |
|---|---|
| `build_map` | Qué bitstream, DTBO y build hay, y cómo se relacionan con todos los mapas UIO del lector |
| `binary_dependencies` | ELF, su fuente o receta, arquitectura, intérprete y bibliotecas que se usan. Que el nombre se parezca no alcanza |
| `read_semantics` | Para esa IP, que los offsets `0x00..0x2c`, el orden y los efectos de leer son los esperados, incluso abriendo y cerrando muchas veces, y que esa CLI no escribe |
| `exclusive_operator` | Que hay un solo lector y operador y ningún proceso de hardware atascado. Revisar `/proc` no alcanza |
| `hardware_authorization` | Quién autorizó las lecturas, cuándo y con qué condiciones. Esta documentación no autoriza nada |

Anota también en las notas de la sesión la configuración del FE y del lpGBT, que se descartaron generadores y loopback, el canal, la fibra, el e-link y qué abarcarían futuros resets. Marcar estas filas no sustituye la prueba de origen.

El resultado es un plan que un colega puede revisar. Si algo no se sabe, deja `confirmed: false` y sigue con inventario y análisis sin la placa. Una declaración equivocada puede abrir paso a accesos peligrosos. Con la validación cerrada y una autorización aparte, sigue con S2; si no, pide el dato que falta.

Que hashes y mapas coincidan no prueba que encajen con el PL cargado. La comprobación frena errores conocidos; no certifica nada.

## 5. S2: primero un ensayo corto, después una observación larga

Objetivo: registrar resultados completos, duraciones, errores y cambios sin perder la primera anomalía.

Necesitas S1 cerrado, un lector compatible, un solo operador, ningún proceso de hardware bloqueado y ningún cambio de firmware, bibliotecas o mapa durante el ensayo. Empieza con tres muestras, no con horas de sondeo.

```bash
python3 diagnostico/atlas_diagnostico.py capturar \
  --plan plan_lectura_01.json --salida sesion_corta_01 \
  --fase caracterizacion_inicial --muestras 3 --intervalo 5 --timeout 3 \
  --autorizar-lecturas
```

Antes de cada ejecución revisa las declaraciones, los hashes, `LD_LIBRARY_PATH` y los mapas, y rechaza `LD_PRELOAD` o `LD_AUDIT` activos. Anota el intento y ejecuta solo `[ruta_del_lector]`, sin shell ni argumentos. La CLI abre y mapea el UIO, lee los doce registros y sale [B01/B02]. Espera cinco segundos después de cada ejecución; como también cuentan las comprobaciones y el proceso, no es un muestreo exacto a 0,2 Hz.

Cada muestra guarda stdout y stderr por separado, el JSON interpretado, el retorno, los tiempos y el XOR con la anterior. Las líneas del constructor y el decimal final se guardan, sin confundirlas con registros. Si cambia `magic` o `clk_thresh`, la sesión para. También para si falta un campo, hay duplicados, stderr no está vacío, el código de salida no es cero, hay timeout o demasiada salida. Nunca cambia un error por un cero.

Lo esperado son tres muestras completas, el supervisor devolviendo `0` y un cierre limpio. `0` significa que terminó o que llegó al límite de repeticiones; no significa que los datos del FE sean buenos. Con `2`, revisa el mensaje y la sesión. `130` suele ser que el operador interrumpió entre muestras; si interrumpe dentro del lector, queda `operator_interrupt` y la sesión devuelve `2`. Si el hijo muere por una señal, se guarda como retorno negativo, por ejemplo `-7` para SIGBUS en los Linux donde SIGBUS vale 7; ese número no es igual en todas las arquitecturas.

Leer puede borrar datos, y relanzar la aplicación cada vez no es lo mismo que un proceso que corre seguido. Redirigir stdout cambia el buffering, así que una salida a medias no dice cuál fue la última lectura completa. El registro y los hashes añaden carga. No uses esto para medir rendimiento.

Revisa a mano la salida y los tiempos del ensayo corto. Si están bien y el procedimiento está autorizado, alárgalo:

```bash
python3 diagnostico/atlas_diagnostico.py capturar \
  --plan plan_lectura_01.json --salida sesion_larga_01 \
  --fase observacion_continua --muestras 720 --intervalo 5 --timeout 3 \
  --autorizar-lecturas
```

Son 720 intentos: más o menos una hora, más el tiempo de ejecución y comprobaciones. Los límites son 3600 muestras, 64 KiB por salida, timeout de 0,1 a 30 s e intervalo mínimo de 1 s. Una sesión no puede durar en teoría más de 24 h, pero eso no vigila ni el disco ni el kernel.

Si quieres, `--detener-iguales 12` para después de doce transiciones seguidas con los nueve grupos iguales (hacen falta trece muestras). Úsalo solo cuando quieras parar y mirar; viene apagado porque el FE puede mandar datos iguales de verdad. Los cambios de header se anotan aparte y no reinician ese contador.

### Timeout y bloqueo preventivo

Si se acaba el tiempo o hay demasiada salida, el supervisor mira a su hijo y manda SIGTERM y luego SIGKILL a su propio grupo de procesos, con esperas cortas. Guarda `alive_after_signals`. Puede quedar un proceso vivo con un acceso pendiente, y en ese caso no lanza ninguna muestra más. Nunca manda señales al programa original que inspeccionaste con `--pid`.

`/tmp/atlas-tgc-diagnostico.lock` evita dos capturas a la vez del mismo script, y se queda escrito si algo falla o se cierra mal. Mientras exista, una sesión nueva no arranca. No frena herramientas ajenas ni otro equipo o contenedor, y `/tmp` puede borrarse al reiniciar. No es un bloqueo del hardware.

Antes de borrar ese archivo a mano: guárdalo, identifica el supervisor, el hijo y sus sesiones, confirma que ya no hay proceso ni acceso pendiente, mira qué causó la anomalía y consigue autorización para seguir. No hay un comando automático de desbloqueo ni de reset. Borrar el lock con un proceso que lo tiene abierto rompe la exclusión.

## 6. S3: estímulo A/B/A y fallo antes y después

Objetivo: intentar descartar una fuente interna o una muestra retenida con un cambio externo conocido.

Necesitas un método de estímulo del FE validado por el ingeniero y la configuración en uso documentada. Con los archivos recuperados no se puede decir cuál es ese método ni qué fuente está elegida. No escribas registros del chip desde este script para «probar opciones». La etapa D de la guía de campo cubre esto.

Con una observación en marcha, desde otra terminal puedes anotar un cambio que ya hiciste:

```bash
python3 diagnostico/atlas_diagnostico.py anotar --sesion sesion_larga_01 \
  --texto 'FASE A: describir estado externo y evidencia de que llega físicamente al FE/e-link.'
python3 diagnostico/atlas_diagnostico.py anotar --sesion sesion_larga_01 \
  --texto 'FASE B: describir estímulo externo aplicado, canal, amplitud/frecuencia y medición independiente.'
python3 diagnostico/atlas_diagnostico.py anotar --sesion sesion_larga_01 \
  --texto 'FASE A2: describir retorno al estado A y observación externa.'
```

Son plantillas: cambia el texto por lo que pasó y ejecuta cada orden en su momento, no las tres seguidas. Las etiquetas no hacen nada en el hardware. La hora es la de la anotación, no necesariamente la del estímulo. Si el cambio cae mientras se está tomando una muestra, márcala como dudosa.

Mantén cada fase durante varias muestras, anota la latencia y la retención esperadas si están documentadas, y repite A/B/A al menos tres veces si se puede. Compara los mismos grupos y guarda los controles del enlace sacados con el procedimiento B ya autorizado, sin añadir otro lector a la vez.

Si los cambios siguen al estímulo de forma repetible y vuelven a A después del tiempo de retención esperado, eso apunta a recepción externa. Un XOR distinto de cero no basta: tienen que encajar el canal, el formato y los tiempos.

Si B no hace nada aunque el estímulo llegó, el problema está en el origen, el canal, la captura o en cómo se muestra. Si los cambios siguen sin importar el estímulo, puede ser un generador, otra fuente, ruido o un formato que no entendemos. Si solo funciona con loopback, el uplink de prueba anda pero el FE sigue sin probarse. Si A2 no vuelve a A, puede ser una retención documentada; sin saberlo, no lo des por fallo.

Si aparece el congelamiento, anota qué se paró y guarda la sesión. Si Linux responde, haz S0 con el PID que falló. Antes de recuperar a mano con autorización, anota qué vas a reiniciar: proceso, capturador, core, MGT, PL, PS o alimentación. Después, haz un inventario nuevo y revisa el plan; no lo reutilices sin mirar. Abre otra sesión con la fase `post_recuperacion` y guarda las dos. El script no recupera ni reinicia nada.

Riesgos: anotaciones equivocadas, horas tardías, varios operadores a la vez y un estímulo sin comprobar. Si `UserData` cambia pero lo que se ve por AXI no, hace falta instrumentar la captura y el rearme. Si `UserData` también se para, mira el enlace, el CDC y los relojes. Esta CLI no ve esas señales: hace falta un ILA existente o el RTL y la build.

## 7. S4: informe sin conexión y paquete para el diagnóstico remoto

Objetivo: analizar sin volver a tocar el hardware.

```bash
python3 diagnostico/atlas_diagnostico.py informe \
  --sesion sesion_larga_01 --salida informe_larga_01.md
```

Resume intentos, resultados, tiempos, repeticiones y cambios en bits altos que el byte bajo no muestra, e incluye las notas del operador. Avisa si hay líneas incompletas o intentos sin resultado, sin inventar lecturas que no pasaron. No decide la causa.

Sale un informe Markdown y los originales quedan intactos. Para comparar A y B en la web, carga los `muestra_00000.out` que correspondan; no cargues el JSONL entero en el comparador. Elige muestras de fases comprobadas, no la primera y la última sin más.

Para el análisis remoto, manda la carpeta de la sesión completa, el informe, el inventario previo y las pruebas de build, configuración y estímulo. Revisa rutas e identificadores internos antes de compartir. El script no comprime ni manda nada. Los `.out` y `.err` son texto UTF-8 con los bytes inválidos reemplazados, no una copia binaria exacta; la CLI recuperada imprime ASCII.

Si un archivo ya existe, elige otro nombre en vez de pisar evidencia. Si el informe no tiene muestras completas, analiza la interrupción o los errores; no lo leas como nueve grupos en cero. Cuidado con tratar las notas a mano como mediciones o con comparar sesiones de distinta configuración. Después, clasifica H1–H7 con [Lecturas congeladas](10_BLOQUEO_LECTURAS.md) y pide la observación que falte.

## 8. Pruebas, límites y lo que falta

Lo nuevo es un envoltorio que observa, escrito porque el usuario pidió un script. No cambia la CLI, `libuio`, `LpGbtSw`, el firmware ni el protocolo de acceso original.

Se diseñó a partir del [catálogo](02_CATALOGO.md), las [incompatibilidades](11_COMPATIBILIDAD.md), B01/B02 (CLI y wrapper), B10 (esperas IC) y B11 (máscara de byte). Los extractos con líneas y hashes están en `evidencias.json` y en la web. B10 explica por qué no se usa `lpGbtRegister` como lector pasivo, no por qué falla la CLI de payload.

Pruebas locales, sin hardware:

```bash
python3 -m unittest discover -s diagnostico -p 'test_*.py' -v
```

Usan ejecutables falsos en carpetas temporales para probar retorno, stderr, señales, timeout, exceso de salida y la parada tras el primer error. También prueban el parser del formato recuperado, las 32 posiciones de bit, el rechazo de duplicados e incompletos, un UIO ambiguo, validaciones pendientes, un hash distinto, el lock, un diario interrumpido y que el inventario no lance procesos. Los ejemplos falsos no son datos de ATLAS.

Falta: correr el inventario en la Trenz, ver qué Python tiene, validar ELF, mapa y lectura, hacer el ensayo corto autorizado y ver qué pasa cuando AXI deja de responder de verdad. No se probó un proceso del kernel no interrumpible ni una caída completa del PS, y que el timeout funcione en local no garantiza que el hardware se recupere.

Si el supervisor muere con SIGKILL o se corta la luz, el hijo y la evidencia pueden quedar a medias. SIGTERM y SIGHUP se tratan como interrupciones cuando Python puede procesarlas, pero no se garantiza que reaccione durante un bloqueo del kernel. El lock y el intento guardado sirven para detectar cierres sucios, no para evitarlos.

No se añadió un contador de frescura, captura coherente de frames ni monitor del MGT. Hacerlo sin saber cómo se comporta el hardware cargado convertiría hipótesis en instrumentos que engañan. El siguiente paso útil es correr S0 y cerrar el plan de S1, no automatizar más accesos.
