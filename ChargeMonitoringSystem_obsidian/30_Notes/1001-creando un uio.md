El objetivo es ser capaz de crear un modulo al que podamos escribir en memoria y así modificar la palabra que se envia por downlink
lo que a futuro nos permitiria hacer una solución para sacar los datos

Para lo cual hemos utilizado AirHDL para:
- crear el mapa de registros
- crear el vhdl y pkg

luego PuzzledWizard:
- crear una libreria de acceso

___
## Reconocer por UIO
Lo primero es que hemos sido capaz de hacerlo visible

I followed a guide that I found on AirHDL and Puzzled Wizard
[AirHdl\_and\_PuzzledLizardWizard\_for\_register\_map\_handling.pdf](https://indico.cern.ch/event/952288/contributions/4005653/attachments/2116548/3561545/AirHdl_and_PuzzledLizardWizard_for_register_map_handling.pdf)

In order to create my own module to be able to write data to PL from the epos system
I followed the steps creating the register map and some register with their offsets, including the `magic, status` that are READ_ONLY

Then, I use the PuzzledWizard to generate the c/cpp libraries, but I realize that my uio was not recognized. So I added one line to `emp-xsa-to-overlay.py` in order to modifiy the pl.dtsi field `compatible`

```python
        for i in range(len(data)):
            if("emp_lpgbt" in data[i]):
                label = re.search(r"emp_lpgbt_\d{1,2}", data[i]).group() # Finds our emp_lpgbt number
                data[i] = data[i].replace("emp_lpgbt@", label + "@") # Put the number in the node
            if('compatible = "xlnx,emp-lpgbt-1.0";' in data[i]):
                data[i] = '\t\tcompatible = "generic-uio";\n'

            # new
            if('compatible = "xlnx,Read-PRBS-regs-1.0";' in data[i]):
                data[i] = '\t\tcompatible = "generic-uio";\n'
```
with this, the module was "correctly recognized" as an uio device (it appears listed in /dev/ and libuio/lsuio, with its name)

I used the generated code from PuzzledWizard in order to acces the memory registers
But I get a `Bus error` which does not come from my code but from a libuio call or some other part

Only for comparing I tried reading register from the working lpgbt
```
[tgc_cms@trenz-tgc puzzled]$ sudo ./readprbs_cli --by-name emp_lpgbt_10 --read-magic
ReadPRBS ctr. Found requested device with ids: 243,7
magic = 0x00000000 (0)
[tgc_cms@trenz-tgc puzzled]$ sudo ./readprbs_cli --by-name Read_PRBS_regs --read-magic
ReadPRBS ctr. Found requested device with ids: 243,4
Bus error
```
___

## Arreglar el Bus error

In [computing](https://en.wikipedia.org/wiki/Computing "Computing"), a **bus error** is a [fault](https://en.wikipedia.org/wiki/Trap_\(computing\) "Trap (computing)") raised by hardware, notifying an [operating system](https://en.wikipedia.org/wiki/Operating_system "Operating system") (OS) that a process is trying to access [memory](https://en.wikipedia.org/wiki/Computer_data_storage "Computer data storage") that the [CPU](https://en.wikipedia.org/wiki/Central_processing_unit "Central processing unit") cannot physically address: an invalid address for the [address bus](https://en.wikipedia.org/wiki/Address_bus "Address bus"), hence the name. In modern use on most architectures, these are much rarer than [segmentation faults](https://en.wikipedia.org/wiki/Segmentation_fault "Segmentation fault"), which occur primarily due to memory access violations: problems in the [_logical_ address](https://en.wikipedia.org/wiki/Logical_address "Logical address") or permissions.

### comprobaciones

Mediante
```
[tgc_cms@trenz-tgc puzzled]$ U=/sys/class/uio/uio4
[tgc_cms@trenz-tgc puzzled]$ cat $U/maps/map0/addr
0x00000000a00d0000
[tgc_cms@trenz-tgc puzzled]$ cat $U/name
Read_PRBS_regs
[tgc_cms@trenz-tgc puzzled]$ cat $U/maps/map0/size
0x0000000000004000
[tgc_cms@trenz-tgc puzzled]$ for i in 0 1 2 3; do [ -e $U/maps/map$i ] && \
  echo map$i && cat $U/maps/map$i/addr && cat $U/maps/map$i/size; done
map0
0x00000000a00d0000
0x0000000000004000
```

- **UIO está bien descubierto**: `/sys/class/uio/uio4/name = Read_PRBS_regs`.
- **Mapa único y suficiente**: `map0.addr = 0xA00D0000`, `map0.size = 0x4000` (16 KB) ⇒ sobra para 4 registros (0x0…0xC).
- **Offsets 0x0/0x4/0x8/0xC** están correctamente **alineados** para AXI-Lite de 32 bits. No tienes que “separarlos” más.

Probaremos el acceos directo a los registros:
![[assets/diagramas/2024/10/reg-adress-map.png]]

___
### confirmaciones
1. correcto en el block design, aparece el modulo con su nombre

2. se encuentra conectado a axi interconnect igual que los emp_lpgbt

3. en el address editor ninguna dirección comparte ese registro, estoy utilizando la ZynqUltraScaleMP, que yo sepa no deberia tener problema, el registro es bastante similar a los otros pero no los pisa

4. el clock se encuentra conectado a todos los demas, como sabras el bloque no se encuentra muerto pues aparece listado como uio, es reconocido

5. exporto con el bloque correctamente, lo veo correctamente listado en el pl.dtsi

6. no tengo formas de revisar el .bit como tal, pero tras cargarlo confirmo que es posible ver esta addr

```

[tgc_cms@trenz-tgc ~]$ grep -i a00d0000 /sys/class/uio/uio*/maps/map0/addr

/sys/class/uio/uio4/maps/map0/addr:0x00000000a00d0000

```

sin embargo obtengo el bus error de todas formas

7. Se encuentra actualizado, el reset se encuentra conectado correctamente, el AXI interconnect lo revisé internamente y posee todas sus debidas conexiones

___
### Registros
Los registros poseen sus separaciones correspondientes
- El segmento de memoria son 16Kb
- sobre la alineación de memoria:
	- **Base address**: `0xA00D0000` → **OK** (alineado a 4 KB/64 KB).
	- **Offsets**: `0x0, 0x4, 0x8, 0xC` con **register width = 32 bits** → **OK** (palabra de 32 bits cada 4 bytes).
	- **Rango lógico**: 4 registros × 4 bytes = **16 bytes (0x10)** → **OK** para el _mapa de registros_.

Si vemos como quedó cargado en el sistema
```
[tgc_cms@trenz-tgc test_uio]$ cat /sys/class/uio/uio4/maps/map0/addr
0x00000000a00d0000
[tgc_cms@trenz-tgc test_uio]$ cat /sys/class/uio/uio4/maps/map0/size
0x0000000000004000
```

```
[tgc_cms@trenz-tgc test_uio]$ ls /proc/device-tree/axi/
#address-cells                 dma-controller@ffaf0000/       mmc@ff170000/
#size-cells                    dp-aud@fd4ac000/               name
Read_PRBS_regs@a00d0000/       emp_lpgbt_0@a0000000/          nand-controller@ff100000/
afi0/                          emp_lpgbt_10@a00a0000/         pcie@fd0e0000/
ahci@fd0c0000/                 emp_lpgbt_11@a00b0000/         perf-monitor@fd0b0000/
ams@ffa50000/                  emp_lpgbt_12@a00c0000/         perf-monitor@fd490000/
can@ff060000/                  emp_lpgbt_1@a0010000/          perf-monitor@ffa00000/
can@ff070000/                  emp_lpgbt_2@a0020000/          perf-monitor@ffa10000/
cci@fd6e0000/                  emp_lpgbt_3@a0030000/          phandle
clocking0/                     emp_lpgbt_4@a0040000/          phy@fd400000/
compatible                     emp_lpgbt_5@a0050000/          ranges
display@fd4a0000/              emp_lpgbt_6@a0060000/          rtc@ffa60000/
dma-controller@fd4c0000/       emp_lpgbt_7@a0070000/          serial@ff000000/
dma-controller@fd500000/       emp_lpgbt_8@a0080000/          serial@ff010000/
dma-controller@fd510000/       emp_lpgbt_9@a0090000/          smmu@fd800000/
dma-controller@fd520000/       empfw_debughub@b0000000/       spi@ff040000/
dma-controller@fd530000/       ethernet@ff0b0000/             spi@ff050000/
dma-controller@fd540000/       ethernet@ff0c0000/             spi@ff0f0000/
dma-controller@fd550000/       ethernet@ff0d0000/             timer@ff110000/
dma-controller@fd560000/       ethernet@ff0e0000/             timer@ff120000/
dma-controller@fd570000/       gpio@ff0a0000/                 timer@ff130000/
dma-controller@ffa80000/       gpu@fd4b0000/                  timer@ff140000/
dma-controller@ffa90000/       i2c@ff020000/                  u-boot,dm-pre-reloc
dma-controller@ffaa0000/       i2c@ff030000/                  usb@ff9d0000/
dma-controller@ffab0000/       interrupt-controller@f9010000/ usb@ff9e0000/
dma-controller@ffac0000/       memory-controller@fd070000/    watchdog@fd4d0000/
dma-controller@ffad0000/       memory-controller@ff960000/    watchdog@ff150000/
dma-controller@ffae0000/       mmc@ff160000/
```

```
[tgc_cms@trenz-tgc test_uio]$ hexdump -Cv /proc/device-tree/axi/Read_PRBS_regs\@a00d0000/reg
00000000  00 00 00 00 a0 0d 00 00  00 00 00 00 00 00 40 00  |..............@.|
00000010
```

de manera que no es un error en la asignación de memoria

**el DT refleja exactamente lo que queremos.**  
el `hexdump` de `reg` se interpreta en big-endian (celdas de 32 bits):

`00 00 00 00  a0 0d 00 00   00 00 00 00  00 00 40 00 ^ addr_hi    ^ addr_lo     ^ size_hi     ^ size_lo`

→ **Base** = `0x00000000a00d0000`  
→ **Size** = `0x0000000000004000` (= **16 KB**)

Esto coincide con lo visto en sysfs:
- `/sys/class/uio/uio4/maps/map0/addr` = `0xA00D0000`
- `/sys/class/uio/uio4/maps/map0/size` = `0x00004000`

Así que **Linux y el device-tree están bien configurados**.

___

Se probará modificar la dirección, los archivos copiados que salieron del vhdl estan en
```
C:\vivado_code\emp_firmware_02_generateAll\emp-firmware-2023.2\emp-firmware-2023.2.srcs\sources_1\imports\Downloads
```

probé darle los actualizados con el Vivado cerrado y reiniciarlo para observar algun cambio.

Es importante usar base address que se encuentre en 0xA... pues la 0xB no funcionó correctamente,
tras cualquier cambio es necesario
- modificar los archivos en la dirección correspondiente
- modificar lo que indica el blockDesign
- verificar el AddressEditor
___

Ahora mismo se utiliza
```
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x11111111
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000000
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0xAAAAAAAA
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000A00
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000B00
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000C00
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000D00
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000E00
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000A00
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000500
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000600
[tgc_cms@trenz-tgc puzzled]$ sudo busybox devmem 0xA00D000C 32 0x00000E00
```

![[assets/mediciones/2024/10/osciloscopesignal.png]]

___

