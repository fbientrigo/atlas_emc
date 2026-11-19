// Solo publica el cuaderno y sus recursos: nunca el respaldo ni el repositorio completo.
import {build} from 'esbuild';
import {execFileSync} from 'node:child_process';
import {mkdir,cp,writeFile} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.dirname(fileURLToPath(import.meta.url)),out=path.join(root,'_site');
await mkdir(path.join(out,'assets'),{recursive:true});
await build({entryPoints:[path.join(root,'web/mermaid-entry.js')],outfile:path.join(out,'assets/mermaid.js'),bundle:true,minify:true,format:'iife',legalComments:'eof'});
await cp(path.join(root,'index.html'),path.join(out,'index.html'));
await cp(path.join(root,'diagnostico'),path.join(out,'diagnostico'),{recursive:true,filter:p=>!p.includes('__pycache__')&&!p.endsWith('.pyc')});
const captureFiles=['README.md','emp','raw.sh','registers.json','registers.py','doctor.py','night.py','test_capture.py'];
execFileSync('tar',['-czf',path.join(out,'emp-capture.tar.gz'),'-C',path.resolve(root,'../..'),
  ...captureFiles.map(file=>'capture/'+file)]);
await writeFile(path.join(out,'.nojekyll'),'');
console.log('Pages preparado en '+out);
