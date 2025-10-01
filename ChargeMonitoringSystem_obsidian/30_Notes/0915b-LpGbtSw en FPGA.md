Lo primero será conseguir la API de gitlab
```bash
mkdir LpGbtSw
cd LpGbtSw/

git clone --branch 0.6.0 --single-branch --depth 1 https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw.git .
```
Y es importante para incluir los submodulos, si no se hace esto se encontrará un error en donde no encuentra el resto del material
```bash
git submodule update --init --recursive
```

Que da de output
```bash
Cloning into '.'...
Username for 'https://gitlab.cern.ch': ftrigofa
Password for 'https://ftrigofa@gitlab.cern.ch':
warning: redirecting to https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw.git/
remote: Enumerating objects: 1369, done.
remote: Counting objects: 100% (306/306), done.
remote: Compressing objects: 100% (304/304), done.
remote: Total 1369 (delta 204), reused 0 (delta 0), pack-reused 1063 (from 1)
Receiving objects: 100% (1369/1369), 440.30 KiB | 4.54 MiB/s, done.
Resolving deltas: 100% (757/757), done.
[tgc_cms@trenz-tgc LpGbtSw]$ ls
BinDepPackager  Demonstrators  LpGbt                      LpGbtRegisterSimulator  README.md  dev_tools        include
CMakeLists.txt  LogIt          LpGbtRegisterClerkFactory  LpGbtUioBackend         build.sh   env_settings.sh
```
Donde 
- build.sh es el script principal, que la documentación indica
- env_settings.sh entinedo que es más orientado a servers LGC del CERN

Procedo a correr el build.sh pero no hay resultados buenos
```bash
[tgc_cms@trenz-tgc LpGbtSw]$ ./build.sh
CMake Warning (dev) at CMakeLists.txt:1 (project):
  cmake_minimum_required() should be called prior to this top-level project()
  call.  Please see the cmake-commands(7) manual for usage documentation of
  both commands.
This warning is for project developers.  Use -Wno-dev to suppress it.

-- The C compiler identification is GNU 11.5.0
-- The CXX compiler identification is GNU 11.5.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Seems we'r                                                        
  Could NOT find Boost (missing: Boost_INCLUDE_DIR program_options system
  filesystem)
Call Stack (most recent call first):
  /usr/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:600 (_FPHSA_FAILURE_MESSAGE)
  /usr/share/cmake/Modules/FindBoost.cmake:2377 (find_package_handle_standard_args)
  CMakeLists.txt:32 (find_package)


-- Configuring incomplete, errors occurred!
./build.sh: line 6: return: can only `return' from a function or sourced script
```

Indicando un posible error, faltan modulos de CMAKE
procederé a actualizar el repositorio y a instalar lo necesario (sudo apt no sirve, esto es AlmaLinux9)

sudo dnf install boost-devel

Luego de correr la build:
```
[100%] Built target registerTranslator
Build standalone out-of-source
```

## PostBuild
Referenciando a que construimos y cargamos el firmware
deberian de existir nodos uio
```bash
ls /dev/uio*
dmesg | grep -i uio
```
Si tu `.dtbo` tenía nodos `compatible = "generic-uio";`, deberías ver algo como `/dev/uio0`, `/dev/uio1`, etc.  
Eso es lo que **LpGbtSw** va a usar como backend.

Lo que vemos como:
```bash
tgc_cms@trenz-tgc LpGbtSw0.6]$ ls /dev/uio*
/dev/uio0  /dev/uio1  /dev/uio2  /dev/uio3
[tgc_cms@trenz-tgc LpGbtSw0.6]$ dmesg | grep -i uio
[    0.000000] Kernel command line: setenv bootargs earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk1p2 ip=dhcp rw uio_pdrv_genirq.of_id=generic-uio
[tgc_cms@trenz-tgc LpGbtSw0.6]$
```

Para terminar el build
```bash
cd build
make -j$(nproc)
```
entraga de output
```
[ 32%] Built target LpGbtSw
[ 60%] Built target LogIt
[ 80%] Built target lpGbtAdc
[ 80%] Built target lpGbtRegister
[ 84%] Built target lpGbtGpio
[ 92%] Built target lpGbtConfiguration
[100%] Built target registerTranslator
```

Comprobamos los binarios
```bash
[tgc_cms@trenz-tgc build]$ ./Demonstrators/LpGbtRegister/lpGbtRegister --help
Options:
  -h [ --help ]                         Show help
  -a [ --address ] arg (=lpgbt-uio://emp_lpgbt_9)
                                        LpGbt address
  -r [ --read ] arg                     Register address to read in hexadecimal
                                        format (e.g., 0x1A)
  -w [ --write ] arg                    Register address and value to write in
                                        hexadecimal format (e.g., 0x1A:0xFF)

[tgc_cms@trenz-tgc build]$ ./Demonstrators/LpGbtConfiguration/lpGbtConfiguration --help
Options:
  -h [ --help ]                         show help
  -v [ --version ]                      print version string
  -a [ --address ] arg (=lpgbt-uio://emp_lpgbt_4)
                                        LpGbt address, one of:
                                        lpgbt-simulator://<>
                                        lpgbt-uio://<emp_lpgbt_num>

  -r [ --read ]                         read LpGbt registers
  -w [ --write ] arg                    LpGbt configuration file path


```

## Cargar Firmware
Por lo que vi, el device tree no es algo persistente, de allí que el LED se apague cuando se reinicia, esto puede ser comodo por una parte al ser capaz de exponer distintos .dtbo para probar distitnas cosas 
```
sudo ./loadFirmare.sh hw_emp_TE0807.dtbo
```
se verá cargado en esta carpeta que podemos revisar, cuando no está cargado esta carpeta estará vacia
```
ls /configfs/device-tree/overlays/
```
___

### Utilizar el firmware

Vamos a ver que expone, primero listaremos los binarios disponibles
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ find build -type f -executable | grep lpGbt
build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration
build/Demonstrators/LpGbtRegister/lpGbtRegister
build/Demonstrators/LpGbtGpio/lpGbtGpio
build/Demonstrators/LpGbtAdc/lpGbtAdc
```
Luego buscaremos en el device-tree
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ grep -r "emp_lpgbt" /proc/device-tree/
grep: /proc/device-tree/__symbols__/emp_lpgbt_3: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_1: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_8: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_6: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_11: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_4: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_2: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_0: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_9: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_7: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_12: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_5: binary file matches
grep: /proc/device-tree/__symbols__/emp_lpgbt_10: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_7@a0070000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_11@a00b0000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_5@a0050000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_3@a0030000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_1@a0010000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_8@a0080000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_12@a00c0000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_6@a0060000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_10@a00a0000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_4@a0040000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_2@a0020000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_0@a0000000/name: binary file matches
grep: /proc/device-tree/axi/emp_lpgbt_9@a0090000/name: binary file matches
[tgc_cms@trenz-tgc LpGbtSw0.6]$ dmesg | grep emp_lpgbt
[ 2803.326355] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_0
[ 2803.336446] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_1
[ 2803.346541] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_10
[ 2803.356723] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_11
[ 2803.366905] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_12
[ 2803.377086] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_2
[ 2803.387181] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_3
[ 2803.397283] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_4
[ 2803.407383] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_5
[ 2803.417480] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_6
[ 2803.427579] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_7
[ 2803.437674] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_8
[ 2803.447768] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_9
[tgc_cms@trenz-tgc LpGbtSw0.6]$
```
Los Warnings son normales
procedo a probar un bloque:
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_0 -r 0x00

[sudo] password for tgc_cms:

StdOutLog::initialize

2025-09-15 13:32:48.203016 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_0

2025-09-15 13:32:48.377145 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_0'

2025-09-15 13:32:48.377418 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049

terminate called after throwing an instance of 'std::runtime_error'

what(): LpGbtSw exception: Failed to wait for IRQ for /dev/uio4

[/home/tgc_cms/LpGbtSw0.6/LpGbtUioBackend/LpGbtUioFunctions.cpp:183] in function "void LpGbtUio::waitIntr(uio_info_t*, int)"

Aborted
```

# Codigos de testing

Se probarón varios modulos distintos usando
```bash

for i in $(seq 0 12); do
  echo "=== probando emp_lpgbt_$i ==="
  sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_$i
done

```

si sabemos que hay uno en particular:
```bash
sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x0
```

Otra forma de probar
```bash
for i in $(seq 0 11); do
  echo "=== probando emp_lpgbt_$i ==="
   sudo ./build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration -a lpgbt-uio://emp_lpgbt_$i 
done
```



sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00

La config completa
```bash
sudo ./build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration -a lpgbt-uio://emp_lpgbt_0 -r
```

```bash
sudo ./build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration -a lpgbt-simulator://emp_lpgbt_10 -r
```


GPIO:
```bash
sudo ./build/Demonstrators/LpGbtGpio/lpGbtGpio -a lpgbt-uio://emp_lpgbt_0

```

ADC:
```bash
sudo ./build/Demonstrators/LpGbtAdc/lpGbtAdc -a lpgbt-uio://emp_lpgbt_0

```

Pero el problema persistía y se relaciona con los interrupts
- Los overlays (`emp_lpgbt_0 … emp_lpgbt_12`) **sí se cargaron**.
- LpGbtSw reconoce cada bloque → log `Initializing uio device 'emp_lpgbt_X'` y lee el _magic number_ `656d7049` (que de hecho es `"empI"` en ASCII → un identificador puesto en el HDL).
- Pero luego, **cuando intenta esperar una interrupción (`waitIntr`) en `/dev/uioX`**, falla en todos los casos → `Failed to wait for IRQ`.


El backend UIO de LpGbtSw está programado para:
1. Mapear los registros AXI del bloque LpGBT.
2. Esperar a qe el kernel le notifique una **interrupción (IRQ)** desde ese bloque, para saber que puede continuar.

👉 El error significa que:
- O bien **las IRQ de los bloques LpGBT no están cableadas en tu bitstream** (no llegan al PS/Zynq),
- O bien el `.dtbo` describe IRQs que no existen físicamente.
- El _magic number_ se lee → la memoria está bien mapeada. El problema es puramente con las interrupciones.

Procedo a revisar las conexiones de interrupt dentro de WSL, con el archivo generado por el scirpt xsa de python
```
fabi@zephyrus:~/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/output$ code pl.dtsi
```

Lo cual chequea que existen las conexiones de IRQ, se revisó el Block Diagram, lo que tambien confirma que tenemos las conexiones hechas
```
notación: modulo[puerto] 
emp_lgbt_0[int_lpgbt_resp] -> xlconcat_0[In0[0:0]] 
emp_lgbt_1[int_lpgbt_resp] -> xlconcat_0[In1[0:0]] 
emp_lgbt_2[int_lpgbt_resp] -> xlconcat_0[In2[0:0]] 
... 
emp_lgbt_12[int_lpgbt_resp] -> xlconcat_1[In4[0:0]] 

Luego 
xlconcat_0[dout[7:0] ] -> zynq_ultra_ps_e_0[pl_ps_irq0[7:0]] 
xlconcat_1[dout[5:0] ] -> zynq_ultra_ps_e_0[pl_ps_irq1[5:0]]
```
Entonces el problema no es el cableado logico, pero que no estan llegando los eventos

La función que falla es en [LpGbtUioBackend/LpGbtUioFunctions.cpp](https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw/-/blob/master/LpGbtUioBackend/LpGbtUioFunctions.cpp)

```cpp
void waitIntr(uio_info_t* uio, int waitDurationMs)
{
    // Interrupt time
    timeval t;
    t.tv_sec = 0;
    t.tv_usec = waitDurationMs * 1000;
    std::string uioDeviceName(uio_get_devname(uio));
    if ( uio_irqwait_timeout(uio, &t) )
    {
        LPGBTSW_EXCEPTION("Failed to wait for IRQ for " + uioDeviceName);
    }
}
```

### Proposed

- Usar un ILA para revisar las señales de `int_lpgbt_resp` 
- Hacer un mapa de señales para hallar la conexión [[0915c-Mapa de conexion]]


___

# Post Reunion
Vamos a probar, con el objetivo de testear el software con un LPGBT conectado mediante SFP

sudo ./build/Demonstrators/LpGbtAdc/lpGbtAdc -a lpgbt-uio://emp_lpgbt_10
sudo ./build/Demonstrators/LpGbtAdc/lpGbtAdc -a lpgbt-uio://emp_lpgbt_11