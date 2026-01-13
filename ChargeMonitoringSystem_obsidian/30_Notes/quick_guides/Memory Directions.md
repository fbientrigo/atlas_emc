Los registros tienen 32 bits

Para la configuracion del reloj, este en verdad viene a ser el clk thresh, que activa cada cuanto estamos leyendo despues de que la PRBS con registros escriba algo. Es necesario modifcarlo para tener en cuenta el cableado o las cuentas de reloj, un valor tipico es `0x00000011`
- `0xA00E002C`
Programas como `sweep_clock.sh` iteran en distintos valores de este threshold e imprime que es lo que lee en un registro especifico

Un registro tipico para escribir y probar palabras
- `0xA00D000C`

Para el uplink, tenemos el objeto en vivado `tgc_readUplink_regs_10 `(el 10 viene a ser el Lpgbt 10 que es el que conectamos por rj45)
el cual tiene un Baseaddr de `0xA0180000` 
y un width de 32 bits tambien. 

- `0x0` magic, read only, solo un identificador
- `0x4` control, write only, no usado aun
- `0x8` status, read only
- `0xC` data prbs

Algo como esto seria una lectura unicamente en el grupo 0
`0x000000AA`

para el grupo 1
`0x0000AA00`

y así...