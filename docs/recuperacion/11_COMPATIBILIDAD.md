# Contratos de compatibilidad y errores que parecen el mismo fallo

**No existe una única versión autoritativa para todas las fuentes.** La compatibilidad debe cerrarse por una cadena de identidades: artefacto de firmware → diseño/IP → Device Tree → mapa UIO → API de registros → ejecutable y biblioteca. Una coincidencia de nombre o una lectura distinta de cero no completa la cadena.

## Matriz para decidir si una herramienta puede usarse

| Contrato | Fuentes que difieren | Resultado si se mezclan | Prueba que falta |
|---|---|---|---|
| Direcciones físicas | BD: `0xA00D0000`/`0xA00E0000` son interrupt controllers; scripts: generador/lector | Leer o escribir otro periférico, fallo de bus o valores plausibles sin significado | Address Editor + bitstream/DTBO activos; no inferir desde un script histórico |
| Lector de payload | Backup: nueve grupos, header y threshold. `output_tgc_readuplink_1002`: un grupo y setter | Offsets de otro IP; no existe traducción automática entre esas clases | Tabla del RTL activo, hash de ELF y receta de compilación |
| Interfaz e-link | `eLink_Interface_v1`: siete grupos de 32 bits, consumidos al leer. Captura backup: nueve grupos, semántica RTL desconocida | Lecturas repetidas pueden borrar datos o dejar el protocolo incompleto | Demostrar entidad integrada, orden y protocolo; no usar la CLI de nueve grupos por semejanza del nombre |
| Control del chip | `emp_lpgbt_N` usa control/FIFO/IRQ y registro remoto. `tgc_readUplink_regs` expone muestras | Confundir dato IC con payload; escribir una dirección de chip como offset AXI | Instancia/puertos/mapa y herramienta correspondiente |
| Canales | BD recuperado: 12 instancias; monitor: 13 posiciones | Leer un campo sin canal o asignar fibra equivocada | Build, cableado y UIO de esa sesión |
| Máscaras | Plantilla antigua `(1 << bitWidth) - 1`; versiones corregidas usan guardas/ULL distintas | Extracción/escritura errónea; comportamiento indefinido para shifts inválidos | Fuente enlazada al ELF, anchura y offset; no atribuir todo `Bus error` a la máscara |
| Selección de datos | Serializer loopback, PRBS, retorno físico y FE real | Éxito aparente de lectura que no valida el origen | Configuración efectiva y A/B/A externo |
| Reset | Inicialización al configurar, reset de lógica y reset de MGT no son equivalentes | Recuperación parcial, estado conservado o cambios de fase | Alcance exacto de la acción que históricamente recuperaba el sistema |

## Cuatro fenómenos que no deben mezclarse

1. **Error de valor:** el acceso retorna, pero el packing, canal o máscara no corresponden.
2. **Muestra antigua:** el bus retorna el contenido retenido; puede que el hardware no haya recibido un nuevo trigger.
3. **Espera de software:** el programa repite una condición o espera un evento; Linux puede seguir operativo.
4. **Transacción sin completar:** la CPU no consigue terminar un acceso o el sistema deja de progresar; requiere evidencia de bus/CPU, no solo una terminal inmóvil.

El diagnóstico ampliado y sus comandos están en [Lecturas congeladas](10_BLOQUEO_LECTURAS.md). Usar la web para registrar cuál de estos fenómenos se observó; no convertir una respuesta del asistente de diagnóstico en una causa confirmada.

## Qué cambió en la interpretación de los problemas

### El script puede ocultar el movimiento

En `read_lpgbt10.sh`, valores `0x000000AA` y `0x123400AA` son iguales después de `& 0xff`. Esa pareja es un **contraejemplo construido**, no datos de una sesión. Basta para demostrar que su silencio no prueba que los registros completos no cambien.

### El script puede romper el protocolo de otra interfaz

`watch_devmem.sh` omite `+0x18` e incluye `+0x28`. En el mapa de nueve grupos esto omite un grupo e incluye header. Si se quisiera usarlo en una interfaz consumible, además sería imprescindible verificar qué lectura acusa recibo. No concluir que esa omisión provocó el bloqueo histórico: `eLink_Interface_v1` no está demostrado como capturador activo y sus offsets no deben transplantarse.

### Un fallo de generación no equivale a un fallo de interconnect

Una máscara C++ inválida es un defecto real. Pero si `devmem` y el programa C++ fallaran sobre la misma dirección validada, la máscara del wrapper no explicaría por sí sola ambos. Igualmente, corregir una máscara no demuestra que el mapa o el firmware estén bien.

### Un nombre de señal no define su polaridad

`uplinkRst_n_i` conserva un nombre que sugiere activo bajo, mientras la implementación modificada lo usa directamente como reset de búsqueda de cabecera. Seguir las asignaciones. Cambiarlo por intuición podría introducir un fallo nuevo.

## Comprobación de coherencia antes de MMIO

Objetivo: cerrar el contrato sin hacer una exploración a ciegas. Condiciones: artefactos y salida del inventario A1/A2 disponibles. Comandos: los de [P0](00_GUIA_CAMPO.md), únicamente inventario en esta fase; no hay un comando que certifique por sí solo todos los contratos.

Comparar nombres, bases, tamaños y offsets en una tabla de la sesión. Resultado esperado: cada fila enlaza el ELF con la IP de esa build. Alternativa: cualquier discrepancia mantiene el acceso pendiente. Riesgo: un Device Tree desactualizado puede describir exactamente lo que esperamos sin que corresponda al PL cargado. Siguiente decisión: pedir build/DTBO o el RTL faltante, no probar direcciones vecinas.

## Evolución futura derivada de esta revisión

Sin implementar cambios todavía: ID/versionado de ABI; contador de capturas y snapshot verificable; timeouts globales para operaciones IC; límites/validación de replies; reset explícito de FSM; validez independiente del valor del payload; comprobación automática de mapas generados y pruebas de recuperación. Priorizar solo tras localizar la build real. Ver [Evolución futura](05_EVOLUCION_FUTURA.md).
