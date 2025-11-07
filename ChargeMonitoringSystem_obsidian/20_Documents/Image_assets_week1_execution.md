# Semana 1 – Ejecución del plan de migración de recursos gráficos

## 1. Auditoría completa de imágenes

### 1.1 Metodología aplicada
- **Extracción de referencias en notas:** se utilizó `rg '!\\[' -n 30_Notes` y un script Python para recorrer los 153 archivos Markdown dentro de `30_Notes`, recopilando todas las incrustaciones `![[...]]` con su nota de origen, número de línea y contexto inmediato.
- **Inventario de archivos gráficos:** se escanearon todas las carpetas del repositorio Obsidian para identificar archivos con extensiones `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp` y `.svg`.
- **Consolidación de resultados:**
  - Se generó `logging/2025-Week1_image_audit.csv` con 78 filas (una por cada referencia encontrada) incluyendo: nombre de la imagen, ubicaciones actuales, nota origen, línea y sintaxis utilizada.
  - Se elaboró `20_Documents/Image_assets_week1_audit_details.md` con fichas individuales por imagen (76 únicas), mostrando contexto resumido y todas las notas donde se utiliza cada recurso.
- **Control de integridad:** durante la auditoría no se detectaron rutas inexistentes; toda referencia encontrada apunta a un archivo disponible en el repositorio local.

### 1.2 Métricas clave
| Métrica | Resultado |
| --- | --- |
| Imágenes totales detectadas en el repositorio | 96 |
| Imágenes referenciadas desde notas (`![[ ]]`) | 76 |
| Referencias totales (algunas imágenes aparecen en varias notas) | 78 |
| Imágenes sin referencias vigentes | 20 |

### 1.3 Imágenes sin referencia actual
Las siguientes 20 imágenes se encuentran almacenadas pero no fueron detectadas en notas. Se registran para decidir su reubicación, documentación o depuración durante las próximas fases:

- 01_relacionFunciones.svg (`_assets/svg/01_relacionFunciones.svg`, `_assets/EMP_Firmware_data/01_relacionFunciones.svg`, `0409_analisis_codigo/01_relacionFunciones.svg`)
- 02_relacionVariables.svg (`_assets/svg/02_relacionVariables.svg`, `_assets/EMP_Firmware_data/02_relacionVariables.svg`, `0409_analisis_codigo/02_relacionVariables.svg`)
- 03_relacionMain.svg (`_assets/svg/03_relacionMain.svg`, `_assets/EMP_Firmware_data/03_relacionMain.svg`, `0409_analisis_codigo/03_relacionMain.svg`)
- 0916_mermaid_interruptFromUplink.svg (`_assets/EMP_Firmware_data/0916_mermaid_interruptFromUplink.svg`)
- 0926_mermaid_downlinkUserData.svg (`_assets/EMP_Firmware_data/0926_mermaid_downlinkUserData.svg`)
- BergM_RTAX-S-LETCross.png (`BergM_RTAX-S-LETCross.png`)
- LEtVsCrossSection.png (`LEtVsCrossSection.png`)
- MGT_Polarity_options.png (`_assets/misc/MGT_Polarity_options.png`)
- MGT_Polarity_options_02va.png (`_assets/misc/MGT_Polarity_options_02va.png`)
- NGMediumResetMask_Results.png (`_assets/misc/NGMediumResetMask_Results.png`)
- ProgrammerModule.png (`_assets/misc/ProgrammerModule.png`)
- Registers_readerSystem.png (`Registers_readerSystem.png`)
- ScrambleData.png (`_assets/EMP_Firmware_data/ScrambleData.png`)
- lpgbt_MGT_user_word_to_rst.svg (`10_Modules/emp_firmware_lpgbt/lpgbt_MGT_user_word_to_rst.svg`)
- output_firmware_emp_gen_tcl.png (`_assets/misc/output_firmware_emp_gen_tcl.png`)
- pinassign.png (`docs_hardware/pinassign.png`)
- schem_b2b_connection_clk7.png (`_assets/misc/schem_b2b_connection_clk7.png`)
- systemConnection.png (`systemConnection.png`)
- tabla_pins_J1.png (`docs_hardware/tabla_pins_J1.png`)
- tabla_pins_J2.png (`docs_hardware/tabla_pins_J2.png`)

### 1.4 Observaciones principales
- Existe duplicación de ciertos recursos (p.ej. las imágenes `01_relacion*.svg` aparecen replicadas en tres rutas distintas).
- Algunos archivos relevantes (p.ej. diagramas de programación `ProgrammerModule.png`) están disponibles pero nunca se referenciaron en notas, lo que sugiere incorporarlos en documentación técnica o archivar versiones obsoletas.
- Se identificaron convenciones de nombres heterogéneas (mezcla de idiomas, abreviaturas y tipografías) que deberán armonizarse durante la fase de migración.

## 2. Diseño de taxonomía propuesta

### 2.1 Principios generales
- **Estructura de carpetas:** `<categoria>/<YYYY>/<MM>/<slug>.<ext>` partiendo de una carpeta raíz común para todos los activos (`assets/` sugerida).
- **Slug normalizado:** utilizar minúsculas, guiones y palabras clave descriptivas (p.ej. `reloj-pll-entrada` en lugar de `table_clock_inputsPLL`).
- **Fecha de origen:** emplear el año y mes del evento documentado (captura, medición, generación de reporte) para facilitar búsquedas temporales.
- **Versionado explícito:** cuando haya múltiples iteraciones relevantes, anexar sufijos `v1`, `v2` o fechas adicionales en el slug para evitar duplicados dispersos.

### 2.2 Categorías y cobertura
La siguiente tabla muestra las seis categorías que cubren el 100 % de los 96 archivos detectados, junto con ejemplos y criterios de clasificación.

| Categoría | Alcance y criterios | Ejemplos actuales | Conteo |
| --- | --- | --- | --- |
| `hardware` | Fotografías de tarjetas, conexiones físicas, asignaciones de pines, cableado y puertos. | `emp_firmware_lpgbt_connection_example.png`, `bootingZynq.png`, `tabla_pins_J1.png` | 23 |
| `firmware` | Evidencias de flujos de Vivado, resultados de síntesis/implementación, diagramas funcionales de IP, marcos de datos y registros. | `LpGbt_FEC5_frameStructure.png`, `Implementation_CriticalWarning.png`, `registerReadingSystem.png` | 49 |
| `diagramas` | Tablas técnicas, esquemáticos eléctricos/lógicos y diagramas de arquitectura. | `schem_clk8_diff.png`, `table_pll_clock_gen.png`, `lpgbt_MGT_user_word_to_rst.svg` | 14 |
| `interfaces` | Capturas de software, GUIs o comunicación con herramientas (PGBT, Mattermost, OPC-UA, programadores). | `pigbt_welcome.png`, `dominiccker_mattermost_02v.png`, `ProgrammerModule.png` | 6 |
| `mediciones` | Gráficas de instrumentos, resultados de laboratorio y mediciones en tiempo real. | `OsciloscopeSignal.png`, `EMP_saturationTest.png` | 1 |
| `documentacion` | Recursos importados de documentación externa (presentaciones, papers, imágenes de referencia). | `BergM_RTAX-S-LETCross.png`, `CLPS.png`, `LEtVsCrossSection.png` | 3 |

> **Verificación de cobertura:** cada archivo del inventario fue evaluado contra los criterios anteriores; no quedan elementos sin categoría asignada.

### 2.3 Ejemplo de rutas objetivo
- Captura de la interfaz PGBT tomada en septiembre de 2022: `interfaces/2022/09/pigbt-uplink-options.png`.
- Tabla de configuración de reloj generada en octubre de 2021: `diagramas/2021/10/clk-config-table.png`.
- Fotografía de conexión EMP–LPGBT obtenida en julio de 2024: `hardware/2024/07/emp-lpgbt-conexion-ejemplo.png`.
- Resultado de implementación Vivado con advertencias registrado en diciembre de 2024: `firmware/2024/12/vivado-implementation-warnings.png`.

### 2.4 Recomendaciones para adopción
1. **Migración asistida:** preparar scripts que lean `logging/2025-Week1_image_audit.csv` para mover cada archivo a la ruta nueva y actualizar referencias en las notas.
2. **Control de duplicados:** consolidar versiones duplicadas antes de moverlas, conservando la más reciente y vinculando notas a un único archivo canónico.
3. **Metadatos mínimos:** al crear un nuevo recurso, registrar fecha, autor y nota asociada dentro del catálogo maestro que se generará en la semana 2.
4. **Checklist operativo:** añadir al flujo de trabajo de notas un paso obligatorio para ubicar imágenes en la taxonomía y registrar su uso en el inventario.

## 3. Entregables generados
- `logging/2025-Week1_image_audit.csv`: hoja de cálculo con vínculos nota ↔ imagen y contexto de uso.
- `20_Documents/Image_assets_week1_audit_details.md`: fichas narrativas por imagen, listas para revisión cruzada con responsables.
- `20_Documents/Image_assets_week1_execution.md` (este documento): resumen ejecutivo de la semana 1, métricas y taxonomía propuesta.

Con estos entregables se da por completada la ejecución de la semana 1, dejando preparados los insumos para la fase de migración y catalogación de la semana 2.
