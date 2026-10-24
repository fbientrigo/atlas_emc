# Aprender siguiendo una lectura real

Usar este itinerario después de la sesión urgente de [operación](00_GUIA_CAMPO.md). Cada paso termina con una pregunta que puede resolverse en código o con una medición concreta.

## 1. Separar tres espacios de direcciones

Una base física AXI identifica un periférico del PL. Un offset identifica un registro dentro de ese periférico. Una dirección de registro lpGBT identifica algo dentro del chip remoto y llega mediante el protocolo IC. Pueden compartir valores numéricos sin significar lo mismo.

Ejemplo verificado: el wrapper de payload usa offset `0x04` para `data_group_0`; el controlador IC lo usa para `control`. En V1, `ULDATASOURCE0=0x128` es una dirección del chip, no el offset del capturador. Buscar `AxiRegisterDefinitions.h`, `TgcReadUplink.cpp` y `LpgbtRegisterMapV1.h`.

**Comprobación:** explicar por qué leer `emp_lpgbt_10 + 0x0C` no obtiene el mismo tipo de dato que `tgc_readUplink_regs + 0x0C`.

## 2. Seguir bits antes de asignarles significado

El core recibe palabras de 32 bits, busca cabecera y reconstruye frames. Después deshace interleaving, corrige FEC y deshace scrambling. Esas operaciones recuperan el protocolo lpGBT; aún no interpretan canales o eventos FE.

Para FEC5/10G24 la interfaz del core presenta 230 bits de UserData y dos bits EC más dos IC. La nota sobre 224 bits e-link conectados no demuestra cómo se empaquetaron nueve registros AXI. Ese packing debe buscarse en el capturador ausente, no deducirse de 9×32.

**Comprobación:** localizar en `lpgbtfpga_uplink.vhd:492–524` qué cambia con FEC12 y por qué el ancho del puerto puede seguir siendo 230.

## 3. Distinguir gearbox, enable y cruce de reloj

Gearbox cambia la agrupación de bits. Un enable indica cuándo un valor de frame es válido dentro de un reloj más rápido. CDC mueve la observación a otro dominio de reloj. No son la misma operación.

En este core, ambos clocks del gearbox se conectan a `uplinkClk_i`. El CDC explícito posterior tiene entrada en el reloj RX y salida en `logicclk40`. `cdc_rx` usa registros, strobes y fase; no almacena todos los eventos para Linux.

**Comprobación:** seguir `uplinkStrobe320`, `lpgbtfpga_uplinkrst_cdc` y `cdc_rx_ready` en `emp_lpgbt.vhd:473–498`. Explicar por qué `uplinkReady_o` y `RX locked` no son la misma señal.

## 4. Entender dónde Linux hace la transacción

`mmap` crea un acceso virtual al dispositivo. La expresión con puntero volatile en `uio_read32` solicita una lectura de palabra al periférico. La CPU no está leyendo una copia ordinaria en RAM. Si el slave no responde, el sistema puede fallar o quedarse esperando, aunque sysfs describa un mapa correcto.

**Comprobación:** seguir `main → getter → uio_read32 → volatile` en [el mapa técnico](01_MAPA_TECNICO.md). Separar una dirección virtual, la base física y el offset de registro.

## 5. Aprender a no sobreinterpretar una captura

Una lectura distinta de cero solo confirma que el programa observó ese valor, si el acceso y máscara son correctos. No informa automáticamente de origen, frescura, frame, canal ni integridad. Una lista de getters no es un snapshot.

Con un patrón sostenido se puede reducir la ambigüedad temporal de una prueba inicial. Con eventos transitorios hace falta un contrato de captura, buffer o handshake. Releer `header` antes/después no garantiza atomicidad si ese header puede repetirse para muchos frames.

**Comprobación:** diseñar la predicción P→Q→P antes de mirar las salidas. Enumerar qué observación refutaría la hipótesis FE y qué seguiría sin poderse concluir aun si la correlación funciona.

## 6. Leer la historia como evidencia experimental

Una nota puede contener comandos ejecutados, resultados, conjeturas y planes en el mismo párrafo. «Parece ruido» o «debería ser sincronización» son hipótesis. «Se usó loopback» limita el alcance de la evidencia aunque el título diga «tenemos lectura».

**Comprobación:** comparar `1006`, `1028` y `1028-1031`. Separar el éxito de recuperación de una constante interna, el defecto de cable anotado y la prueba de FE sin fidelidad demostrada. [Historia reconstruida](03_HISTORIA.md).
