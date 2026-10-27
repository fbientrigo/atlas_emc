# Briefing para la sesión con el ingeniero

**Decisión requerida:** identificar la build activa y su interfaz de captura antes de elegir el lector. La documentación y el respaldo contienen varias generaciones incompatibles.

## Conocido y desconocido

| Conocido por archivos | Todavía desconocido en el equipo |
|---|---|
| CLI TGC AArch64; nombre fijo `tgc_readUplink_regs`; map0 `0x00..0x2C` | ELF y bibliotecas que se ejecutan hoy |
| Nueve grupos, `magic`, `data_header`, `clk_thresh` | Packing FE, trigger, rearme, semántica de lectura y coherencia |
| XSA Trenz: XCZU4EG; variantes Enclustra: XCZU4CG | Modelo físico actual y relación con el bitstream cargado |
| XSA xV23 conecta `emp_lpgbt_11` a `elink_memory_interfa_0` | Si esa interfaz, la TGC u otra es la instalada |
| Ensayos históricos con patrones y loopback | Recepción actual de datos externos, fidelidad y tasa sostenible |

## Herramientas disponibles

`tgc_readuplink_cli`: candidato para palabras crudas del mapa TGC de nueve grupos. `readuio`: alternativa existente con nombre/offset explícitos, tras validar su versión. `fwMonitor`: estados FPGA del enlace. `lpGbtRegister`: configuración del chip mediante control IC activo. `readprbs_cli`: lectura y estímulo del bloque de pruebas; no es un receptor FE universal. `atlas_diagnostico.py`: inventario y supervisor de la CLI TGC, con informe offline.

## Qué necesitamos confirmar juntos

1. Placa/SoC, chip lpGBT V0/V1, fibra/MGT y e-link físico utilizados.
2. Bitstream/DTBO activos, hashes, procedimiento de carga y exportación de Vivado correspondiente.
3. RTL del capturador: fuente de cada grupo, dominio de reloj, `magic`, header, threshold, trigger, rearme y efectos de lectura.
4. Configuración efectiva de fuentes de datos: Serializer, grupos, PRBS/loopback, enables, tasas y FEC. Una configuración guardada no prueba el estado vigente.
5. Estímulo FE seguro que produzca una predicción precisa y pueda medirse independientemente.
6. Programa exacto que se detenía; si retornaba al prompt; qué reset se usaba y cuánto duraba la recuperación.

## Qué mediremos

Primero identidad y estado sin MMIO. Después, si el mapa está validado, tres lecturas acotadas con salida, errores, retorno y tiempos. Finalmente A/B/A: patrón o estímulo FE sostenido, cambio previsto en bits/grupos identificados y vuelta a A, repitiendo el ciclo si el tiempo lo permite.

**Captura satisfactoria:** datos completos, identidad/configuración conservadas, respuesta al estímulo en el canal previsto, control físico confirmado y fuentes internas excluidas. Sin packing conocido solo podemos acreditar sensibilidad al estímulo, no decodificación correcta.

**Evitar:** direcciones históricas a ciegas, dos lectores simultáneos, reset antes de registrar el fallo y tratar `RX locked`, `selftest OK` o un código de salida cero como prueba de datos válidos. `clkProgrammer -i` requiere además verificar bus y página del Si5345.

[Guion de 120 minutos](LAB_SESSION.md) · [evidencias y pendientes](AUDIT_AND_UNCERTAINTIES.md). No se han ejecutado binarios del respaldo ni validado el hardware.
