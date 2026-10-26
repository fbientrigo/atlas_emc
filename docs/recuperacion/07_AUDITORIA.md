# Auditoría adversarial y límites de la entrega

## Revisión de afirmaciones y comandos

| Premisa cuestionada | Hallazgo | Tratamiento en esta entrega |
|---|---|---|
| Las direcciones históricas son reutilizables | BD asigna A00D/A00E a interrupt controllers | Advertencia explícita antes de MMIO; ninguna receta de escritura histórica como procedimiento actual. |
| UIO significa periférico operativo | Nota con UIO visible y `Bus error`; otra con CPU stalls | Inventario separado de lectura; parada ante fallo, sin barrido a ciegas. |
| `--help` es siempre inocuo | CLI de payload no procesa argumentos | No se recomienda ayuda de esa CLI para explorar el binario. |
| La ayuda del cargador describe todas las opciones operativas | `getopts` rechaza opciones largas antes de su comprobación | Usar únicamente `-l`/`-h` para inspección; el parser se comprobó aislado, sin ejecutar el cargador. |
| Leer chip no modifica nada | Backend `lpGbtRegister -r` escribe controlador y consume FIFO | Fuera del inventario pasivo, con condiciones y autorización local. |
| Nueve palabras son un frame | No hay protocolo de snapshot/contador en el software | Captura cruda sin afirmación de coherencia o eventos nuevos. |
| Header valida el payload | JSON promete checker, RTL ausente y CLI solo imprime | Semántica marcada DESCONOCIDA; no se inventa criterio de header. |
| «Tenemos lectura» demuestra FE | La nota 1006 usa loopback | Evidencia limitada a loopback. |
| No se hicieron ensayos FE | Nota 1028–1031 sí los registra | Se reconocen ensayos con resultados discrepantes; no se declara éxito ni inexistencia. |
| La nota más reciente corrige automáticamente el mapa | `Memory Directions`, añadida en enero 2026, mezcla offsets incompatibles | Contradicción conservada, pendiente de build; fecha no sustituye comprobación. |
| El nombre Trenz identifica la FPGA | BD declara XCZU4EG/TE0807; hay otros modelos en el contexto | Modelo actual pendiente; no extrapolar Zynq-7000 a este mapa. |
| Existe `eLink_Interface`, por tanto ya recibe FE | Fuente presente, no instanciada en BD recuperado | Alternativa existente a investigar, sin atribuir despliegue. |
| Se analizó todo el respaldo | Solo ZIP curado y dos gitingest materializados | Alcance declarado; sin afirmar inspección del TAR completo o binarios. |

No se modificaron fuentes originales, no se cargó firmware, no se escribieron registros y no se accedió a hardware real. Solo se añadieron documentos, extractos documentales y la lectura local generada en la rama indicada.

## Verificaciones de integridad y trazabilidad realizadas

- Se cotejaron los 77 archivos curados con SHA-256 del MANIFEST: todos coinciden.
- Se comprobó baseline de `main`, árbol completo no truncado y ausencia de fuentes del capturador por nombre; se analizaron componentes, nets y segmentos del BD.
- Se contrastaron mapa JSON de nueve grupos, clase backup y variante de un grupo.
- Se consultó historial por rutas y archivos modificados de las revisiones posteriores que podían cambiar la interpretación.
- Se contrastaron cuatro archivos de los gitingest con las copias del backup; no se generaliza esa igualdad al repositorio completo.
- Los extractos navegables incluyen ruta, líneas y hash del archivo completo. Se conservan sin copiar historiales, credenciales o notas de acceso a la nueva documentación.

## Verificación de la lectura local

Se ejecutó `node verificar_base.mjs --static` sobre el HTML generado. Resultado: **OK**, 10 documentos, 15 fuentes, 8 enlaces Markdown internos del contenido indexado, 4 modos, 11 nodos, 6 entradas de tareas y 5 búsquedas de términos técnicos. La prueba compila el JavaScript embebido y ejecuta sus funciones de composición/rutas con un doble DOM mínimo en Node; no es una prueba de renderizado de navegador. También verifica la intercepción de enlaces con tildes, los destinos de tareas y la ausencia de dependencias remotas automáticas en el HTML. Una comprobación adicional de todos los Markdown, incluido README, verificó 19 enlaces locales sin destinos ausentes; los 15 extractos coinciden con sus líneas y hashes originales.

Durante la verificación se corrigieron escapes de expresiones regulares al generar el script y el tratamiento de anclas con tildes. Los archivos Markdown se conservan como fuente editorial.

**Pendiente:** Playwright está disponible, pero no había Chromium instalado. El intento de obtenerlo no produjo un archivo válido. Por ello no se ejecutó la prueba completa en navegador, ni se certifican aquí renderizado visual, viewport móvil, foco/lectores de pantalla o funcionamiento específico de `file://` en cada navegador. El script deja esa comprobación reproducible preparada; no se presenta como aprobada. Se recomienda abrir el HTML local antes de depender de la interfaz en una sesión de laboratorio; la guía Markdown independiente sigue disponible.

Nada de lo anterior representa ejecución en hardware. La página no ofrece botones para ejecutar comandos, cargar firmware ni enviar datos al sistema.

## Límites que no puede cerrar una auditoría estática

No se ha probado accesibilidad AXI, configuración eléctrica, fuente del Serializer, lock actual, compatibilidad del ELF, empaquetado de grupos, disparo de captura ni fidelidad FE. La prueba A/B/A está propuesta; no se ejecutó. No hay prueba de adquisición de eventos sin pérdida, incluso si una futura prueba con constantes sostenidas resulta correcta.

P1 es una reconstrucción acotada a las fuentes recuperadas: falta unir UserData con el capturador y faltan informes PDF, detalles del FE y build activa. P2 ofrece acceso real al conocimiento disponible, no una simulación de funcionamiento ni certificación del sistema. La revisión P3 de esta entrega no homologa un procedimiento para firmware desconocido.

## Actualización: web mejorada y bloqueo intermitente

Esta sección reemplaza el estado de verificación de navegador de la primera edición, que se conserva arriba como registro del trabajo inicial.

### Verificación completada

- Revisión visual de portada y mapa en Chrome remoto mediante la vista previa local.
- Interacción con nodos del mapa, búsqueda `clearIntr` y apertura del extracto B10 con líneas originales.
- Dos ramas del diagnóstico: proceso IC que no termina, y lector payload que retorna con valores repetidos. Las recomendaciones difieren y mantienen explícita su condición de hipótesis.
- Vista de exportación Markdown generada con observaciones, fecha y límites. Texto seleccionable como alternativa a descarga/copia automáticas.
- Pruebas Node: sintaxis del JavaScript empaquetado, enlaces Markdown/anclas de etapas, 28 extractos y once entidades. Parser completo/parcial, duplicados, hexadecimales inválidos, límites de tamaño, ausencia de grupos y XOR de cada una de las 32 posiciones de bit. Diagnóstico distingue rutas IC/payload/script y no atribuye bucles IC a la CLI payload.
- Modelos Python: cinco contraejemplos reducidos. No es una simulación del diseño ni una ejecución en hardware.

### Limitaciones de verificación de la web

La descarga Blob no produjo un archivo verificable mediante el navegador remoto. La copia automática tampoco estuvo disponible; sí se observó la selección alternativa del texto. No se presenta la descarga como validada de extremo a extremo. Se añadió una vista revisable para que el informe pueda copiarse manualmente.

Una interrupción de sesión cerró la pestaña y la vista previa. Al retomarla, el navegador no pudo adquirir la pestaña de error por su política de URL. No se intentó sortear esa restricción. El comparador completo en navegador, la persistencia tras recargar y el viewport móvil quedan pendientes; su lógica y estructura se revisaron estáticamente. No se declara una cobertura visual universal.

### Refutación de hipótesis del fallo

- `ready` retenido: el reset derivado del core puede borrarlo; no atribuir toda pérdida de enlace a un ready pegado.
- FSM eLink: existe salida alternativa por escritura downlink; falta demostrar integración en la build. No llamar al fallo inevitable.
- Watchdog IC: `0x10004` no selecciona la ruta single afectada. No usar el defecto como explicación de la CLI payload.
- FIFO IC: se resetea al iniciar cada transacción. La explicación de acumulación entre consultas correctas queda refutada en su forma simple.
- Script silencioso: el byte bajo puede ser constante aunque cambie el resto. El silencio no es prueba de bloqueo completo.
- Reiniciar recupera: no identifica la pieza responsable sin conocer alcance, estado previo y repetibilidad.

No se modificaron fuentes originales, no se ejecutaron binarios de adquisición, no se abrió MMIO y no se cargó firmware. La causa histórica sigue abierta; el resultado es una investigación trazable y un procedimiento para localizarla.

## Ampliación 25-10-2026 — script diagnóstico solicitado

Se añade `diagnostico/atlas_diagnostico.py` y [sesión S0–S4](12_SCRIPT_DIAGNOSTICO.md), sin modificar herramientas originales. Es un supervisor de la CLI existente, no un nuevo driver ni un remedio del bloqueo. `inventario` consulta archivos Linux; `capturar` exige un plan revisado y una opción explícita de autorización de lecturas. No se ejecutó ese modo sobre hardware.

**Pruebas locales:** 18 pruebas automatizadas aprobadas, incluyendo 32 posiciones de bit, datos incompletos, hash distinto, UIO ambiguo, timeout, SIGBUS sintético, exceso de salida, bloqueo cooperante, detención tras primer error e informe con diario incompleto. Un doble de proceso que sigue vivo comprueba que el supervisor no llama a una espera final ilimitada; no representa un ensayo de bloqueo AXI real. Una sesión sintética correcta comprueba archivos de salida, cambios de bits altos y liberación del lock.

**Refutaciones incorporadas:** el plan no puede acreditar por sí solo la build cargada; la lista de bibliotecas no se resuelve automáticamente; `/proc` no prueba exclusividad; cada lanzamiento nuevo puede ocultar fallos de una aplicación persistente; timeout y SIGKILL no garantizan completar/abortar MMIO; igualdad no prueba antigüedad; XOR no demuestra origen ni coherencia. No se habilita barrido de direcciones, control IC, monitor de otra IP ni recuperación automática.

**Web:** se incorpora el documento a búsqueda y biblioteca, con enlaces desde OPERAR e INVESTIGAR. La generación y las comprobaciones estáticas se repiten sobre 13 documentos; no se amplía la cobertura de navegador declarada en la sección anterior. Los archivos `.out` del script son compatibles por formato con el comparador de dos capturas; no se importan sesiones JSONL completas en él.

**Pendiente:** S0 en Trenz, identidad de build/ELF/dependencias, semántica de lectura del capturador, estímulo FE y autorización para el ensayo corto. La investigación de la causa sigue abierta.


## Ampliación 26-10-2026 — guía breve y publicación Pages

- Interfaz simplificada siguiendo WIRED / OBSERVATORY: fondo blanco, tipografía monoespaciada, líneas finas y azul de selección. Portada por tareas y catálogo en filas desplegables; documentación extensa conservada.
- Nueva guía resumida: ocho diagramas Mermaid, más dos del mapa técnico. Se elimina la sustitución de Mermaid por un enlace. Biblioteca fijada y empaquetada localmente, sin CDN de ejecución.
- Diez diagramas pasan el parser real de Mermaid con JSDOM. En navegador se observó la arquitectura renderizada y, al expandir la guía, los ocho diagramas nuevos. La portada y navegación se revisaron visualmente. No se declara una prueba exhaustiva de todos los tamaños de pantalla.
- Enlaces y lógica estática comprobados sobre 14 documentos, 28 fuentes y 39 enlaces Markdown internos. Se conservan los límites anteriores de hardware y descarga; el despliegue no valida instrumentos ni datos FE.
- Workflow construye y verifica antes de desplegar. El artefacto incluye solo `_site`, no las fuentes originales ni el respaldo. Estado definitivo y URL: ejecución de GitHub Actions.
- El HTML necesita el recurso `assets/mermaid.js` para los gráficos; la carpeta completa funciona sin red. La descripción antigua de un HTML único autosuficiente queda sustituida por el procedimiento actual de uso local.
