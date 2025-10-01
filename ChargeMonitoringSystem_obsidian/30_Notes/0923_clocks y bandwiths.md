Se conversa sobre los relojes de Elinks
Estos son 29 relojes independientes que pueden ser tomados,
- los datos y sus envios no se modifican al cambiar estos relojes
- se encuentran sincronizados a pesar de todo, osea en fase con la señal 40MhZ

Sobre los ancho de banda existe la problematica donde al UpLink (lpgbt -> EMP) conexión por fibra es de 5.12 o 10.24 Gb/s
sin embargo hacia el FE (Front End Device) solo tenemos 2.56 Gb/s

	Son 64 bits cada 25ns -> 2.56 Gb/s

Sin embargo mucho de esto son Headers y error correction, el D-Field es efectivamente 32 bits -> 1.28 Gb/s
Sean 8 bits solo para un grupo, y dentro de ese grupo solo 2 bits para un solo FE

	2 bits cada 25ns -> 0.08 Gb/s = 80 Mb/s

___

