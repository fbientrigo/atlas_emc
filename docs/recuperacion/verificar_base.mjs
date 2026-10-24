// Comprueba datos, enlaces y lógica. La revisión de navegador se registra aparte.
// Uso: node verificar_base.mjs [--static]
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import vm from 'node:vm';
const root=path.dirname(fileURLToPath(import.meta.url));
const html=await readFile(path.join(root,'index.html'),'utf8');
const data=JSON.parse(html.match(/<script id="data" type="application\/json">([\s\S]*?)<\/script>/)[1]);
const script=html.match(/<script>([\s\S]*?)<\/script>/)[1];
new vm.Script(script);
const docs=new Map(data.docs.map(d=>[d.id,d]));let links=0;
for(const d of data.docs)for(const s of d.sections)for(const m of s.html.matchAll(/href="(?:\.\/)?(\d\d_[^#"]+)\.md(?:#([^"\s]+))?"/g)){
 const target=docs.get(m[1]);assert(target,'Documento inexistente: '+m[1]);
 if(m[2]){const anchor=decodeURIComponent(m[2]);assert(target.sections.some(s=>s.anchor===anchor||s.html.includes('id="'+anchor+'"')),'Ancla inexistente: '+m[0])}links++;
}
const app=await readFile(path.join(root,'web/aplicacion.js'),'utf8');
for(const m of app.matchAll(/(?:go|link)\('[^']*'\s*,\s*'(\d\d_[^']+)'\s*,\s*'([^']+)'\)/g)){
 assert(docs.get(m[1])?.sections.some(s=>s.anchor===m[2]||s.html.includes('id="'+m[2]+'"')),'Ancla de interfaz inválida: '+m[2]);
}
for(const m of app.matchAll(/go\('(\d\d_[^']+)'\s*,\s*'([^']+)'\)/g))assert(docs.get(m[1])?.sections.some(s=>s.anchor===m[2]),'Ruta inválida: '+m[0]);
for(const m of app.matchAll(/anchor:'([^']+)'/g))assert(docs.get('00_GUIA_CAMPO').sections.some(s=>s.anchor===m[1]),'Etapa inválida: '+m[1]);
for(const [id,e] of Object.entries(data.entities)){
 for(const k of e.related)assert(data.entities[k],id+' relación ausente: '+k);
 for(const k of e.docs)assert(docs.has(k),id+' documento ausente: '+k);
 for(const k of e.sources)assert(data.sources.some(s=>s.id===k),id+' fuente ausente: '+k);
}
const seen=new Set();for(const s of data.sources){assert(!seen.has(s.id),'ID duplicado');seen.add(s.id);assert(/^[a-f\d]{64}$/.test(s.sha256));for(const e of s.excerpts){const lines=e.text.split('\n');assert.equal(lines.length,e.end-e.start+1);lines.forEach((line,i)=>assert(line.startsWith((e.start+i)+':')))}}
assert(!/<(?:script|link|img)[^>]+(?:src|href)="https?:/i.test(html),'Dependencia externa automática');
assert(!/\b(?:fetch|XMLHttpRequest|WebSocket)\s*\(/.test(app),'Red no esperada');
const ctx=vm.createContext({});vm.runInContext(await readFile(path.join(root,'web/logica.js'),'utf8'),ctx);const L=ctx.AtlasLogic;
const capture=(x=0)=>['magic: 0x12345678',...Array.from({length:9},(_,i)=>'data_group_'+i+': 0x'+(i===0?x:0).toString(16).padStart(8,'0')),'data_header: 0x00000001','clk_thresh: 0x0000000e','14'].join('\n');
const a=L.parseCapture(capture()),b=L.parseCapture(capture(0x80000001));assert(a.complete);assert.equal(a.ignored.length,1);let r=L.compareCaptures(a,b);assert.equal(r.changedGroups,1);assert.equal(r.rows[1].xor,0x80000001);assert.equal(r.rows[1].bits.join(','),'31,0');
for(let i=0;i<32;i++){const v=2**i;const r=L.compareCaptures(a,L.parseCapture(capture(v)));assert.equal(r.rows[1].bits.join(','),String(i));assert.equal(r.rows[1].xor,v)}
r=L.compareCaptures(a,a);assert.equal(r.changedGroups,0);assert.equal(r.comparableGroups,9);
assert(L.parseCapture(capture()+'\ndata_group_0: 0x0').errors.length);assert(!L.parseCapture('data_group_0: 0x0').complete);
for(const input of ['data_group_0: 0x100000000','data_group_0: 12','data_group_9: 0x0','data_group_0: -1','data_header: 0xGG'])assert(L.parseCapture(input).errors.length,'Aceptó valor inválido: '+input);
assert(L.parseCapture('x'.repeat(200001)).errors.length);assert.equal(L.parseCapture('<img src=x onerror=alert(1)>').values.magic,undefined);
assert.equal(L.compareCaptures(L.parseCapture(''),L.parseCapture('')).comparableGroups,0);
assert.equal(L.compareCaptures(a,L.parseCapture(capture().replace('clk_thresh: 0x0000000e','clk_thresh: 0x0000000f'))).configurationChanged[0],'clk_thresh');
assert.equal(L.diagnose({linux:'no'}).stop,true);assert.equal(L.diagnose({linux:'yes',returns:'no',tool:'ic'}).priority[0],'H5');assert.equal(L.diagnose({returns:'no',tool:'payload'}).stop,true);
assert.equal(L.diagnose({returns:'yes',tool:'script'}).priority[0],'H2');assert.equal(L.diagnose({returns:'yes',tool:'payload',link:'lost'}).priority[0],'H3');assert(!L.diagnose({returns:'yes',tool:'payload'}).priority.includes('H5'));assert(L.diagnose({}).title.includes('Falta'));assert(L.diagnose({returns:'yes',tool:'ic'}).title.includes('control IC'));
console.log(JSON.stringify({resultado:'OK',alcance:'Sintaxis, enlaces, fuentes y lógica pura; no sustituye navegador ni hardware',documentos:data.docs.length,fuentes:data.sources.length,entidades:Object.keys(data.entities).length,enlacesMarkdown:links,casosBits:32,pruebas:['parseo completo/parcial','duplicados','límites 32 bits','datos malformados','entrada HTML como texto','capturas vacías','cambio de configuración','diagnóstico por ruta y síntoma','sin dependencias automáticas de red']},null,2));
