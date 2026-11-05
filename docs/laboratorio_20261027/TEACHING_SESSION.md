# Cinco lecciones para razonar en el laboratorio

[Inicio](START_HERE.md) · [Guion experimental](LAB_SESSION.md) · [Pauta de respuestas](#pauta-de-respuestas--consultar-después)

Dedicar unos 8–12 minutos por lección antes de la sesión o durante una puerta bloqueada. No se suman automáticamente a los 120 minutos de laboratorio. Usar las fuentes B del [atlas](TOOL_AND_PATH_ATLAS.md), no ejecutar sus binarios. Escribir una predicción **antes** de leer la pauta. En una sesión interactiva posterior: una pregunta por turno, evaluar el razonamiento, dar una pista y permitir corregir antes de revelar la respuesta.

## Lección 1 — Recibir no es imprimir

**Intuición física.** Un voltímetro puede conservar su última lectura aunque se haya desconectado la señal. Del mismo modo, un registro legible puede contener datos antiguos. Recibir exige una cadena causal entre el cambio externo y lo que observamos.

**Arquitectura.** FE → e-link → selección de fuente del lpGBT → enlace óptico → MGT → core uplink → CDC → capturador → AXI → Linux. Cada frontera tiene un contrato diferente; Linux no recibe directamente una trama óptica.

**Código real.** Abrir B/read_all_lpgbt/tgc_readuplink_cli.cpp:21–55 y B/emp-tools/src/fwMonitor/fwMonitor.cpp:35–45. Luego [R03](TOOL_AND_PATH_ATLAS.md#r03): `emp_lpgbt.vhd:473–498`, que separa UserData/EC/IC tras CDC, y `cdc_rx.vhd:150–218`. La CLI muestra palabras; el monitor muestra estados. Ninguno de esos dos códigos mide por sí solo la procedencia FE.

**Ejercicio y predicción.** Dibujar tres columnas: magnitud física, señal de FPGA y palabra Linux. Elegir un estímulo que el ingeniero pueda verificar y proponer dónde debería observarse el cambio. En cada columna escribir «observable con herramientas actuales» o «requiere evidencia adicional».

**Pregunta de diagnóstico.** `RX locked=1`, la CLI termina y todos los grupos se repiten durante A/B/A. ¿Qué conclusión aceptarías, cuál rechazarías y qué medirías a continuación? Da dos explicaciones que los mismos resultados todavía no distinguen.

**Comprobación.** Buscar qué alimenta RX locked en [R03/debughub](TOOL_AND_PATH_ATLAS.md#r03) y qué condición hace subir ready en CDC. Separar lo comprobado por el código de la conexión activa desconocida.

**Interpretación.** Completar: «El indicador demuestra ___ en esta implementación; para demostrar FE aún falta ___». No resolver una incertidumbre de origen repitiendo más veces el mismo estado.

## Lección 2 — Una dirección necesita un contrato

**Intuición física.** El número de un conector no dice qué instrumento está conectado. Una base AXI puede conservar su número y cambiar de función entre builds.

**Arquitectura.** Dirección física = base + offset de registro. `mmap` crea una dirección virtual. UIO publica nombre, tamaño y offset del mapa; la biblioteca suma el offset sysfs y el del registro. La selección del mapa en `mmap` usa múltiplos del tamaño de página, no la dirección física.

**Código real.** B/libuio/base.c:246–271 y 344–386; B/libuio/mem.c:209–221; B/read_all_lpgbt/TgcReadUplink.cpp:160–177. Contrastar [R01 y X01](SYSTEM_MAP.md#versiones-incompatibles).

**Ejercicio y predicción, exclusivamente aritmético.** Suponer un contrato TGC ya validado con base A00E0000. Calcular dirección física y offset de `data_group_5`; indicar qué argumento recibe `uio_read32`. Ahora sustituir la build por el BD R01: predecir qué deja de ser válido aunque la suma numérica no cambie. No acceder a esa dirección.

**Pregunta de diagnóstico.** Sysfs anuncia `tgc_readUplink_regs`, map0 de 16 KiB, y el ELF coincide por SHA-256 con el respaldo. ¿Ejecutarías la CLI? Identifica una evidencia faltante que pueda invalidar la compatibilidad y otra que afecte a los efectos de lectura.

**Comprobación.** Localizar la carga `volatile uint32_t` y buscar las comprobaciones de límites/alineación. Revisar si una lectura normal del archivo `/dev/uioN` equivale a leer el payload; contrastar el [UIO HOWTO oficial](https://docs.kernel.org/driver-api/uio-howto.html).

**Interpretación.** Escribir qué garantizan sysfs, hash, `volatile` y el mapa de registros, y qué no garantiza ninguno por separado. No confundir permiso Linux de lectura con semántica hardware sin efectos.

## Lección 3 — Seguir una CLI hasta el bus

**Intuición física.** Un panel puede mostrar un valor sin comprobar su validez. El nombre de una opción como «selftest» no sustituye al código que ejecuta.

**Arquitectura.** CLI → clase → búsqueda por nombre UIO → apertura/mapeo → getter → carga MMIO → máscara → formato de salida. Dependencias dinámicas forman parte del recorrido ejecutado.

**Código real.** B/read_all_lpgbt/tgc_readuplink_cli.cpp; B/read_all_lpgbt/TgcReadUplink.cpp; B/libuio/{base.c,mem.c}; B/puzzled_working/readprbs_cli.cpp:198–201,264–282.

**Ejercicio y predicción.** Trazar `data_group_0` con seis nombres concretos de función desde `main` hasta la instrucción que lee memoria. Contar registros distintos y explicar la línea decimal final. Marcar las funciones que podrían escribir en el wrapper y comprobar si la CLI las invoca.

**Pregunta de diagnóstico.** Un colega propone ejecutar `tgc_readuplink_cli --help` para inspeccionar opciones y luego `readprbs_cli --selftest` para certificar el receptor. ¿Qué cambiarías y por qué? No responder solo «es peligroso»: predice los accesos y el significado del resultado.

**Comprobación.** Leer firma de `main`, constructor y getters. En PRBS seguir ramas de `selftest`, `write-data` y `write-control`; comprobar si hay aserción sobre valores leídos. Inspeccionar ELF con `readelf`, sin ejecutarlo, y relacionar `NEEDED` con las bibliotecas reales pendientes de localizar.

**Interpretación.** Una fuente permite explicar lo que pretende hacer ese código; un ELF diferente requiere procedencia adicional. Un `OK` puede significar únicamente que la ejecución llegó al final.

## Lección 4 — Qué demuestra una captura

**Intuición física.** Dos fotos iguales pueden ser de una escena inmóvil o una copia de la misma foto. Un cambio puede ser señal, ruido o un contador interno. Necesitamos una intervención con predicción.

**Arquitectura.** El capturador podría retener muestras, entregar palabras secuenciales o requerir rearme. Nueve registros de 32 bits no prueban que existan 288 bits útiles del mismo evento; UserData de una variante tiene 230 bits. Hace falta el packing real.

**Código y datos reales.** B/read_lpgbt10.sh:4–17; B/watch_devmem.sh:7–25; B/1024/typical_out/{0xAAAAAAAB.txt,0xAAAAAAAE.txt,0xAAAAAAEA.txt}; [mapa TGC](SYSTEM_MAP.md#qué-significa-cada-palabra-del-lector-tgc).

**Ejercicio y predicción.** Comparar esas tres capturas como texto. Enumerar offsets presentes y ausentes. Identificar qué cambia y por qué sus nombres de archivo no certifican el estímulo realmente aplicado ni su momento. Como cálculo **simulado**, comparar `0x123400AA` con `0xABCD00AA`: predecir la salida de una comparación de 32 bits y de `& 0xff`.

**Pregunta de diagnóstico.** En una prueba real, A y A2 coinciden y B cambia siempre el grupo esperado; el packing es desconocido y no se ha leído la selección efectiva PRBS/loopback. ¿Qué puedes afirmar ahora y qué control falta antes de atribuir los datos al FE? ¿Qué observación invalidaría tu predicción original?

**Comprobación.** Diseñar una ficha A/B/A con estímulo medido, canal, plazo de respuesta, muestras alejadas de transiciones y controles de fuente. Comprobar si las capturas antiguas contienen esos metadatos. No inventarlos a partir de timestamps del archivo.

**Interpretación.** Separar cuatro niveles: lectura completa, actualización, sensibilidad causal al estímulo y decodificación correcta. La tasa de errores necesita referencia, número de bits comparados y duración; no se obtiene de tres palabras cambiantes.

## Lección 5 — Intermitencia como experimento

**Intuición física.** Reiniciar un osciloscopio puede recuperar la pantalla sin reparar el sensor. Una intervención que toca varios componentes no identifica cuál falló.

**Arquitectura.** Separar proceso, transacción AXI, captura/rearme, CDC, core/MGT, reloj y origen FE. La ruta IC tiene sus propias esperas y no es la ruta de lectura TGC.

**Código real.** B/LpGbtSw/LpGbtUioBackend/LpGbtUioFunctions.cpp:99–126,172–185,221–230; B/LpGbtSw/LpGbtUioBackend/LpGbtUioBackend.cpp:38–64; B/emp-tools/systemd_service/systemd-programclock.service. Comparar con ausencia de bucle IRQ en la CLI TGC y [RTL alternativo R09](TOOL_AND_PATH_ATLAS.md#r09).

**Ejercicio y predicción.** Preparar dos fichas de fallo: «CLI retorna en tiempo habitual, datos iguales» y «proceso no retorna, Linux responde». Para cada una elegir la primera observación pasiva, una hipótesis y una prueba que la refutaría. Señalar qué evidencia se perdería con reboot.

**Pregunta de diagnóstico.** Después de reiniciar vuelve a funcionar durante un minuto. Un colega concluye «es la FIFO». El reboot también puede reprogramar reloj. ¿Qué experimento mínimo distinguiría dos causas y qué debes conservar antes de hacerlo? No proponer un reset más amplio.

**Comprobación.** Buscar qué bucles IC carecen de límite y comprobar que el timeout de `waitIntr` no limita los bucles restantes. Leer qué ejecuta la unidad systemd, sin asumir que está instalada. Si se usa RTL alternativo para una hipótesis, escribir explícitamente que su presencia en la build activa no está demostrada.

**Interpretación.** Formular una conclusión con condición: «Si ___ progresa y ___ no, investigaremos ___». No localizar el bloqueo MMIO a partir de la última línea stdout sin considerar buffering.

---

## Pauta de respuestas — consultar después

Evaluar cada lección sobre 4 puntos: 1 por predicción concreta; 1 por referencia al código real; 1 por distinguir evidencia/límite; 1 por siguiente medida que discrimina hipótesis. Máximo 20. Una decisión de MMIO sin mapa/semántica validada obliga a revisar la lección 2 independientemente de la nota. No hay nota que autorice hardware.

### 1 — Transporte frente a procedencia

Aceptar: la ejecución observada devuelve palabras y el monitor declara lock conforme a su implementación. Rechazar: «datos FE actuales demostrados». Lock es alineación de cabecera, compatible con fuentes internas. Ready CDC retenido no prueba nuevos strobes. Datos iguales podrían ser FE constante, retención o canal/fuente equivocada. Siguiente medida: verificar estímulo físico y selección de fuente/canal; luego observar progreso en una frontera intermedia con instrumentación validada. No afirmar que el CDC es culpable.

### 2 — Mapa y efectos

Grupo 5: offset `0x04 + 5×4 = 0x18 = 24` bytes; dirección del ejemplo `0xA00E0018`; getter usa map0 y offset24. En R01 esa región corresponde a un controlador de interrupciones, por lo que desaparece el contrato TGC aunque la dirección siga existiendo. Nombre UIO y SHA del ELF no prueban bitstream activo ni efectos de lectura. Se necesita vínculo build/DT/ABI y semántica del capturador. `uio_read32` no valida rango; `volatile` obliga al acceso de C, no a capturar nueve palabras atómicamente. `read()` de `/dev/uioN` pertenece a notificación IRQ, no a payload arbitrario.

### 3 — Accesos y significado de OK

Recorrido: `main` → constructor `TgcReadUplink` → `uio_find_by_uio_name` / `uio_open` → `readDataGroup0Value` → `uio_read32` → carga volatile32 → máscara/formato. Hay doce registros distintos; decimal final repite threshold. El setter existe, pero la CLI no lo ejecuta. `main()` no procesa argumentos, así que `--help` también toca hardware. El selftest PRBS hace lecturas y muestra OK sin comparar datos esperados; no escribe el generador en estas fuentes ni certifica FE. Inspeccionar código/ELF de forma pasiva y reservar pruebas hardware para contratos validados.

### 4 — Capas de validez

Los scripts omiten +0x18, por lo que falta grupo5; una lista de nueve líneas que incluye header no son nueve grupos. En las tres capturas citadas se conservan grupos iniciales presentes y cambia grupo8; falta historial temporal/control físico. En el ejemplo simulado cambia la palabra completa, pero el byte bajo sigue AA; el bucle que compara solo ese byte no termina. A/B/A reproducible permite una afirmación de sensibilidad, reforzada por control independiente; para FE se requiere excluir fuentes internas y demostrar canal/origen. Sin packing no se certifica decodificación. Si B físicamente verificado no cambia los bits que la predicción exige dentro del plazo especificado, esa predicción queda refutada para esa configuración; no demuestra automáticamente una FIFO rota.

### 5 — Una intervención, una frontera

Si retorna, medir datos/estímulo y progreso, no tratarlo como proceso bloqueado. Si no retorna, conservar PID, estado, mapeos, salida/errores y tiempos; no lanzar otro lector. Un proceso D puede sugerir espera kernel, pero no identifica por sí solo AXI. El timeout de IRQ IC no limita clearIntr ni drenaje FIFO. La unidad systemd puede programar reloj en boot si está activa, por lo que reboot no aísla FIFO. Una prueba discriminante adecuada observa simultáneamente —mediante instrumentación ya disponible— UserData antes de captura y dato expuesto: progreso anterior con salida detenida apunta a captura/rearme; pérdida anterior desplaza investigación hacia transporte/reloj. Si se requiere intervención, escoger un único dominio ya documentado y conservar antes/después; su procedimiento lo define el ingeniero. No inventar uno desde las fuentes históricas.

## Aplicar lo aprendido

Sin mirar la pauta, explicar al ingeniero en dos minutos: ejecutable candidato, identidad que falta, función que hace MMIO, límite de lo que significa una palabra y prueba que demostraría actualización externa. Si alguna respuesta depende del RTL TGC faltante, decirlo y pedir exactamente ese contrato; reconocer ese límite es parte de dominar el sistema.
