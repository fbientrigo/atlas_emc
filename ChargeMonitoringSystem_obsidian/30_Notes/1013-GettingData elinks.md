El LPGBT como tal:
![[assets/diagramas/2024/10/lpgbt-diagram.png]]


Existen las conexiones con eports que son a los aparatos del front end.
Existe ademas
- downlink: cuando el counting room (EMP) se comunica hacia el LpGBT a 2.56Gb/s a 64 bits el frmae
- uplink: cuando el LpGbt lleva información al counting room (EMP) a 10.24 Gb/s 

## Conexión a Front End
Se tienen 3 pares diferenciales
- data hacia el front end
- data desde el front end
- clock hacia el front end

![[assets/diagramas/2024/10/lpgbt-bandwiths-table.png]]

estos se comunican mediante CLPS

![[assets/documentacion/2024/10/clps.png]]

Para lops Test queremos dejar el LpGbt como: Simplex Transmitter
en donde recibe datos de los FE y transmite via Uplink.
![[assets/interfaces/2024/10/lpgbt-uplinkframe.png]]



Vamos a leer aqui
![[assets/interfaces/2024/10/tgc-readuplink-regs.png]]

____
![[assets/diagramas/2024/10/lpgbt-fec5-framestructure.png]]

![[assets/interfaces/2024/10/lpgbt-uplinkdatarates.png]]


Se envio un
enviado                recibido
0x00000011         0x00001F8F     00000000000000000001111110001111

Enviando a 320


0x442886EA