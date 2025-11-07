El objetivo es hacer un tracking para poder encontrar la conexión de los relojes Si5345 y Si5338 para verificar la estabilidad, pues emp_firmware no ha podido funcionar debido a una falla de conexión, no sé entiende actualmente la naturaleza del problema.

Se vieron
- Schematics
- PinOut Design

## J33 -> Es un input coaxial para el reloj MPSoC Module 
	Este llega luego como IN2_P, IN2_N hasta J3-66 (conectados a Mezz) 
![[assets/diagramas/2024/09/table-clock-inputspll.png]]


El cual al observar TRM-TE0807 observamos que esta es una freucneica que viene como input al reloj. Lo que quiere decir que esto es que somos capaces de controlar la frecuencia a utilizar.
En la datasheet Si5345
![[assets/diagramas/2024/09/table-in-sel-delay-modes.png]]

Por lo que en caso de evaluar algun problema con el cristla oscilador que recibe Si5345 podria existir un fallback.

## Si5345 Outs
En cuanto al output tiene distintos outputs
![[assets/diagramas/2024/09/table-outclk.png]]

Ojo que el OUT9 parece ser usado como LoopBack
![[assets/diagramas/2024/09/table-out8out9.png]]


Procedo a buscar en conexiones:
J2-13 -> CLK7_P 
J2-15 -> CLK7_N

Siguiendolas en la pg23/36 seccion CLK
![[assets/diagramas/2024/09/schem-clk7-diff.png]]

Vemos como pasan por aqui  se modifican y reingresan por J3
B230_CLK1_P -> 61
B230_CLK1_N -> 59

DEADEND
___
Investigando rutas de TP

	No se encuentran TP para clock

## J32 -> es un output coaxial
	Si5358
- Se hizo mediciones pero esta pegado en 3.1V


## DASjdaskdj

#tags
[[0911-ZynqModel]]
___

Para medir el output de Si5345 antes de llegar a 5338

Buscamos el IN1 de 5338
	Se medira a el IN1 de Si53358 (que viene CLK8 de Si5345)
		se registro un voltaje de 0.5V
![[assets/diagramas/2024/09/schem-clk8-diff.png]]

Se prueba medir justo en la resistencia, lo que entrega un voltaje, proveniente del cristal, sin embargo el Si5345 no entrega señal de reloj, solo fija.

___

# Busqueda con los esquematicos de TE0807-03

El reloj de Si5345 tiene varias entradas, para evaluar si el problema viene en alguna de estas, sigamos cada una:
![[assets/diagramas/2024/09/table-pll-clock-gen.png]]

## Inputs

### IN0
Oscilador de 25MHz, U25

### IN1
B2B conector, J2-4, J2-6
sin embargo esta se encuentra desactivada en la carrier board en uso:
![[assets/diagramas/2024/09/schem-b2b-connections-non.png]]



### IN2
Se encuentra en B2B J3-66 y J3-68 del Carrier Board, 
el cual solo se conecta hacia el J33

![[assets/diagramas/2024/09/schem-in2-p-clock.png]]

### IN3
Forma parte de un loop, la salida OUT9 del mismo Si5345 es la que da a la IN3
![[assets/diagramas/2024/09/schem-in3-p.png]]

### Question
Muchas de las interacciones con el Si5345 no son claras, no sabemos si esta funcionado, si tiene o no una input valida y si le enviamos corriente por J33 que ocurriría, por ello es necesario conocer la programación de este.



### Control 

Es posible controlar este oscilador


## Outs

- CLK0_P
	- J2-3
- CLK0_N
	- J2-1
- 
- CLK7_P
	- J2-13
- CLK7_N
	- J2-15
- 
- CLK8_P
	- J2-7
- CLK8_N
	- J2-9

La mayoria de salidas acaban en el B2B, 
a excepción de OUT9, todas estas pasan por un capacitor de 10nF 10v

Para estos ver paginas TE0807 - PS_GT
- B227_CLK0_P
	- D10-, XCZU3EG-1FBV900E
- B227_CLK0_N
	- D9-, XCZU3EG-1FBV900E
- ![[assets/diagramas/2024/09/schem-b227-ck0-p.png]]

- B226_CLK0_P
- B226_CLK0_N
	- Tambien llegan al mismo dispositivo XCZU4EG, como MGTREF
- B225_CLK1_P
- B225_CLK1_N
	- Tambien llegan al mismo dispositivo XCZU4EG, como MGTREF
- B224_CLK1_P
- B224_CLK1_N
	- Tambien llegan al mismo dispositivo XCZU4EG, como MGTREF
- B505_CLK2_P
- B505_CLK2_N
	- Llegan al mismo dispositivo XCZU4EG, como PS_MGTREF
- B505_CLK3_P
- B505_CLK3_N
	- Llegan al mismo dispositivo XCZU4EG, como PS_MGTREF

