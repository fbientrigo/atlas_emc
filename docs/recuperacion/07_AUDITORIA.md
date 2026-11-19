# Auditoría: qué se revisó y qué quedó pendiente

## Supuestos que se pusieron a prueba

| Supuesto | Qué se encontró | Qué hace la guía |
|---|---|---|
| Las direcciones antiguas se pueden reusar | El BD pone A00D y A00E en interrupt controllers | Avisa antes de cualquier MMIO y no usa escrituras antiguas como procedimiento. |
| Si hay UIO, el periférico funciona | Una nota tiene un UIO visible con `Bus error`, otra tiene CPU stalls | Separa inventario y lectura, y para ante un fallo en vez de barrer direcciones. |
| `--help` siempre es inofensivo | La CLI de payload no lee argumentos | No recomienda pedirle ayuda a esa CLI. |
| La ayuda del cargador lista opciones que funcionan | `getopts` rechaza las opciones largas antes | Solo usa `-l` y `-h`. El parser se probó aislado, sin correr el cargador. |
| Leer el chip no cambia nada | `lpGbtRegister -r` escribe el controlador y vacía la FIFO | Lo deja fuera del inventario, con condiciones y autorización local. |
| Nueve palabras son un frame | El software no tiene snapshot ni contador | Guarda la captura cruda sin afirmar coherencia ni eventos nuevos. |
| El header valida el payload | El JSON promete un checker, falta el RTL y la CLI solo imprime | Lo marca DESCONOCIDO y no inventa un criterio. |
| «Tenemos lectura» prueba el FE | La nota 1006 usó loopback | Lo trata como prueba de loopback. |
| Nunca se probó el FE | La nota 1028–1031 sí tiene ensayos | Reconoce los ensayos y sus resultados dispares, sin declarar éxito. |
| La nota más nueva corrige el mapa | `Memory Directions`, de enero de 2026, mezcla offsets que no encajan | Deja la contradicción abierta hasta saber la build. |
| «Trenz» identifica la FPGA | El BD declara XCZU4EG/TE0807 y hay otros modelos en juego | Deja el modelo actual por confirmar. |
| Si existe `eLink_Interface`, ya recibe el FE | La fuente está, pero no está en el BD recuperado | La deja como pista a investigar. |
| Se analizó todo el respaldo | Solo el ZIP curado y dos gitingest | Lo dice así y no afirma haber visto el TAR ni los binarios. |

No se cambiaron fuentes originales, no se cargó firmware, no se escribieron registros y no se tocó el hardware. Solo se añadieron documentos, extractos y la web en la rama indicada.

## Comprobaciones de integridad

- Los 77 archivos curados coinciden con los SHA-256 del MANIFEST.
- Se comprobó el baseline de `main` con el árbol completo, y que las fuentes del capturador no aparecen por nombre. Se analizaron componentes, nets y segmentos del BD.
- Se compararon el JSON de nueve grupos, la clase del backup y la variante de un grupo.
- Se revisó el historial por rutas y los archivos cambiados en las revisiones que podían cambiar la lectura.
- Se compararon cuatro archivos de los gitingest con las copias del backup. Coinciden, pero eso no se extiende al repositorio completo.
- Cada extracto de la web lleva ruta, líneas y hash del archivo completo. No se copiaron historiales, credenciales ni notas de acceso.

## Primera verificación de la web

`node verificar_base.mjs --static` sobre el HTML generado dio OK: 10 documentos, 15 fuentes, 8 enlaces Markdown internos, 4 secciones, 11 nodos, 6 tareas y 5 búsquedas técnicas. La prueba compila el JavaScript y ejecuta rutas y vistas con un DOM mínimo en Node; no es una prueba en navegador. También comprueba los enlaces con tildes, los destinos de las tareas y que el HTML no carga nada remoto. Aparte, se revisaron los 19 enlaces locales de todos los Markdown, incluido el README, y los 15 extractos coinciden con sus líneas y hashes.

Durante esa revisión se corrigieron escapes de expresiones regulares y las anclas con tildes.

Faltó probarla en un navegador real: había Playwright pero no Chromium, y la descarga no dio un archivo válido. Por eso no se dan por probados el aspecto visual, el móvil, el foco, los lectores de pantalla ni `file://` en cada navegador. La guía en Markdown sigue disponible si la web falla.

La web no ejecuta comandos, no carga firmware y no envía datos a ningún sistema.

## Lo que una auditoría sin hardware no puede cerrar

No se probó el acceso AXI, la parte eléctrica, la fuente del Serializer, el lock actual, la compatibilidad del ELF, el empaquetado de los grupos, el disparo de la captura ni que los datos del FE lleguen intactos. La prueba A/B/A está propuesta, no hecha. Tampoco hay prueba de adquisición sin pérdidas, aunque una prueba futura con constantes sostenidas salga bien.

P1 se limita a las fuentes recuperadas: falta unir UserData con el capturador, y faltan los PDF, los detalles del FE y la build cargada. P2 da acceso a lo que se sabe; no simula ni certifica el sistema. La revisión P3 no aprueba ningún procedimiento para un firmware desconocido.

## Segunda revisión: web y bloqueo intermitente

Esta sección pone al día lo que se probó en el navegador después de la primera versión.

### Qué se probó

- Revisión visual de la portada y del mapa en Chrome remoto, con la vista previa local.
- Clic en nodos del mapa, búsqueda de `clearIntr` y apertura del extracto B10 con sus líneas.
- Dos ramas del diagnóstico: un proceso IC que no termina y un lector de payload que termina repitiendo valores. Las recomendaciones son distintas y se presentan como hipótesis.
- Exportación Markdown con observaciones, fecha y límites, con el texto seleccionable por si fallan la descarga o la copia.
- Pruebas en Node: sintaxis del JavaScript, enlaces y anclas, 28 extractos y once componentes. Parser completo y parcial, duplicados, hexadecimales inválidos, límites de tamaño, grupos ausentes y XOR en las 32 posiciones de bit. El diagnóstico separa las rutas IC, payload y script, y no culpa a la CLI de payload de los bucles IC.
- Cinco contraejemplos reducidos en Python. No simulan el diseño ni se ejecutaron en hardware.

### Qué no se pudo probar

La descarga con Blob no dio un archivo comprobable en el navegador remoto, y la copia automática tampoco funcionó; sí funcionó seleccionar el texto. Por eso se añadió la ventana para copiar el informe a mano.

Una interrupción cerró la pestaña y la vista previa, y al volver el navegador no pudo tomar la pestaña de error por su política de URL. No se intentó saltar esa restricción. Quedan sin probar en el navegador el comparador completo, la persistencia al recargar y el móvil; su lógica y estructura se revisaron sobre el código.

### Hipótesis del fallo que no se sostienen

- `ready` retenido: el reset que viene del core puede borrarlo, así que no toda pérdida de enlace es un ready pegado.
- FSM eLink: puede salir por una escritura downlink, y falta probar que esté en la build. El fallo no es inevitable.
- Watchdog IC: `0x10004` no elige la ruta single afectada, así que ese defecto no explica la CLI de payload.
- FIFO IC: se vacía al empezar cada transacción, así que la idea de que se llena entre consultas correctas no se sostiene.
- Script callado: el byte bajo puede quedarse quieto aunque cambie el resto. Que no imprima no prueba un bloqueo.
- Reiniciar lo arregla: sin saber qué se reinició, el estado anterior y si se repite, no dice qué pieza fallaba.

No se tocaron fuentes, no se ejecutaron binarios de adquisición, no se abrió MMIO y no se cargó firmware. La causa sigue abierta; lo que hay es una investigación con fuentes y un procedimiento para encontrarla.

## Ampliación del 25-10-2026: script de diagnóstico

Se añadieron `diagnostico/atlas_diagnostico.py` y la [sesión S0–S4](12_SCRIPT_DIAGNOSTICO.md), sin tocar las herramientas originales. Es un supervisor de la CLI existente; no es un driver ni arregla el bloqueo. `inventario` solo lee archivos de Linux. `capturar` exige un plan revisado y una opción explícita para autorizar las lecturas. Ese modo no se ejecutó sobre hardware.

Pasan 18 pruebas automáticas: 32 posiciones de bit, datos incompletos, hash distinto, UIO ambiguo, timeout, SIGBUS simulado, salida demasiado grande, lock entre sesiones, parada tras el primer error e informe con el diario a medias. Un proceso falso que no termina comprueba que el supervisor no se queda esperando para siempre; no reproduce un bloqueo AXI real. Una sesión falsa correcta comprueba los archivos de salida, los cambios en bits altos y que el lock se libera.

Límites que se tuvieron en cuenta: el plan no prueba qué build está cargada; la lista de bibliotecas no se resuelve sola; `/proc` no garantiza exclusividad; lanzar el programa cada vez puede esconder fallos de una aplicación que corre seguido; timeout y SIGKILL no garantizan que termine o se corte el MMIO; que dos muestras sean iguales no dice que sean viejas; y el XOR no prueba origen ni coherencia. No hay barrido de direcciones, control IC, monitor de otra IP ni recuperación automática.

En la web, el documento aparece en la búsqueda y en la documentación, con enlaces desde OPERAR e INVESTIGAR. Las pruebas estáticas se repitieron con 13 documentos; la cobertura en navegador no cambió. Los `.out` del script se pueden cargar en el comparador; las sesiones JSONL completas no.

Falta: S0 en la Trenz, identificar build, ELF y dependencias, saber qué hace la lectura del capturador, el estímulo FE y la autorización para el ensayo corto. La causa sigue abierta.

## Ampliación del 26-10-2026: guía breve y Pages

- Interfaz más simple al estilo WIRED / OBSERVATORY: fondo blanco, letra monoespaciada, líneas finas y azul para la selección. Portada por tareas y catálogo en filas desplegables, sin perder la documentación larga.
- Guía resumida nueva con ocho diagramas Mermaid, más dos del mapa técnico. Mermaid va empaquetado en local, sin CDN.
- Los diez diagramas pasan el parser de Mermaid con JSDOM. En el navegador se vio la arquitectura y, al abrir la guía, los ocho diagramas nuevos. Portada y navegación se revisaron a ojo, no en todos los tamaños de pantalla.
- Enlaces y lógica comprobados sobre 14 documentos, 28 fuentes y 39 enlaces Markdown internos. Siguen los mismos límites de hardware y descarga; publicar no valida instrumentos ni datos del FE.
- El workflow construye y prueba antes de publicar. Solo se sube `_site`, sin fuentes originales ni respaldo. El estado final y la URL los da GitHub Actions.
- El HTML necesita `assets/mermaid.js` para los diagramas, y la carpeta completa funciona sin red. Ya no es un HTML único autosuficiente; ver [uso local](09_USO_LOCAL.md).
