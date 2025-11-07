De acuerdo a la repo oficial [gbt-fpga / lpgbt-fpga · GitLab](https://gitlab.cern.ch/gbt-fpga/lpgbt-fpga)
![[LpGbt_userBandwith.png]]

Deberiamos tener entonces los 224 de manera correcta
donde solo 6 bits van a estar desconectados.

___

## Que se hizo?
Se probaron las distintas salidas del programa lpgbt leyendo los registros
Estudiamos los distintos mapeos observando solo 1 bit de diferencia con respecto a 0xAAAAAAAA
sin embargo ocurre extrañamente que estos dos acaban identicos, a pesar de reiniciarse el sistema, se repitió 2 veces cada medida reiniciando el sistema, con el mismo resultado.

```
[tgc_cms@trenz-tgc out]$ diff 0xAAAAAAAA.txt 0xAAAAAAA2.txt
1,2c1,2
< === Lectura devmem (2025-10-24 16:01:32) ===
< Palabra escrita: 0xAAAAAAAA
---
> === Lectura devmem (2025-10-24 15:57:03) ===
> Palabra escrita: 0xAAAAAAA2
11c11
< 0xA00E0024   : 0xF0F0F0F0
---
```