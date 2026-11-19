# Compatibilidad, y fallos que parecen el mismo

No hay una versión que valga para todas las fuentes. Para saber si una herramienta sirve hay que seguir una cadena: firmware → diseño e IP → Device Tree → mapa UIO → API de registros → ejecutable y biblioteca. Que coincida un nombre o que una lectura dé distinto de cero no completa la cadena.

## Cuándo se puede usar una herramienta

| Qué tiene que coincidir | Dónde no coincide | Qué pasa si se mezcla | Qué falta comprobar |
|---|---|---|---|
| Direcciones físicas | En el BD, `0xA00D0000` y `0xA00E0000` son interrupt controllers; en los scripts, generador y lector | Se lee o escribe otro periférico, falla el bus o salen valores creíbles sin sentido | Address Editor más el bitstream y el DTBO cargados; no sacarlo de un script viejo |
| Lector de payload | Backup: nueve grupos, header y threshold. `output_tgc_readuplink_1002`: un grupo y un setter | Offsets de otra IP; no hay forma automática de pasar de una clase a otra | Tabla del RTL cargado, hash del ELF y receta de compilación |
| Interfaz e-link | `eLink_Interface_v1`: siete grupos de 32 bits que se borran al leerlos. Captura del backup: nueve grupos, RTL desconocido | Leer de más puede borrar datos o dejar el protocolo a medias | Qué entidad está integrada, en qué orden y con qué protocolo; no usar la CLI de nueve grupos porque el nombre se parezca |
| Control del chip | `emp_lpgbt_N` usa control, FIFO, IRQ y registro remoto. `tgc_readUplink_regs` da muestras | Tomar un dato IC por payload, o usar una dirección del chip como offset AXI | Instancia, puertos, mapa y la herramienta que corresponde |
| Canales | BD recuperado: 12 instancias. Monitor: 13 posiciones | Leer un campo sin canal o asignar mal la fibra | Build, cableado y UIO de esa sesión |
| Máscaras | Plantilla antigua `(1 << bitWidth) - 1`; las versiones corregidas usan guardas o ULL distintas | Extracción o escritura erróneas; comportamiento indefinido con desplazamientos inválidos | La fuente con la que se compiló el ELF, anchura y offset. No todo `Bus error` es culpa de la máscara |
| Selección de datos | Serializer en loopback, PRBS, cable de retorno o FE real | La lectura parece funcionar pero el origen no está probado | Configuración en uso y A/B/A externo |
| Reset | Inicializar al configurar, reset de lógica y reset del MGT no son lo mismo | Recuperación parcial, estado que se conserva o cambios de fase | Qué abarcaba exactamente la acción que antes lo recuperaba |

## Cuatro fallos que no hay que mezclar

1. Valor equivocado: el acceso vuelve, pero el packing, el canal o la máscara no corresponden.
2. Muestra vieja: el bus devuelve lo que quedó guardado; quizá el hardware no recibió un trigger nuevo.
3. Espera del software: el programa repite una condición o espera un evento, y Linux puede seguir funcionando.
4. Transacción sin terminar: la CPU no consigue completar un acceso o el sistema deja de avanzar. Para decir esto hace falta evidencia del bus o de la CPU, no solo una terminal quieta.

El diagnóstico completo y sus comandos están en [Lecturas congeladas](10_BLOQUEO_LECTURAS.md). Usa la web para anotar cuál de estos fallos viste; lo que sugiere el diagnóstico es una pista, no una causa confirmada.

## Qué cambió al revisar los problemas

### El script puede ocultar el movimiento

En `read_lpgbt10.sh`, `0x000000AA` y `0x123400AA` quedan iguales después de `& 0xff`. Es un ejemplo inventado, no datos de una sesión, pero alcanza para ver que el silencio del script no prueba que los registros no cambien.

### El script puede romper el protocolo de otra interfaz

`watch_devmem.sh` se salta `+0x18` e incluye `+0x28`. Con el mapa de nueve grupos, eso deja fuera un grupo y mete el header. Si se usara con una interfaz que borra al leer, además habría que saber qué lectura confirma la recepción. Eso no prueba que esa omisión causara el bloqueo: no está demostrado que `eLink_Interface_v1` sea el capturador cargado, y sus offsets no se pueden trasplantar.

### Un fallo de generación no es un fallo del interconnect

Una máscara C++ mal hecha es un error real. Pero si `devmem` y el programa C++ fallaran en la misma dirección validada, la máscara del wrapper no explicaría los dos. Y al revés: arreglar la máscara no prueba que el mapa o el firmware estén bien.

### El nombre de una señal no dice su polaridad

`uplinkRst_n_i` parece activo en bajo por el nombre, pero el código modificado lo usa tal cual como reset de la búsqueda de cabecera. Sigue las asignaciones. Cambiarlo por intuición podría meter un fallo nuevo.

## Comprobar la coherencia antes de MMIO

El objetivo es cerrar el contrato sin explorar a ciegas. Necesitas los artefactos y la salida del inventario A1/A2. En esta fase usa solo los comandos de inventario de [P0](00_GUIA_CAMPO.md); no existe un comando que certifique todo de una vez.

Haz una tabla con nombres, bases, tamaños y offsets de la sesión. Lo que buscas es que cada fila una el ELF con la IP de esa build. Si algo no coincide, el acceso sigue pendiente. Cuidado: un Device Tree viejo puede describir justo lo que esperas sin corresponder al PL cargado. Lo siguiente es pedir la build y el DTBO, o el RTL que falta, no probar direcciones vecinas.

## Mejoras que salen de esta revisión

Sin implementar todavía: un ID o versión de ABI; un contador de capturas y un snapshot comprobable; timeouts globales en las operaciones IC; límites y validación de las respuestas; reset explícito de la FSM; validar el payload sin depender de su valor; comprobar automáticamente los mapas generados; y pruebas de recuperación. Tiene sentido priorizarlas solo cuando se encuentre la build real. Ver [Evolución futura](05_EVOLUCION_FUTURA.md).
