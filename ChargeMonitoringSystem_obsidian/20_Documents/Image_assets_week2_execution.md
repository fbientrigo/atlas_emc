# Semana 2 – Renombrado asistido y catálogo maestro

## 1. Migración automatizada a la nueva taxonomía
- **Script dedicado:** se implementó `scripts/relocate_assets.py`, que lee el inventario de la semana 1, clasifica cada activo según reglas heurísticas y lo mueve a `assets/<categoria>/<YYYY>/<MM>/<slug>.<ext>`.
- **Ejecución controlada:**
  - Previsualización (`python3 scripts/relocate_assets.py`) para validar el plan de movimientos.
  - Aplicación real (`python3 scripts/relocate_assets.py --apply`) que:
    - reubica 102 archivos gráficos existentes en el repositorio,
    - normaliza los nombres (slug en minúsculas con guiones),
    - agrega sufijos `-vN` cuando detecta duplicados, preservando versiones históricas.
- **Distribución final por categoría:**
  - `firmware`: 47 archivos
  - `diagramas`: 20 archivos
  - `interfaces`: 16 archivos
  - `hardware`: 14 archivos
  - `documentacion`: 3 archivos
  - `mediciones`: 2 archivos
- **Suposiciones explícitas:** ante la ausencia de año en la nomenclatura histórica, se tomó 2024 como campaña base y se infirió el mes a partir de la nota que originó cada evidencia.
- **Residuos heredados:** los directorios `_assets/*` permanecen únicamente con archivos auxiliares (`.txt`); todas las imágenes viven ahora dentro de `assets/`.

## 2. Actualización masiva de referencias Markdown
- El script reemplaza cualquier incrustación `![[…]]` que apuntaba a un nombre suelto por la ruta final en `assets/…`, conservando modificadores de tamaño (`|300`, `|600`, etc.).
- Validación posterior:
  - `rg '!\[\[[^]]*\.(png|jpg|jpeg|gif|bmp|svg)' -g'*.md' ChargeMonitoringSystem_obsidian | grep -v 'assets/'` → sin coincidencias, lo que confirma cero enlaces rotos.
  - La única referencia obsoleta (`petalinux_system_conf.png`) se documentó en `logging/0826-petalinux.md` como captura pendiente, eliminando la incrustación rota.

## 3. Generación del catálogo maestro
- **Registro estructurado:** `logging/2025-week2_assets_catalog.csv` exporta para cada imagen su origen, categoría, fecha (año/mes inferidos) y notas donde aparece.
- **Índice legible:** el script `scripts/generate_assets_index.py` transforma el CSV en `20_Documents/assets_index.md`, tabla con las columnas requeridas (`imagen`, `uso principal`, `fecha`, `autor`).
- **Flujo reproducible:**
  1. Ejecutar `python3 scripts/relocate_assets.py --apply` tras añadir nuevas imágenes.
  2. Regenerar el CSV y el índice con `python3 scripts/generate_assets_index.py`.
  3. Documentar cualquier archivo sin nota vinculada dentro de la sección de validación (ver semana 3).

Con estos entregables se cierra la semana 2, dejando a disposición scripts idempotentes para mantener la taxonomía y los catálogos sincronizados.
