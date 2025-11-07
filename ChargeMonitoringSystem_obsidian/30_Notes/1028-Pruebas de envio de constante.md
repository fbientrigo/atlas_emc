Vamos primero a usar
"reading_1006.dtbo"

El reloj:
```
sudo busybox devmem 0xA00E002C 32 0x00000011
```

con este somos capaz de escribir en la RPRBS como le llamamos
```
sudo busybox devmem 0xa00d000c 32 0xAAAABBBB
```

Luego es posible leerlo con el sweep clock que se tiene, que permite leer el grupo 0 de datos
```
[tgc_cms@trenz-tgc ~]$ sudo ./sweep_clock.sh
==============================
 Sweep clk_thresh values
==============================
Resultados guardados en: clk_sweep_results.log
==============================
[001] Escribiendo clk_thresh = 0x00000000 ... leído 0x00000000
[002] Escribiendo clk_thresh = 0x00000001 ... leído 0x00000000
[003] Escribiendo clk_thresh = 0x00000002 ... leído 0x00000000
[004] Escribiendo clk_thresh = 0x00000003 ... leído 0x00000000
[005] Escribiendo clk_thresh = 0x00000004 ... leído 0x00000000
[006] Escribiendo clk_thresh = 0x00000005 ... leído 0x00000000
[007] Escribiendo clk_thresh = 0x00000006 ... leído 0x00000000
[008] Escribiendo clk_thresh = 0x00000007 ... leído 0x00000000
[009] Escribiendo clk_thresh = 0x00000008 ... leído 0x00000000
[010] Escribiendo clk_thresh = 0x00000009 ... leído 0x00000000
[011] Escribiendo clk_thresh = 0x0000000A ... leído 0x00000000
[012] Escribiendo clk_thresh = 0x0000000B ... leído 0x00000000
[013] Escribiendo clk_thresh = 0x0000000C ... leído 0x00000000
[014] Escribiendo clk_thresh = 0x0000000D ... leído 0x00000000
[015] Escribiendo clk_thresh = 0x0000000E ... leído 0xAAAABBBB
[016] Escribiendo clk_thresh = 0x0000000F ... leído 0xAAAABBBB
[017] Escribiendo clk_thresh = 0x00000010 ... leído 0x00000000
[018] Escribiendo clk_thresh = 0x00000011 ... leído 0x00000000
[019] Escribiendo clk_thresh = 0x00000012 ... leído 0x00000000
==============================
 Fin del barrido
==============================

=== Valores distintos de cero encontrados ===
15:0x0000000E 0xAAAABBBB
16:0x0000000F 0xAAAABBBB
```

aveces la lectura puede dar 0 por motivos de sincronización estimo.

# Solo grupo 0 hace DownlinkLoopback
Para confirmar el funcionamiento de lectura antes, usando loopback interno dentro del LpGbt
estas pruebas son equivalentes a pruebas anteriores
### Downlink 320
### Uplink 320
Palabra escrita: 0xAAAABBBB
2 intentos para leer
```
=== Valores distintos de cero encontrados ===
15:0x0000000E 0xAAAABBBB
16:0x0000000F 0xAAAABBBB
```

### Uplink 640
Palabra escrita: 0xAABBC640
se requirio de 3 intentos para leer:
```
=== Valores distintos de cero encontrados ===
15:0x0000000E 0xAABBC640
16:0x0000000F 0xAABBC640
```

### Uplink 1280
Palabra escrita: 0xAABB1280
Dos intentos para leer:
```
=== Valores distintos de cero encontrados ===
14:0x0000000D 0xAABB1280
15:0x0000000E 0xAABB1280
16:0x0000000F 0xAABB1280
```

# Ahora tomamos el frame para loopback
Esto quiere decir la opción en Uplink Serializer Data Source: Loopback Downlink Frame @ 10G24
estamos enviando todo el downlink frame tal y como se recibe
en el grupo 0 es facilmente legible
- se confirma que con loopbacks internos de este tipo, no hay un scrambling que ocurra
### Downlink 320
### Uplink 320
Palabra escrita: 0xAAAA0320
2 intentos para leer
```
=== Valores distintos de cero encontrados ===
15:0x0000000E 0xAAAA0320
16:0x0000000F 0xAAAA0320
```

### Uplink 640
Palabra escrita: 0xAABBC640
se requirio de 3 intentos para leer:
```
=== Valores distintos de cero encontrados ===
15:0x0000000E 0xAABBC640
16:0x0000000F 0xAABBC640
```

### Uplink 1280
Palabra escrita: 0xAABB1280
4 intentos para leer:
```
=== Valores distintos de cero encontrados ===
15:0x0000000E 0xAABB1280
16:0x0000000F 0xAABB1280
```

___

## Lectura Fisica (nuevo)
Tenemos el grupo 0 con el RJ45 haciendo el loopback fisico
y con Serializer: En uplink funcionamiento normal.

Estamos escribiendo 0x000000AA

Y luego en el grupo 0 hacemos sweep clock
```
[001] Escribiendo clk_thresh = 0x00000000 ... leído 0x00FF8700
[002] Escribiendo clk_thresh = 0x00000001 ... leído 0x00FF8F00
[003] Escribiendo clk_thresh = 0x00000002 ... leído 0x00FF8F00
[004] Escribiendo clk_thresh = 0x00000003 ... leído 0x00FF8F00
[005] Escribiendo clk_thresh = 0x00000004 ... leído 0x00FFBF00
[006] Escribiendo clk_thresh = 0x00000005 ... leído 0x00FFBF00
[007] Escribiendo clk_thresh = 0x00000006 ... leído 0x00FFBF00
[008] Escribiendo clk_thresh = 0x00000007 ... leído 0x00FF8700
[009] Escribiendo clk_thresh = 0x00000008 ... leído 0x00FF8700
[010] Escribiendo clk_thresh = 0x00000009 ... leído 0x00FF8700
[011] Escribiendo clk_thresh = 0x0000000A ... leído 0x00FF8700
[012] Escribiendo clk_thresh = 0x0000000B ... leído 0x00FF8F00
[013] Escribiendo clk_thresh = 0x0000000C ... leído 0x00FF8F00
[014] Escribiendo clk_thresh = 0x0000000D ... leído 0x00FF8F00
[015] Escribiendo clk_thresh = 0x0000000E ... leído 0x00FF9F00
[016] Escribiendo clk_thresh = 0x0000000F ... leído 0x00FF9F00
[017] Escribiendo clk_thresh = 0x00000010 ... leído 0x00FF9F00
[018] Escribiendo clk_thresh = 0x00000011 ... leído 0x00FFBF05
[019] Escribiendo clk_thresh = 0x00000012 ... leído 0x00FFBF05
```

Donde los ultimos 2 bits del frame, representan el CH0 en donde estamos escribiendo
aquellos daran 00 muchas veces, y a veces se lee 05 que quiere decir:

0x05: 0000 0101

lo cual hace sentido con un dato desfasado

___

Prueba con 0xB8 : 101100
Y see lee

0x05: 0101
0xC0: 1100

La cadena de bits que se envían son 0's y en una ocasión un 0xB8 lo que en binario es:
... 0000 0000 1011 1000 0000 0000 ... (frame de bits original)
    0     0       B       8      0       0
Lo cual implica que hay un corrimiento en los datos y faltaría sincronizar el reloj de frame ya que lo que se recibe es:
... 0000 0101 1100 0000 0000 ...(frame de bits no sincronizados)
    0     5       C      0        0

___


# 1029 intenamos leer AA

Deberiamos ser capaces de leer algunas de estas variables:

Pos 00: 00000000  ->  0x00
Pos 01: 00000001  ->  0x01
Pos 02: 00000010  ->  0x02
Pos 03: 00000101  ->  0x05
Pos 04: 00001010  ->  0x0A
Pos 05: 00010101  ->  0x15
Pos 06: 00101010  ->  0x2A
Pos 07: 01010101  ->  0x55
Pos 08: 10101010  ->  0xAA (sincronizacion perfecta)
Pos 09: 01010100  ->  0x54
Pos 10: 10101000  ->  0xA8
Pos 11: 01010000  ->  0x50
Pos 12: 10100000  ->  0xA0
Pos 13: 01000000  ->  0x40
Pos 14: 10000000  ->  0x80
Pos 15: 00000000  ->  0x00

### Primer Test
Utilizamos el cable antiguo, aquel RJ45 que se encuentra cortado por la mitad y leimos en el osciloscopio una señal con un voltaje de referencia de unos 800mV

Debia ser AA idealemente,

pero las lecturas fueron: FB, BB, BF

esto sugiere ruido
### Segundo Test
- Se incorpora un cable RJ45 personalizado, hecho con la herramienta para disminuir los errores
- ademas de ser más corto

Para el test comprobamos la lectura loop back dentro del chip funcionaba, comprobando la salud del sistema de registros
```
sudo busybox devmem 0xa00d000c 32 0xAAAABBBB
...
[008] Escribiendo clk_thresh = 0x0000000F ... leído 0xAAAABBBB
[009] Escribiendo clk_thresh = 0x00000011 ... leído 0xAAAABBBB
[010] Escribiendo clk_thresh = 0x00000013 ... leído 0xAAAABBBB
```

Sin embargo al leer las lecturas son
0x78
que no hace sentido

### Tercer Test
Prueba de ponerle explicitamente un const con 0x0 a los demás grupos
en caso de existir algun cross talk

Este es el loop back fisico,
```
=== Lectura devmem (14:39:37) ===
0xA00E0004   : 0x00000000
0xA00E0008   : 0x00000000
0xA00E000C   : 0x00000000
0xA00E0010   : 0x00000000
0xA00E0014   : 0x00000000
0xA00E001C   : 0x00000000
0xA00E0020   : 0x00000003
```
recordar que los ultimos bits del grupo 6 no tienen importancia, de acuerdo a los docs

y con la palabra 0xAA
nuevamente acabamos igual
```
[014] Escribiendo clk_thresh = 0x0000000E ... leído 0x00000000
[015] Escribiendo clk_thresh = 0x0000000F ... leído 0x00000078
[016] Escribiendo clk_thresh = 0x00000010 ... leído 0x00000078
[017] Escribiendo clk_thresh = 0x00000011 ... leído 0x00000078
[018] Escribiendo clk_thresh = 0x00000012 ... leído 0x00000000
```
Tambien viene acompañado de un dato anomalo en el mismo tiempo
```
[015] Escribiendo clk_thresh = 0x0000000F ... leído 0x00000000
[016] Escribiendo clk_thresh = 0x00000010 ... leído 0x7C787800
[017] Escribiendo clk_thresh = 0x00000011 ... leído 0x7C787800
[018] Escribiendo clk_thresh = 0x00000012 ... leído 0x7C787800
[019] Escribiendo clk_thresh = 0x00000013 ... leído 0x00000000
```

Probamos con 0xFF
Entonces llega:
```
[015] Escribiendo clk_thresh = 0x0000000F ... leído 0x00000000
[016] Escribiendo clk_thresh = 0x00000010 ... leído 0x0000003F
[017] Escribiendo clk_thresh = 0x00000011 ... leído 0x0000003F
[018] Escribiendo clk_thresh = 0x00000012 ... leído 0x0000003F
[019] Escribiendo clk_thresh = 0x00000013 ... leído 0x00000000
```

sin embargo hay un dato anomalo que nos parece extraño
```
[016] Escribiendo clk_thresh = 0x00000010 ... leído 0x00000000
[017] Escribiendo clk_thresh = 0x00000011 ... leído 0xFFFFFFC0
[018] Escribiendo clk_thresh = 0x00000012 ... leído 0xFFFFFFC0
[019] Escribiendo clk_thresh = 0x00000013 ... leído 0xFFFFFFC0
[020] Escribiendo clk_thresh = 0x00000014 ... leído 0x00000000
```

___

## Post Test
Se encontró que el cable utilizado estaba roto por dentro, y en particular uno de los pins,estaba conectado con la tierra.
De manera que se debio de desechar y encontrar cable nuevo,
y volver a hacerlo

___

