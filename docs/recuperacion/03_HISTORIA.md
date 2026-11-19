# Historia reconstruida y contradicciones

Aquí se separan tres fechas: la del ensayo, la de la nota y la del commit. Un nombre como `0916` o una carpeta de imágenes `2024` no basta para fechar un experimento, porque las notas se editan después sin cambiar de nombre.

## Secuencia de trabajo recuperada

| Periodo o fuente | Qué se intentaba | Qué quedó registrado | Qué se puede concluir |
|---|---|---|---|
| Nota `0918-AXI Addressing` | Leer el bloque del lpGBT desde el PS | `devmem2` y un lector en C; logs de CPU stalls al acceder a `0xA0000000` | Hubo accesos que dejaron el sistema sin respuesta. Reloj, reset e interconexión siguen siendo hipótesis, y una captura de Vivado no prueba la respuesta actual. |
| 2025-09-23, logs fechados en `0923` | Comparar el firmware de master con el tag v0.2 y sus herramientas | En master faltan los UIO del monitor y del IC. En v0.2 el controlador imprime magic `656d7049`; un canal devuelve 0 y otro espera la IRQ y falla | El firmware y la conexión cambian el resultado. La nota culpa a la conexión, sin un diagnóstico del payload FE. |
| `0924-getting data out` | Inyectar el downlink con una constante y leer registros | Se añade una constante de downlink; bucles de `lpGbtRegister` sobre `0x00` y `0x12e` | Son pruebas de control y configuración del chip. UserData no se leyó. |
| `0929-PRBS Signal para lpgbt` | Crear un generador y ver el orden de los grupos | Reempaquetado de IP, patrón `EEEEAAAA`, mención de un strobe y un bloque de código vacío | Se intentó, pero la nota no trae el generador completo. |
| `0930-LibUIO Implementation` | Acceder al uplink con herramientas Linux | `lsuio -v` lista los dispositivos IC y termina con `free(): invalid pointer` | Falla el programa al enumerar. No dice nada del payload ni de que la placa esté rota. |
| `1001-creando un uio` | Crear registros AirHDL y wrappers PuzzledWizard | Se cambia `compatible` a `generic-uio`; el periférico aparece pero da `Bus error`; luego se anotan escrituras de constantes | Que Linux vea el dispositivo no significa que AXI funcione. No hay una causa ni un arreglo que se pueda reusar a ciegas. |
| `1002-Codigo de recepción` | Exponer el uplink como grupos AXI | AirHDL, `magic`, `data_group_x`; nota de que Vivado no aceptaba un array | Es el diseño del lector, sin el RTL de captura en esta revisión. |
| `1006-Tenemos lectura` | Ver datos en los registros | Dice que usó loopback y que probó offsets | Una cadena de prueba que funcionó, sin recepción externa del FE. |
| `1007-multipleLPGBT` | Multiplicar los lectores | Trece bases `0xA00E..0xA01A` cambiadas en el BD y el Address Editor | Es otra build. Son instancias, no grupos de un frame. |
| `1010-elink`, `1013-GettingData elinks` | Conectar el FE y recibir por el uplink | Pruebas de pares y cables, objetivo Simplex Transmitter, un ejemplo enviado y recibido que no coincide | No hay pinout final aprobado ni configuración completa que se pueda repetir. |
| `1021-Loopback real` | Mandar PRBS7 y hacer loopback | Nota muy corta, sin resultado de éxito | «Real» en el título no significa FE real. |
| 2025-10-24, `1024-lpgbt outs official repo` y backup `1024` | Ver cómo se reparten los patrones | Dos patrones distintos dan casi la misma salida; los scripts escriben threshold y generador | Algo raro pasa con la sensibilidad o el mapeo. No se sabe dónde se pierde la diferencia. |
| `1028-Pruebas de envio de constante` | Leer constantes con loopback interno y después físico | `AAAABBBB` aparece solo en ciertas ventanas de threshold; el cable físico da discrepancias; más tarde se anota un cable dañado o un pin a tierra | La recuperación interna funcionó en su momento. El cable dañado está anotado, pero no explica todos los fallos anteriores ni prueba que la reparación final funcionara. |
| `1028-1031-Testing`, sección FE | Llevar una señal desde el FE con un cable modificado y el reloj del lpGBT | Ensayo de `0x03` con valores como `0xEE6EEEEE`, resultados variables y un capturador que a veces se queda detenido | Hubo ensayos con el FE. Faltan A/B/A, mapeo y actualización para decir que el dato llegó intacto. Tampoco se puede decir que nunca se probó el FE ni que quedó funcionando. |
| Enero y febrero 2026, commits posteriores | Recordar direcciones y rehacer el setup | `Memory Directions`, notas nuevas de setup y mapas conceptuales reescritos | Son revisiones posteriores; hay que contrastarlas con el código, y no confirman lo que se concluyó antes. |

## Cronología Git comprobada

El 24-10-2026 el repositorio devolvió `main=c02a33b645dc70fb4076add25b78c5246589676e`, el mismo baseline del ZIP, sin revisiones posteriores en `main`. Las demás ramas eran de migración de imágenes y no se usaron como evidencia de firmware.

| Commit | Fecha de autor UTC | Qué se comprobó |
|---|---|---|
| [`fdd3be8`](https://github.com/fbientrigo/atlas_emc/commit/fdd3be86865ccfb7fdeeb502d5c5a34613ea86dd) | 2025-10-01 | Historia de la carpeta de notas: material hasta el 1 de octubre de 2025. Es la fecha del commit, no de todos los ensayos. |
| [`71acc42`](https://github.com/fbientrigo/atlas_emc/commit/71acc42e906078effa8ee07a1d48edcd19f2fc6b) | 2025-11-07 | Primer commit de `1028-1031-Testing`, con un mensaje de actualización de octubre y noviembre. |
| [`4d2a9a5`](https://github.com/fbientrigo/atlas_emc/commit/4d2a9a5cce8c25c1d2133c3ed66e7374e7cb9aa6) | 2025-11-07 | Otra revisión de esa nota durante la migración de imágenes. No es una prueba FE nueva. |
| [`6bfe4d1`](https://github.com/fbientrigo/atlas_emc/commit/6bfe4d11172c8fa0469eeca3a7c54ce0fe54109b) | 2025-11-12 | Llegan `epos-firmware` y `puzzledWizards` («epos y puzzled»). No identifica el bitstream cargado. |
| [`d3e252c`](https://github.com/fbientrigo/atlas_emc/commit/d3e252c210bef5cac281ea588853f3ec603c1856) | 2026-01-13 | Añade `quick_guides/Memory Directions.md`, posterior a los ensayos de octubre. Su mapa sigue sin encajar con el lector de nueve grupos. |
| [`8b1c674`](https://github.com/fbientrigo/atlas_emc/commit/8b1c674db1ecdc0112edd7e905bc8d9ca2c446de) | 2026-02-23 | Cambia mucho `0915c-Mapa de conexion` y `0916-mapa MGT`, así que esas notas ya no son el texto de septiembre de 2025. |
| [`c02a33b`](https://github.com/fbientrigo/atlas_emc/commit/c02a33b645dc70fb4076add25b78c5246589676e) | 2026-02-23 | Añade notas de SSH y setup y una imagen, y actualiza el encendido. La nota `1210` es solo una imagen, sin procedimiento FE escrito. |

Se revisó el historial por rutas y los archivos cambiados en los commits posteriores que importaban. No se auditó cada commit ni todas las imágenes y PDFs. No apareció ningún texto posterior que cierre por sí solo la validación del FE.

## Máscaras de registros y generación de código

La plantilla `puzzledWizards/templates/airhdl_to_cppbody.jinja:110–121` mantiene `(1 << bitWidth) -1`. Para un campo de 32 bits con `int` de 32 bits, desplazar 1 en 32 posiciones es comportamiento indefinido. Así que un cero después del wrapper puede ser un fallo de la máscara y no una lectura física de cero. Un `SIGBUS`, en cambio, no se explica con ese error de cálculo sin más pruebas.

| Variante | Qué hace | Alcance |
|---|---|---|
| Plantilla Jinja | Desplaza un `int` y escribe sin recortar el dato a la máscara | Si se regenera, vuelve el error. No se tocó. |
| `puzzled_working/ReadPRBS.cpp:142–158` | `make_mask` trata width>=32 antes de desplazar y recorta la escritura | Arregla los campos reales de 32 bits con offset 0. No sirve para campos arbitrarios de más de 32 bits. |
| `puzzled_writePRBS/ReadPRBS.cpp:149–162` y `patch_bits.py` | Usa `1ULL` y fija la máscara si width>=32 | Bien para los campos 32/0 usados, no para cualquier width/offset. Si width llega al ancho de ULL, el desplazamiento se calcula antes del if. |
| `read_all_lpgbt/TgcReadUplink.cpp:297–311` | Mismo estilo, con ULL | Aquí no está el `1 << 32`. Eso no dice qué wrapper lleva el ELF instalado. |

El parche de la máscara no arregló el bus, el cable, la sincronización ni la recepción del FE: son problemas de otras capas.

## Tres contradicciones que siguen abiertas

1. Direcciones. El BD original pone `axi_intc_1/2` en A00D/A00E, y los scripts ponen ahí el generador y el lector. Se resuelve sabiendo qué build hay, no eligiendo la nota más nueva.
2. Mapa de registros. El JSON de nueve grupos y el backup chocan con el mapa de un grupo de `output_tgc_readuplink_1002` y con los nombres control/status de la nota de enero. No hay un mapa único.
3. Tiempos. Las notas hablan de un threshold tras el envío y de problemas de captura, pero falta el RTL que diga cómo se actualiza con el FE solo. Puede haber un patrón óptico válido que esa lógica experimental no capture.
