// Comprobación de navegación y lectura offline; nunca opera hardware.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath, pathToFileURL} from 'node:url';
import path from 'node:path';
import vm from 'node:vm';
const root = path.dirname(fileURLToPath(import.meta.url));
const html = await readFile(path.join(root, 'index.html'), 'utf8');
const data = JSON.parse(html.match(/<script id="data" type="application\/json">([\s\S]*?)<\/script>/)[1]);
const byId = new Map(data.docs.map(d => [d.id, d]));
let checkedLinks = 0;
for (const d of data.docs) for (const section of d.sections) {
  for (const match of section.html.matchAll(/href="([^"\s]+)"/g)) {
    const href = match[1];
    const m = href.match(/^(?:\.\/)?(\d\d_[^#]+)\.md(?:#(.+))?$/);
    if (!m) continue;
    const target = byId.get(m[1]);
    assert(target, 'Documento inexistente: ' + href);
    if (m[2]) {
      const anchor=decodeURIComponent(m[2]);
      assert(target.sections.some(s => s.anchor === anchor || s.html.includes('id="' + anchor + '"')), 'Ancla inexistente: ' + href);
    }
    checkedLinks++;
  }
}
const script=html.match(/<script>([\s\S]*?)<\/script>/)[1];
new vm.Script(script);
// Doble DOM mínimo para probar las funciones de composición y rutas en Node.
// No sustituye renderizado, eventos reales, accesibilidad o viewport de navegador.
const callbacks={};
const element=()=>({innerHTML:'',textContent:'',value:'',style:{},children:[],append(x){this.children.push(x)},replaceChildren(){this.children=[]},addEventListener(){},setAttribute(){},scrollIntoView(){},querySelectorAll(){return []},querySelector(selector){const value=selector.match(/="(.*)"/)?.[1];return value&&this.innerHTML.includes(value)?element():null},insertAdjacentHTML(_,s){this.innerHTML=s+this.innerHTML}});
const elements=new Map(['content','q','results','expand','collapse','data'].map(x=>[x,element()]));
elements.get('data').textContent=JSON.stringify(data);
const context=vm.createContext({document:{getElementById:id=>elements.get(id),querySelectorAll:()=>[],createElement:element,addEventListener:(n,f)=>callbacks[n]=f},window:{addEventListener(){}},location:{hash:''},CSS:{escape:s=>s}});
vm.runInContext(script,context);
const call=(name,...args)=>vm.runInContext(name+'('+args.map(x=>JSON.stringify(x)).join(',')+')',context);
const rendered=()=>elements.get('content').innerHTML;
for(const mode of ['operar','entender','investigar','aprender']){call('home',mode);assert(rendered().includes('<h2>'),'Modo sin contenido: '+mode)}
for(const doc of data.docs){call('showDoc',doc.id);assert(rendered().includes('aria-label="'+doc.title+'"'),'Documento no renderizado: '+doc.id)}
for(const source of data.sources){call('showSource',source.id);assert(rendered().includes(source.sha256));assert(rendered().includes(source.excerpts[0].start+':'))}
const entityKeys=vm.runInContext('Object.keys(entities)',context);
for(const id of entityKeys){call('showEntity',id);assert(rendered().includes('class="entity"'));for(const source of vm.runInContext('entities['+JSON.stringify(id)+'].sources',context))assert(data.sources.some(s=>s.id===source))}
call('home','operar');
const taskLinks=[...rendered().matchAll(/href="#doc\/([^"/]+)\/([^"/]+)"/g)];
assert.equal(taskLinks.length,6);
for(const [,id,encoded] of taskLinks){const anchor=decodeURIComponent(encoded);assert(byId.get(id)?.sections.some(s=>s.anchor===anchor),'Tarea apunta a ancla inválida: '+anchor);call('showDoc',id,anchor);assert(!rendered().includes('Sección no encontrada'))}
for(const term of ['readDataGroup0Value','Bus error','clk_thresh','mgt_word_i','ULDATASOURCE']){elements.get('q').value=term;call('search');assert(elements.get('results').children.length>1,'Búsqueda sin resultados: '+term)}
elements.get('q').value='termino-inexistente-7391';call('search');assert(elements.get('results').children[0].textContent.includes('Sin coincidencias'));
let prevented=false;
callbacks.click({target:{closest:s=>s==='a'?{getAttribute:()=> '00_GUIA_CAMPO.md#etapa-e--diagn%C3%B3stico-remoto'}:null},preventDefault(){prevented=true}});
assert(prevented,'No intercepta enlaces Markdown');
assert.equal(context.location.hash,'#doc/00_GUIA_CAMPO/etapa-e--diagn%C3%B3stico-remoto');
assert(!/<(?:script|link|img)[^>]+(?:src|href)="https?:/i.test(html),'Dependencia remota automática');
console.log(JSON.stringify({validacion:'estatica y funciones JavaScript en Node; sin navegador',documentos:data.docs.length,fuentes:data.sources.length,enlacesMarkdown:checkedLinks,modos:4,nodos:entityKeys.length,tareas:taskLinks.length,busquedas:5,resultado:'OK'},null,2));
if(process.argv[2]==='--static')process.exit(0);
const {chromium} = await import(process.argv[2] || 'playwright');
const browser = await chromium.launch({headless:true, args:['--no-sandbox']});
try {
  const page = await browser.newPage({viewport:{width:1280,height:960}});
  const errors = [], requests = [];
  page.on('pageerror', e => errors.push(String(e)));
  page.on('request', r => {if (/^https?:/.test(r.url())) requests.push(r.url())});
  await page.route(/^https?:/, r => r.abort());
  await page.goto(pathToFileURL(path.join(root, 'index.html')).href);
  await page.waitForSelector('#content h2');
  for (const [mode, text] of [['operar','Leer datos reales'],['entender','Arquitectura y relaciones'],['investigar','Entrar desde un síntoma'],['aprender','Recuperar criterio técnico']]) {
    await page.click('[data-mode="'+mode+'"]');
    await page.waitForFunction(t => document.getElementById('content').textContent.includes(t), text);
  }
  await page.click('[data-mode="entender"]');
  await page.click('[data-entity="mgt"]');
  await page.waitForFunction(() => document.querySelector('.entity h3').textContent.includes('MGT'));
  await page.click('.entity a[href="#nodo/core"]');
  await page.waitForFunction(() => document.querySelector('.entity h3').textContent === 'Core uplink');
  await page.click('.entity a[href="#fuente/R02"]');
  await page.waitForSelector('.source pre');
  assert((await page.locator('.source').first().textContent()).includes('263:'), 'Faltan números de línea');
  await page.fill('#q', 'readDataGroup0Value');
  await page.waitForSelector('#results .result');
  assert((await page.locator('#results').textContent()).includes('resultado'));
  await page.locator('#results .result').first().click();
  await page.waitForSelector('#content article, #content .source');
  await page.fill('#q', 'termino-que-no-existe-7391');
  assert((await page.locator('#results').textContent()).includes('Sin coincidencias'));
  await page.fill('#q', '"><img src=x onerror=alert(1)>');
  assert.equal(await page.locator('#results img').count(), 0);
  await page.fill('#q', '');
  for (const doc of data.docs) {
    await page.evaluate(id => location.hash = 'doc/' + encodeURIComponent(id), doc.id);
    await page.waitForFunction(t => document.querySelector('#content article')?.getAttribute('aria-label') === t, doc.title);
    await page.click('#expand');
    assert.equal(await page.locator('#content details:not([open])').count(), 0);
    await page.click('#collapse');
    assert.equal(await page.locator('#content details[open]').count(), 0);
  }
  await page.evaluate(() => location.hash='modo/operar');
  await page.waitForSelector('#content .card');
  for (const href of await page.locator('#content .card a').evaluateAll(xs => xs.map(x=>x.getAttribute('href')))) {
    await page.evaluate(h=>location.hash=h,href);
    await page.waitForSelector('#content article');
    assert.equal(await page.locator('#content .notice').count(),0,'Ruta de tarea rota: '+href);
    assert.equal(await page.locator('#content details[open]').count(),1,'No abre la sección: '+href);
  }
  await page.evaluate(() => location.hash='doc/02_CATALOGO');
  await page.waitForSelector('#content article');
  await page.locator('#content article a[href="00_GUIA_CAMPO.md"]').first().click();
  await page.waitForFunction(() => location.hash.startsWith('#doc/00_GUIA_CAMPO'));
  await page.setViewportSize({width:390,height:844});
  await page.evaluate(() => location.hash='modo/operar');
  await page.waitForSelector('#content .card');
  assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth+1), 'Desborde horizontal móvil');
  assert.deepEqual(errors, [], 'Errores JavaScript');
  assert.deepEqual(requests, [], 'La lectura local intenta usar red');
  console.log(JSON.stringify({resultado:'OK',documentos:data.docs.length,fuentes:data.sources.length,enlacesMarkdown:checkedLinks,modos:4,red:requests.length,erroresJS:errors.length,pruebas:['navegación','relaciones','extractos','búsqueda','sin resultados','entrada HTML como texto','expandir/resumir','anclas de tareas','enlaces Markdown interceptados','viewport móvil']},null,2));
} finally {await browser.close()}
