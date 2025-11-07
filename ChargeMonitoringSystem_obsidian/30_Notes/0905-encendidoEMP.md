- Se procede a necender con 12V la placa, el cable parecia ser faulty pues causo que se encendiera y apagara al poco
- Se conecta mediante
	- https://network.cern.ch/sc/fcgi/sc.fcgi?Action=SelectForDisplay
	- "Barraza Altamirano" se busca como el responsable
	- se selecciona la placa TGC en esa busqueda
- Procedemos a conectar un microusb (mini) al computador

- Se instala el programa PuTTY para conexión serial
	- las instrucciones indican que debe de presionarse el boton más cercano a la placa TE0790-03

es posible conocer el terminal port:
![[assets/interfaces/2024/09/com8-devices.png]]


Luego de escuchar el ventilador se ve este mensaje

![[assets/firmware/2024/09/bootingzynq.png]]

Luego al entrar con 
- root
- EMPaina

´´´bash
[root@trenz-tgc ~]# sudo ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 128.141.43.110  netmask 255.255.255.192  broadcast 128.141.43.127
        inet6 fe80::fe0f:e7ff:fe20:ec4f  prefixlen 64  scopeid 0x20<link>
        ether fc:0f:e7:20:ec:4f  txqueuelen 1000  (Ethernet)
        RX packets 40  bytes 4688 (4.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 42  bytes 4760 (4.6 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 50

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
´´´

En el sistema vemos cual es la ip y con esa nos conectamos

Al conectarse por fuera utilizamos
 ssh -v tgc_cms@128.141.43.110

aunque tambien es posible
ssh -v tgc_cms@trenz-tgc

___

Luego la sección de artefactos se localizan,
se ha encontrado en
[root@trenz-tgc emp-tools]# find / -type d -name "bin_EMP"

de manera:
/home/tgc_cms/clk_files/EMPToolsArtifacts/

___

Se chequea el estado del reloj, las librerias se encuentran

[root@trenz-tgc ~]# ls /etc/systemd/system/systemd-programclock.service
/etc/systemd/system/systemd-programclock.service
[root@trenz-tgc ~]# ls /lib/systemd/system/systemd-programclock.service
/lib/systemd/system/systemd-programclock.service


Al buscar el estado
se encuentran fechas antiguas:

○ systemd-programclock.service - Programming the Si5345 chip during startup.
     Loaded: loaded (/etc/systemd/system/systemd-programclock.service; enabled;>
     Active: inactive (dead) since Tue 2024-04-30 00:00:07 UTC; 1 year 4 months>
   Duration: 2.205s
    Process: 329 ExecStart=/usr/bin/clkProgrammer -c (code=exited, status=0/SUC>
   Main PID: 329 (code=exited, status=0/SUCCESS)
        CPU: 132ms

Apr 30 00:00:05 trenz-tgc systemd[1]: Started Programming the Si5345 chip durin>
Apr 30 00:00:05 trenz-tgc clkProgrammer[329]: StdOutLog::initialize
Apr 30 00:00:05 trenz-tgc clkProgrammer[329]: 2024-04-30 00:00:05.618913 [main_>
Apr 30 00:00:07 trenz-tgc clkProgrammer[329]: 2024-04-30 00:00:07.444262 [main_>
Apr 30 00:00:07 trenz-tgc systemd[1]: systemd-programclock.service: Deactivated>
~
~
~
~


Vamos a probar apagar y cender a ver si el reloj se resetea

___

Los artefactos se encuentran en
[EMCI-EMP / emp-tools · GitLab](https://gitlab.cern.ch/emci-emp/emp-tools)
El cual require de permisos para poder acceder, se solicitaron a Domynik


## Exploracion del reloj
El programa clockProgrammer se encuentra cargado,
no sabemos si corre al iniciarse o si continua ejecutandose, logs de systemclt no mostraban trazas de este, así que explorando se encuentra que al ejecutarlo y ver los logs
este muere en un proceso.

[tgc_cms@trenz-tgc ~]$ clkProgrammer --help
Options:
  -h [ --help ]           show help
  -c [ --configure ]      Program SI5345
  -i [ --read_mon_info ]  Show monitoring Information

[tgc_cms@trenz-tgc ~]$ clkProgrammer -i
StdOutLog::initialize
2025-09-08 12:20:10.859584 [main_si5345.cpp:80, ERR] Failed to open I2C device file: /dev/i2c-13
2025-09-08 12:20:10.859882 [main_si5345.cpp:81, ERR] --help to check options
[tgc_cms@trenz-tgc ~]$

Exploración de los buses dispnibles

