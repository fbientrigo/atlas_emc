# Notas de trabajo EMP / lpGBT

[Orden de trabajo y herramientas](14_NOTAS_DE_TRABAJO.md): firmware, reloj, lpGBT y lectura; rutas desde el home, opciones y ejemplos. Esta es la entrada actual de la web.


**Para el ingeniero:** [guía de campo independiente](00_GUIA_CAMPO.md). A1/A2 pueden hacerse ahora. Las lecturas MMIO requieren cerrar la identidad del firmware y su capturador. La recepción FE correcta todavía no está demostrada.

**Entrada breve:** [guía resumida](13_GUIA_RAPIDA.md). **Web:** https://fbientrigo.github.io/atlas_emc/ — despliegue mediante GitHub Actions desde `main`. [Construcción y uso sin conexión](09_USO_LOCAL.md).

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

Investigación iniciada el 24-10-2026 sobre baseline `c02a33b`. P0 se entregó primero en el commit `a73b65b`; después se amplió P1 y se preparó el acceso local. No se ha operado hardware ni modificado código original. La documentación se desarrolló en `docs/clean` y se publica desde `main`.

| Hito | Estado y alcance |
|---|---|
| P0 | Guía estática terminada; ejecución local y prueba FE pendientes. |
| P1 | Reconstrucción acotada con fuentes, variantes y dos recorridos; falta RTL/integración del capturador, configuración FE y build activa. |
| P2 | Base local de consulta sobre evidencia disponible; lógica de búsqueda, relaciones y extractos comprobada en Node. Portada, mapa, búsqueda y diagnóstico revisados en navegador; ver límites en auditoría. |
| P3 | Revisión adversarial de afirmaciones y comprobaciones estáticas; hardware pendiente; revisión visual parcial y pruebas de lógica completadas. |

La web incluye un selector **CLARO / OSCURO** en la cabecera. Respeta inicialmente la preferencia del sistema, conserva la elección manual en este navegador y actualiza también los diagramas Mermaid.

## Revisión de lecturas congeladas y web mejorada

- [Análisis del bloqueo y procedimientos F0/F1](10_BLOQUEO_LECTURAS.md).
- [Matriz de incompatibilidades](11_COMPATIBILIDAD.md).
- Web local: mapa interactivo, diagnóstico condicional, comparación XOR de capturas, catálogo filtrable y registro de sesión con exportación revisable.
- Los modelos de `analisis/contraejemplos.py` comprueban ramas reducidas; no simulan el FPGA ni prueban la causa histórica.

## Diagnóstico reproducible del bloqueo

[Script y sesión de laboratorio S0–S4](12_SCRIPT_DIAGNOSTICO.md): inventario pasivo, plan bloqueado hasta validar compatibilidad, envoltorio de la CLI existente, anotaciones de estímulo/recuperación e informe offline. Código en `diagnostico/atlas_diagnostico.py`. Probado con procesos sintéticos; ejecución en la Trenz pendiente. Comenzar por `inventario`, no por `capturar`.
