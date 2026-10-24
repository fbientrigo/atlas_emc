# Utilizar la web sin conexión

Descargar `index.html` y abrirlo en un navegador. El archivo incluye documentos, estilos, lógica y 28 extractos de fuentes. No necesita servidor, instalación, cuenta o conexión para consultar el contenido. Los enlaces al repositorio sí requieren red. GitHub muestra el código del HTML; esta entrega no habilita hosting público.

## Cuatro entradas y funciones reales

| Entrada | Uso |
|---|---|
| OPERAR | Seis etapas de campo, catálogo filtrable y registro de sesión. |
| ENTENDER | Mapa seleccionable de once componentes; relaciones verificadas y correspondencias pendientes diferenciadas. |
| INVESTIGAR | Diagnóstico condicional del bloqueo, pruebas F0/F1 y comparación de capturas. |
| APRENDER | Seis recorridos conceptuales, historia experimental y contraejemplos. |

La búsqueda acepta palabras de tareas, funciones, registros y señales. `/` enfoca el campo. Los resultados abren secciones o extractos numerados. Los documentos permiten expandir, resumir, preparar una descarga Markdown e imprimir. Copiar un bloque no lo ejecuta.

## Comparar capturas

Pegar una sola salida de `tgc_readuplink_cli` por lado. Se reconocen `magic`, `data_group_0` a `data_group_8`, `data_header` y `clk_thresh`, seguidos de `: 0x` y hasta ocho dígitos hexadecimales. No se interpretan logs como valores. Se rechazan etiquetas duplicadas, grupos fuera de rango y valores inválidos. La ausencia de un registro se muestra como ausencia, nunca se reemplaza por cero.

El resultado muestra A, B, XOR y posiciones de bits diferentes. Detecta cambios en magic/threshold y advierte de comparación parcial. **No certifica novedad, coherencia, integridad ni origen FE.** Los archivos se leen en el navegador, con límite de 200 kB. No se suben ni se guardan automáticamente.

## Diagnóstico y registro de sesión

El diagnóstico recomienda la próxima prueba según observaciones declaradas. “No observado” evita inventar evidencia. No ofrece probabilidades ni confirma una causa.

El registro vive en memoria. Solo “Guardar en este navegador” usa almacenamiento local. Su disponibilidad con `file://` depende del navegador; exportar conserva una copia independiente. Los checks no validan hardware ni autorizan comandos. Las capturas del comparador no se incluyen automáticamente en el registro.

Cada exportación abre una vista revisable, con texto seleccionable, enlace de descarga y copia. Si la descarga está limitada, seleccionar y copiar manualmente el texto a un archivo. La copia automática puede no estar disponible en contextos HTTP o file locales; el botón selecciona el texto como alternativa. La descarga automática del navegador remoto de pruebas no pudo verificarse; la generación visible del informe sí.

## Mantenimiento

Los Markdown y `evidencias.json` contienen la fuente editorial. `web/entidades.json` define las relaciones; `web/logica.js` contiene análisis puro; `web/aplicacion.js` y `web/estilos.css` implementan la vista. El generador produce un único HTML. No editar ese HTML como fuente primaria.

Dependencia de construcción: Node y `marked` (17.0.5 en esta entrega). Ninguna dependencia de ejecución externa.

```bash
node generar_base.mjs /RUTA/ABSOLUTA/marked/lib/marked.esm.js
node verificar_base.mjs --static
python3 analisis/contraejemplos.py
```

La ruta de marked es un parámetro del PC de mantenimiento, no de la Trenz. Los checks validan enlaces, sintaxis, metadatos, parser, XOR y decisiones condicionales. Los modelos Python son contraejemplos reducidos, no simulación RTL. Ver [alcance de auditoría](07_AUDITORIA.md).
