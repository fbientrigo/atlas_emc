# Utilizar la web sin conexión

La publicación se realiza mediante `.github/workflows/guia-pages.yml` desde `main`. Dirección prevista: https://fbientrigo.github.io/atlas_emc/. El resultado de Actions es la autoridad sobre el estado del despliegue.

Para uso offline, conservar la carpeta generada `_site` completa: `index.html`, `assets/mermaid.js` y `diagnostico/`. Abrir su `index.html` en el navegador. La consulta no requiere servicios externos; los enlaces a GitHub sí requieren conexión. El HTML aislado conserva textos y herramientas, pero necesita el recurso local para dibujar Mermaid. No se usa una CDN en tiempo de ejecución.

## Cuatro entradas y funciones reales

| Entrada | Uso |
|---|---|
| OPERAR | Seis etapas de campo, catálogo filtrable y registro de sesión. |
| ENTENDER | Guía resumida con diagramas; mapa de once componentes accesible desde sus relaciones y búsqueda. |
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

Los Markdown y `evidencias.json` son la fuente editorial; `web/` contiene la vista. El generador integra 14 documentos y 28 extractos en HTML. `empaquetar_pages.mjs` empaqueta Mermaid y copia únicamente el cuaderno y el script diagnóstico a `_site`. El respaldo y el resto del repositorio quedan fuera del artefacto.

Node 22 y dependencias fijadas con `package-lock.json`. Desde `docs/recuperacion`:

```bash
npm ci --ignore-scripts --no-audit --no-fund
npm run build
npm test
python3 -m unittest discover -s diagnostico -p 'test_*.py'
```

Abrir `_site/index.html` o servir esa carpeta con el servidor local habitual. `npm test` valida enlaces, lógica de comparación y sintaxis de los diez diagramas. Actions ejecuta esas pruebas antes de publicar mediante `actions/deploy-pages`. La primera publicación requiere Pages configurado como **GitHub Actions** y que el entorno `github-pages` permita desplegar desde `main`.

La guía resumida y la documentación extensa comparten fuentes; no editar el HTML generado como fuente primaria. El recurso Mermaid se construye durante el workflow y no se guarda en Git. Cambiar las dependencias requiere actualizar el lockfile y repetir las comprobaciones.
