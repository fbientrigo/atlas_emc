// Genera una lectura local desde los documentos; no tiene acceso al hardware.
// Uso: node generar_base.mjs [ruta absoluta a marked/lib/marked.esm.js]
import {readFile, writeFile, readdir} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
const {marked} = await import(process.argv[2] || 'marked');
const root = path.dirname(fileURLToPath(import.meta.url));
const slug = s => s.toLowerCase().replace(/<[^>]*>/g, '').replace(/[^\p{L}\p{N}\s_-]/gu, '').replace(/\s/g, '-');
const renderer = new marked.Renderer();
renderer.heading = function ({tokens, depth}) {
  const html = this.parser.parseInline(tokens);
  return `<h${depth} id="${slug(html)}">${html}</h${depth}>\n`;
};
renderer.code = function ({text, lang}) {
  if (lang === 'mermaid') return '<p><a href="#modo/entender">Explorar estas conexiones en el mapa de relaciones.</a> El diagrama Mermaid original se conserva en el documento Markdown.</p>';
  const escaped = text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  return `<pre><code>${escaped}</code></pre>\n`;
};
marked.use({renderer});
const docs = [];
for (const file of (await readdir(root)).filter(n => /^\d\d_.*\.md$/.test(n)).sort()) {
  const md = await readFile(path.join(root, file), 'utf8');
  const pieces = md.split(/(?=^## )/m);
  const title = md.match(/^# (.+)/m)?.[1] || file;
  docs.push({id: file.slice(0, -3), file, title, sections: pieces.map((text, i) => {
    const heading = text.match(/^## (.+)/m)?.[1] || 'Antes de comenzar';
    return {title: heading, anchor: i ? slug(heading) : '', text, html: marked.parse(text)};
  })});
}
const sources = JSON.parse(await readFile(path.join(root, 'evidencias.json'), 'utf8'));
if (!docs.some(d => d.id === '00_GUIA_CAMPO') || sources.length < 1) throw Error('Falta la guía o las evidencias');
const data = JSON.stringify({docs, sources}).replaceAll('<', '\\u003c');
const html = String.raw`<!doctype html>
<html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>EMP / lpGBT · Cuaderno de recuperación</title>
<style>
:root{font-family:system-ui,sans-serif;color:#172b35;background:#f7f8f8;line-height:1.6;--accent:#14546d;--line:#d8e0e3}*{box-sizing:border-box}body{margin:0}header,main,footer{max-width:1120px;margin:auto;padding:20px 24px}header{border-bottom:1px solid var(--line)}h1{font-size:1.75rem;line-height:1.25}h2{font-size:1.35rem}h3{font-size:1.12rem}a{color:var(--accent)}button,input{font:inherit}button{cursor:pointer;color:var(--accent);background:white;border:1px solid var(--line);border-radius:7px;padding:9px 14px;text-align:left}button:hover,button[aria-pressed=true]{background:#e2eef2;border-color:var(--accent)}button:focus-visible,a:focus-visible,input:focus-visible,summary:focus-visible{outline:3px solid #d18b16;outline-offset:3px}nav,.actions{display:flex;gap:8px;flex-wrap:wrap;margin:16px 0}.sub,.meta{color:#526670;font-size:.9rem}.notice{border-left:4px solid #c58c20;padding:10px 16px;background:#fff7e4}.search{width:100%;padding:11px;border:1px solid #a8b9c0;border-radius:7px}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(255px,1fr));gap:14px}.card,.entity,details,.source{background:white;border:1px solid var(--line);padding:16px;border-radius:8px;margin:12px 0}.card h3{margin:0 0 8px}.card p{margin:0 0 12px}summary{cursor:pointer;font-weight:650}details[open]>summary{margin-bottom:16px}pre{background:#eef2f3;padding:14px;overflow:auto;line-height:1.45;font-size:.85rem;white-space:pre}code{font-family:ui-monospace,monospace;font-size:.9em;overflow-wrap:anywhere}table{display:block;overflow-x:auto;width:100%;border-collapse:collapse;font-size:.92rem;margin:20px 0}td,th{border:1px solid var(--line);padding:9px;vertical-align:top;text-align:left}th{background:#eef2f3}.result{display:block;width:100%;margin:8px 0}.result small{display:block;color:#526670}.route{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:8px;padding:0;list-style:none}.route button{height:100%;width:100%}.badge{display:inline-block;background:#e8edef;border-radius:4px;padding:1px 7px;font-size:.8rem}.unknown{background:#fff1cd}.empty{padding:24px;background:white}footer{font-size:.85rem;color:#526670;border-top:1px solid var(--line)}@media print{header nav,.searchbox,.actions,button,footer{display:none}details{border:0}main{max-width:none}pre{white-space:pre-wrap}table{display:table}}
</style>
<header><p class="meta">ATLAS TGC Charge Monitoring · Investigación del 24-10-2026</p><h1>Operar con evidencia. Recuperar el sistema.</h1>
<p class="notice">Estado actual del hardware: <strong>DESCONOCIDO</strong>. Esta base documenta fuentes y procedimientos; no se conecta a la Trenz. Las lecturas MMIO requieren verificar sus condiciones previas.</p>
<nav aria-label="Formas de explorar"><button data-mode="operar">OPERAR</button><button data-mode="entender">ENTENDER</button><button data-mode="investigar">INVESTIGAR</button><button data-mode="aprender">APRENDER</button></nav>
<div class="searchbox"><label for="q">Buscar una tarea, señal, registro, función o síntoma</label><input class="search" id="q" type="search" placeholder="Ej.: Bus error, clk_thresh, readDataGroup0Value" autocomplete="off"><div id="results" aria-live="polite"></div></div></header>
<main id="content" tabindex="-1"></main><footer>Contenido local, sin servicios externos. Los enlaces a GitHub abren las fuentes cuando hay conexión. <a href="#doc/07_AUDITORIA">Alcance y auditoría</a> · <a href="#doc/08_FUENTES">Procedencia de fuentes</a>. Los Markdown son la fuente editorial; index.html es una vista generada.</footer>
<script id="data" type="application/json">${data}</script>
<script>
'use strict';
const DB=JSON.parse(document.getElementById('data').textContent), content=document.getElementById('content'), query=document.getElementById('q'), results=document.getElementById('results');
const E=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const norm=s=>s.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
const go=(doc,anchor='')=>'#doc/'+encodeURIComponent(doc)+(anchor?'/'+encodeURIComponent(anchor):'');
const link=(title,doc,anchor='')=>'<a href="'+go(doc,anchor)+'">'+E(title)+'</a>';
const entities={
 fe:{name:'Front-end y e-link',status:'DESCONOCIDO actual',text:'Origen externo que debemos distinguir de los patrones internos. Faltan firmware FE, pinout homologado, estímulo reproducible y configuración vigente.',related:['chip','captura'],docs:['00_GUIA_CAMPO','04_INCERTIDUMBRES'],sources:[]},
 chip:{name:'lpGBT y Serializer',status:'PARCIAL / notas',text:'Concentra e-links y transmite por uplink. Las notas usan tanto loopback como modo normal. Normal no excluye un cable físico de retorno. No hay receta validada para la selección actual.',related:['fe','mgt','ic'],docs:['00_GUIA_CAMPO','01_MAPA_TECNICO'],sources:['B06','B07']},
 mgt:{name:'MGT y cabecera',status:'VERIFICADO / estática',text:'El BD conecta CH10_MGT_USRWORD_o con MGT_USRWORD_i del wrapper. El core busca el patrón de cabecera 01 y devuelve bitslip. No implica alineación de palabras FE.',related:['chip','core','monitor'],docs:['01_MAPA_TECNICO','03_HISTORIA'],sources:['R01','R02']},
 core:{name:'Core uplink',status:'VERIFICADO / estática',text:'Gearbox, deinterleaver, FEC y descrambler. FEC5/10G24 ofrece UserData[229:0], EC y IC. El gearbox usa enable dentro del reloj RX; no es el CDC posterior.',related:['mgt','cdc','ic'],docs:['01_MAPA_TECNICO','06_APRENDER'],sources:['R02']},
 cdc:{name:'CDC y UserData',status:'VERIFICADO / estática',text:'cdc_rx lleva 234 bits del dominio RX a logicclk40. El wrapper separa 230 bits de usuario. Su ready no es un contador de frames ni la condición RX locked.',related:['core','captura'],docs:['01_MAPA_TECNICO','06_APRENDER'],sources:['R01','R06']},
 captura:{name:'Capturador de payload',status:'DESCONOCIDO / RTL ausente',text:'El software declara nueve grupos, header y clk_thresh. Falta el RTL de la build de lectura: trigger, packing, coherencia y actualización con FE autónomo. El BD consultado no instancia este módulo.',related:['cdc','axi','cpp'],docs:['00_GUIA_CAMPO','04_INCERTIDUMBRES'],sources:['B01','B02']},
 axi:{name:'AXI y mapa de direcciones',status:'CONTRADICTORIO entre versiones',text:'En el BD, A00D/A00E son interrupt controllers. En scripts históricos son generador/lector. No trasladar direcciones entre builds. Device Tree describe un contrato, no prueba respuesta eléctrica.',related:['captura','uio','ic'],docs:['01_MAPA_TECNICO','03_HISTORIA'],sources:['B07']},
 uio:{name:'Device Tree / UIO',status:'VERIFICADO / software',text:'libuio busca nombres en sysfs, abre el nodo y mapea sus regiones. Un UIO visible no prueba que el slave responda. El número uioN no es el canal óptico.',related:['axi','cpp','monitor'],docs:['00_GUIA_CAMPO','02_CATALOGO'],sources:['B03','B04']},
 cpp:{name:'TgcReadUplink / CLI',status:'VERIFICADO / software',text:'Nombre fijo tgc_readUplink_regs, sin parser ni espera por evento. Lee cada registro por separado. --help tampoco evita MMIO en la copia recuperada. No concatena un frame coherente.',related:['uio','captura'],docs:['02_CATALOGO','01_MAPA_TECNICO'],sources:['B01','B02','B03']},
 ic:{name:'Control IC / LpGbtSw',status:'VERIFICADO / software y RTL',text:'Consulta registros del chip remoto. Incluso -r modifica dirección, control e IRQ del controlador y consume su FIFO. No es extracción de payload FE.',related:['chip','core','axi'],docs:['01_MAPA_TECNICO','02_CATALOGO'],sources:['B06','B07']},
 monitor:{name:'fwMonitor / debughub',status:'VERIFICADO / estática',text:'RX locked viene de cabecera FPGA; TX ready del downlink; XCVR Ready es AND de TX/RX del MGT. Estados no certifican fuente FE ni integridad del dato.',related:['mgt','uio'],docs:['00_GUIA_CAMPO','02_CATALOGO'],sources:['B05','R03']}
};
function card(title,text,doc,anchor=''){return '<section class="card"><h3>'+E(title)+'</h3><p>'+E(text)+'</p>'+link('Abrir procedimiento',doc,anchor)+'</section>'}
function setMode(mode){document.querySelectorAll('[data-mode]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.mode===mode)))}
function home(mode){setMode(mode);if(mode==='entender'){showEntity('captura');return}
 if(mode==='operar')content.innerHTML='<h2>Leer datos reales desde el front-end</h2><p>Comenzar por el inventario. Cada etapa incluye condiciones, efectos, alternativas, riesgos y siguiente decisión.</p><div class="cards">'+[
 ['A1 · Inventariar la Trenz','Puede hacerse ahora: Linux, UIO, firmware disponible y metadatos.','etapa-a1--inventario-de-linux-device-tree-y-firmware'],
 ['A2 · Identificar ejecutables','Puede hacerse ahora: rutas, variantes, arquitectura y dependencias.','etapa-a2--localizar-y-distinguir-ejecutables'],
 ['Antes de MMIO','Resolver identidad de build y semántica antes de leer registros.','punto-de-parada-obligatorio-antes-de-b-y-c'],
 ['B · Estado del enlace','Lectura condicionada de fwMonitor; interpretar cada columna.','etapa-b--diagnosticar-el-enlace'],
 ['C · Palabras de payload','Usar el lector existente; no asumir novedad ni snapshot.','etapa-c--consultar-los-datos-expuestos-por-la-fpga'],
 ['D · Atribuir datos al FE','Prueba externa A/B/A, pendiente del estímulo y configuración reales.','etapa-d--prueba-externa-aba']].map(x=>card(x[0],x[1],'00_GUIA_CAMPO',x[2])).join('')+'</div>';
 else if(mode==='investigar')content.innerHTML='<h2>Entrar desde un síntoma</h2><p>Conservar el primer fallo y buscar una prueba discriminante. No recargar firmware ni barrer direcciones para ocultar el estado inicial.</p><div class="cards">'+['No aparece UIO','Bus error','Registros siempre cero','Datos que no cambian','Solo hay datos con loopback','Sin RX locked','Datos desfasados','Canal inesperado'].map(x=>card(x,'Ver causas alternativas y pruebas para descartarlas.','00_GUIA_CAMPO','etapa-e--diagnóstico-remoto')).join('')+'</div><div class="actions">'+link('Historia de fallos y ensayos','03_HISTORIA')+' · '+link('Pruebas que faltan','04_INCERTIDUMBRES')+'</div>';
 else if(mode==='aprender')content.innerHTML='<h2>Recuperar criterio técnico paso a paso</h2><p>Del espacio de direcciones al protocolo y la captura, con comprobaciones que se pueden buscar en código.</p><div class="cards">'+[
 ['1 · Tres direcciones','Base física, offset AXI y registro del chip.','1-separar-tres-espacios-de-direcciones'],
 ['2 · Del bit al significado','Protocolo lpGBT, campos y payload FE.','2-seguir-bits-antes-de-asignarles-significado'],
 ['3 · Relojes y enable','Gearbox y CDC no son la misma operación.','3-distinguir-gearbox-enable-y-cruce-de-reloj'],
 ['4 · El acceso hardware','main, mmap, puntero volatile y bus AXI.','4-entender-dónde-linux-hace-la-transacción'],
 ['5 · Qué prueba una captura','Origen, novedad, coherencia e integridad.','5-aprender-a-no-sobreinterpretar-una-captura'],
 ['6 · Leer la historia','Separar resultados, hipótesis y planes.','6-leer-la-historia-como-evidencia-experimental']].map(x=>card(x[0],x[1],'06_APRENDER',x[2])).join('')+'</div>';
 else{content.innerHTML='<p class="empty">Modo desconocido. Seleccionar una de las cuatro entradas.</p>'}
 content.innerHTML+='<p class="sub">También: '+link('catálogo de herramientas','02_CATALOGO')+' · '+link('evolución futura','05_EVOLUCION_FUTURA')+'</p>';
}
function showEntity(id){setMode('entender');const e=entities[id];if(!e){content.innerHTML='<p>Nodo desconocido.</p>';return}
 content.innerHTML='<h2>Arquitectura y relaciones trazables</h2><p>Seleccionar un componente. Las conexiones en fuentes no certifican el hardware actual. La unión del bus UserData al capturador sigue sin demostrarse.</p><ol class="route">'+Object.entries(entities).map(([key,v])=>'<li><button data-entity="'+key+'" aria-pressed="'+(key===id)+'">'+E(v.name)+'</button></li>').join('')+'</ol><section class="entity"><span class="badge '+(/DESCONOCIDO|CONTRADICTORIO/.test(e.status)?'unknown':'')+'">'+E(e.status)+'</span><h3>'+E(e.name)+'</h3><p>'+E(e.text)+'</p><p>Relacionado con: '+e.related.map(k=>'<a href="#nodo/'+k+'">'+E(entities[k].name)+'</a>').join(' · ')+'</p><p>Profundizar: '+e.docs.map(k=>link(DB.docs.find(d=>d.id===k).title,k)).join(' · ')+'</p><div class="actions">'+e.sources.map(k=>'<a href="#fuente/'+k+'">Ver extracto '+k+'</a>').join(' · ')+'</div></section>';
}
function showDoc(id,anchor=''){const d=DB.docs.find(d=>d.id===id);if(!d){content.innerHTML='<p>Documento desconocido.</p>';return}
 const mode=id==='06_APRENDER'?'aprender':id==='01_MAPA_TECNICO'?'entender':id==='03_HISTORIA'||id==='04_INCERTIDUMBRES'?'investigar':'operar';setMode(mode);
 const selected=d.sections.findIndex(s=>s.anchor===anchor||s.html.includes('id="'+anchor+'"'));
 content.innerHTML='<div class="actions"><button id="expand">Expandir todo</button><button id="collapse">Resumir</button><a href="'+d.file+'">Markdown original</a></div><article aria-label="'+E(d.title)+'">'+d.sections.map((s,i)=>i===0?s.html:'<details '+(anchor&&i===selected?'open':'')+' data-section="'+E(s.anchor)+'"><summary>'+E(s.title)+'</summary>'+s.html+'</details>').join('')+'</article>';
 document.getElementById('expand').onclick=()=>content.querySelectorAll('details').forEach(x=>x.open=true);document.getElementById('collapse').onclick=()=>content.querySelectorAll('details').forEach(x=>x.open=false);
 if(anchor){const target=content.querySelector('[id="'+CSS.escape(anchor)+'"]')||content.querySelector('[data-section="'+CSS.escape(anchor)+'"]');if(target)target.scrollIntoView({block:'start'});else content.insertAdjacentHTML('afterbegin','<p class="notice">Sección no encontrada. Usar búsqueda o expandir el documento.</p>')}
}
function showSource(id){const s=DB.sources.find(x=>x.id===id);if(!s){content.innerHTML='<p>Fuente desconocida.</p>';return}setMode('entender');content.innerHTML='<h2>'+E(s.title)+'</h2><p><span class="badge">VERIFICADO / inspección estática</span></p><p><code>'+E(s.path)+'</code></p><p class="meta">'+(s.origin==='backup'?'Respaldo curado; extracto documental. No es una fuente desplegable.':'Repositorio, baseline c02a33b. No acredita la build activa.')+'</p><p class="meta">SHA-256 del archivo completo: <code>'+E(s.sha256)+'</code></p>'+s.excerpts.map(x=>'<section class="source"><h3>Líneas '+x.start+'–'+x.end+'</h3><pre><code>'+E(x.text)+'</code></pre></section>').join('')+(s.url?'<p><a target="_blank" rel="noreferrer" href="'+s.url+'">Abrir archivo completo en GitHub</a></p>':'<p>El archivo completo está en fuentes_backup del ZIP original, con el mismo path y hash en MANIFEST.json.</p>');}
function search(){results.replaceChildren();const q=norm(query.value.trim());if(!q)return;const hits=[];
 for(const d of DB.docs)for(const s of d.sections)if(norm(s.title+' '+s.text).includes(q))hits.push({label:s.title+' · '+d.title,text:s.text.slice(0,180),href:go(d.id,s.anchor)});
 for(const s of DB.sources)if(norm(s.path+' '+s.title+' '+s.excerpts.map(e=>e.text).join(' ')).includes(q))hits.push({label:s.id+' · '+s.title,text:s.path,href:'#fuente/'+s.id});
 const count=document.createElement('p');count.className='sub';count.textContent=hits.length?hits.length+' resultados; se muestran hasta 16.':'Sin coincidencias. Probar con otro término.';results.append(count);
 for(const hit of hits.slice(0,16)){const a=document.createElement('a');a.className='result';a.href=hit.href;a.textContent=hit.label;const small=document.createElement('small');small.textContent=hit.text;small.style.display='block';a.append(small);results.append(a)}
}
function route(){let parts;try{parts=location.hash.slice(1).split('/').map(decodeURIComponent)}catch{content.textContent='Enlace inválido.';return}if(parts[0]==='doc')showDoc(parts[1],parts[2]);else if(parts[0]==='fuente')showSource(parts[1]);else if(parts[0]==='nodo')showEntity(parts[1]);else home(parts[1]||'operar');}
document.addEventListener('click',event=>{const mode=event.target.closest('[data-mode]');if(mode){location.hash='modo/'+mode.dataset.mode;query.value='';search();return}const node=event.target.closest('[data-entity]');if(node){location.hash='nodo/'+node.dataset.entity;return}
 const a=event.target.closest('a');if(!a)return;const href=a.getAttribute('href');const match=href?.match(/^(?:\.\/)?(\d\d_[^#]+)\.md(?:#(.+))?$/);if(match&&DB.docs.some(d=>d.id===match[1])){event.preventDefault();location.hash=go(match[1],decodeURIComponent(match[2]||''))}
});
query.addEventListener('input',search);window.addEventListener('hashchange',route);route();
</script></html>`;
await writeFile(path.join(root, 'index.html'), html);
console.log(`Base generada: ${docs.length} documentos, ${sources.length} fuentes con extractos.`);
