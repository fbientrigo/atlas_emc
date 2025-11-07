# Semana 3 – Validación cruzada y normativa operativa

## 1. Metodología de revisión
- Se confrontó `logging/2025-week2_assets_catalog.csv` con todas las notas Markdown para confirmar que cada `![[…]]` apunta a la nueva ruta normalizada.
- Se inspeccionó `assets_index.md` para detectar filas sin notas asociadas y se generaron listados específicos de imágenes huérfanas.
- Se revisaron los logs y documentos técnicos para identificar referencias históricas que carecían del archivo físico.

## 2. Resultados principales
- **Enlaces vigentes:** tras la actualización automática, ninguna incrustación `![[…]]` apunta a rutas antiguas; la búsqueda `rg '!\[\[[^]]*\.(png|jpg|jpeg|gif|bmp|svg)' -g'*.md' | grep -v 'assets/'` retorna cero coincidencias.
- **Captura faltante:** el log `logging/0826-petalinux.md` mencionaba `petalinux_system_conf.png`. Se dejó constancia textual de la ausencia mientras se recupera el artefacto desde respaldos previos.
- **Imágenes sin nota asociada (26):**
  - Diagramas: `assets/diagramas/2024/01/schem-b2b-connection-clk7.png`, `assets/diagramas/2024/09/0926-mermaid-downlinkuserdata.svg`, …
  - Documentación externa: `assets/documentacion/2024/01/bergm-rtax-s-letcross.png`, `assets/documentacion/2024/01/letvscrosssection.png`.
  - Duplicados históricos EMP (`01_relacion*.svg`, `ScrambleData.png`, etc.) preservados como `-v2` en `assets/firmware/2024/01/` para evaluación técnica.
  - Fotografías sin contexto actual: `assets/hardware/2024/01/systemconnection.png`, `assets/hardware/2024/01/emp-firmware-lpgbt-connections.png`.
- **Acciones recomendadas:**
  1. Revisar con los responsables de firmware si los duplicados pueden consolidarse en una versión canónica.
  2. Incluir en próximas notas de hardware las fotografías `systemconnection.png` y `emp-firmware-lpgbt-connections.png` o archivarlas si ya no representan el estado real.
  3. Recuperar la captura `petalinux_system_conf.png` desde respaldos o regenerarla para completar el historial.

## 3. Normativa para futuras notas
- Se creó `20_Documents/Note_creation_checklist.md` con el checklist actualizado para la generación de notas.
- Nuevo paso obligatorio: **toda imagen debe almacenarse en `assets/<categoria>/<YYYY>/<MM>/` usando slug descriptivo** y registrarse de inmediato en el catálogo (`python3 scripts/generate_assets_index.py`).
- El checklist incluye verificación de metadatos (autor/fecha) y la sincronización del CSV maestro para evitar divergencias en auditorías trimestrales.

La validación cierra la semana 3 dejando documentadas las excepciones, las tareas pendientes y la norma operativa que evitará regresiones.
