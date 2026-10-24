# Registro de incertidumbres y pruebas de cierre

No hay estado de hardware actual observado en esta investigación. Esta tabla convierte cada hueco en un dato o una prueba concreta. Para la solicitud al ingeniero, enviar los siete conjuntos de [P0, etapa E](00_GUIA_CAMPO.md#etapa-e--diagnóstico-remoto).

| ID / prioridad | Pregunta y estado | Evidencia que falta | Criterio verificable para cerrar |
|---|---|---|---|
| U1 / bloquea MMIO | ¿Qué firmware está activo? DESCONOCIDO | DTBO/bitstream, hashes, carga, exportación de build | Trazabilidad del artefacto al diseño y corroboración de mapa activo; listar archivos no basta. |
| U2 / bloquea lector | ¿Qué RTL implementa `tgc_readUplink_regs`? DESCONOCIDO | VHDL, pkg, BD y Address Editor de la build de lectura | Conexión de un UserData identificado a cada campo, semántica de read, firma y tamaño. |
| U3 / bloquea fuente FE | ¿Qué fuente usa realmente el Serializer y cada grupo? DESCONOCIDO | Versión chip, configuración vigente y bitfields de esa versión | Modo normal, e-link habilitado, tasas/FEC consistentes, sin generador ni retorno; documentar el comando existente exacto antes de cambiar. |
| U4 / bloquea selección de canal | ¿Qué FE/e-link llega a qué instancia Linux? DESCONOCIDO | Pinout aprobado, placa/chip, fibra/MGT, BD, sysfs | Cadena explícita FE→canal e-link→chip→pipeline→capturador→UIO, sin usar `uioN` como canal. |
| U5 / bloquea ejecución fiable | ¿Qué bytes y bibliotecas se ejecutarán? DESCONOCIDO | ELF, hashes, Build ID, dependencias y receta/fuente | Arquitectura compatible; dependencias resueltas; API y mapa coincidentes; selección entre variantes justificada. |
| U6 / bloquea atribución temporal | ¿La captura se actualiza con FE autónomo? DESCONOCIDO | Trigger, enable, timestamp/contador si existe, retención y CDC del capturador | Prueba documentada de cambio ante estímulo FE sin depender de un patrón interno. Capturas repetidas iguales no prueban actualización. |
| U7 / bloquea éxito experimental | ¿Se conserva el patrón FE de forma reproducible? DESCONOCIDO | Método FE, datos eléctricos medidos y A/B/A con mapeo previo | Respuesta P→Q→P repetida, bits previstos y transporte estable; fuentes internas excluidas. |
| U8 / bloquea integridad de eventos | ¿Nueve palabras son un frame coherente? DESCONOCIDO | RTL de snapshot/handshake, contador o buffer, semántica de overflow | Snapshot estable o protocolo de lectura coherente demostrado; un header repetido no sustituye un contador único. |
| U9 / limita diagnóstico | ¿Qué errores FEC y reloj son observables? PARCIAL | Build debughub y acceso a señales/counters usados | Tabla de señales efectivamente conectadas y salidas de tooling probado; no inventar BER o contador ausente. |
| U10 / compatibilidad | ¿Hay 12 o 13 pipelines? CONTRADICTORIO entre fuentes | BD activo y rutas de canal 12 | Recuento de instancias y conexiones de esa build; campo software de 13 bits no es prueba de 13 canales. |

## Afirmaciones que ya pueden cerrarse estáticamente

- La CLI backup no tiene parser, no escribe threshold desde `main()` ni espera eventos.
- El monitor consulta estados FPGA y no demuestra la procedencia FE.
- El control IC y el payload tienen periféricos y semánticas distintas.
- La nota de octubre 6 usa loopback explícito; la de octubre 31 sí contiene ensayos FE, sin verificación suficiente de fidelidad.
- El BD recuperado y los scripts históricos de captura no pueden usarse como un único mapa.

## Qué obtener antes de plantear software nuevo

Priorizar la exportación histórica de Vivado y los binarios del lector que ya funcionaban en las pruebas de loopback. No es necesario disponer de todo el disco para cerrar U2: bastan top/BD, fuentes del capturador, parámetros, Address Editor y relación con el bitstream. Para U3 hace falta configuración efectiva, no una captura de otra sesión ni un nombre de modo aislado.

Si el lector existente solo admite captura disparada por la lógica de envío interna, primero comprobar si hay otra build o una interfaz `eLink_Interface` ya integrada. Solo después de demostrar que ninguna sirve corresponde evaluar desarrollo adicional.

## Bloqueo intermitente — preguntas adicionales

- **U11:** ejecutable exacto, retorno al prompt y alcance del reinicio histórico. Cierre: logs antes/después, PID y acción de recuperación identificada.
- **U12:** trigger y rearme del capturador activo. Cierre: RTL enlazado a build y evidencia de progreso desde UserData hasta los registros.
- **U13:** ¿se integra `eLink_Interface_v1` o la FSM IC single? Cierre: jerarquía de síntesis y configuración efectiva. No trasladar sus defectos a otra interfaz.

Ver [hipótesis y pruebas discriminantes](10_BLOQUEO_LECTURAS.md).
