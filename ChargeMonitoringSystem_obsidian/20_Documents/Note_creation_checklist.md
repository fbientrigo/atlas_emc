# Checklist para creación y mantenimiento de notas

1. **Contexto y metadatos**
   - Registrar fecha y responsable al inicio de la nota.
   - Enlazar la nota con el proyecto o sprint correspondiente.
2. **Gestión de imágenes y evidencias**
   - Guardar cada recurso gráfico en `assets/<categoria>/<YYYY>/<MM>/<slug>.<ext>` usando los scripts provistos (`scripts/relocate_assets.py`).
   - Actualizar el catálogo maestro ejecutando `python3 scripts/generate_assets_index.py`.
   - Referenciar las imágenes en la nota con `![[assets/...]]`, confirmando que la vista previa funciona.
3. **Registro en logging**
   - Añadir en `logging/` un apunte con los cambios relevantes y las evidencias asociadas.
4. **Validaciones finales**
   - Ejecutar `rg '!\[\[[^]]*\.(png|jpg|jpeg|gif|bmp|svg)' -g'*.md' | grep -v 'assets/'` para verificar que no queden enlaces rotos.
   - Revisar duplicados potenciales (`assets/.../-vN`) y decidir si se consolidan o se mantienen versiones paralelas.
5. **Auditoría periódica**
   - Programar revisiones trimestrales para detectar archivos fuera de `assets/` o sin nota asociada.
   - Documentar las excepciones y acciones correctivas en `Image_assets_week3_validation.md`.

> Este checklist es obligatorio para nuevas notas y actualizaciones que incorporen imágenes u otras evidencias visuales.
