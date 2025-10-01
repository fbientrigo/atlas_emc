---
title: "Configurar ambiente EMP y cargarle proyecto ejemplo"
file: "[[Configurar ambiente EMP y cargarle proyecto ejemplo.pdf]]"
date_imported: "2025-08-20"
status: "to_read"   # to_read | skimmed | annotated
tags: [module/emp, type/howto, project/ChaMS]
lang: "auto"
---
# Resumen (3–5 bullets)
- Una vez teniendo AlmaLinux corriente se indica el uso de QEMU para testeo
- Crea el sistema EPOS dentro
- Se indca como conectar con el sistema mediante  (EMP test board)

# Puntos clave (3)
- 

# Acciones (0–3)
- [ ] 

# Notas y enlaces


### Step 7 Load Firmware to TrenzBoard
El link correcot es:
[EMCI-EMP / emp-firmware · GitLab](https://gitlab.cern.ch/emci-emp/emp-firmware)

El objetivo mio es modifcar el emp_lpgBT
se debe modificar el ipcore, este incluye el modulo de lecturea de lpgbt, necesitamos leer 12 (hardcoded en 13)

Si se modifica software es Vitis, pero esta parte es un ipcore a modificar.

Debemos evaluar:
- Conectarse al lpgbt y sacar algo
- Este modulo recibe y hace algo con esto, se debe entender bien el funcionamiento

Se debe conectar con el protocolo AXI4 (protocolo memoria de com), pues con ese se comunica al PS, que lo que hara será acceder al puerto eethernet del EMP

Considerar como se carga el OS, entender bien entonces como somos capaces de acceder a los puertos
	Es necesario tener acceso a los datos, que tira el bloque ipcore LPGBT. Por tanto tener acceso a los puertos.

Luego será un script para que los datos se tiren por un socket


___

Objetivo de realizar pruebas:
Evaluar la capacidad de comunicam

Es posible hacer pruebas simples,
Pruebas simples:
ej: modificar el bloque, hacer una RAM escribir en esta, e ir enviando ocon un interrupt timer esa palabra, a manera de saber si estamos conectados. Tendriamos la conexión entre firmware y el puerto
Luego decodificar datos

Prueba avanzada:
Enviar una señal patrón mediante la fibra
- tiene Lpgbt un patrón?
	- Es posible configurarlo con PLLGBT 
	- ![[ProgrammerModule.png]]
		- permite programar
		- mirar el estados
		- y muy posiblemetne hacer un patrón para enviar atraves de la fibra


Propuestas:
Usar el i2c para chequear los sensores de temperatura
(ver Firefly)

____
