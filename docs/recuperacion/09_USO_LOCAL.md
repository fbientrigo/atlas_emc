# Usar la web sin conexión

La web se publica con `.github/workflows/guia-pages.yml` desde `main` y está en [GitHub Pages](https://fbientrigo.github.io/atlas_emc/). Si dudas de si un cambio ya salió, mira el resultado en Actions.

Para usarla sin red, copia la carpeta `_site` entera: `index.html`, `assets/mermaid.js`, `diagnostico/` y `emp-capture.tar.gz`. Abre `index.html` en el navegador. Todo funciona sin servicios externos, salvo los enlaces a GitHub. Si copias solo el HTML, verás textos y herramientas pero no los diagramas, porque necesitan `assets/mermaid.js`.

## Las cuatro secciones

| Sección | Para qué |
|---|---|
| OPERAR | Leer, guardar el CSV, mapa UIO y herramientas. |
| ENTENDER | Guía resumida con diagramas. El mapa de once componentes se abre desde la búsqueda o desde las relaciones. |
| INVESTIGAR | Diagnóstico del bloqueo, procedimientos F0/F1 y comparación de capturas. |
| APRENDER | Seis temas, las pruebas anteriores y los contraejemplos. |

La búsqueda acepta tareas, funciones, registros y señales. La tecla `/` lleva al buscador. Cada resultado abre una sección o un extracto con líneas numeradas. En los documentos puedes abrir y cerrar secciones, descargar el Markdown e imprimir. Copiar un bloque de código no lo ejecuta.

## Comparar capturas

Pega una salida de `emp read` o `tgc_readuplink_cli` en cada lado. Se reconocen `magic`, `data_group_0` a `data_group_8`, `data_header` y `clk_thresh`, seguidos de espacio o dos puntos y un hexadecimal `0x` de hasta ocho dígitos. Las líneas de log se ignoran. Se rechazan etiquetas repetidas, grupos fuera de rango y valores inválidos. Si falta un registro aparece como ausente; nunca se rellena con cero.

El resultado muestra A, B, el XOR y qué bits cambiaron. Avisa si cambió magic o threshold y si la comparación es parcial. Solo compara valores: no dice si las muestras son nuevas, coherentes, íntegras o del FE. Los archivos se leen en el navegador, hasta 200 kB, y no se suben ni se guardan.

## Diagnóstico y notas de sesión

El diagnóstico sugiere la próxima prueba a partir de lo que marques. Si no lo miraste, deja "No lo miré"; así no inventas datos. No da probabilidades ni confirma causas.

Las notas viven en memoria. Solo "Guardar en este navegador" usa el almacenamiento local, y con `file://` depende del navegador. Exportar deja una copia aparte. Marcar casillas no valida el hardware ni autoriza comandos. Las capturas del comparador no entran en las notas.

Al exportar se abre una ventana con el texto, un enlace de descarga y un botón de copiar. Si el navegador bloquea la descarga, copia el texto a mano. En HTTP o `file://` la copia automática puede fallar; entonces el botón selecciona el texto. En las pruebas no se pudo comprobar la descarga automática, pero sí que el informe se genera y se ve.

## Mantenimiento

La fuente son los Markdown y `evidencias.json`. La vista está en `web/`. El generador junta documentos y extractos en el HTML, y `empaquetar_pages.mjs` añade Mermaid, el script de diagnóstico y el paquete de captura a `_site`. El respaldo y el resto del repositorio no se publican.

Necesitas Node 22, `tar` y las dependencias fijadas en `package-lock.json`. Desde `docs/recuperacion`:

```bash
npm ci --ignore-scripts --no-audit --no-fund
npm run build
npm test
python3 -m unittest discover -s diagnostico -p 'test_*.py'
```

Abre `_site/index.html` o sirve esa carpeta con cualquier servidor local. `npm test` revisa enlaces, la lógica de comparación y la sintaxis de los diagramas. Actions corre esas pruebas antes de publicar con `actions/deploy-pages`. La primera vez, Pages tiene que estar configurado como GitHub Actions y el entorno `github-pages` tiene que permitir desplegar desde `main`.

La guía resumida y los documentos largos salen de los mismos Markdown, así que edita los `.md`, no el HTML generado. `mermaid.js` se construye en el workflow y no está en Git. Si cambias dependencias, actualiza el lockfile y vuelve a correr las pruebas.
