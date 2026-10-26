import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {JSDOM} from 'jsdom';
const dom=new JSDOM('<!doctype html><html><body></body></html>');
globalThis.window=dom.window;globalThis.document=dom.window.document;
const {default:mermaid}=await import('mermaid');
const root=path.dirname(fileURLToPath(import.meta.url));
mermaid.initialize({startOnLoad:false,securityLevel:'strict'});
let count=0;
for(const file of (await readdir(root)).filter(f=>/^\d\d_.*\.md$/.test(f))){
 const md=await readFile(path.join(root,file),'utf8');
 for(const m of md.matchAll(/```mermaid\n([\s\S]*?)```/g)){await mermaid.parse(m[1]);count++}
}
assert(count>=10,'Faltan diagramas');
const html=await readFile(path.join(root,'_site/index.html'),'utf8');
assert(html.includes('src="assets/mermaid.js"'));
assert((await readFile(path.join(root,'_site/assets/mermaid.js'))).length>10000);
for(const src of html.matchAll(/<script[^>]+src="([^"]+)"/g))await readFile(path.join(root,'_site',src[1]));
console.log('OK: '+count+' diagramas Mermaid parseados y recurso local empaquetado');
