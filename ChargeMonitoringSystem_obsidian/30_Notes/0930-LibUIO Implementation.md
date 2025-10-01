Se explora la libreria para ser capaz de utilizarla en la lectura de información,
el objetivo es leer de un `lpgbt` el `uplinkdata`
Ya se comprobó el envio de datos hacia abajo `downlinkData`
___

### Funcionamiento basico de libuio

#### Listas dispositivos disponibles
```bash
[tgc_cms@trenz-tgc libuio]$ sudo ./lsuio -v
[sudo] password for tgc_cms:
Name   : axi-pmon
Version: 1.0
DevId  : 243:0
DevNode: /dev/uio0
Map    :
  0 addr: 0xffa00000
    size: 0x00010000
  offset: 0x00000000
  1 addr: 0xffff000801dfd000
    size: 0x00001000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : axi-pmon
Version: 1.0
DevId  : 243:1
DevNode: /dev/uio1
Map    :
  0 addr: 0xfd0b0000
    size: 0x00010000
  offset: 0x00000000
  1 addr: 0xffff000801e31000
    size: 0x00001000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_3
Version: devicetree
DevId  : 243:10
DevNode: /dev/uio10
Map    :
  0 addr: 0xa0030000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_4
Version: devicetree
DevId  : 243:11
DevNode: /dev/uio11
Map    :
  0 addr: 0xa0040000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_5
Version: devicetree
DevId  : 243:12
DevNode: /dev/uio12
Map    :
  0 addr: 0xa0050000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_6
Version: devicetree
DevId  : 243:13
DevNode: /dev/uio13
Map    :
  0 addr: 0xa0060000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_7
Version: devicetree
DevId  : 243:14
DevNode: /dev/uio14
Map    :
  0 addr: 0xa0070000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_8
Version: devicetree
DevId  : 243:15
DevNode: /dev/uio15
Map    :
  0 addr: 0xa0080000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_9
Version: devicetree
DevId  : 243:16
DevNode: /dev/uio16
Map    :
  0 addr: 0xa0090000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : axi-pmon
Version: 1.0
DevId  : 243:2
DevNode: /dev/uio2
Map    :
  0 addr: 0xfd490000
    size: 0x00010000
  offset: 0x00000000
  1 addr: 0xffff000801e36000
    size: 0x00001000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : axi-pmon
Version: 1.0
DevId  : 243:3
DevNode: /dev/uio3
Map    :
  0 addr: 0xffa10000
    size: 0x00010000
  offset: 0x00000000
  1 addr: 0xffff000801e3a000
    size: 0x00001000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_0
Version: devicetree
DevId  : 243:4
DevNode: /dev/uio4
Map    :
  0 addr: 0xa0000000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_1
Version: devicetree
DevId  : 243:5
DevNode: /dev/uio5
Map    :
  0 addr: 0xa0010000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_10
Version: devicetree
DevId  : 243:6
DevNode: /dev/uio6
Map    :
  0 addr: 0xa00a0000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_11
Version: devicetree
DevId  : 243:7
DevNode: /dev/uio7
Map    :
  0 addr: 0xa00b0000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_12
Version: devicetree
DevId  : 243:8
DevNode: /dev/uio8
Map    :
  0 addr: 0xa00c0000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryName   : emp_lpgbt_2
Version: devicetree
DevId  : 243:9
DevNode: /dev/uio9
Map    :
  0 addr: 0xa0020000
    size: 0x00004000
  offset: 0x00000000

Attr.  :
scandir: No such file or directoryfree(): invalid pointer
Aborted
[tgc_cms@trenz-tgc libuio]$
```

#### Interactuar con UIO
abrir un UIO te da acceso a sus mapas de memoria y a las interrupciones
```
abrir un UIO te da acceso a sus mapas de memoria y a las interrupciones
```