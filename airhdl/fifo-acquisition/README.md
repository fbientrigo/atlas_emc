# Adquisición FIFO del uplink 10

El lpGBT entrega una palabra de 230 bits. El firmware la rellena a 256 bits,
la pone en la FIFO y copia un bloque a RAM. Linux lee la RAM a través del
periférico AirHDL `cmb_event_regs_0`.

| Punto | Valor para la entrega EMP del 17-11-2026 |
| --- | --- |
| UIO | `cmb_event_regs_0`, base `0xA01B0000`, tamaño `0x10000`, offset `0` |
| Firma | `0x454D5001` |
| RAM de un evento | `+0x1000` a `+0x8FFC` inclusive |
| Formato | 1024 frames de 8 palabras de 32 bits, 32 KiB de datos crudos |

El lector reutiliza el helper C de `emp-deploy-final-1117`. Funciona con
Python 3.9+, un compilador C y la libuio del EMP. La carpeta se puede copiar
completa a la Trenz. El [mapa AirHDL rev29](../cmb_event_regs_rev29/cmb_event_regs.md)
documenta los registros. El [lector de snapshots del uplink 10](../coherent-capture/)
usa su propia interfaz en `0xA0180000`.

## 1. Encontrar el UIO

En la Trenz, desde esta carpeta:

```bash
python3 fifo.py check
```

Este comando lee sysfs sin abrir `/dev/uioN`. Si falla, lista los mapas UIO
publicados por Linux:

```bash
for uio in /sys/class/uio/uio*; do
    [ -r "$uio/maps/map0/addr" ] || continue
    printf '%-8s %-30s %s\n' "${uio##*/}" "$(cat "$uio/name")" "$(cat "$uio/maps/map0/addr")"
done
```

| Resultado | Qué revisar |
| --- | --- |
| La base aparece con otro nombre | Nombre exportado por el nodo UIO del overlay activo. |
| El nombre aparece con otra base o tamaño | Mapa del overlay y asignación AXI en el XSA de esa versión. |
| No aparecen ni el nombre ni la base | Overlay activo y registro del dispositivo `generic-uio` en el kernel. Un bitstream puede incluir el bloque aunque Linux todavía carezca de su UIO. |
| Hay más de una coincidencia | Nodos duplicados en el árbol activo. |

`Expected unique UIO name AND physical base match` es el mensaje del lector
anterior para el mismo fallo. La verificación del mapa debe pasar antes de
intentar leer la firma. Si conservas el paquete de despliegue, desde su carpeta
`payload/` puedes ejecutar `python3 emp.py verify expected-uios.json` para
comprobar el conjunto de mapas esperado.

## 2. Compilar y leer el estado

```bash
make
sudo python3 fifo.py status
```

Si `libuio.h` vive en otra carpeta, usa
`make LIBUIO_INCLUDE=/ruta/a/los/headers`. Si la firma coincide y sale
`READY=0`, el mapa responde y aún falta un bloque publicado. Si sale
`BUSY=1`, espera a que el controlador termine. Un bloque listo tiene
`READY=1 BUSY=0 event_size=32768`. El bit `OVERFLOW` queda en el CSV dentro de
`status`. Conviene tenerlo presente antes de asumir continuidad entre frames.

El lector consulta un bloque que el controlador ya publicó. El firmware
controla el inicio, la publicación y el ACK. El mapa rev29 define
`enable`, `test_start` y `ack` en `control` (+0x04). Para la primera prueba
en placa, la secuencia es confirmar la versión cargada, solicitar un bloque
con el patrón de prueba del controlador, esperar `READY`, guardar y revisar
el CSV, y recién entonces liberar el bloque con ACK. Con el controlador de
referencia, `test_start` es el bit 3 (máscara `0x08`) y `ack` es el bit 1
(máscara `0x02`). Ambos son pulsos. `enable` es el bit 0 y controla nuevas
capturas de datos del enlace. Se puede repetir la
lectura antes del ACK y se obtendrá el mismo `event_id` si el bloque sigue
publicado. La captura continua requiere que otro proceso gestione el ciclo
de adquisición y ACK.

## 3. Guardar y revisar el bloque

```bash
sudo python3 fifo.py capture
```

El comando imprime la ruta de `runs/<fecha-UTC>_event_<id>.csv`. Usa
`--out-dir /ruta` si quieres guardar en otro disco. El lector comprueba la
firma, el estado, el tamaño y el ID antes y después de leer la RAM. Si
cambia la cabecera, rechaza el bloque antes de crear el CSV.

Cada fila guarda un frame. `w0` contiene los bits 31 a 0 y `w7` contiene
los bits 255 a 224. En una captura de datos del lpGBT, los bits 255 a 230
son padding. Para inspeccionar dos frames consecutivos del CSV:

```bash
head -n 3 runs/<archivo>.csv
```

Antes de aplicar bitslip comprueba el orden de palabras. El controlador de
referencia tiene un patrón de prueba donde el frame 0 va de
`0x00000000` a `0x00000007`, el frame 1 de `0x00000008` a
`0x0000000f` y el último termina en `0x00001fff`. Ese patrón permite
verificar el orden usando un estímulo conocido, si la imagen cargada
implementa esa versión.

`make test` ejecuta las pruebas sin hardware. La lectura del bloque FIFO
en la Trenz queda pendiente de confirmar con el overlay y el mapa activos.
