# Auditoría: qué sabemos y qué falta medir

[Inicio](START_HERE.md) · [Evidencia B/R/X y paths](TOOL_AND_PATH_ATLAS.md) · [Pruebas de laboratorio](LAB_SESSION.md)

Fecha de investigación: 27-10-2026. Main inspeccionado: `3379d3e12c9b4d1fd99019678bc8023e594455a8`. Fuente prioritaria: TAR completo, SHA-256 `60fd64b63bbcea0c7ddb3791b1095af3882a2d767835f8c6f2a1f42b46cfaf01`. No se ejecutaron binarios/scripts de hardware; no hubo conexión al equipo. Esta auditoría complementa la guía anterior sin reescribirla ni modificar la adquisición.

## Cómo leer las conclusiones

- **VERIFICADO:** bytes, código, configuración o resultado local identificable. Siempre limitado al artefacto inspeccionado.
- **INFERIDO:** consecuencia plausible con condiciones todavía sin medir.
- **CONTRADICTORIO:** fuentes que no pueden describir el mismo contrato; no decidir por mayoría.
- **DESCONOCIDO:** falta evidencia para la afirmación.

Prioridad **P0**: resolver antes del acceso hardware al que afecta. **P1**: corregir para interpretar el ensayo sin error. **P2**: mantenimiento, trazabilidad o ampliación posterior. La prioridad de un documento señala su actualización más importante, no que todo su contenido sea incorrecto.

## Revisión de docs/recuperacion

Escalas independientes 0–5: utilidad para mañana (0 ninguna, 5 directamente ejecutable) y confiabilidad documental (0 sin respaldo, 5 afirmaciones revisadas con límites explícitos). No son probabilidades ni certificación hardware. La vigencia distingue información histórica de evidencia nueva. Se revisan los quince Markdown fuente; web generada y pruebas se consideran por separado.

| Documento | Utilidad | Confianza | Vigencia frente al respaldo completo | Error, límite o actualización requerida | Prioridad |
|---|---:|---:|---|---|---|
| [00_GUIA_CAMPO](../recuperacion/00_GUIA_CAMPO.md) | 5 | 4 | Puertas y conservación de evidencia vigentes | Alcance anterior de 77 archivos; ahora se conoce arquitectura ELF y fuente de reloj/monitor. Añadir familias XSA/overlay antes de elegir base; no invalida sus cautelas | P0 |
| [01_MAPA_TECNICO](../recuperacion/01_MAPA_TECNICO.md) | 4 | 4 | Cadena conceptual útil, integración sigue abierta | Completar A00D=e-link en xV23 y A00D=PRBS/A00E=TGC en overlays. BD de main no representa todos los diseños | P0 |
| [02_CATALOGO](../recuperacion/02_CATALOGO.md) | 5 | 3 | Herramientas correctas, fuentes completas cambian detalles | Línea108 atribuye escritura a `--selftest`; B04 muestra solo lecturas. Actualizar cuatro duplicados EMPTools, dependencias, página Si5345 y error con retorno0 | P1 |
| [03_HISTORIA](../recuperacion/03_HISTORIA.md) | 2 | 4 | Historia, no diagnóstico actual | No convertir orden de notas/fechas en causalidad. Nuevas familias XSA no permiten identificar build de cada captura. No se encontró error causal adicional confirmado | P2 |
| [04_INCERTIDUMBRES](../recuperacion/04_INCERTIDUMBRES.md) | 4 | 4 | Preguntas hardware centrales siguen abiertas | Arquitectura de ELF y disponibilidad de fuente reloj/monitor ya resueltas para el TAR; identidad ejecutada/packing/RTL siguen abiertas | P1 |
| [05_EVOLUCION_FUTURA](../recuperacion/05_EVOLUCION_FUTURA.md) | 2 | 4 | Propuestas, no resultados implementados | Contadores, versionado y captura coherente son útiles después de cerrar ABI; no necesarios para comenzar inventario. No error confirmado que exija reescritura | P2 |
| [06_APRENDER](../recuperacion/06_APRENDER.md) | 4 | 4 | Conceptos y recorrido útiles | Complementar con predicción previa, decisiones prácticas y pauta separada; no confundir explicación de UIO con validación del capturador | P2 |
| [07_AUDITORIA](../recuperacion/07_AUDITORIA.md) | 3 | 4 | Auditoría del alcance anterior | Sus pruebas offline no validan sistema real. No cubre XSA/BSP y nuevos duplicados del respaldo completo | P1 |
| [08_FUENTES](../recuperacion/08_FUENTES.md) | 4 | 3 | Extractos comprobables, alcance parcial | 13 hashes B coinciden; 15 extractos R coinciden por líneas, pero sus hashes no son todos hashes crudos de archivos actuales. Especificar normalización, no afirmar cambio semántico | P2 |
| [09_USO_LOCAL](../recuperacion/09_USO_LOCAL.md) | 3 | 3 | Uso offline aprovechable | Líneas3/45 hablan de `docs/clean`; workflow y README usan main. No hace falta desplegar web para esta sesión | P2 |
| [10_BLOQUEO_LECTURAS](../recuperacion/10_BLOQUEO_LECTURAS.md) | 5 | 4 | Buen diagnóstico condicional | Mantener separación IC/TGC y RTL alternativo/activo. Añadir posible reprogramación de reloj durante boot y límite de diagnóstico Si5345 | P1 |
| [11_COMPATIBILIDAD](../recuperacion/11_COMPATIBILIDAD.md) | 5 | 4 | Regla de no mezclar mapas vigente | Ampliar matriz con HWH xV23, generaciones 0x800/A00C y DTBO de main. Es una omisión de alcance, no prueba de mapa activo erróneo | P0 |
| [12_SCRIPT_DIAGNOSTICO](../recuperacion/12_SCRIPT_DIAGNOSTICO.md) | 5 | 5 | Código/parámetros y límites revisados; 18 tests pasan | Perfil TGC específico; no certifica firmware, bibliotecas completas ni kill de MMIO bloqueado. Lecturas reales pendientes; conservar estos límites | P1 |
| [13_GUIA_RAPIDA](../recuperacion/13_GUIA_RAPIDA.md) | 5 | 4 | Útil para inventario/captura condicionada | Añadir selección por familias y límites del reloj/selftest; no expandirla con comandos exploratorios | P1 |
| [README](../recuperacion/README.md) | 4 | 4 | Índice y acceso local útiles | Describe alcance histórico; incorporar referencia a nueva síntesis en una revisión editorial futura si se decide integrarla. No necesario alterar web ahora | P2 |

No se «corrigen» los archivos anteriores en este PR: las rectificaciones concretas están aquí y los procedimientos nuevos las incorporan. La puntuación 5 del documento del supervisor mide fidelidad al código probado, no seguridad certificada de una instalación desconocida.

## Hallazgos trazables que cambian decisiones

| ID / clasificación | Evidencia primaria y contraste | Consecuencia operativa / evidencia que falta |
|---|---|---|
| F01 **CONTRADICTORIO**, P0: A00D/A00E | R01 BD: INTC1/2 de 64 KiB. X01/X02 HWH: e-link A00D de 16 KiB, sin MEMRANGE A00E. R06 DTSI y DTBO: PRBS A00D y TGC A00E, 16 KiB | Diseños distintos, no una dirección universal. Obtener bitstream/DT activos y su contrato. No probar bases con devmem |
| F02 **VERIFICADO**, P0: plataforma histórica | XSA Trenz/EMP XCZU4EG, Enclustra XCZU4CG; lectores/EMPTools ELF AArch64 | No son evidencia de una instalación Zynq-7000 ni de placa física actual. Confirmar modelo/SoC y toolchain antes de ejecutar |
| F03 **VERIFICADO** / **DESCONOCIDO**, P0: contrato TGC | B01/B02: 12 registros, getters independientes; R04 JSON revisión27 coincide; R06 expone nombre UIO. RTL correspondiente no identificado | Packing, atomicidad, rearme, trigger, efectos y significado físico de header/threshold desconocidos. No llamar frame a nueve palabras |
| F04 **VERIFICADO**, P0: ayuda no inocua | B01 `main()` sin argc/argv, constructor en línea21 | `--help` abre/mapea/lee igual. Usar inspección estática para identificar herramientas |
| F05 **CONTRADICTORIO**, P1: selftest | Catálogo línea108 frente a B04 `do_selftest`:264–273 y ramas de escritura280–282 | La opción sola no escribe en estas fuentes; sí hace MMIO. Su OK no compara contenido. No certificar FE con selftest |
| F06 **VERIFICADO**, P1: observación parcial | B10 `read_lpgbt10.sh`: máscara0xff y bucle sin límite. watch/send_and_read omiten +0x18 e incluyen +0x28 | «No cambia» puede significar solo byte bajo constante; nueve líneas no son nueve grupos. Usar palabras completas y comprobar campos |
| F07 **VERIFICADO**, P1: barrido engañoso | B/sweep_clock.sh:32 escribe +0x2C;36 lee +4;39 sustituye vacío por cero; B/test_saturation.sh usa direcciones fijas | No es medida validada de frecuencia del Si5345, BER ni throughput. Salidas históricas requieren control de errores y build |
| F08 **VERIFICADO** / **INFERIDO**, P1: página Si5345 | B06 `readRegister`:33–35 no selecciona página; `writeRegister`:38–44 sí; postámbulo termina0B24/0B25 | Defecto de selección comprobado en fuente. Lectura de estado incorrecta es condicional a página efectiva distinta; comprobar estado/página/bus con procedimiento aprobado. No raíz del congelamiento demostrada |
| F09 **VERIFICADO**, P1: éxito de CLI insuficiente | B06 main:79–84 atrapa excepción, registra y retorna0. B05 backend UIO:17–40 registra fallo y continúa | Retorno0 no basta para reloj; error/crash de monitor no prueba pérdida óptica. Preservar stderr/logs y procedencia ELF |
| F10 **VERIFICADO** / **INFERIDO**, P1: reboot cambia más que FIFO | B06 unidad systemd ejecuta `clkProgrammer -c` | Reprogramación en boot solo si instalada/activa. Registrar alcance de recuperación; mejora post-reboot no identifica causa |
| F11 **VERIFICADO**, P0: control remoto activo | B07 readRegister escribe registros IC; clearIntr/drain sin límite; readValues[6] sin guardia | `-r` de chip no es inventario pasivo ni lectura de payload. Timeout IRQ no limita toda transacción; evitar usarlo como sonda genérica |
| F12 **VERIFICADO**, P1: ready ≠ progreso | R03 `cdc_rx.vhd`:185–187 sube ready tras strobe; solo reset lo borra; debughub212–246 expone alineación | Ready alto no prueba nuevos datos. Tampoco demuestra que se perdió reloj: observar strobes/progreso reales |
| F13 **VERIFICADO**, P2: versiones duplicadas | CLI PRBS idénticas por bytes, ELF distintos; cuatro fwMonitor/cuatro clkProgrammer distintos. B01 ELF AArch64 y símbolos TGC encontrados | No atribuir cada ELF a fuente por proximidad de carpetas. Faltan manifiestos/recetas exactas; bibliotecas también deben identificarse |
| F14 **CONTRADICTORIO**, P2: publicación | 09_USO_LOCAL:3,45 dice docs/clean; [workflow](../../.github/workflows/guia-pages.yml) dispara y despliega main | Corregir indicación editorial al integrar. No cambiar workflow ni desplegar para resolver adquisición |

Rutas y líneas completas de B/R/X están en el [atlas](TOOL_AND_PATH_ATLAS.md#fuentes-primarias-para-abrir). Las etiquetas de contradicción no implican que dos diseños válidos no puedan coexistir: indican que no se pueden mezclar como una sola build.

## Qué se resolvió al ampliar el respaldo

**VERIFICADO:** 2048 archivos regulares inventariados; fuentes, objetos, bibliotecas, ejecutables, scripts, datos, configuraciones y versiones antiguas separados. Se inspeccionaron nueve XSA externos y diez BSP; los XSA internos aportan dos contenidos adicionales. Sus 16 HWH no aportan módulo TGC/Read_PRBS ni RTL del capturador. Esto delimita una búsqueda, no prueba ausencia de esa lógica en cualquier bitstream externo.

La fuente de `fwMonitor` y `clkProgrammer` está en `emp-tools`; ya no es correcto tratarlas como cajas negras a nivel fuente. La relación exacta con cada ELF sigue sin demostrar. Los ELF principales son AArch64 y sus dependencias están identificadas estáticamente; bibliotecas efectivas del equipo desconocidas. El build de LpGbtSw conserva configuración V1, no prueba versión física del chip actual.

Los overlays cd/dd/direct de main aportan un candidato real a la pareja PRBS/TGC esperada por scripts. Sus propiedades binarias DTBO coinciden con DTSI en los nodos de interés y firmware-name. Eso mejora trazabilidad del Device Tree, pero no identifica packing ni valida el `.bit.bin` como implementación de la clase C++.

**Evidencia histórica limitada:** B/1024 contiene 20 capturas `.txt`, dos versiones de script y una nota `.md`. Las capturas son muestras sin una secuencia temporal/estímulo suficientemente documentada. Tres logs de raíz tienen 340, 290 y 225 líneas respectivamente; cantidad de líneas no equivale a eventos válidos. No se calcula BER ni velocidad de adquisición a partir de ellas.

## Hipótesis de congelamiento y pruebas discriminantes

No existe una causa raíz demostrada. Priorizar por la manifestación actual, no por parecido con una nota antigua.

| Hipótesis / estado | Evidencia que la hace plausible | Prueba mínima que la distingue | Observación que la debilita o refuta |
|---|---|---|---|
| H1 Observación del byte bajo, **INFERIDO** para el fallo | B/read_lpgbt10.sh espera cambio de `&0xff` | Comparar palabras completas de evidencia ya registrada; revisar proceso/script concreto | Los 32 bits y fuente física realmente permanecen constantes: máscara sola no explica el fallo |
| H2 FE constante o ausencia de estímulo, **DESCONOCIDO** | Una palabra puede repetirse legítimamente | Estímulo A/B/A verificado en FE y predicción con plazo | Estímulo llega, cambia en UserData y no llega al registro: localizar después del core |
| H3 Captura retenida/rearme, **INFERIDO** | RTL alternativo R09 contiene FSM esperando envío/lecturas; contrato TGC ausente | Obtener RTL activo; observar dato de entrada, trigger/rearme y AXI en el mismo canal | Si input tampoco progresa, retención no es explicación suficiente del origen detenido |
| H4 Pérdida de progreso core/CDC/reloj, **INFERIDO** | Ready puede retenerse; monitor no expone progreso | Instrumentación existente de reloj/strobe/UserData y estado del enlace antes/después | Progreso sano hasta entrada del capturador mientras AXI queda fijo desplaza frontera hacia captura |
| H5 Proceso/MMIO no termina, **DESCONOCIDO** | AXI sin respuesta puede bloquear; biblioteca no tiene watchdog hardware | Conservar PID/estado/wchan/mapeos/salida; revisión del último acceso con instrumentación, sin otro lector | CLI termina normalmente en tiempo habitual: no hay bloqueo de esa ejecución, aunque datos sean viejos |
| H6 Espera del canal IC, **INFERIDO** si falla lpGbtRegister | clearIntr/drain sin límite y guardia de vector ausente en B07 | Identificar proceso y ruta de control, revisar progreso IRQ/FIFO mediante método aprobado | Falla exclusivamente CLI TGC, que no llama a IC/IRQ: esos bucles no explican su ejecución |
| H7 Otro lector o efectos de lectura, **DESCONOCIDO** | Flags/consumo existen en implementaciones alternativas; procesos concurrentes posibles | Inventario de procesos + coordinación + semántica de IP, ensayo con un lector | Contrato activo no destructivo y exclusividad demostrada debilitan esa explicación |
| H8 Reloj reprogramado al boot, **INFERIDO** | Unidad systemd recuperada llama -c; diagnóstico -i condicionado por página | Comprobar unidad instalada/activa y evidencia de reloj antes/después con método válido | Unidad no activa y reloj estable debilitan ese mecanismo de recuperación; no excluyen otros resets |
| H9 Mapa/build/biblioteca equivocados, **DESCONOCIDO** | Varias familias incompatibles y ELF distintos | Cerrar cadena bitstream–DT–ABI–ELF–dependencias | Identidad y contrato demostrados descartan mezcla conocida, no defectos internos de la build |

**Dos límites al razonamiento desde RTL histórico:**

1. En R09, proceso RX usa `check_bit` con semántica de señal del ciclo previo y `dlFIFO_full_s`; FSM no asigna explícitamente `fsm_state` en reset, espera lecturas y admite una salida alternativa por envío. Son observaciones de esa implementación. No prueban que exista una FIFO bloqueada en el capturador TGC activo.
2. R03 `emp_lpgbt.vhd:731–768` coloca watchdog en una rama que puede quedar sin evaluar mientras FIFO está vacía; el comando recuperado `0x10004` no selecciona ese camino. Además, el FIFO IC tiene reset de transacción en `ic_top.vhd`; una explicación por acumulación indefinida debe comprobar primero ese reset. No trasladar automáticamente estos defectos a payload.

**No demostrable con las capturas actuales:** qué reset curaba el fallo, cuánto duraba la mejoría con configuración constante, si hubo pérdida de reloj, si los grupos pertenecen al mismo frame y si la fuente era externa. Solicitar estas observaciones en lugar de elegir una explicación por plausibilidad.

## Pendientes concretos para el ingeniero

| Puerta | Pieza necesaria | Qué permite decidir |
|---|---|---|
| P0 identidad | Modelo/SoC, bitstream/DTBO cargados, hashes y procedimiento de boot/carga | Qué familia de mapa y herramientas corresponde |
| P0 lectura | RTL/ABI exacto de TGC o interfaz realmente instalada; offsets/efectos/trigger/rearme | Si se puede leer y en qué orden; si los datos se consumen |
| P1 significado | Packing FE→e-link→UserData→grupos/header; firma magic; unidad threshold | Qué significa cada palabra y qué predicción física hacer |
| P1 procedencia | Canal/fibra/e-link y estado efectivo de fuentes, loopback/PRBS, V0/V1, tasas/FEC | Cómo excluir un origen interno |
| P1 fallo | Proceso original, retorno o bloqueo, último dato bueno/primero malo, reset preciso | Qué hipótesis merece la siguiente medida |
| P1 validación | Estímulo externo seguro, instrumento independiente, latencia esperada | Ensayo A/B/A con criterio de refutación |

## Pruebas realizadas y límites de esta entrega

Ejecutado offline en esta revisión:

```bash
# LECTURA PASIVA / pruebas con ejecutables sintéticos, no binarios del respaldo.
python3 -m unittest discover -s docs/recuperacion/diagnostico -p 'test_*.py' -v
```

**Resultado: 18 pruebas aprobadas.** Comprueban parser, validaciones, errores, timeout y persistencia del supervisor en escenarios sintéticos. No reproducen un AXI atascado ni certifican que SIGKILL termine un proceso kernel no interrumpible.

Inspección estática adicional: inventario/hashes del TAR, ELF con file/readelf/nm, fuentes de lectores y bibliotecas, scripts, registros, HWH/XSA/BSP, DTSI y propiedades DTBO, extractos históricos y workflow. No se recompiló adquisición, no se ejecutó firmware ni se conectó hardware. Verificación documental: enlaces/anclas locales, un Mermaid y 15 bloques shell válidos; ocho entregables y 120 minutos comprobados. Estado de continuación en [PROJECT_STATE](PROJECT_STATE.md).

Las evidencias R antiguas merecen una precisión: 15 extractos coinciden con las líneas actuales, aunque sus hashes declarados no coinciden con todos los archivos crudos. Once se explican normalizando el salto de línea final; no se ha cerrado la canonicalización de las cuatro restantes. Esto reduce confianza en esos hashes como identidad de archivo, no invalida extractos comprobados ni demuestra cambios de código.

**Próxima medida experimental que desbloquea el trabajo:** inventario en la placa y enlace verificable entre build activa y contrato de lectura. Hasta entonces, las recomendaciones de MMIO permanecen condicionadas y la recepción externa actual es **DESCONOCIDA**.
