# Script de diagnóstico: conservar el bloqueo y separar sus causas

**Entregable nuevo, 25-10-2026. VERIFICADO mediante pruebas de software locales; NO validado en la Trenz.** El script `diagnostico/atlas_diagnostico.py` acompaña al tooling existente. No implementa MMIO, no escribe registros, no programa el lpGBT, no cambia el estímulo y no reinicia nada. En modo `capturar` ejecuta la CLI existente, que sí accede al hardware y cuyas lecturas pueden tener efectos laterales si el mapa no corresponde.

Su objetivo es contestar: **¿qué dejó de avanzar, cuándo y bajo qué condiciones?** No promete identificar una causa interna del FPGA sin señales de progreso observables. La causa del bloqueo histórico sigue DESCONOCIDA.

## 1. Qué se puede aprender

| Evidencia conservada | Pregunta que ayuda a responder | Límite |
|---|---|---|
| Intento registrado antes de lanzar la CLI; resultado y duración después | ¿El comando terminó o quedó un intento sin resultado? | Si Linux se bloquea, no hay garantía de persistencia completa ni localización de la instrucción |
| stdout, stderr, código de salida y estado del proceso al fallar | ¿Fue valor repetido, error, señal o espera? | Un timeout no demuestra fallo AXI; el buffering puede ocultar impresiones anteriores al bloqueo |
| Los nueve grupos completos, XOR y bits diferentes | ¿Solo parecía quieto porque se observaba el byte bajo? | Las nueve lecturas son independientes; no forman un snapshot demostrado |
| `magic` y `clk_thresh` | ¿Cambió identidad aparente o configuración durante la prueba? | `magic` esperado sigue sin estar establecido para la build activa; no es identificación criptográfica |
| Sysfs UIO, hashes del lector y dependencias declaradas | ¿Estamos mezclando mapa, binario o biblioteca? | Sysfs no acredita que el PL cargado implemente ese mapa; no se resuelve automáticamente el enlazado dinámico |
| UTC, tiempo monotónico, boot ID y observaciones del operador | ¿Cuánto pasó hasta el fallo y qué cambió antes? | El timestamp corresponde a software, no a la llegada del frame |
| Estímulo A/B/A registrado manualmente | ¿Los cambios se correlacionan de forma repetible con una causa externa? | La correlación no demuestra por sí sola la ruta ni descarta un loopback |

El script distingue explícitamente muestras incompletas de ceros. Payload repetido se informa como **repetición**, no como «receptor congelado». No se decodifica `data_header` como número de evento porque su semántica no está demostrada.

## 2. Requisitos y alcance

Linux, Python 3.7 o posterior, biblioteca estándar y un directorio local con espacio libre. No instalar dependencias desde Internet ni usar `sudo` automáticamente. Comprobar primero:

```bash
python3 --version
# Desde la raíz de la copia de atlas_emc:
cd docs/recuperacion
python3 diagnostico/atlas_diagnostico.py --help
```

**Estos son comandos nuevos propuestos y comprobados localmente**, no comandos históricos. El `--help` pertenece a nuestro script y no lanza hardware. No ejecutar `tgc_readuplink_cli --help`: la CLI recuperada no interpreta opciones y realizaría sus lecturas [B01].

Modos disponibles: `inventario`, `identidad`, `preparar`, `capturar`, `anotar`, `informe`. Solo `capturar` ejecuta un proceso hardware. No hay modo genérico para introducir `devmem`, `lpGbtRegister`, un script de pruebas o un comando de reset. El perfil está limitado a la variante recuperada de nueve grupos de `tgc_readuplink_cli`.

**Riesgos residuales:** CPU, disco y sondeos pueden cambiar el comportamiento temporal; una lectura con efecto lateral puede consumir o alterar datos. El timeout es del supervisor: no cancela de forma fiable una transacción AXI ni garantiza que un proceso en estado no interrumpible desaparezca. Si se bloquea el sistema entero, también puede detenerse este recolector.

## 3. Procedimiento S0 — inventario sin lecturas MMIO

**Objetivo:** obtener contexto y, si el fallo ya existe, conservar el estado del proceso antes de reiniciar.

**Condiciones:** Linux responde; directorio de trabajo escribible; no hace falta haber cerrado el mapa FPGA. No lanzar otra aplicación de hardware para este paso.

```bash
python3 diagnostico/atlas_diagnostico.py inventario --salida inventario_01.json
```

Si ya se conoce la ruta absoluta del ejecutable, incluir su identidad sin ejecutarlo:

```bash
printf 'Ruta absoluta del tgc_readuplink_cli identificado: '
read -r LECTOR
python3 diagnostico/atlas_diagnostico.py inventario \
  --lector "$LECTOR" --salida inventario_lector_01.json
```

Si el programa original está actualmente atascado, inspeccionar su PID en lugar de iniciar `capturar`:

```bash
printf 'PID del proceso que ya está fallando: '
read -r PID_FALLO
python3 diagnostico/atlas_diagnostico.py inventario \
  --pid "$PID_FALLO" --salida inventario_fallo_01.json
```

**Qué hace:** lee archivos concretos de `/proc` y metadatos de `/sys/class/uio`, Device Tree, FPGA manager y overlays presentes. Lee cabecera ELF y SHA-256 si se indicó un archivo. Busca candidatos a lectores por nombre, descriptores y mapeos. No abre `/dev/uioN` ni `/dev/mem`, no ejecuta `lsuio`, `ldd`, scripts o binarios de hardware. No recoge el entorno completo ni contraseñas; los mapas, rutas y variables `LD_*` seleccionadas sí pueden contener información interna.

**Resultado esperado:** JSON con UIO/mapas disponibles y errores de permisos/atributos inexistentes conservados. Un mapa vacío o un FPGA manager sin `firmware` no es un fallo del script ni prueba de PL vacío. Los metadatos expuestos no identifican por sí solos el bitstream activo.

**Alternativas:** `possible_readers.candidates` es una pista; nombres truncados, permisos y carreras impiden garantizar exclusividad. `unreadable_maps` informa parte de esa falta de cobertura. No mata procesos ajenos. Si no hay Python, usar F0 de [Lecturas congeladas](10_BLOQUEO_LECTURAS.md); no instalarlo durante un fallo si eso destruye la evidencia.

**Riesgos:** consumo de CPU/disco, inspección parcial y datos internos en el archivo. **Siguiente decisión:** proceso original sin terminar → conservar inventario y revisar su ruta de ejecución; CLI conocida, mapa y permisos aún pendientes → S1. No saltar directamente a capturar.

## 4. Procedimiento S1 — plan de lectura revisable

**Objetivo:** fijar qué ELF, bibliotecas y mapa se autorizan para la sesión. La plantilla comienza bloqueada.

**Condiciones:** S0 con `--lector`; exactamente un UIO llamado `tgc_readUplink_regs`; `map0` de al menos `0x30` bytes, base alineada y offset sysfs cero. Si falla esto, este perfil no se adapta probando direcciones alternativas.

```bash
python3 diagnostico/atlas_diagnostico.py preparar \
  --inventario inventario_lector_01.json --salida plan_lectura_01.json
```

**Qué hace:** copia la identidad del lector y los mapas del inventario; no ejecuta la CLI. Crea `validation` con cinco confirmaciones inicialmente falsas y `libraries` vacío. No elige una dirección histórica como correcta.

Revisar A2 y el punto de parada previo a MMIO de la [guía de campo](00_GUIA_CAMPO.md). Identificar el intérprete y bibliotecas efectivamente usados mediante ELF, receta de compilación y configuración del loader. Para cada archivo identificado:

```bash
printf 'Ruta absoluta de biblioteca o intérprete ya identificado: '
read -r BIBLIOTECA
python3 diagnostico/atlas_diagnostico.py identidad "$BIBLIOTECA"
```

Añadir cada objeto JSON obtenido a la lista `libraries` del plan: intérprete, `libuio`, runtime C++ y dependencias restantes que correspondan al ELF. El script comprueba esos hashes, **no que la lista esté completa ni que el loader realmente elija esos archivos**. Si el binario es estático o no corresponde a esta variante, detener y adaptar el perfil después de investigar; no inventar una biblioteca para pasar la comprobación.

Completar las cinco filas de `validation`, poniendo `confirmed: true` **solo después** de aportar evidencia concreta en `evidence`:

| Clave | Evidencia que debe registrar el ingeniero |
|---|---|
| `build_map` | Identidad de bitstream/DTBO/build y conexión documentada con todos los mapas UIO del lector |
| `binary_dependencies` | ELF, fuente/receta correspondiente, arquitectura, intérprete y bibliotecas efectivas; no basta semejanza del nombre |
| `read_semantics` | Confirmación para esa IP de offsets `0x00..0x2c`, orden y efectos de lectura, incluyendo aperturas/cierres repetidos y ausencia de escrituras en esa CLI |
| `exclusive_operator` | Coordinación de un solo lector/operador y ausencia de procesos hardware atascados; no basta el escaneo de `/proc` |
| `hardware_authorization` | Quién autorizó esas lecturas, cuándo y bajo qué condiciones; esta documentación no constituye autorización |

Conservar además la configuración FE/lpGBT, exclusión de generadores/loopback, canal, fibra, e-link y alcance de futuros resets en las notas de sesión. La evidencia que falta para una prueba de origen no se subsana marcando estas filas.

**Resultado esperado:** plan que un colega pueda revisar. **Alternativa:** cualquier desconocido mantiene `confirmed: false`; se puede continuar con inventario y análisis offline. **Riesgos:** una declaración incorrecta puede permitir accesos inseguros. **Siguiente decisión:** validación cerrada y autorización independiente → S2; en otro caso pedir el dato faltante.

**Refutación de la premisa:** hashes y mapas coincidentes no demuestran compatibilidad con el PL activo. La comprobación es una barrera contra discrepancias conocidas, no una certificación automática.

## 5. Procedimiento S2 — ensayo corto, después observación prolongada

**Objetivo:** registrar resultados completos, duración, errores y cambios sin perder la primera anomalía.

**Condiciones:** S1 cerrado; lector ya compatible; un solo operador; sin proceso hardware bloqueado; ningún cambio de firmware, bibliotecas o mapa durante el ensayo. Empezar con tres muestras, no con horas de sondeo.

```bash
python3 diagnostico/atlas_diagnostico.py capturar \
  --plan plan_lectura_01.json --salida sesion_corta_01 \
  --fase caracterizacion_inicial --muestras 3 --intervalo 5 --timeout 3 \
  --autorizar-lecturas
```

**Qué hace realmente:** comprueba las declaraciones, hashes, entorno `LD_LIBRARY_PATH` y mapas antes de cada ejecución; rechaza `LD_PRELOAD`/`LD_AUDIT` activos. Registra un intento y ejecuta exclusivamente `[ruta_del_lector]`, sin shell ni argumentos. La CLI abre/mapea UIO, lee los doce registros y sale [B01/B02]. Duerme cinco segundos **después** de cada ejecución; la cadencia incluye también comprobaciones y tiempo de proceso. No es muestreo a 0,2 Hz exactos.

Cada muestra conserva stdout/stderr en archivos separados, JSON parseado, retorno, tiempos y XOR frente a la anterior. Las líneas de constructor y el decimal final se conservan; no se confunden con registros. Si cambia `magic` o `clk_thresh`, detiene la sesión. Si falta un campo, hay duplicados, stderr no vacío, código de salida distinto de cero, timeout o exceso de salida, también detiene. No reemplaza el error por cero.

**Resultado esperado:** tres muestras completas; retorno del supervisor `0` y cierre limpio. `0` significa ejecución completa o umbral de repetición alcanzado, **no datos FE válidos**. Un retorno `2` requiere revisar el mensaje y la sesión; `130` puede indicar interrupción del operador entre muestras. Si la interrupción ocurre dentro del lector, queda `operator_interrupt` y la sesión devuelve `2`. Una señal del hijo se conserva como retorno negativo: por ejemplo `-7` para SIGBUS en las plataformas Linux donde SIGBUS=7; no codificar ese número como portable a todas las arquitecturas.

**Riesgos:** leer puede consumir datos; relanzar la aplicación cambia la condición experimental respecto de un proceso persistente. Redirección de stdout cambia buffering: una salida parcial no permite localizar exactamente la última lectura completada. El registro y los hashes añaden carga. No usar este ensayo como medida de rendimiento.

**Siguiente decisión:** comprobar manualmente salida y tiempos del ensayo corto. Si son consistentes y el procedimiento está autorizado, ampliar:

```bash
python3 diagnostico/atlas_diagnostico.py capturar \
  --plan plan_lectura_01.json --salida sesion_larga_01 \
  --fase observacion_continua --muestras 720 --intervalo 5 --timeout 3 \
  --autorizar-lecturas
```

Son 720 intentos, aproximadamente una hora **más** ejecución y comprobaciones; no una garantía de duración exacta. Hay límites de 3600 muestras, 64 KiB por flujo de salida, timeout de 0,1–30 s e intervalo mínimo de 1 s. El presupuesto nominal de duración de una sesión no puede superar 24 h; no es un watchdog global de disco/kernel.

Opcional: `--detener-iguales 12` para parar después de doce transiciones consecutivas con los nueve grupos idénticos. Se necesitan trece muestras para observar doce transiciones. Usarlo solamente cuando sea útil detener y examinar; por defecto está desactivado porque el FE puede producir datos idénticos legítimos. Los cambios de header se registran por separado y no rompen este contador de payload.

### Timeout y bloqueo preventivo

Al expirar el tiempo o exceder la salida, el supervisor inspecciona su hijo, envía SIGTERM y después SIGKILL a su propio grupo de procesos, con esperas acotadas. Conserva `alive_after_signals`. **Puede quedar un proceso vivo y un acceso pendiente.** Nunca inicia otra muestra después de esa anomalía. No envía señales al programa original inspeccionado con `--pid`.

El archivo `/tmp/atlas-tgc-diagnostico.lock` evita dos capturas cooperantes y queda con contenido tras un fallo o cierre no limpio. Una nueva sesión se niega a continuar. Esto no bloquea herramientas ajenas ni otro host/contenedor, y `/tmp` puede perderse al reiniciar. No es un interlock hardware.

Antes de retirar manualmente ese archivo: conservarlo, identificar el supervisor/hijo y sus sesiones, confirmar que ya no hay proceso o acceso pendiente, revisar el origen de la anomalía y obtener autorización para continuar. No se incluye una orden automática de desbloqueo ni de reset. Borrar un lock mientras un proceso lo tiene abierto puede invalidar la exclusión.

## 6. Procedimiento S3 — estímulo A/B/A y fallo antes/después

**Objetivo:** intentar refutar una fuente interna o una muestra retenida mediante una intervención externa conocida.

**Condiciones:** mecanismo de estímulo FE validado por el ingeniero y configuración efectiva documentada. Los archivos recuperados **no bastan para prescribir ese mecanismo ni la selección actual del origen**. No escribir registros del chip para «probar opciones» desde este script. Usar D de la guía de campo para cerrar este punto.

Con una sesión de observación en marcha, desde otra terminal se puede registrar una intervención manual ya realizada:

```bash
python3 diagnostico/atlas_diagnostico.py anotar --sesion sesion_larga_01 \
  --texto 'FASE A: describir estado externo y evidencia de que llega físicamente al FE/e-link.'
python3 diagnostico/atlas_diagnostico.py anotar --sesion sesion_larga_01 \
  --texto 'FASE B: describir estímulo externo aplicado, canal, amplitud/frecuencia y medición independiente.'
python3 diagnostico/atlas_diagnostico.py anotar --sesion sesion_larga_01 \
  --texto 'FASE A2: describir retorno al estado A y observación externa.'
```

**Son plantillas de anotación:** sustituir el texto por lo ocurrido y ejecutar cada orden en su momento; no copiarlas consecutivamente como si hubieran ocurrido tres fases. Las etiquetas no accionan hardware. El timestamp es el de la anotación, no necesariamente el instante del estímulo. Si la transición cae dentro del intervalo de ejecución de una muestra, marcar esa muestra como ambigua.

Mantener cada fase durante varias muestras, registrar latencia/retención esperadas si están documentadas y repetir A/B/A al menos tres veces si resulta viable. Comparar los mismos grupos y conservar controles de enlace obtenidos mediante el procedimiento B ya autorizado, sin añadir otro lector simultáneo.

**Resultado esperado y fundamento:** cambios reproducibles compatibles con el estímulo y vuelta a A tras el tiempo de vaciado/retención esperado favorecen la hipótesis de recepción externa. No basta cualquier XOR distinto de cero. Deben concordar canal, formato y comportamiento temporal.

**Resultados alternativos:** B no produce efecto pese a comprobar estímulo físico → origen/canal/captura o representación incorrectos; cambios continúan independientemente del estímulo → generador, otra fuente, ruido o formato no entendido; solo funciona con loopback → uplink de prueba funcional, recepción FE aún no demostrada. A2 no vuelve a A puede ser retención documentada; sin esa semántica no declarar fallo definitivo.

Si aparece el congelamiento, anotar qué se detuvo y conservar la sesión. Si Linux responde, ejecutar S0 con el PID original que falló. Antes de cualquier recuperación manual autorizada, registrar su alcance: proceso, capturador, core, MGT, reconfiguración PL, reboot PS o alimentación. Después, hacer inventario nuevo y revisar el plan; no reutilizarlo a ciegas. Crear otra sesión con fase `post_recuperacion` y conservar ambas. El script no recupera ni reinicia.

**Riesgos:** anotaciones erróneas, timestamps tardíos, interacción entre operadores y estímulo no demostrado. **Siguiente decisión:** si `UserData` cambia pero no lo expuesto a AXI, hace falta instrumentar captura/rearme; si también se detiene `UserData`, investigar enlace/CDC/relojes. Esas señales no son observables por esta CLI; obtener ILA existente o RTL/build, no inferirlas del texto.

## 7. Procedimiento S4 — informe offline y paquete para diagnóstico remoto

**Objetivo:** analizar sin volver a tocar hardware.

```bash
python3 diagnostico/atlas_diagnostico.py informe \
  --sesion sesion_larga_01 --salida informe_larga_01.md
```

**Qué hace:** resume intentos, resultados, tiempos, repeticiones y cambios en bits altos invisibles al byte bajo. Incluye las notas del operador. Advierte ante líneas incompletas o intentos sin resultado; no reconstruye una lectura que no ocurrió. No asigna causa raíz automáticamente.

**Resultado esperado:** informe Markdown y originales intactos. Para comparar A/B en la web local, cargar los archivos `muestra_00000.out` correspondientes; no cargar todo el JSONL en el comparador de dos capturas. Elegir muestras de fases verificadas, no la primera y última por defecto.

Enviar para análisis remoto la carpeta de sesión completa, el informe, el inventario previo y las pruebas de build/configuración/estímulo relacionadas. Revisar rutas e identificadores internos antes de compartir. El script no comprime ni envía nada automáticamente. Los archivos `.out/.err` son texto UTF-8 con sustitución de bytes inválidos; no una copia binaria forense arbitraria. La CLI recuperada produce texto ASCII.

**Alternativas:** error de archivo existente → elegir otro nombre, no sobrescribir evidencia. Informe sin muestras completas → analizar la interrupción/errores, no tratarlo como nueve grupos de ceros. **Riesgos:** interpretar las notas manuales como mediciones, comparar sesiones con distinta configuración. **Siguiente decisión:** clasificar H1–H7 usando [Lecturas congeladas](10_BLOQUEO_LECTURAS.md) y solicitar la observación que falte.

## 8. Revisión adversarial, pruebas y límites pendientes

La implementación nueva es un **envoltorio de observación**, autorizado por la petición del usuario de diseñar un script. No modifica la CLI, `libuio`, `LpGbtSw`, firmware ni el protocolo de acceso original.

Evidencia de diseño: [catálogo](02_CATALOGO.md), [incompatibilidades](11_COMPATIBILIDAD.md), B01/B02 (CLI y wrapper), B10 (esperas IC), B11 (máscara de byte). Los extractos originales con líneas y hashes están en `evidencias.json` y la web. B10 justifica no reutilizar `lpGbtRegister` como lector pasivo, no atribuirle el fallo de la CLI payload.

Pruebas locales reproducibles, **sin hardware**:

```bash
python3 -m unittest discover -s diagnostico -p 'test_*.py' -v
```

Se usan ejecutables sintéticos en directorios temporales para comprobar retorno, stderr, señal, timeout, exceso de salida y detención tras el primer error; parser de formato recuperado, 32 posiciones de bit, rechazo de duplicados/incompletos, contrato UIO ambiguo, validaciones pendientes, hash distinto, lock, diario interrumpido e inventario que no lanza procesos. Los ejemplos sintéticos no representan datos de ATLAS.

Pendiente: ejecutar inventario en la Trenz; comprobar disponibilidad/versiones de Python; validar ELF/mapa/semántica; ejecutar el ensayo corto autorizado; verificar comportamiento bajo pérdida real de respuesta AXI. No se ha ensayado un proceso kernel verdaderamente no interrumpible ni una caída completa del PS. Las pruebas locales del timeout no garantizan recuperación del hardware.

Un supervisor terminado con SIGKILL o una pérdida de alimentación puede dejar hijo/evidencia incompleta. SIGTERM/SIGHUP se tratan como interrupciones cuando Python puede procesarlas, sin promesa de reacción durante un bloqueo del kernel. El archivo de lock y el intento persistido permiten detectar cierres no limpios, no impedirlos.

No hay contador de frescura añadido, captura coherente de frames ni monitor MGT automático. Añadirlos sin la semántica del hardware activo sería convertir hipótesis en instrumentos engañosos. El siguiente avance útil depende de **ejecutar S0 y cerrar el contrato de S1**, no de automatizar más accesos.
