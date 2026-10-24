# Recuperación operativa EMP / lpGBT

**Para el ingeniero:** [guía de campo independiente](00_GUIA_CAMPO.md). A1/A2 pueden hacerse ahora. Las lecturas MMIO requieren cerrar la identidad del firmware y su capturador. La recepción FE correcta todavía no está demostrada.

**Para explorar localmente:** descargar la rama y abrir `docs/recuperacion/index.html`. [Uso sin conexión](09_USO_LOCAL.md). GitHub muestra el código del HTML; no publica automáticamente una web. No se ha habilitado hosting.

| Necesito… | Entrada |
|---|---|
| Operar y registrar una sesión | [Procedimiento P0](00_GUIA_CAMPO.md) |
| Seguir señales y llamadas | [Mapa técnico y recorridos](01_MAPA_TECNICO.md) |
| Elegir una herramienta existente | [Catálogo operacional](02_CATALOGO.md) |
| Entender por qué llegamos a este estado | [Historia y versiones](03_HISTORIA.md) |
| Saber qué pedir al ingeniero | [Incertidumbres y pruebas de cierre](04_INCERTIDUMBRES.md) |
| Evaluar limpieza después de operar | [Evolución futura](05_EVOLUCION_FUTURA.md) |
| Recuperar criterio técnico | [Itinerario de aprendizaje](06_APRENDER.md) |
| Revisar rigor y límites | [Auditoría](07_AUDITORIA.md) |
| Rastrear afirmaciones | [Fuentes y cobertura](08_FUENTES.md) |

Investigación iniciada el 24-10-2026 sobre baseline `c02a33b`. P0 se entregó primero en el commit `a73b65b`; después se amplió P1 y se preparó el acceso local. No se ha operado hardware ni modificado código original. La documentación y sus archivos de soporte se añaden solo en `docs/clean`.

| Hito | Estado y alcance |
|---|---|
| P0 | Guía estática terminada; ejecución local y prueba FE pendientes. |
| P1 | Reconstrucción acotada con fuentes, variantes y dos recorridos; falta RTL/integración del capturador, configuración FE y build activa. |
| P2 | Base local de consulta sobre evidencia disponible; lógica de búsqueda, relaciones y extractos comprobada en Node. Portada, mapa, búsqueda y diagnóstico revisados en navegador; ver límites en auditoría. |
| P3 | Revisión adversarial de afirmaciones y comprobaciones estáticas; hardware pendiente; revisión visual parcial y pruebas de lógica completadas. |

## Revisión de lecturas congeladas y web mejorada

- [Análisis del bloqueo y procedimientos F0/F1](10_BLOQUEO_LECTURAS.md).
- [Matriz de incompatibilidades](11_COMPATIBILIDAD.md).
- Web local: mapa interactivo, diagnóstico condicional, comparación XOR de capturas, catálogo filtrable y registro de sesión con exportación revisable.
- Los modelos de `analisis/contraejemplos.py` comprueban ramas reducidas; no simulan el FPGA ni prueban la causa histórica.
