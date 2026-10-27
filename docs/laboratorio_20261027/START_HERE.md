# Mañana: identificar, capturar, demostrar

**Tenemos un lector de registros. Todavía no tenemos una recepción FE validada.** La tarea de mañana es unir el firmware activo con ese lector y comprobar una respuesta externa reproducible. Investigación estática del 27-10-2026; ningún acceso a hardware.

## Los primeros diez minutos

1. Abrir [el briefing](ENGINEER_BRIEFING.md) con el ingeniero. Identificar placa, canal y qué significaba «reiniciar» cuando se recuperaba el sistema.
2. En la **Trenz**, desde la raíz de `atlas_emc`, ejecutar solo el inventario:

   ```bash
   # LECTURA PASIVA del hardware; crea un archivo local nuevo.
   python3 docs/recuperacion/diagnostico/atlas_diagnostico.py inventario \
     --salida inventario_trenz_01.json
   ```

   Si falta Python, usar [A: inventario manual](LAB_SESSION.md#etapa-a--identidad-0-25-min). Si el archivo existe, elegir otro nombre. No reemplazar evidencia.
3. Localizar `read_all_lpgbt/tgc_readuplink_cli`, su `TgcReadUplink.cpp` y las bibliotecas. La ubicación anterior es **relativa al respaldo**, no una ruta instalada garantizada. [Atlas de rutas](TOOL_AND_PATH_ATLAS.md).
4. Antes de ejecutarlo, confirmar **bitstream + Device Tree + mapa de registros + ELF/bibliotecas + efectos de lectura**. El nombre UIO y `magic` por sí solos no cierran esa identidad.

**No ejecutar `tgc_readuplink_cli --help`: su `main()` ignora argumentos y lee hardware.** Tampoco usar los scripts históricos de barrido como inventario.

## Tres hallazgos que cambian la decisión

- **`0xA00D0000` no identifica un periférico universal.** El BD del repositorio ubica allí un controlador de interrupciones; dos XSA del respaldo, una interfaz e-link; los overlays `out_lpgbt_10_*` del repositorio, `Read_PRBS_regs`. Son diseños distintos. [Matriz](SYSTEM_MAP.md#versiones-incompatibles).
- **El lector TGC devuelve doce registros secuenciales, sin contador de frescura ni snapshot demostrado.** Los nueve grupos no son automáticamente un frame. La función que toca MMIO es `uio_read32()`, en `libuio/mem.c:209–221`.
- **«Pegado» tiene varias causas distinguibles.** `read_lpgbt10.sh` oculta cambios fuera del byte bajo; el control IC tiene bucles sin límite; si la CLI TGC retorna normalmente, esas esperas IC no explican su repetición. [Árbol de diagnóstico](LAB_SESSION.md#etapa-f--congelamiento-100-120-min).

## Ruta de dos horas

| Minutos | Resultado que debemos obtener |
|---|---|
| 0–25 | Identidad Linux/placa/UIO y procedencia del firmware, o bloqueo exacto |
| 25–40 | Lector compatible seleccionado; mapa y bibliotecas confirmados |
| 40–55 | Estado del transporte, separado de validez del payload |
| 55–75 | Tres capturas completas con metadatos, si las puertas anteriores están cerradas |
| 75–100 | Prueba FE A/B/A con predicción previa y control físico |
| 100–120 | Clasificar el fallo o ensayar cómo conservarlo antes de recuperar |

Seguir [LAB_SESSION](LAB_SESSION.md). Si falta el mapa/RTL activo, usar el tiempo restante para resolverlo y practicar offline; no improvisar MMIO.

**Éxito acotado:** una respuesta FE reproducible en la configuración documentada. No implica adquisición continua, frames coherentes ni ausencia de pérdidas.

Consulta: [arquitectura](SYSTEM_MAP.md) · [rutas](TOOL_AND_PATH_ATLAS.md) · [referencia rápida](QUICK_REFERENCE.md) · [cinco lecciones](TEACHING_SESSION.md) · [auditoría](AUDIT_AND_UNCERTAINTIES.md).
