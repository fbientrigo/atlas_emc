# Checkpoint de continuación — laboratorio ATLAS

Estado al 27-10-2026. **Checkpoint parcial, no entrega terminada.** Actualizar este archivo; no crear otra serie de estados.

## Objetivo y autorización

Completar ocho documentos en español para recuperar contexto y preparar una sesión de 120 minutos con el ingeniero. Fuente principal: respaldo `trenz-tgc-backup-20261023.tar.gz`; secundaria: main de `fbientrigo/atlas_emc`. El usuario autoriza rama nueva y PR revisable; prohíbe ejecutar binarios/scripts hardware del respaldo, modificar adquisición o publicar el respaldo entero. No modificar main ni la web. Solicitó checkpoints para continuar tras límites de sesión.

## Base autoritativa

- Main inspeccionado: `3379d3e12c9b4d1fd99019678bc8023e594455a8`; árbol `aa6b61e06a9e06e270bfed6e5b33f7449d403d81`.
- Rama de trabajo: `docs/laboratorio-trenz-20261027`.
- TAR SHA-256: `60fd64b63bbcea0c7ddb3791b1095af3882a2d767835f8c6f2a1f42b46cfaf01`.
- 2653 entradas TAR, 2048 archivos; 9 XSA externos, 10 BSP inspeccionados, 11 contenidos XSA distintos al incluir los embebidos. Sin RTL `.v/.vhd` en el respaldo/BSP. No se ha ejecutado hardware.
- Local transitorio: `/workspace/scratch/66ddc240d9c9/atlas_emc`, respaldo extraído en `../backup/`, adjuntos en `../upload/`. No confiar en persistencia de esas rutas entre sesiones; volver a obtener repositorio y adjunto si faltan.
- La instrucción completa está en el adjunto `Pasted text.txt`; fuentes complementarias `libuio_gitingest.txt` y `lpgbtsw_gitingest.txt`. No equivalen a instalación actual.

## Resultado verificado y delta

Redactados: [START_HERE](START_HERE.md), [ENGINEER_BRIEFING](ENGINEER_BRIEFING.md), [SYSTEM_MAP](SYSTEM_MAP.md), [TOOL_AND_PATH_ATLAS](TOOL_AND_PATH_ATLAS.md), [LAB_SESSION](LAB_SESSION.md). Los tres primeros contienen síntesis; el atlas concentra paths exactos, hashes y referencias B/R/X. LAB tiene etapas 25+15+15+20+25+20 = 120 minutos, puertas y comandos condicionados.

Hallazgos de continuidad que no hay que redescubrir:

1. A00D0000 identifica `axi_intc_1` en el BD del repositorio, `elink_memory_interfa_0` en XSA xV23 del TAR y `Read_PRBS_regs` en tres overlays `out_lpgbt_10_{cd,dd,direct}` de main. Estos últimos sitúan TGC en A00E0000; se analizaron tanto DTSI como DTBO binarios. Ninguna variante está acreditada como activa.
2. XSA xV23 Trenz/EMP: XCZU4EG, 13 controladores IC, interfaz e-link en A00D de 16 KiB, UserData conectado a `emp_lpgbt_11`; reloj uplink desde `clk_wiz_0`. No equiparar esa IP con TGC ni con RTL `eLink_Interface_v1`. Variantes anteriores sitúan e-link en A00C o usan familia 0x800…; Enclustra XCZU4CG.
3. CLI TGC B/read_all_lpgbt lee doce registros 0x00..0x2C y repite threshold decimal. No acepta argumentos: `--help` también lee. AArch64 dinámico; `uio_read32` hace carga volatile32 sin comprobar límites. No hay espera IRQ ni contador de frescura/snapshot demostrado. Packing y RTL del capturador activo desconocidos.
4. `read_lpgbt10.sh` espera indefinidamente por cambio del byte bajo. `watch_devmem.sh` y `1024/send_and_read.sh` omiten +0x18; incluyen header. `sweep_clock.sh` escribe threshold, no programa Si5345; oculta fallos sustituyéndolos por cero. Capturas históricas no prueban frescura ni FE.
5. `readprbs_cli --selftest` en ambas fuentes del TAR SOLO LEE y luego imprime OK sin validar contenido. `02_CATALOGO.md` afirma que modifica generador: contradicción concreta P1. Las dos fuentes CLI son idénticas, los ELF son distintos.
6. `fwMonitor` lee siete campos y muestra cuatro indicadores; no muestra valores de reloj ni prueba progreso. Backend UIO continúa tras ciertos fallos. Cuatro ELF AArch64 distintos; no se conocen sus revisiones exactas. `RX locked` es alineación de cabecera; ready CDC se retiene tras strobe hasta reset, no es heartbeat.
7. `clkProgrammer`: `readRegister` trunca a byte bajo y no selecciona página; `writeRegister` sí. Postámbulo de configure termina en página 0B. Diagnóstico de página incorrecta es inferido si página efectiva no es cero. main captura excepción y puede devolver cero. Unidad systemd programa reloj al arrancar SI instalada/activa; no prueba causa del fallo.
8. `LpGbtUioBackend::readRegister` hace escrituras IC, espera, drena FIFO y accede a readValues[6] sin comprobar longitud; clearIntr y drenaje tienen bucles sin límite. No es payload ni lectura pasiva. Build recuperado V1 (`USE_LPGBT_V0=OFF`). TrigoLpGbt existe en gitingest, no TAR. No ejecutar build.sh: borra build.
9. RTL alternativo eLink tiene FSM que espera lectura/rearme y decisiones de FIFO sospechosas; solo hipótesis, no capturador activo demostrado. Watchdog de otra FSM IC queda fuera de rama vacía, pero comando 0x10004 no usa ese camino. FIFO IC se resetea por transacción: no afirmar acumulación sin comprobar reset.
10. `09_USO_LOCAL.md` menciona deploy docs/clean; README/workflow usan main. `evidencias.json`: 13 hashes B coinciden; 15 extractos R coinciden exactamente en líneas, aunque hashes no son bytes crudos actuales (11 coinciden normalizando newline final). No inferir código cambiado por esa diferencia; falta especificar canonicalización.

## Validación ejecutada

`python -m unittest discover -s docs/recuperacion/diagnostico -p 'test_*.py' -v`: **18 tests aprobados**, sintéticos, sin hardware. `npm ci --ignore-scripts --no-audit --no-fund` completó para usar Mermaid/jsdom existentes. No se regeneró la web. Pendientes validación de enlaces/anclas, Mermaid nuevo, sintaxis shell y revisión final de los ocho documentos.

## Puerta abierta y siguiente acción

**Puerta:** completar los tres documentos restantes y verificar coherencia de la entrega antes de marcar PR listo.

**Siguiente acción:** redactar `TEACHING_SESSION.md` (cinco lecciones con ciclo intuición→arquitectura→código→predicción→comprobación→interpretación; pauta separada), `AUDIT_AND_UNCERTAINTIES.md` (15 Markdown de docs/recuperacion, utilidad/confiabilidad 0–5, vigencia, errores/P0–P2, hipótesis y límites) y `QUICK_REFERENCE.md`.

Auditoría ya revisada: 00 guía sólida con alcance 77 archivos antiguo; 01/11 mapas incompletos frente a XSA/overlays nuevos; 02 error selftest; 03 cronología histórica; 04 algunas incógnitas ELF ahora parcialmente resueltas; 05 futuro útil no urgente; 06 conceptual útil, añadir ejercicios separados; 07 auditoría histórica; 08 hashes/canonicalización; 09 rama deploy incorrecta; 10 congelamiento condicional sólido; 12 supervisor con 18 pruebas; 13 guía rápida útil; README índice. No reescribir documentos antiguos: recoger correcciones en auditoría nueva.

**Correcto si:** ocho entregables presentes, enlaces locales/anclas válidos, Mermaid parsea, comandos coinciden con CLI real y riesgos etiquetados, 120 minutos suman, ninguna afirmación certifica hardware actual, diff solo documental revisado. Después actualizar este estado, publicar rama y crear/actualizar PR revisable; no merge.

## Congelado y presentación final

Fuera de alcance: ejecución hardware, cambios de adquisición/firmware/web, publicación del TAR/historial/configuraciones privadas, conclusiones causales sin medición. No pedir confirmaciones ya autorizadas.

La respuesta final debe mostrar primero START_HERE, briefing y tres hallazgos principales; luego laboratorio, atlas, mapa, enseñanza, auditoría y referencia, con enlace al PR. Separar pruebas offline de validación experimental pendiente. Continuar el trabajo original tras guardar este checkpoint; el usuario no pidió detenerse.
