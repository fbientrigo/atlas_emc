/* Lógica pura de análisis local. No abre dispositivos ni realiza solicitudes de red. */
(function(root){
'use strict';
const fields=['magic',...Array.from({length:9},(_,i)=>'data_group_'+i),'data_header','clk_thresh'];
const norm=s=>String(s).normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
function parseCapture(text){
 const values={}, errors=[], ignored=[];
 if(text.length>200000){return {values,errors:['El texto pasa de 200 kB. Pega una sola captura.'],ignored,missing:fields,complete:false}}
 text.split(/\r?\n/).forEach((line,i)=>{
  const m=line.match(/^\s*(magic|data_group_[0-8]|data_header|clk_thresh)(?:\s*:\s*|\s+)0x([\da-fA-F]{1,8})\s*$/);
  if(m){if(Object.hasOwn(values,m[1]))errors.push('Línea '+(i+1)+': '+m[1]+' aparece dos veces. ¿Hay dos capturas mezcladas?');else values[m[1]]=parseInt(m[2],16)>>>0;}
  else if(/^\s*(magic|data_group_\d+|data_header|clk_thresh)(?:\s*:|\s+\S)/.test(line))errors.push('Línea '+(i+1)+': etiqueta o valor hexadecimal de 32 bits no válido.');
  else if(line.trim())ignored.push(i+1);
 });
 const missing=fields.filter(k=>!Object.hasOwn(values,k));
 return {values,errors,ignored,missing,complete:!errors.length&&!missing.length};
}
function compareCaptures(a,b){
 const rows=fields.map(k=>{
  const av=a.values[k],bv=b.values[k],available=av!==undefined&&bv!==undefined;
  const xor=available?(av^bv)>>>0:null;
  return {field:k,a:av,b:bv,xor,bits:available?Array.from({length:32},(_,i)=>31-i).filter(i=>(xor>>>i)&1):[],changed:available&&xor!==0};
 });
 const groups=rows.filter(r=>r.field.startsWith('data_group_'));
 return {rows,changedGroups:groups.filter(r=>r.changed).length,comparableGroups:groups.filter(r=>r.xor!==null).length,valid:a.errors.length===0&&b.errors.length===0,complete:a.complete&&b.complete,configurationChanged:rows.filter(r=>['magic','clk_thresh'].includes(r.field)&&r.changed).map(r=>r.field)};
}
function diagnose(a){
 const r={title:'Falta describir el síntoma',priority:[],next:'Anota si Linux responde y si el comando vuelve al prompt.',stop:false,limit:'Es una orientación, no un diagnóstico. No sabemos el estado actual del hardware.'};
 if(a.linux==='no')return {...r,title:'Primero hay que volver a ver el sistema',priority:['H4','H3'],next:'Guarda el último estado y mira por la consola que tengas. Separa red, kernel, reloj y alimentación. No lances más MMIO ni reinicios de prueba.',stop:true};
 if(a.returns==='no'){
  r.title='El comando no termina';r.stop=true;
  r.priority=a.tool==='ic'?['H5','H4']:a.tool==='script'?['H2','H4']:['H4','H2'];
  r.next='Sigue F0: anota PID, estado y ejecutable, y guarda stderr y logs. No abras un segundo lector. '+(a.tool==='ic'?'Mira clearIntr y readICRxFifo: el timeout de IRQ no cubre sus bucles.':'Que no salga nada no prueba que una lectura MMIO esté bloqueada.');
 }else if(a.returns==='yes'){
  r.title='El comando termina: ¿se actualizan las muestras?';
  r.priority=a.tool==='script'?['H2','H1','H3','H7']:['H1','H2','H3','H7'];
  r.next=a.stimulus==='yes'?'Guarda A y B completas y mira, en la misma ventana, si se mueve UserData y si se actualiza el capturador. Documenta la prueba externa.':'Sin un estímulo externo confirmado, que las muestras sean iguales no dice nada. Consigue el método FE y la configuración en uso antes de hablar de bloqueo.';
  if(a.link==='lost'){r.priority=['H3','H7',...r.priority.filter(x=>!['H3','H7'].includes(x))];r.next='El estado del enlace cambió: revisa reloj, reset y fuente óptica con la configuración validada. '+r.next;}
 }
 if(a.tool==='ic'&&a.returns==='yes'){r.title='La lectura termina, pero es del control IC';r.priority=['H5'];r.next='Los registros de control del lpGBT no son muestras FE. Compara estado y errores con la herramienta de payload validada.';}
 if(a.reset&&a.reset!=='unknown')r.limit+=' Se recuperaba con: '+a.reset+'. Falta confirmar qué abarcaba, y eso solo no explica la causa.';
 return r;
}
root.AtlasLogic={fields,norm,parseCapture,compareCaptures,diagnose};
})(globalThis);
