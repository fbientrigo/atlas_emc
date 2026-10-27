# Referencia rápida de mesa

[Inicio](START_HERE.md) · [Sesión completa y puertas](LAB_SESSION.md) · [Atlas de paths B/R](TOOL_AND_PATH_ATLAS.md)

**Antes de MMIO:** build/DT/mapa + ELF/bibliotecas + efectos de lectura + operador único. `--help` de TGC lee hardware. Bases históricas no autorizan accesos.

## Qué abrir para cada pregunta

| Quiero… | Herramienta / fuente | Límite |
|---|---|---|
| Identificar instalación | R/docs/recuperacion/diagnostico/atlas_diagnostico.py, `inventario` | Pasivo; no prueba identidad PL por sí solo |
| Leer palabras TGC | B/read_all_lpgbt/tgc_readuplink_cli; TgcReadUplink.cpp | Solo mapa de nueve grupos validado; no es stream de eventos |
| Encontrar acceso al bus | B/libuio/mem.c:209–221, `uio_read32` | Carga volatile32 sin comprobación de rango |
| Ver transporte | B/emp-tools/empTools/fwStatus/fwStatus.cpp, `fwMonitor` | Estado del debughub, no origen/frescura FE |
| Consultar/configurar chip | B/LpGbtSw/LpGbtUioBackend/ | IC activo: escribe incluso al leer; no payload |
| Revisar prueba interna | B/puzzled_working/readprbs_cli.cpp | Selftest lee; OK no valida contenido |
| Revisar reloj | B/emp-tools/src/i2cDevices/si5345.cpp | Lectura sin selección de página; diagnóstico condicionado |
| Comparar capturas | Supervisor `informe`; comparador en R/docs/recuperacion/ | Solo datos guardados; no determina causa ni origen automáticamente |

## Registros: solo el contrato TGC B/read_all_lpgbt

| Offset | Campo | No asumir |
|---|---|---|
| 0x00 | magic | Firma/versionado sin especificación |
| 0x04,08,0C,10,14,18,1C,20,24 | grupos 0…8, 32 bits cada uno | Un mismo frame, packing o 288 bits FE útiles |
| 0x28 | data_header | Cabecera física o contador |
| 0x2C | clk_thresh | Hz, período o programación Si5345 |

PRBS usa +4 **control**, +8 **status**, +C **data**. IC usa +4 **control**, +8 **status**, +C **FIFO RX**. Igual offset no implica igual función. A00D puede ser INTC, e-link o PRBS según build; [matriz](SYSTEM_MAP.md#versiones-incompatibles).

## Comandos por nivel de efecto

Desde raíz de R en el dispositivo; variables y plan preparados según [LAB_SESSION](LAB_SESSION.md). Usar nombres de salida nuevos.

```bash
# LECTURA PASIVA: no ejecuta el lector.
python3 "$DIAG" inventario --lector "$LECTOR" --salida inventario_02.json
readelf -h -l -d -n "$LECTOR"
sha256sum "$LECTOR"
python3 "$DIAG" preparar --inventario inventario_02.json --salida plan_02.json
```

Completar evidencia y bibliotecas del plan; no convertir todos los booleanos en true para saltar la puerta.

```bash
# MMIO DE SOLO LECTURA VERIFICADA: contrato y plan cerrados.
python3 "$DIAG" capturar --plan plan_02.json --salida sesion_02 \
  --fase inicial --muestras 3 --intervalo 5 --timeout 3 --autorizar-lecturas

# LECTURA PASIVA: revisar incluso una sesión fallida.
python3 "$DIAG" informe --sesion sesion_02 --salida informe_02.md
```

**ACCIONES CON EFECTOS, fuera de la rutina:** `clkProgrammer -c/-i`, `lpGbtRegister -r/-w`, writes PRBS, scripts devmem, carga de overlay, reset y cambio de estímulo. Usar únicamente procedimiento específico validado. «Read» de chip puede escribir el controlador; lectura AXI puede consumir/limpiar registros.

## Síntoma → próxima decisión

| Síntoma | Primera observación útil / acción siguiente |
|---|---|
| No vuelve al prompt | PID/estado/wchan, salida y tiempos; no iniciar otro lector |
| Vuelve, palabras iguales | Comparar 32 bits y A/B/A físico; distinguir constante de retenido |
| Cambian bits altos, byte bajo igual | Revisar máscara `&0xff` de read_lpgbt10.sh |
| Lock alto, datos quietos | No inferir frescura; observar strobe/captura en instrumentación existente |
| Faltan palabras o hay stderr | Conservar fallo; no sustituir por cero |
| Funciona solo tras reboot | Registrar qué cambió, incluida programación de reloj al boot si activa |
| Error de UIO/ABI | Detener; revisar identidad, no probar otra base histórica |

**Antes de reset:** última buena/primera mala, inventario, PID, sesiones/lock, hashes, mapa, estímulo y estados disponibles. **Captura satisfactoria:** completa, trazable y respuesta FE prevista reproducible, con fuentes internas excluidas. Si falta packing, conclusión limitada a sensibilidad; no BER ni decodificación certificada.
