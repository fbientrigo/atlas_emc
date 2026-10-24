# Utilizar la base sin conexión

Abrir `docs/recuperacion/index.html` en un navegador local después de descargar la rama `docs/clean`. No hace falta instalar servicios, ejecutar Python ni levantar un servidor. La búsqueda y los extractos están incluidos en el propio archivo.

## Cuatro entradas

| Entrada | Para qué sirve |
|---|---|
| OPERAR | Acceder al inventario, punto de parada, monitor, lectura y prueba externa. |
| ENTENDER | Seleccionar componentes, ver relaciones, estado de evidencia, referencias y extractos con líneas. |
| INVESTIGAR | Partir de síntomas y abrir pruebas discriminantes, incertidumbres o historia. |
| APRENDER | Recorrer seis explicaciones que conectan conceptos con código y comprobaciones. |

Buscar términos como `Bus error`, `clk_thresh`, `readDataGroup0Value`, `mgt_word_i` o `ULDATASOURCE`. Los resultados abren la sección o el extracto real. Los documentos se resumen con secciones desplegables; «Expandir todo» facilita una lectura continua. Los enlaces internos funcionan mediante fragmentos de URL.

Los extractos de fuentes funcionan offline. Los enlaces a GitHub requieren conexión. Los diagramas Mermaid permanecen en los Markdown para su representación en GitHub; la vista local remite al mapa de relaciones. No se incluyen datos de hardware en vivo, controles de operación remota ni estados simulados.

## Decisión tecnológica

Una página HTML autocontenida, con JavaScript y CSS nativos, es suficiente para leer, buscar y seguir relaciones. No requiere backend, cuenta, base de datos ni bibliotecas en ejecución. Los Markdown conservan la fuente editorial; `evidencias.json` conserva los extractos y su procedencia. No se reorganizaron los directorios históricos.

## Mantener el contenido

Editar los documentos, revisar fuentes y regenerar `index.html`. No editar la vista generada como fuente de verdad. El generador usa Node y `marked`; en esta entrega se utilizó la instalación disponible de `marked` 17.0.5. La dependencia solo es necesaria para regenerar, no para consultar la base.

```bash
node generar_base.mjs /RUTA/ABSOLUTA/marked/lib/marked.esm.js
```

La ruta es un parámetro de mantenimiento, no una ruta presente por defecto en la Trenz. También puede omitirse si `marked` está instalado y resoluble como módulo en el entorno del generador. Los extractos deben actualizarse desde el archivo original conservando líneas, hash y versión. Cambiar el SHA de una referencia sin revisar su contenido invalida la trazabilidad.

La comprobación de contenido, sintaxis, rutas y funciones en Node no requiere dependencias externas:

```bash
node verificar_base.mjs --static
```

La prueba completa de navegador usa el mismo script y una instalación local de Playwright con Chromium:

```bash
node verificar_base.mjs /RUTA/ABSOLUTA/playwright/index.mjs
```

Ningún comando de mantenimiento necesita ejecutarse en la Trenz. Solo genera o revisa documentación en el PC de trabajo.

La comprobación Node pasó en esta entrega. La de navegador quedó pendiente por falta del ejecutable Chromium; ver el alcance exacto en [la auditoría](07_AUDITORIA.md).
