# Evolución futura

Estas son oportunidades identificadas, **sin implementar cambios en software de hardware, firmware ni fuentes originales**. Ninguna sustituye el cierre de P0.

| Orden | Problema demostrado / riesgo | Cambio mínimo que se podría evaluar | Evidencia de utilidad antes de ampliar |
|---|---|---|---|
| 1 | Artefactos sin correspondencia verificable; mapas distintos comparten direcciones | Manifiesto de release con SHA de fuentes, BD, DTBO, bitstream y binarios | Identificar una instalación sin recurrir a memoria o ensayo MMIO. |
| 2 | Capturador sin RTL recuperado, novedad/atomicidad sin contrato | Recuperar fuente y documentar snapshot/trigger; si faltan, evaluar la mínima señal de actualización | Demostrar coherencia o límite explícito con un estímulo externo. |
| 3 | CLI de payload ignora argumentos y fija nombre | Solo si `readuio` existente no basta, exponer selección inequívoca y ayuda sin tocar hardware | Lectura del canal correcto y ayuda verificable sin MMIO. |
| 4 | Plantilla genera máscara con desplazamiento indefinido para 32 bits | Corregir la plantilla y acotar widths/offsets; regenerar solo con comparación de mapa | Pruebas de campos 1/31/32 y preservación de bits ajenos; no cambiar mapas por accidente. |
| 5 | `lsuio` libera puntero desplazado; backends pueden seguir tras fallo | Corregir manejo de recursos/errores en rama de mantenimiento separada | Enumeración termina bien; ausencia de UIO aborta antes de cualquier acceso. |
| 6 | `readValues[6]` sin validar; espera IRQ corta y bucles sin límite claro | Validar trama/longitud/error y acotar esperas antes de presentar un byte como válido | Respuesta corta, ausencia de IRQ y FIFO inválida producen diagnósticos explícitos. |
| 7 | Scripts descartan stderr, mezclan error y cero, omiten grupo 5, sobrescriben logs | Unificar captura solo después de fijar semántica del lector y necesidad real | Un registro de ensayo conserva identidad/configuración, retornos y datos completos. |
| 8 | Builds duplicadas y dependencia de entorno; `build.sh` borra build | Receta reproducible aislada, dependencias identificadas y comparación de binarios | Reproducir una herramienta necesaria sin perder artefactos anteriores. |
| 9 | `eLink_Interface` existe pero no está conectado en el BD recuperado | Revisar si alguna build funcional ya lo integra antes de crear otra interfaz | Evidencia de despliegue y captura con el FE real; no basta con tener el VHDL. |

No se recomienda migrar frameworks, cambiar distribución Linux, rehacer la adquisición ni consolidar todos los repositorios antes de saber qué herramientas se usan y qué problema actual resuelve el cambio.
