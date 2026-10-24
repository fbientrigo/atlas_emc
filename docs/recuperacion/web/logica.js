/* Lógica pura de análisis local. No abre dispositivos ni realiza solicitudes de red. */
(function(root){
'use strict';
const fields=['magic',...Array.from({length:9},(_,i)=>'data_group_'+i),'data_header','clk_thresh'];
const norm=s=>String(s).normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
function parseCapture(text){
 const values={}, errors=[], ignored=[];
 if(text.length>200000){return {values,errors:['El texto supera 200 kB. Seleccionar una única captura.'],ignored,missing:fields,complete:false}}
 text.split(/\r?\n/).forEach((line,i)=>{
  const m=line.match(/^\s*(magic|data_group_[0-8]|data_header|clk_thresh):\s*0x([\da-fA-F]{1,8})\s*$/);
  if(m){if(Object.hasOwn(values,m[1]))errors.push('Línea '+(i+1)+': etiqueta duplicada '+m[1]+'. No mezclar capturas.');else values[m[1]]=parseInt(m[2],16)>>>0;}
  else if(/^\s*(magic|data_group_\d+|data_header|clk_thresh)\s*:/.test(line))errors.push('Línea '+(i+1)+': etiqueta o hexadecimal de 32 bits no válido.');
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
 const r={title:'Falta caracterizar el síntoma',priority:[],next:'Registrar si Linux responde y si la ejecución retorna al prompt.',stop:false,limit:'Orientación condicional, no diagnóstico confirmado. Hardware actual desconocido.'};
 if(a.linux==='no')return {...r,title:'Primero: recuperar observabilidad del sistema',priority:['H4','H3'],next:'Conservar el último estado y observar por la consola ya disponible. Distinguir red, kernel, reloj y alimentación. No lanzar más MMIO ni reinicios exploratorios.',stop:true};
 if(a.returns==='no'){
  r.title='La ejecución no finaliza';r.stop=true;
  r.priority=a.tool==='ic'?['H5','H4']:a.tool==='script'?['H2','H4']:['H4','H2'];
  r.next='Aplicar F0: identificar PID, estado y ejecutable, conservar stderr y logs. No iniciar un segundo lector. '+(a.tool==='ic'?'Investigar clearIntr y readICRxFifo: el timeout IRQ no cubre sus bucles.':'La ausencia de salida no identifica por sí sola una instrucción MMIO bloqueada.');
 }else if(a.returns==='yes'){
  r.title='La ejecución termina; investigar actualización de muestras';
  r.priority=a.tool==='script'?['H2','H1','H3','H7']:['H1','H2','H3','H7'];
  r.next=a.stimulus==='yes'?'Conservar A/B completas; comprobar movimiento de UserData y actualización del capturador en la misma ventana. La prueba externa debe estar documentada.':'No hay estímulo externo confirmado: muestras iguales aún son inconclusas. Obtener método FE y configuración efectiva antes de atribuir un bloqueo.';
  if(a.link==='lost'){r.priority=['H3','H7',...r.priority.filter(x=>!['H3','H7'].includes(x))];r.next='El estado de enlace cambió: contrastar reloj/reset y fuente óptica, con la configuración validada. '+r.next;}
 }
 if(a.tool==='ic'&&a.returns==='yes'){r.title='La lectura termina, pero corresponde al control IC';r.priority=['H5'];r.next='No usar registros de control del lpGBT como muestras FE. Comparar estado/errores y la herramienta de payload validada.';}
 if(a.reset&&a.reset!=='unknown')r.limit+=' Recuperación declarada: '+a.reset+'. Su alcance debe verificarse; no demuestra por sí solo la causa.';
 return r;
}
root.AtlasLogic={fields,norm,parseCapture,compareCaptures,diagnose};
})(globalThis);
