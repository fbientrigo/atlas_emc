# Notas de trabajo EMP / lpGBT

Para leer datos en la Trenz y guardar el CSV, abre [Leer y guardar datos del EMP](15_OPERAR_EMP.md). Ahí están los comandos y los resultados del 19-11-2026. El firmware, el reloj y las CLI anteriores están en [Orden de trabajo y herramientas](14_NOTAS_DE_TRABAJO.md).

Si eres el ingeniero en la placa, la [guía de campo](00_GUIA_CAMPO.md) se lee sola. El inventario (A1 y A2) se puede hacer ya. Para leer registros MMIO hay que saber antes qué firmware está cargado y qué capturador tiene. Para decir que los datos vienen del front-end falta la prueba A/B/A.

Hay una [guía resumida](13_GUIA_RAPIDA.md) con diagramas. La web está en https://fbientrigo.github.io/atlas_emc/ y se publica con GitHub Actions desde `main`. Para usarla sin conexión, ver [Uso local](09_USO_LOCAL.md).

| Si necesitas… | Abre |
|---|---|
| Leer, grabar y encontrar el CSV | [Guía de operación](15_OPERAR_EMP.md) |
| Demostrar que llegan datos del front-end | [Guía de campo](00_GUIA_CAMPO.md) |
| Seguir señales y llamadas | [Mapa técnico](01_MAPA_TECNICO.md) |
| Elegir una herramienta | [Catálogo](02_CATALOGO.md) |
| Saber cómo llegamos aquí | [Historia y versiones](03_HISTORIA.md) |
| Saber qué pedir al ingeniero | [Incertidumbres](04_INCERTIDUMBRES.md) |
| Ver qué limpiar más adelante | [Evolución futura](05_EVOLUCION_FUTURA.md) |
| Repasar conceptos | [Aprender](06_APRENDER.md) |
| Ver qué se revisó y qué no | [Auditoría](07_AUDITORIA.md) |
| Encontrar la fuente de una afirmación | [Fuentes](08_FUENTES.md) |

La investigación empezó el 24-10-2026 sobre el commit `c02a33b`. P0 se entregó primero, en `a73b65b`. Después se amplió P1 y se preparó la web. Durante esa investigación no se tocó el hardware ni el código original. Los documentos se escribieron en `docs/clean` y se publican desde `main`.

| Hito | Estado |
|---|---|
| P0 | Guía terminada. Falta ejecutarla en la placa y hacer la prueba FE. |
| P1 | Reconstrucción con fuentes, variantes y dos recorridos. Faltan el RTL del capturador, la configuración FE y la build cargada. |
| P2 | Web de consulta sobre lo recuperado. Búsqueda, relaciones y extractos probados en Node; portada, mapa, búsqueda y diagnóstico revisados en el navegador. Límites en la auditoría. |
| P3 | Revisión crítica de las afirmaciones y pruebas estáticas. Falta el hardware; la revisión visual es parcial. |

La cabecera tiene un botón CLARO / OSCURO. Arranca con el tema del sistema, recuerda tu elección en ese navegador y también cambia los diagramas.

## Lecturas congeladas

- [Análisis del bloqueo y procedimientos F0/F1](10_BLOQUEO_LECTURAS.md).
- [Tabla de incompatibilidades](11_COMPATIBILIDAD.md).
- La web incluye el mapa interactivo, un diagnóstico por preguntas, la comparación XOR de capturas, el catálogo con filtros y un registro de sesión que se puede exportar.
- `analisis/contraejemplos.py` prueba ramas pequeñas del RTL. No simula la FPGA ni explica la causa del fallo.

## Script de diagnóstico

El [script y la sesión S0–S4](12_SCRIPT_DIAGNOSTICO.md) hacen un inventario sin tocar registros y dejan el plan de lectura bloqueado hasta confirmar la compatibilidad. Luego ejecutan la CLI existente, anotan el estímulo y la recuperación, y generan un informe sin conexión. El código está en `diagnostico/atlas_diagnostico.py`. Está probado con procesos falsos; falta correrlo en la Trenz. Empieza por `inventario`, no por `capturar`.
