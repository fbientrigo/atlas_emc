# Evolución futura

Cosas que se podrían mejorar más adelante. No se cambió nada en el software de hardware, el firmware ni las fuentes originales, y nada de esto reemplaza terminar P0.

| Orden | Problema o riesgo | Cambio mínimo a evaluar | Cómo saber que sirvió |
|---|---|---|---|
| 1 | No se puede relacionar cada artefacto con su origen, y mapas distintos usan las mismas direcciones | Un manifiesto por release con SHA de fuentes, BD, DTBO, bitstream y binarios | Poder identificar una instalación sin depender de la memoria ni probar MMIO. |
| 2 | Falta el RTL del capturador y no está definido cuándo una muestra es nueva o atómica | Recuperar la fuente y documentar snapshot y trigger; si no aparece, ver qué señal de actualización mínima haría falta | Mostrar coherencia, o su límite exacto, con un estímulo externo. |
| 3 | La CLI de payload ignora los argumentos y tiene el nombre fijo | Solo si el `readuio` existente no alcanza: permitir elegir el dispositivo y dar una ayuda que no toque el hardware | Leer el canal correcto y ver la ayuda sin MMIO. |
| 4 | La plantilla genera una máscara con desplazamiento indefinido para 32 bits | Corregir la plantilla y limitar widths y offsets; regenerar solo comparando el mapa | Probar campos de 1, 31 y 32 bits sin tocar bits vecinos ni cambiar mapas por accidente. |
| 5 | `lsuio` libera un puntero desplazado y los backends siguen tras un fallo | Arreglar recursos y errores en una rama de mantenimiento aparte | La enumeración termina bien y, sin UIO, se aborta antes de cualquier acceso. |
| 6 | `readValues[6]` sin comprobar, espera de IRQ corta y bucles sin límite | Validar trama, longitud y errores, y limitar las esperas antes de dar un byte por bueno | Una respuesta corta, una IRQ que no llega o una FIFO inválida dan errores claros. |
| 7 | Los scripts tiran stderr, confunden error con cero, se saltan el grupo 5 y pisan logs | Unificar la captura solo cuando se sepa qué hace el lector y haga falta de verdad | Cada ensayo guarda identidad, configuración, retornos y datos completos. |
| 8 | Builds duplicadas que dependen del entorno; `build.sh` borra `build` | Receta reproducible aislada, dependencias identificadas y comparación de binarios | Rehacer una herramienta sin perder artefactos anteriores. |
| 9 | `eLink_Interface` existe pero no está conectada en el BD recuperado | Ver si alguna build que funcionó ya la integra antes de crear otra interfaz | Pruebas de que está montada y captura con el FE real. Tener el VHDL no alcanza. |

No migres frameworks, cambies de distribución, rehagas la adquisición ni juntes repositorios hasta saber qué herramientas se usan y qué problema resuelve el cambio.

## Lo que salió de la revisión del bloqueo

Solo en las versiones que se confirme que están montadas, por este orden: timeout global y límite a la respuesta IC; comprobar `readValues[6]`; reset explícito de la FSM; un watchdog que no dependa de las ramas prioritarias; validar el payload sin usar «distinto de cero»; contador de capturas y snapshot. No se implementó nada. Detalles y límites en [el análisis](10_BLOQUEO_LECTURAS.md).
