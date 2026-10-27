// Compila documentos y código de la vista en un único HTML offline.
// Uso: node generar_base.mjs [ruta absoluta a marked/lib/marked.esm.js]
import {readFile, writeFile, readdir} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
const {marked}=await import(process.argv[2]||'marked');
const root=path.dirname(fileURLToPath(import.meta.url));
const slug=s=>s.toLowerCase().replace(/<[^>]*>/g,'').replace(/[^\p{L}\p{N}\s_-]/gu,'').replace(/\s/g,'-');
const renderer=new marked.Renderer();
renderer.heading=function({tokens,depth}){const html=this.parser.parseInline(tokens);return `<h${depth} id="${slug(html)}">${html}</h${depth}>\n`};
renderer.code=function({text,lang}){if(lang==='mermaid')return '<pre class="mermaid">'+text.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;')+'</pre>';return '<pre><code>'+text.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;')+'</code></pre>\n'};
marked.use({renderer});
const docs=[];
for(const file of (await readdir(root)).filter(n=>/^\d\d_.*\.md$/.test(n)).sort()){
 const md=await readFile(path.join(root,file),'utf8'),pieces=md.split(/(?=^## )/m);
 docs.push({id:file.slice(0,-3),file,title:md.match(/^# (.+)/m)?.[1]||file,sections:pieces.map((text,i)=>{const title=text.match(/^## (.+)/m)?.[1]||'Antes de comenzar';return {title,anchor:i?slug(title):'',text,html:marked.parse(text)}})});
}
const sources=JSON.parse(await readFile(path.join(root,'evidencias.json'),'utf8'));
const entities=JSON.parse(await readFile(path.join(root,'web/entidades.json'),'utf8'));
const data=JSON.stringify({docs,sources,entities,edition:'2026-10-26 / guía resumida y Pages'}).replaceAll('<','\\u003c');
const css=await readFile(path.join(root,'web/estilos.css'),'utf8');
const js=(await readFile(path.join(root,'web/logica.js'),'utf8'))+'\n'+(await readFile(path.join(root,'web/aplicacion.js'),'utf8'));
if(/<\/script/i.test(js))throw Error('Un cierre script literal requiere escape antes de empaquetar');
const themeBootstrap = `<script id="theme-init">(function(){let saved;try{saved=localStorage.getItem('atlas-guide-theme')}catch{}const systemDark=window.matchMedia?.('(prefers-color-scheme: dark)').matches;document.documentElement.dataset.theme=(saved==='light'||saved==='dark')?saved:(systemDark?'dark':'light')})();<\/script>`;
const html=`<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="description" content="Cuaderno de campo ATLAS TGC Charge Monitoring: operación, arquitectura, diagnóstico y evidencia para EMP / lpGBT."><meta name="color-scheme" content="light dark">${themeBootstrap}<title>ATLAS · Recuperación EMP / lpGBT</title><style>${css}</style></head><body>
<a class="sr-only" href="#content">Saltar al contenido</a>
<header class="topbar"><div class="shell topbar-inner"><a class="brand" href="#modo/operar"><span class="brand-mark" aria-hidden="true">▥</span><div>ATLAS // TGC<span>EMP · lpGBT / GUÍA OPERATIVA</span></div></a><span class="top-note">CUADERNO DE CAMPO / 26 OCT 2026</span><div class="header-actions"><button type="button" id="theme-toggle" class="button theme-toggle" aria-label="Cambiar a modo oscuro" aria-pressed="false"><span aria-hidden="true" data-theme-icon>☾</span><span data-theme-text>OSCURO</span></button><a class="button" href="#sesion">Registro de sesión ↗</a></div></div></header>
<div class="navigation"><div class="shell nav-inner"><nav class="modes" aria-label="Formas de explorar"><button data-mode="operar">OPERAR</button><button data-mode="entender">ENTENDER</button><button data-mode="investigar">INVESTIGAR</button><button data-mode="aprender">APRENDER</button></nav><div class="search-area"><label class="search-field" for="q"><span aria-hidden="true">⌕</span><span class="sr-only">Buscar tarea, señal, registro, función o síntoma</span><input id="q" type="search" placeholder="Buscar señal, registro, síntoma…" autocomplete="off"><kbd aria-hidden="true">/</kbd></label><div id="results" class="search-results" aria-live="polite"></div></div></div></div>
<div class="shell state-strip"><span class="dot" aria-hidden="true"></span><span>Hardware actual: <strong>por verificar</strong> · Fuentes estáticas e históricas · Sin conexión al equipo.</span></div>
<main class="shell" id="content" tabindex="-1"></main><div class="toast" id="toast" role="status"></div>
<footer><div class="shell"><span>Conocimiento local. Ninguna acción de esta web opera el hardware.</span><div><a href="#biblioteca">Documentos y fuentes</a><a href="#doc/07_AUDITORIA">Auditoría</a><a href="#doc/09_USO_LOCAL">Uso local</a></div></div></footer>
<script id="data" type="application/json">${data}</script><script src="assets/mermaid.js"></script><script>${js}</script></body></html>`;
await writeFile(path.join(root,'index.html'),html);
console.log(JSON.stringify({documentos:docs.length,fuentes:sources.length,componentes:Object.keys(entities).length,bytes:Buffer.byteLength(html)}));
