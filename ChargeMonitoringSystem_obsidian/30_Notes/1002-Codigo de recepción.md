Utilizando AirHDL de base para generar con los registros, entregamos
- magic, como un index para probar que se encuentre vivo el device
- data_group_x
	- es donde se extraen los distintos frames dentro del uplink

___
el arreglo no es permitido en esta versión de Vivado 
![[1002_problm_1_slv32array_noexiste.png|400]]

por ello pasamos a modifica e incluir la lista de grupos como se indica arriba

## Pasos
Luego de tener el .json, pkg.vhd y .vhd
se procede a incluir el Modulo con
- AddSource, añadir ambos .vhd, luego Add Module
- correr Connection Automation
	- para ser incluido por el Axi interconnect