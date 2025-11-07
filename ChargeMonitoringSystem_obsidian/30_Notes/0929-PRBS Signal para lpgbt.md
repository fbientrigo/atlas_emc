### PRBS
![[assets/firmware/2024/09/ip-creation-not-lib.png]]

![[assets/firmware/2024/09/ip-creation.png]]

Despues de repackage ip
![[assets/firmware/2024/09/succes-package-prbs.png]]

Se probo generar denuevo pero sin Lib

![[assets/firmware/2024/09/ip-prbs32-wrn.png]]

despues de repackage ip
![[assets/firmware/2024/09/repackaginf-prbs32.png]]

___
## Alternativa 0930
Se procedió a utilizar un PRBS hecho mediante codigo como antes, el cual se logró dejar dentro de un IP package.
El codigo utilizado para enviar datos esporadicos es:
```


```


Patrón
Para probar el orden de los grupos se le envió
`EEEEAAAA`

___


## Creación de un Wrapper

Debe aparecer uno más que ahora:
```
[tgc_cms@trenz-tgc libuio]$ sudo ls /dev/ | grep uio
uio0
uio1
uio10
uio11
uio12
uio13
uio14
uio15
uio16
uio2
uio3
uio4
uio5
uio6
uio7
uio8
uio9
```

En caso de no funcionar coordinar con el strobe
![[assets/firmware/2024/09/connection-dataregister-prbs32.png]]


