# Historia reconstruida y contradicciones

Este registro separa fecha de ensayo, fecha de escritura y fecha de commit. Un nombre `0916` o una carpeta de imágenes `2024` no basta para datar el experimento. Las notas pueden editarse después conservando su nombre.

## Secuencia de trabajo recuperada

| Periodo / fuente | Qué se intentaba | Implementación / observación conservada | Interpretación que sí resiste revisión |
|---|---|---|---|
| Nota `0918-AXI Addressing` | Consultar desde PS el bloque del lpGBT | `devmem2` y lector C; logs de CPU stalls al acceder a `0xA0000000` | Hubo accesos que dejaron al sistema sin respuesta. Reloj/reset/interconexión siguen como hipótesis; una captura de Vivado no prueba respuesta actual. |
| 2025-09-23, logs fechados en `0923` | Comparar firmware master con tag v0.2 y herramientas | Master: faltan UIO para monitor/IC. v0.2: controlador imprime magic `656d7049`; un canal devuelve 0, otro espera IRQ y falla | Identidad de firmware y configuración de conexión afectan la prueba. La nota atribuye un problema a conexión, sin diagnóstico independiente completo de payload FE. |
| `0924-getting data out` | Inyectar downlink mediante constante y consultar registros | Se añade constante de downlink; bucles `lpGbtRegister` consultan `0x00`/`0x12e` | Son pruebas de control/configuración del chip, no extracción de UserData. |
| `0929-PRBS Signal para lpgbt` | Crear un generador y observar orden de grupos | Repackaging de IP, patrón `EEEEAAAA`, referencia a strobe; bloque de código vacío | Hay intención y ensayo; la nota no contiene la implementación completa del generador. |
| `0930-LibUIO Implementation` | Acceder al uplink con herramientas Linux | `lsuio -v` lista dispositivos IC y termina en `free(): invalid pointer` | Enumeración y fallo del programa; no una prueba de payload ni de placa averiada. |
| `1001-creando un uio` | Crear registros AirHDL y wrappers PuzzledWizard | Cambio de `compatible` a `generic-uio`; periférico visible con `Bus error`; luego anota escrituras de constantes | Descubrimiento Linux y funcionamiento AXI son cosas distintas. No hay causa única ni corrección trazada que pueda reutilizarse ciegamente. |
| `1002-Codigo de recepción` | Exponer uplink como grupos AXI | AirHDL, `magic`, `data_group_x`; nota sobre sustituir array no aceptado por Vivado | Diseño del lector, sin RTL de captura recuperado en esta revisión. |
| `1006-Tenemos lectura` | Ver datos en registros | Declara explícitamente uso de loopback y prueba de offsets | Observación histórica de una cadena de prueba; no recepción externa FE. |
| `1007-multipleLPGBT` | Multiplicar lectores | Trece bases históricas `0xA00E..0xA01A` modificadas en BD/Address Editor | Propuesta de otra build. No confundir instancias con grupos de un frame. |
| `1010-elink`, `1013-GettingData elinks` | Conectar FE y recibir por uplink | Pruebas de pares/cables y objetivo Simplex Transmitter; ejemplo enviado/recibido no coincidente | No hay pinout final homologado ni configuración completa reproducible. |
| `1021-Loopback real` | Enviar PRBS7 y hacer loopback | Nota muy breve, sin resultado de éxito documentado | El título «real» no significa FE real. |
| 2025-10-24, tiempos de `1024-lpgbt outs official repo` y backup `1024` | Distinguir cómo se distribuyen patrones | Dos patrones distintos producen salidas prácticamente iguales; scripts escriben threshold y generador | Hay una anomalía de sensibilidad/mapeo. No demuestra dónde se perdió la diferencia. |
| `1028-Pruebas de envio de constante` | Leer constantes con loopback interno y después físico | `AAAABBBB` aparece solo en ventanas de threshold; cable físico produce discrepancias; nota posterior identifica cable dañado/pin a tierra | La recuperación interna es histórica. El defecto de cable está anotado, pero no explica de forma demostrada todos los fallos anteriores ni prueba la reparación final. |
| `1028-1031-Testing`, sección FE | Propagar señal desde FE con cable modificado y reloj desde lpGBT | Ensayo de `0x03` con observaciones como `0xEE6EEEEE`, resultados variables y capturador que a veces queda detenido | Existieron ensayos FE. Faltan correlación A/B/A, mapeo y actualización que permitan acreditar fidelidad. No afirmar que nunca se intentó FE, ni que quedó funcionando. |
| Enero/febrero 2026, commits posteriores | Recordar direcciones y rehacer setup | `Memory Directions`, nuevas notas de setup, reescritura de mapas conceptuales | Son revisiones posteriores que deben contrastarse con código; no validan automáticamente las conclusiones históricas. |

## Cronología Git comprobada

La consulta del repositorio del 24-10-2026 devolvió `main=c02a33b645dc70fb4076add25b78c5246589676e`, igual al baseline del ZIP. No había una revisión posterior en `main` en ese momento. Las otras ramas existentes eran de migración de imágenes; no se usaron como evidencia de firmware desplegado.

| Commit | Fecha de autor UTC | Hecho relevante comprobado |
|---|---|---|
| [`fdd3be8`](https://github.com/fbientrigo/atlas_emc/commit/fdd3be86865ccfb7fdeeb502d5c5a34613ea86dd) | 2025-10-01 | Historia de la carpeta de notas: material hasta 1 de octubre de 2025. Fecha de commit, no de todos los ensayos. |
| [`71acc42`](https://github.com/fbientrigo/atlas_emc/commit/71acc42e906078effa8ee07a1d48edcd19f2fc6b) | 2025-11-07 | Primer commit devuelto para `1028-1031-Testing`; mensaje de actualización de octubre/noviembre. |
| [`4d2a9a5`](https://github.com/fbientrigo/atlas_emc/commit/4d2a9a5cce8c25c1d2133c3ed66e7374e7cb9aa6) | 2025-11-07 | Nueva revisión de esa nota durante migración de assets. El commit no equivale a una nueva prueba FE. |
| [`6bfe4d1`](https://github.com/fbientrigo/atlas_emc/commit/6bfe4d11172c8fa0469eeca3a7c54ce0fe54109b) | 2025-11-12 | Historial consultado de `epos-firmware` y `puzzledWizards`: incorporación «epos y puzzled». No identifica bitstream activo. |
| [`d3e252c`](https://github.com/fbientrigo/atlas_emc/commit/d3e252c210bef5cac281ea588853f3ec603c1856) | 2026-01-13 | Añade `quick_guides/Memory Directions.md`; es posterior a los ensayos de octubre. Su mapa sigue siendo contradictorio con el lector de nueve grupos. |
| [`8b1c674`](https://github.com/fbientrigo/atlas_emc/commit/8b1c674db1ecdc0112edd7e905bc8d9ca2c446de) | 2026-02-23 | Modifica mucho `0915c-Mapa de conexion` y `0916-mapa MGT`. No tratarlas como texto congelado de septiembre de 2025. |
| [`c02a33b`](https://github.com/fbientrigo/atlas_emc/commit/c02a33b645dc70fb4076add25b78c5246589676e) | 2026-02-23 | Añade notas de SSH/setup y una imagen; actualiza encendido. La nota `1210` es solo una referencia a imagen, sin procedimiento FE textual. |

Se consultaron historial por rutas y archivos modificados de los commits posteriores relevantes; no se auditó cada commit del repositorio ni todas sus imágenes/PDFs. No se encontró una evidencia textual posterior que cierre por sí sola la validación FE.

## Máscaras de registros y generación de código

La plantilla `puzzledWizards/templates/airhdl_to_cppbody.jinja:110–121` conserva `(1 << bitWidth) -1`. Para un campo de 32 bits en una plataforma con `int` de 32 bits, desplazar 1 por 32 tiene comportamiento indefinido. Un valor cero tras el wrapper puede ser un problema de máscara software y no una lectura física cero. No atribuir un `SIGBUS` a ese error aritmético sin otra prueba.

| Variante | Implementación observada | Alcance |
|---|---|---|
| Plantilla Jinja | Desplazamiento de `int` y escritura sin recorte explícito del dato a la máscara | Riesgo de regenerar el defecto; no se modificó. |
| `puzzled_working/ReadPRBS.cpp:142–158` | `make_mask`: trata width>=32 antes de desplazar; recorta escritura | Corrección presente para campos reales de 32 bits/offset 0. No es una especificación válida para campos arbitrarios de más de 32 bits. |
| `puzzled_writePRBS/ReadPRBS.cpp:149–162` y `patch_bits.py` | Usa `1ULL`, después fija máscara si width>=32 | Correcto para los campos 32/0 utilizados; no valida toda combinación width/offset. Si width alcanza el ancho de ULL, el desplazamiento se evalúa antes del if. |
| `read_all_lpgbt/TgcReadUplink.cpp:297–311` | Mismo estilo con ULL | No está el defecto de `1 << 32` en esta copia. Esto no identifica qué wrapper hay dentro del ELF instalado. |

No se infiere que el parche arreglara el bus, el cable, la sincronización ni la recepción FE. Son problemas de capas distintas.

## Tres contradicciones que siguen abiertas

1. **Direccionamiento:** BD original con `axi_intc_1/2` en A00D/A00E frente a scripts de generador/lector en esas bases. Resolver por identidad de build, no seleccionando la nota más reciente.
2. **Mapa de registros:** JSON nueve grupos y backup frente a mapa de un grupo de `output_tgc_readuplink_1002` y nombres control/status de la nota de enero. No hay un mapa universal.
3. **Semántica temporal:** notas describen threshold tras el envío y problemas de captura; no está el RTL que pruebe cómo se actualiza con FE autónomo. Un patrón óptico válido podría existir sin ser capturado por esa lógica experimental.
