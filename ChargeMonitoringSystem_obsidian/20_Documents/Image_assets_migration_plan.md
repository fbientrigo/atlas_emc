# Plan de gestión y migración de recursos gráficos

## Objetivo
Establecer un proceso estructurado para auditar, reorganizar y documentar todos los recursos gráficos utilizados en el repositorio Obsidian, garantizando trazabilidad total entre notas y evidencias visuales, así como normas sostenibles para el futuro.

## Cronograma y entregables

### Semana 1

#### Auditoría completa (2 días)
- Exportar un listado con la ruta, nombre y uso de cada imagen detectada en las notas (`rg "!\\[" -n 30_Notes`).
- Registrar los vínculos nota ↔ imagen en la misma hoja de cálculo utilizada para los logs del equipo.

#### Diseño de taxonomía (1 día)
- Definir una estructura de carpetas y nombres de archivo con el formato `<categoria>/<YYYY>/<MM>/<slug>.<ext>`.
- Alinear las categorías con el equipo (p. ej., `hardware`, `firmware`, `plots`, `diagramas`).
- Validar que la taxonomía cubra el 100 % de los casos antes de mover archivos.

### Semana 2

#### Renombrado y migración asistida (3 días)
- Desarrollar scripts para mover y renombrar las imágenes siguiendo la taxonomía aprobada.
- Actualizar automáticamente las rutas en los archivos Markdown (herramientas sugeridas: `obsidian-export` o scripts personalizados).
- Verificar que no existan enlaces rotos mediante búsquedas de `![[` y `![]`.
- **Estado 2025-11-07:** completado con `scripts/relocate_assets.py`; ver `Image_assets_week2_execution.md`.

#### Catálogo maestro (1 día)
- Generar un índice en `20_Documents/assets_index.md` con una tabla que incluya `imagen`, `uso principal`, `fecha` y `autor`.
- Completar la tabla al 100 % antes de finalizar la semana.
- **Estado 2025-11-07:** `assets_index.md` generado automáticamente desde `logging/2025-week2_assets_catalog.csv`.

### Semana 3

#### Validación cruzada (2 días)
- Revisar, junto con el plan de migración de notas, que cada evidencia mencionada quede enlazada en la nueva estructura.
- Documentar cualquier imagen huérfana y decidir si se archiva o se incorpora con la metadata correspondiente.
- **Estado 2025-11-07:** consolidado en `Image_assets_week3_validation.md` con lista de pendientes y acciones.

#### Normativa futura (continuo)
- Incorporar en el checklist de creación de notas la obligatoriedad de almacenar imágenes siguiendo la taxonomía.
- Registrar los metadatos de cada nueva imagen en el catálogo maestro.
- Programar auditorías trimestrales para detectar archivos fuera de las carpetas oficiales y corregir desviaciones.
- **Estado 2025-11-07:** checklist formalizado en `Note_creation_checklist.md`.

## Resultados esperados
- Inventario completo y confiable de los recursos gráficos.
- Taxonomía consensuada que asegure coherencia y escalabilidad.
- Migración sin enlaces rotos y documentación actualizada al 100 %.
- Procesos recurrentes que prevengan la acumulación de activos desorganizados en el futuro.
