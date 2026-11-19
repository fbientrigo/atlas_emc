# EMP / lpGBT · guía de trabajo

La Trenz muestra los registros del EMP, y el enlace IC 10 respondió en la sesión del 19-11-2026. Para saber de dónde viene el payload falta la prueba con un estímulo conocido del front-end.

## Leer datos

Para diagnosticar, leer y guardar el CSV, usa la [guía de operación con emp](15_OPERAR_EMP.md). La [prueba A/B/A del front-end](00_GUIA_CAMPO.md#etapa-d-prueba-externa-aba) y el [procedimiento con la CLI anterior](00_GUIA_CAMPO.md#etapa-c-leer-los-datos-expuestos-por-la-fpga) están en la guía de campo.

## Arquitectura

El camino RX dentro del wrapper está comprobado en el código recuperado. No sabemos qué fuente está seleccionada hoy ni cómo se conecta el capturador de nueve grupos. Las flechas discontinuas son conexiones sin confirmar.

```mermaid
flowchart TD
 FE["Front-end / e-links"] -. "configuración pendiente" .-> CHIP["lpGBT"]
 CHIP -. "enlace físico actual por verificar" .-> MGT["MGT / palabras RX"]
 MGT --> CORE["Gearbox / FEC / descrambler"]
 CORE --> CDC["CDC / UserData 230 bits"]
 CDC -. "integración ausente en la evidencia" .-> CAP["Capturador de nueve grupos"]
 CAP -. "RTL por obtener" .-> AXI["Registros AXI"]
 AXI --> SW["UIO / C++ / terminal"]
```

La clase C++ dice qué registros espera el software. Que la build cargada los tenga es otra cuestión. [Mapa con fuentes](01_MAPA_TECNICO.md).

## Dominios de reloj

El gearbox trabaja con un enable dentro del dominio RX. Después, el CDC pasa 234 bits, y el wrapper los separa en 230 bits de usuario, EC e IC. `ready` no cuenta eventos.

```mermaid
flowchart TD
 subgraph RX["Dominio RX / fuente RTL"]
 M["MGT_USRWORD_i"] --> G["Gearbox 32 a 256 bits"]
 G --> D["Decodificación / 234 bits"]
 end
 D --> C["cdc_rx / relojes relacionados"]
 subgraph PS["Dominio logicclk40"]
 C --> U["UserData 229:0 + EC + IC"]
 U -. "captura por reconstruir" .-> R["Registros visibles al PS"]
 end
```

Wrapper, core y CDC están comprobados en el código. El reloj y el protocolo del capturador cargado son desconocidos. Este CDC no es una FIFO asíncrona cualquiera. [Detalles y límites](10_BLOQUEO_LECTURAS.md#3-hallazgos-nuevos-en-rtl-y-software).

## De un comando a una lectura

La CLI recuperada no lee argumentos, así que incluso `--help` accede al hardware. Hace doce lecturas independientes (extractos B01–B04).

```mermaid
sequenceDiagram
 participant CLI as main()
 participant CPP as TgcReadUplink
 participant UIO as libuio
 participant MEM as MMIO
 CLI->>CPP: constructor por nombre tgc_readUplink_regs
 CPP->>UIO: uio_find_by_uio_name / uio_open
 UIO->>UIO: open + mmap
 CLI->>CPP: readDataGroup0Value()
 CPP->>UIO: uio_read32(map 0, offset 4)
 UIO->>MEM: lectura volatile de 32 bits
 MEM-->>CLI: valor e impresión hexadecimal
```

La flecha de vuelta resume el retorno por las funciones. Que `open` y `mmap` funcionen no garantiza que AXI responda. [Recorrido completo](01_MAPA_TECNICO.md).

## Registros del lector

Esta tabla sale de la clase C++ recuperada. Falta comprobarla en el hardware actual, así que no la uses para explorar otra build.

| Registro | Offset | Qué sabemos |
|---|---|---|
| `magic` | `0x00` | Identificador que espera la clase. No conocemos su valor actual. |
| `data_group_0..8` | `0x04..0x24`, paso 4 | Nueve palabras de 32 bits. No sabemos el packing, el frame ni el canal. |
| `data_header` | `0x28` | Falta el RTL. No lo trates como contador de eventos. |
| `clk_thresh` | `0x2c` | Ajuste de temporización según las notas. No lo barras para diagnosticar. |

Las nueve palabras juntas son 288 bits. No las pegues como si fueran los 230 bits del payload. [Catálogo y variantes](02_CATALOGO.md).

## Control del chip y payload

Son dos caminos distintos. `lpGbtRegister -r` toca el controlador IC y vacía su FIFO, así que no es una lectura inocente del payload.

```mermaid
flowchart TD
 L["Linux"] --> P["tgc_readuplink_cli"]
 L --> I["lpGbtRegister / LpGbtSw"]
 P --> R["Registros del capturador"]
 I --> C["Control / IRQ / FIFO IC"]
 C --> CHIP["Registro remoto del lpGBT"]
 R --> DATA["Palabras expuestas por la FPGA"]
```

Comprobado en el código recuperado (B01–B03, B06, B10). En cada build hay que confirmar cómo está integrado en el hardware. [Herramientas](02_CATALOGO.md).

## Cuando los valores se pegan

Lo primero: ¿el comando vuelve al prompt? Que un reset lo arreglara no dice qué pieza fallaba.

```mermaid
flowchart TD
 Q{"¿Termina el comando?"} -->|"No"| P["Conservar PID / stderr / estado Linux"]
 Q -->|"Sí"| B{"¿Cambian palabras completas?"}
 B -->|"Sí, pero no el byte bajo"| S["Revisar script o representación"]
 B -->|"No"| E{"¿Hay estímulo externo demostrado?"}
 E -->|"No"| U["Resultado inconcluso"]
 E -->|"Sí"| C["Observar progreso UserData y captura"]
 P --> X["Separar bucle IC, espera y acceso AXI"]
```

Si la CLI termina pero repite la misma muestra, lo más probable es que haya que mirar la captura, el rearme y la fuente. La causa original sigue sin conocerse. [Hipótesis H1–H7](10_BLOQUEO_LECTURAS.md) y [script S0–S4](12_SCRIPT_DIAGNOSTICO.md).

## Qué mide cada indicador

| Observación | Qué te dice | Qué no te dice |
|---|---|---|
| Aparece el UIO | Linux registró el dispositivo | Si la IP es compatible o si AXI responde |
| `RX locked` | La FPGA encontró la cabecera (debughub) | De dónde viene el dato, si está íntegro o si es nuevo |
| `XCVR Ready` | AND de ready TX y RX del MGT | Si llegan eventos nuevos |
| El payload cambia | Hay diferencia entre dos lecturas | Si es un frame coherente o viene de fuera |
| El payload se repite | Los valores leídos son iguales | Si el capturador está detenido |

```mermaid
flowchart TD
 S["Niveles de estado / fwMonitor"] --> A["Enlace y alineación, según build"]
 P["Contador o strobe observado"] --> B["Progreso, si su semántica se conoce"]
 D["Estímulo FE y respuesta A/B/A"] --> C["Evidencia de origen externo"]
 A --> V["Combinar evidencias; ninguna basta sola"]
 B --> V
 C --> V
```

La CLI recuperada no muestra contadores ni strobes. La figura describe la prueba que querríamos hacer, con instrumentos que todavía no hay. [Diagnóstico de enlace](00_GUIA_CAMPO.md#etapa-b-diagnosticar-el-enlace).

## Prueba externa A/B/A

Antes de hacerla hay que confirmar el reloj del FE, el cableado, la fuente seleccionada, el estímulo y cuánto retiene la captura. El script solo anota los cambios; no los hace.

```mermaid
sequenceDiagram
 participant OP as Ingeniero
 participant FE as Front-end
 participant LOG as Capturas Linux
 OP->>FE: fijar estado A y comprobarlo físicamente
 OP->>LOG: conservar varias muestras A
 OP->>FE: aplicar estímulo B conocido
 OP->>LOG: anotar instante y conservar muestras B
 OP->>FE: volver a A
 OP->>LOG: conservar A2 y comparar tras la latencia esperada
```

Si los cambios siguen al estímulo y se repiten, eso apunta a recepción externa. Si solo aparecen con loopback, el FE sigue sin probarse. Repite la prueba y guarda la configuración. [Condiciones y qué la invalida](00_GUIA_CAMPO.md#etapa-d-prueba-externa-aba).

## Incompatibilidades que importan

```mermaid
flowchart TD
 B["Build / bitstream identificado"] --> R["RTL y mapa de esa build"]
 R --> T["Device Tree / mapas UIO"]
 T --> C["Contrato de registros"]
 C --> E["ELF + bibliotecas correspondientes"]
 S["Scripts históricos A00D / A00E"] -. "no trasladar direcciones" .-> T
```

En el BD recuperado, `0xA00D0000` y `0xA00E0000` son interrupt controllers, pero algunos scripts los usan como generador y lector. Son versiones distintas que se contradicen. Esto no prueba que la dirección actual esté mal. [Tabla de compatibilidad](11_COMPATIBILIDAD.md).

## Qué falta para cerrar la recuperación

- Qué build está cargada y el RTL del capturador de nueve grupos.
- Packing de los grupos, significado del header, trigger, rearme y coherencia.
- Configuración real del FE y del lpGBT, fuente seleccionada y un estímulo externo repetible.
- Captura del fallo antes del reset y qué se reinicia exactamente.

[Incertidumbres](04_INCERTIDUMBRES.md) · [Historia](03_HISTORIA.md) · [Auditoría](07_AUDITORIA.md) · [Fuentes](08_FUENTES.md). Todo esto sale del código y de las notas; esta investigación no operó el hardware.
