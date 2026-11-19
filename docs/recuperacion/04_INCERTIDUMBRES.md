# Lo que no sabemos y cómo cerrarlo

Esta investigación no vio el estado actual del hardware. La tabla convierte cada hueco en un dato que pedir o una prueba que hacer. Para pedírselo al ingeniero, manda los siete conjuntos de datos de [P0, etapa E](00_GUIA_CAMPO.md#etapa-e-diagnóstico-remoto).

| ID y qué bloquea | Pregunta | Qué falta | Cuándo se da por cerrada |
|---|---|---|---|
| U1, bloquea MMIO | ¿Qué firmware está cargado? | DTBO y bitstream, hashes, cómo se cargó, exportación de la build | Se puede seguir el artefacto hasta el diseño y el mapa cargado coincide. Listar archivos no alcanza. |
| U2, bloquea el lector | ¿Qué RTL implementa `tgc_readUplink_regs`? | VHDL, pkg, BD y Address Editor de la build de lectura | Se sabe qué parte de UserData va a cada campo, qué hace leer, la firma y el tamaño. |
| U3, bloquea la fuente FE | ¿Qué fuente usan el Serializer y cada grupo? | Versión del chip, configuración en uso y bitfields de esa versión | Modo normal, e-link habilitado, tasas y FEC coherentes, sin generador ni retorno. El comando exacto queda documentado antes de cambiar nada. |
| U4, bloquea elegir canal | ¿Qué FE o e-link llega a qué instancia de Linux? | Pinout aprobado, placa y chip, fibra y MGT, BD, sysfs | Cadena completa FE → canal e-link → chip → pipeline → capturador → UIO, sin usar `uioN` como canal. |
| U5, bloquea ejecutar con confianza | ¿Qué binario y qué bibliotecas se van a ejecutar? | ELF, hashes, Build ID, dependencias y fuente o receta | Arquitectura compatible, dependencias resueltas, API y mapa coincidentes, y una razón para elegir esa variante. |
| U6, bloquea saber cuándo se capturó | ¿La captura se actualiza con el FE solo? | Trigger, enable, timestamp o contador si existe, retención y CDC del capturador | Una prueba documentada de que cambia con un estímulo del FE sin patrón interno. Capturas iguales repetidas no prueban que se actualice. |
| U7, bloquea dar el experimento por bueno | ¿El patrón del FE llega intacto y de forma repetible? | Método FE, datos eléctricos medidos y A/B/A con mapeo previo | P→Q→P repetido, en los bits previstos, con transporte estable y fuentes internas descartadas. |
| U8, bloquea la integridad de eventos | ¿Las nueve palabras son un frame coherente? | RTL de snapshot o handshake, contador o buffer, qué pasa con el overflow | Snapshot estable o un protocolo de lectura coherente demostrado. Repetir el header no sustituye a un contador. |
| U9, limita el diagnóstico | ¿Qué errores de FEC y de reloj se pueden ver? Se sabe en parte | Build del debughub y acceso a sus señales y contadores | Tabla de las señales conectadas de verdad y salidas de herramientas probadas. No inventar BER ni contadores que no existen. |
| U10, compatibilidad | ¿Hay 12 o 13 pipelines? Las fuentes se contradicen | BD cargado y rutas del canal 12 | Contar instancias y conexiones en esa build. Un campo de 13 bits en el software no prueba 13 canales. |

## Lo que ya se puede dar por cerrado

- La CLI del backup no tiene parser, no escribe el threshold desde `main()` y no espera eventos.
- El monitor lee estados de la FPGA y no dice de dónde viene el dato.
- El control IC y el payload son periféricos distintos y funcionan distinto.
- La nota del 6 de octubre usó loopback. La del 31 de octubre sí tiene ensayos con el FE, pero no confirma que el patrón llegara intacto.
- El BD recuperado y los scripts antiguos de captura no forman un solo mapa.

## Qué conseguir antes de pensar en software nuevo

Lo primero es la exportación antigua de Vivado y los binarios del lector que funcionaban en las pruebas de loopback. Para cerrar U2 no hace falta el disco entero: basta con el top y el BD, las fuentes del capturador, sus parámetros, el Address Editor y la relación con el bitstream. Para U3 hace falta la configuración en uso, no una captura de otra sesión ni el nombre de un modo suelto.

Si el lector solo captura cuando lo dispara la lógica de envío interna, mira primero si hay otra build o una `eLink_Interface` ya integrada. Solo cuando ninguna sirva tiene sentido desarrollar algo nuevo.

## Bloqueo intermitente: preguntas adicionales

- U11: qué ejecutable era, si volvía al prompt y qué se reiniciaba. Se cierra con logs de antes y después, el PID y la acción que lo recuperó.
- U12: trigger y rearme del capturador cargado. Se cierra con el RTL ligado a la build y pruebas de que UserData avanza hasta los registros.
- U13: ¿está integrada `eLink_Interface_v1` o la FSM IC single? Se cierra con la jerarquía de síntesis y la configuración en uso. Sus defectos no se aplican a otra interfaz.

Ver [hipótesis y pruebas para distinguirlas](10_BLOQUEO_LECTURAS.md).
