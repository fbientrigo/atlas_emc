Para programar se referencia a:
[[Setup EMP development environment & reference project]]

Además los source code se obtienen de dos proyectos
[EMCI-EMP / emp-tools · GitLab](https://gitlab.cern.ch/emci-emp/emp-tools)
[atlas-dcs-emp-software / epos · GitLab](https://gitlab.cern.ch/atlas-dcs-emp/epos)
___


En lo cual en la sección:
Creating a Device Tree overlay to program the FPGA

Lo cual se parte por tener el repo listo con etools:


1.- se almacena el output .xsa obtenido por [[0912-compilando_empfirmwarev0.2]] en la carpeta
/etools/xsa-to-overlays/xsa-to-overlays

En mi caso la ruta copleta:
```
/home/fabi/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays
```


2.- Queremos ejecutar el programa
emp-xsa-to-overlays.py
Pero este necesita tener ciertas referencias a otras herramientas,
Existen dos posibles rutas, una es construir en Windows, sin embargo en este desarrollo requerimos de petalinux que no está.
Pero de tenerse se puede continuar a utilizar dtc con Vivado
sourcing C:\Xilinx\Vivado\2023.2\settings64.bat

Se hacen instrucciones que son en sistemas linux, pues se necesita el programa "dtc" device tree compiler.


a.- comenzamos por adquirir el repo
```bash
git clone --branch 3.0.0 --depth 1 --single-branch https://gitlab.cern.ch/atlas-dcs-emp/epos.git .
```

Tomé una versión terminada, asegurando estabilidad
sin embargo hay varias versiones y no se especifica como cambian una de la otra


b.- se procede a instalar dtc, sistema tipo debian
sudo apt-get install device-tree-compiler

c.- se debe referenciar el directorio de petalinux para acceder a la herramienta xsct

export PATH=$PATH:<Petalinuxdir>/tools/xsct/bin/

en mi caso:

export PATH=$PATH:/home/fabi/petainstaller/tools/xsct/bin/


d.- Ahora el programa podria ser ejecutado,

!!! Sin embargo
Al ser usado, hay algo que no aparece en la guia y es que es necesario el programa bootgen
que solo se encuentra disponible en Vivado,
Por tanto es obligatorio el activar las settings
esto requirio que instalará Vitis en WSL, 
una vez hecho eso y haciendole source al archivo de settings
```
fabi@zephyrus:~/vivado_install/Vitis/2023.2$ source settings64.sh
```
Se procede a correr el script, con el .xsa del compilado


fabi@zephyrus:~/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays$ ./emp-xsa-to-overlays.py hw_emp_TE0807.xsa


Tenemos el output
fabi@zephyrus:~/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/output$ ls
hw_emp_TE0807.bit.bin  hw_emp_TE0807.dtbo  pl.dtsi

## Subir a la maquina

Para subir esto a la maquina comenzamos en el local
```
fabi@zephyrus:~/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/output$ scp hw_emp_TE0807* tgc_cms@trenz-tgc:~/
tgc_cms@trenz-tgc's password:
hw_emp_TE0807.bit.bin                                                                 100% 7625KB  15.5MB/s   00:00
hw_emp_TE0807.dtbo                                                                    100% 6800     1.5MB/s   00:00
```
se movieron al lugar:
```
[tgc_cms@trenz-tgc ~]$ mv hw_emp_TE0807* /lib/firmware/
```

Y luego se procede a cargar el firmware mediante las funcionalidades

Vamos a la carpeta
/home/tgc_cms/epos/etools

y allí dentro podemos listar las disponibles
```bash
[tgc_cms@trenz-tgc etools]$ ./loadFirmare.sh -l
Firmware files:
emp_fw_TE0807_wrapper.dtbo
hw_emp_TE0807.dtbo
```

Para cargar el firmware se referencia solo el nombre, es necesario usar sudo
```
[tgc_cms@trenz-tgc etools]$ sudo ./loadFirmare.sh hw_emp_TE0807.dtbo
[sudo] password for tgc_cms:
Firmware 'hw_emp_TE0807.dtbo' was successfully loaded.
```

Resultados:
0915 2pm
se ha ejecutado sin errores, y el sistema fue reiniciado
Todo funciona bien

Un detalle interesante es que se encendió el unico LED en la Mezz, tras haber ejecutado el script de loadFirmware, el cual de acuerdo al TMR
![[On_board_LED.png]]

Continuando a construir la API
LpGbtSw

[atlas-dcs-emp-software / LpGbtSw · GitLab](https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw)

[[0915b-LpGbtSw en FPGA]]