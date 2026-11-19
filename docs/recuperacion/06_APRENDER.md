# Aprender siguiendo una lectura real

Esto es para después de la sesión urgente de [operación](00_GUIA_CAMPO.md). Cada tema termina con una pregunta que se responde en el código o con una medición.

## 1. Separar tres espacios de direcciones

Una base física AXI señala un periférico del PL. Un offset señala un registro dentro de ese periférico. Una dirección de registro del lpGBT señala algo dentro del chip remoto, y se llega a ella por el protocolo IC. Los números pueden coincidir y significar cosas distintas.

Ejemplo comprobado: el wrapper de payload usa el offset `0x04` para `data_group_0`, y el controlador IC lo usa para `control`. En V1, `ULDATASOURCE0=0x128` es una dirección del chip, no un offset del capturador. Míralo en `AxiRegisterDefinitions.h`, `TgcReadUplink.cpp` y `LpgbtRegisterMapV1.h`.

Pregunta: ¿por qué leer `emp_lpgbt_10 + 0x0C` no da el mismo tipo de dato que `tgc_readUplink_regs + 0x0C`?

## 2. Seguir bits antes de asignarles significado

El core recibe palabras de 32 bits, busca la cabecera y rearma los frames. Después deshace el interleaving, corrige con FEC y deshace el scrambling. Con eso se recupera el protocolo del lpGBT, pero todavía no hay canales ni eventos del FE.

Con FEC5/10G24, el core entrega 230 bits de UserData, dos de EC y dos de IC. La nota que habla de 224 bits de e-link conectados no explica cómo se reparten en nueve registros AXI. Ese packing está en el capturador que falta; no se deduce de 9×32.

Pregunta: en `lpgbtfpga_uplink.vhd:492–524`, ¿qué cambia con FEC12 y por qué el puerto puede seguir siendo de 230 bits?

## 3. Distinguir gearbox, enable y cruce de reloj

El gearbox cambia cómo se agrupan los bits. Un enable marca cuándo un frame es válido dentro de un reloj más rápido. El CDC pasa la señal a otro dominio de reloj. Son tres operaciones distintas.

En este core, los dos relojes del gearbox van a `uplinkClk_i`. El CDC que viene después entra con el reloj RX y sale en `logicclk40`. `cdc_rx` usa registros, strobes y fase, y no guarda los eventos para Linux.

Pregunta: sigue `uplinkStrobe320`, `lpgbtfpga_uplinkrst_cdc` y `cdc_rx_ready` en `emp_lpgbt.vhd:473–498`. ¿Por qué `uplinkReady_o` y `RX locked` son señales distintas?

## 4. Entender dónde Linux hace la transacción

`mmap` da una dirección virtual que apunta al dispositivo. El puntero volatile de `uio_read32` pide una lectura de una palabra al periférico; la CPU no está leyendo una copia en RAM. Si el slave no responde, el sistema puede fallar o quedarse esperando, aunque sysfs muestre un mapa correcto.

Pregunta: sigue `main → getter → uio_read32 → volatile` en [el mapa técnico](01_MAPA_TECNICO.md) y separa la dirección virtual, la base física y el offset del registro.

## 5. Aprender a no sobreinterpretar una captura

Una lectura distinta de cero solo dice que el programa vio ese valor, si el acceso y la máscara están bien. No dice de dónde viene, si es nuevo, a qué frame o canal pertenece ni si está íntegro. Una lista de getters no es un snapshot.

Con un patrón sostenido se reduce la duda sobre el momento en una primera prueba. Con eventos sueltos hace falta un contrato de captura, un buffer o un handshake. Leer `header` antes y después no garantiza atomicidad si el mismo header se repite en muchos frames.

Pregunta: escribe la predicción P→Q→P antes de mirar las salidas. ¿Qué resultado tumbaría la hipótesis del FE? ¿Y qué seguirías sin saber aunque la correlación funcione?

## 6. Leer la historia como evidencia experimental

Una nota puede mezclar en un mismo párrafo comandos ejecutados, resultados, sospechas y planes. «Parece ruido» o «debería ser sincronización» son hipótesis. «Se usó loopback» limita lo que prueba la nota, aunque el título diga «tenemos lectura».

Pregunta: compara `1006`, `1028` y `1028-1031`. Separa la constante interna que sí se recuperó, el cable dañado que se anotó y la prueba del FE que no confirma que el dato llegara intacto. [Historia reconstruida](03_HISTORIA.md).
