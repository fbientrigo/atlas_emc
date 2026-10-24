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
