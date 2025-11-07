Al cargar el firmware observamos LED6 que se activa como
![[assets/firmware/2024/09/sch-statled.png|300]]

el LED2 y los demas acabanen la CPLD 
![[assets/firmware/2024/09/sch-statled-u39b.png|200]]

___

Se intentó cargar el firmware del master, sin embargo la luz ni encendia, pero no funcionaban las señales.

Luego lo que se hace es cargar el firmware 0.2v, con esto procedemos a usar los programas compilados de LpgbtSw, *todas estas funciones debido a lpgbtUIO es necesario el uso de sudo*
- utilizamos el programa de registros y leyendo 0x00
	- entregando magic number 
	- esperanod la señal 
- el configuration
	- lo utilizamos sin -r pues es problematico
	- entrega magic number
	- esperando señal
- lo mismo se repite con el GPIO, se queda esperando la señal de interrupt
	- sin embargo el 11 acabo con una operación de write, antes de desconectarse
		- start write register with addres
		- interesante pues de a cuerdo a [[0919-Puertos]] el canal 11 podría ser al que nos encontramos conectados ahora mismo

12pm
Luego de reponer la conexión acabamos con una respuesta en el 10
lo que obtuvimos una respuesta enorme 
	todas las veces intenta escribir en el registro 291, con un valor de 4 (b11)
		luego procedio con el registro 472
	tambien funcionó con el lpgbtRegister
		lo que entregó una respuesta, RegisterAddress:0, Value 0x00
Luego procedemos a lpgbt register
a loq ue cambiamos la configuracion en la Pi, lo que conllevo a un cambio de 0x150 
### Functional Programs
#### Todo esto hecho con la versión del firmware 0.2v 

```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00
StdOutLog::initialize
2025-09-22 12:21:00.952966 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10
2025-09-22 12:21:01.126733 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_10'
2025-09-22 12:21:01.126986 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049
Read: Register Address: 0 Value: 0x00

```

Otro programa
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo build/Demonstrators/LpGbtGpio/lpGbtGpio -a lpgbt-uio://emp_lpgbt_10 -r 0x00
StdOutLog::initialize
2025-09-22 12:21:37.660549 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10
2025-09-22 12:21:37.660872 [RegisterClerkFactory.cpp:38, DBG] backendType: 'lpgbt-uio' specificAddress: 'emp_lpgbt_10'
2025-09-22 12:21:37.840935 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_10'
2025-09-22 12:21:37.841186 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049
2025-09-22 12:21:37.841384 [LpGbtUioBackend.cpp:70, DBG] Start writeRegister with address 291 and value 0
2025-09-22 12:21:37.841574 [LpGbtUioBackend.cpp:80, TRC] Reply received for register 291
2025-09-22 12:21:37.841740 [LpGbtUioBackend.cpp:70, DBG] Start writeRegister with address 291 and value 0
2025-09-22 12:21:37.841902 [LpGbtUioBackend.cpp:80, TRC] Reply received for register 291
2025-09-22 12:21:37.842062 [LpGbtUioBackend.cpp:70, DBG] Start writeRegister with address 291 and value 4
2025-09-22 12:21:37.842222 [LpGbtUioBackend.cpp:80, TRC] Reply received for register 291
2025-09-22 12:21:37.842383 [LpGbtUioBackend.cpp:70, DBG] Start writeRegister with address 28 and value 128
2025-09-22 12:21:37.842542 [LpGbtUioBackend.cpp:80, TRC] Reply received for register 28
2025-09-22 12:21:37.852828 [Gpio.cpp:234, INF] Reading the value of pin 0
2025-09-22 12:21:37.852980 [LpGbtUioBackend.cpp:41, DBG] Start readRegister with address 432
2025-09-22 12:21:37.853142 [LpGbtUioBackend.cpp:51, TRC] Reply received for register 432
2025-09-22 12:21:37.853302 [LpGbtUioBackend.cpp:56, TRC] Reply payload: 000000E1000000010000000100000000000000B0000000010000000000000050
2025-09-22 12:21:37.853520 [Gpio.cpp:89, DBG] Read input pin voltage level register content: 0b00000000
2025-09-22 12:21:37.853681 [lpGbtGpio.cpp:112, INF] The value of pin 0 is: LOW
2025-09-22 12:21:37.853853 [lpGbtGpio.cpp:120, ERR] 0x00 is not a valid argument for functionality 'write'
2025-09-22 12:21:37.854011 [LpGbtUioBackend.cpp:70, DBG] Start writeRegister with address 291 and value 4
2025-09-22 12:21:37.854171 [LpGbtUioBackend.cpp:80, TRC] Reply received for register 291
2025-09-22 12:21:37.854332 [LpGbtUioBackend.cpp:70, DBG] Start writeRegister with address 291 and value 0
2025-09-22 12:21:37.854492 [LpGbtUioBackend.cpp:80, TRC] Reply received for register 291
```

Lectura de ADC
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo build/Demonstrators/LpGbtAdc/lpGbtAdc -a lpgbt-uio://emp_lpgbt_10
StdOutLog::initialize
2025-09-22 12:22:40.584898 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10
2025-09-22 12:22:40.760301 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_10'
2025-09-22 12:22:40.760552 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049
2025-09-22 12:22:40.771574 [lpGbtAdc.cpp:94, INF] For channel 0 got ADC value: 889
2025-09-22 12:22:40.772016 [lpGbtAdc.cpp:94, INF] For channel 1 got ADC value: 1023
2025-09-22 12:22:40.772443 [lpGbtAdc.cpp:94, INF] For channel 2 got ADC value: 1023
2025-09-22 12:22:40.772853 [lpGbtAdc.cpp:94, INF] For channel 3 got ADC value: 1023
2025-09-22 12:22:40.773265 [lpGbtAdc.cpp:94, INF] For channel 4 got ADC value: 1023
2025-09-22 12:22:40.773685 [lpGbtAdc.cpp:94, INF] For channel 5 got ADC value: 1023
2025-09-22 12:22:40.774106 [lpGbtAdc.cpp:94, INF] For channel 6 got ADC value: 1023
2025-09-22 12:22:40.774510 [lpGbtAdc.cpp:94, INF] For channel 7 got ADC value: 1023
2025-09-22 12:22:40.875127 [lpGbtAdc.cpp:94, INF] For channel 0 got ADC value: 1023
2025-09-22 12:22:40.875625 [lpGbtAdc.cpp:94, INF] For channel 1 got ADC value: 1023
2025-09-22 12:22:40.876047 [lpGbtAdc.cpp:94, INF] For channel 2 got ADC value: 1023
2025-09-22 12:22:40.876453 [lpGbtAdc.cpp:94, INF] For channel 3 got ADC value: 1023
...
```

#### emp_firmware versión master, sept 2025
Para comprobar que es el emp_firmware funcional, queremos volver a intentar ahora que ya tenemos el cableado correcto a ver si el firmware de la rama master (sept 2025) era uno de los problemas




___
# PiGbt
Luego procedimos a realizar las conexiones del PiGBT, tenemos entonces

![[assets/interfaces/2024/09/pigbt-welcome.png]]

![[assets/interfaces/2024/09/pigbt-lpgbt-locked.png]]

### test_features
A lo que se configura un test pattern
![[assets/interfaces/2024/09/pigbt-pattern-4a4c.png]]

el cual es enviado
![[assets/interfaces/2024/09/pigbt-uplinkoptions.png]]

a lo que tenemos distintos pins en la EMCI carrier board, 
configuramos un reloj de datarate más lento para poder leerlo
![[assets/interfaces/2024/09/pigbt-uplink-datarate.png]]


El reloj se observaba igual en el caso a partir de los pins de RJ45, así que probamos cambiar el test pattern pero especificandpo que era downlink y no uplink
![[assets/interfaces/2024/09/pigbt-pattern.png]]

pero no se observó nada.

Pero al modificar el reloj en el apartado, encontramos
![[assets/interfaces/2024/09/pigbt-clockps.png]]

En observamos un aumento de la señal de reloj en el osciloscopio
![[assets/interfaces/2024/09/pigbt-datarate.png]]

### Problematica
Conocer de los 6 elinks, a que canal y grupo pertenecen,
de manera que es necesario un algoritmo de filtrado.

Se tienen
- 6 conectores (J1, ..., J6)
- 4 canales (C0, ..., C3)
- 4 grupos (G0, ..., G3)

Los canales se encuentran activados dependiendo de la velocidad que elegimos
- 320 speed 
	- C0
- 160 speed
	- C0, C1
- 80 speed
	- C0, C1, C2, C3

Mientras que los grupos son seleccionables a mano mediante la interfaz
y los conectores son la manera en la que podemos medir.

Cuidados, no debemos de tener activada data mirroring, la cual se encuentra en el registro 0x0A9:
vemos que se encuentra en 0 aquel registro
0x0A9 0x00

### Algoritmo propuesto

##### Paso 1: Filtrar la intersección entre conectores con canales

Comenzamos habilitando todos los grupos, ya sea permitiendo el Downlink tipico o enviando el patrón 0xAAAAAAAA

Luego procedemos a elegir las velocidades, lo que nos entregará información
	mucha para canal 0
	la mitad para canal 2
	y un cuarto de información para canal 1 y 3

Asumiendo que los canales no pueden superponerse, osea, si un conector pertenece a un canal, este no puede pertenecer a otro.

##### Paso 2: Filtrar grupos por canales
Esta vez se realiza un filtrado
ya que nos encontremos solo con canales disponibles
- c0
- c0, c2
- c0, c1, c2, c3

lo que equivaldra a grupos de conectores
- JX
- JY
- JZ

Procederemos a solo activar 1 de 4 grupos y ver cuales se mantienen

___
Que información ganamos:
- Tenemos unas ideas de cuales son los canales 0
- y muy bien cuales conectores pertenecen al canal 2
- Sin embargo los canales 1 y canales 3 no podrán ser diferenciados por completo ni saber 

De igual manera sabemos que conectores pertenecen a cual grupo
- JX, JY, JZ --> 


___

# Como funcionan

Los grupos son conjuntos de canales, con un total de 8bits
Grupo 0, 1, 2, 3

Cada uno tiene canales, los cuales se activarán o no dependiendo de la velicdad
Grupo 0: Ch0, Ch1, .Ch2, Ch3

De manera que en la carrier que tenemos
Grupo 0:
J1=ch0, J2=ch1, J3=ch2, J4=ch3

Grupo1:
J5=ch0, J6=ch1



