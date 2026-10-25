# Lecturas congeladas: qué sabemos y cómo localizar el fallo

**La causa del bloqueo histórico sigue DESCONOCIDA.** Hay evidencia suficiente para separar varios mecanismos y para evitar reiniciar sin conservar el estado del fallo. La prioridad es distinguir **un comando que no termina** de **un comando que termina mostrando siempre la misma muestra**. Son fallos distintos.

**Instrumento de diagnóstico, 25-10-2026:** [script y procedimientos S0–S4](12_SCRIPT_DIAGNOSTICO.md). Automatiza inventario y conservación de evidencia; las lecturas quedan condicionadas a cerrar la compatibilidad. No implementa ni ejecuta recuperación hardware.

El usuario confirma el 24-10-2026 que el sistema funcionaba un tiempo, dejaba de actualizar valores y volvía a funcionar tras reiniciar. La nota `1028-1031-Testing.md`, líneas 93–96, registra el mismo síntoma. **VERIFICADO / observación histórica escrita**, sin captura de señales ni definición del alcance de «reset». No conocemos aún el ejecutable exacto ni si quedaba bloqueado el proceso, Linux o solamente los valores.

## 1. Separar el síntoma antes de buscar la causa

| Observación durante el fallo | Qué permite concluir | Qué no demuestra |
|---|---|---|
| Cada ejecución devuelve todas las líneas y vuelve al prompt | Esa ejecución terminó sus accesos y su impresión | Que el capturador reciba eventos nuevos, que el dato sea FE o que nueve palabras sean coherentes |
| No vuelve al prompt; una segunda terminal funciona | El sistema operativo sigue atendiendo esa sesión | Que la instrucción bloqueada sea MMIO: puede ser una espera, un bucle, `sudo` o salida a terminal |
| Ninguna sesión responde | Hay una afectación más amplia o un problema de comunicación | Que el origen sea el capturador; distinguir red, CPU, kernel y alimentación mediante consola disponible |
| Solo falla `lpGbtRegister`; el lector payload ya validado sigue funcionando | La ruta de control IC merece investigación separada | Que todo el uplink esté muerto |
| Solo deja de imprimir `read_lpgbt10.sh` | El byte bajo no cambió, falló un acceso o la ejecución se detuvo | Que los 32 bits o el resto de grupos no cambien: el script observa únicamente `& 0xff` |

**INFERIDO:** si la CLI termina repetidamente, un AXI permanentemente sin respuesta durante esas mismas lecturas pierde fuerza como explicación. Puede haber un capturador congelado detrás de un slave AXI perfectamente accesible. Un reset global altera demasiadas piezas para localizar cuál era responsable.

## 2. Hipótesis priorizadas por prueba discriminante

El orden indica utilidad para investigar; no es una probabilidad calculada.

| ID | Mecanismo candidato | Evidencia y alcance | Prueba discriminante / condición para descartarlo |
|---|---|---|---|
| H1 | Captura sin nuevo trigger, contador/enable detenido o FSM sin rearme | **INFERIDO.** Nota 1028–1031 L66–67 liga la captura a una señal interna de envío y a contar relojes. El RTL del capturador de nueve grupos falta. | Si `UserData` cambia y la señal de actualización del registro no, localizar el capturador. Si el registro se actualiza con cada evento documentado, H1 pierde fuerza. Obtener RTL y build antes de programar triggers. |
| H2 | Presentación o criterio de cambio engañoso | **VERIFICADO / estático.** `read_lpgbt10.sh` L5–15 espera solo cambios del byte bajo. `watch_devmem.sh` L22 oculta stderr y L25 no duerme. El sweep convierte salida vacía en cero. | Comparar salida completa, código de salida y stderr del lector existente validado, con el mismo estímulo. Que cambien bits altos refuta «todo está congelado». No introducir una segunda lectura si la primera está bloqueada. |
| H3 | Se pierde reloj, alineación o avance del camino uplink/CDC | **INFERIDO.** Hay dependencia explícita de relojes, strobes y reset en RTL. Los bits de estado no son contadores de muestras. | Captura simultánea antes/después de `uplinkStrobe320`, `lpgbtfpga_uplinkData_320`, `lpgbtfpga_uplinkData_40`, relojes/reset y registro final, si existe instrumentación. Si el camino hasta el registro avanza, buscar presentación. |
| H4 | Acceso AXI sin respuesta, slave en reset o mapa incorrecto | **INFERIDO.** El mapa BD y el de los scripts son incompatibles; `libuio` no valida respuesta funcional antes del acceso. | Un lector que no termina requiere observar bus/CPU; `ARVALID/ARREADY` y `RVALID/RREADY` separan aceptación de dirección y respuesta. Hace falta ILA ya disponible o una futura build autorizada. `Bus error` no es la misma firma que dato repetido. |
| H5 | Control IC atrapado en software | **VERIFICADO / mecanismo condicional.** Dos bucles sin límite en `LpGbtUioFunctions.cpp`; puede no alcanzarse siquiera `waitIntr`. | Solo relevante si el comando fallido usa `LpGbtSw`. Identificar el bucle/estado de IRQ/FIFO. No aplicar esta explicación a la CLI payload, que no llama esas funciones. |
| H6 | FSM de `eLink_Interface_v1` retenida o protocolo de lectura incompleto | **VERIFICADO / mecanismo en una fuente, despliegue DESCONOCIDO.** Hay lectura con efecto lateral y estado no reinicializado explícitamente. | Primero demostrar que esa entidad o su lógica están en la build. Si el capturador activo es otro y no comparte esa FSM, no usar H6 como causa. |
| H7 | Fuente FE o selección de origen dejan de producir el estímulo | **DESCONOCIDO.** No tenemos configuración vigente, reloj FE ni método de estímulo homologado. | Comparación externa A/B/A acompañada de medida eléctrica y configuración efectiva. Un generador interno que cambia no acredita que el FE funcione. |

## 3. Hallazgos nuevos en RTL y software

### F1 — `ready` retenido no es un latido de recepción

**VERIFICADO / estática, R07 y R09.** En `cdc_rx.vhd` L178–191, `ready_b_o` se pone a cero durante `reset_a_strobe_sync` y a uno después de un `strobe_a_r`. No hay rama que lo vuelva a cero solo porque dejen de aparecer strobes. El reloj A detenido tampoco puede ejecutar ese proceso. La captura intermedia sigue un contador de fase; no se habilita exclusivamente por cada strobe válido. El módulo exige relojes relacionados por un factor entero (L36–39), no es una FIFO asíncrona genérica.

**Límite adversarial:** el wrapper conecta `cdc_uplink_reset <= not uplinkReady_s`; una pérdida del `ready` del core puede resetear el CDC. Por tanto, no se afirma que siempre mantenga `ready=1` al perder enlace. El contraejemplo válido es «ausencia de strobe sin reset efectivo»; comprobar si puede ocurrir en la build y relojes reales. `fwMonitor` ni siquiera imprime este `cdc_rx_ready`: `RX locked` corresponde a la cabecera. No confundir ambos indicadores.

**Consecuencia práctica:** un bit de estado a uno no exonera la cadena de captura. Registrar simultáneamente progreso y datos, no solamente niveles.

### F2 — `eLink_Interface_v1` puede retener estado; leer tiene efectos

**VERIFICADO / estática, R08. Esta entidad NO está instanciada en el BD recuperado.** No es prueba del capturador `tgc_readUplink_regs` de nueve grupos.

- La FSM sale de `idle` al escribir downlink (L268–272). No es un receptor autónomo continuo.
- En `waiting_resp`, `or rx_out` determina respuesta válida, sin consultar `ulFIFO_empty_s` en esa decisión (L278–293). Un payload de ceros no se acepta como respuesta. La semántica de `dout` con FIFO vacía requiere inspeccionar la IP concreta; no suponemos que sea nueva información.
- Al leer cada grupo se borra su valor y su bit `regStatus` (L295–318). Omitir un grupo impide completar esa condición; existe una salida alternativa por nueva escritura downlink (L319–324). **No es un bloqueo inevitable ni necesariamente irrecuperable.**
- El reset limpia `regStatus`, `intr`, `TX_WrEN` y `tx_in`, pero no asigna `fsm_state <= idle` (L259–265). La inicialización declarativa `:= idle` no equivale a ejecutar esa asignación ante cada reset. Si el estado era `waiting_resp`, un reset por ese puerto no lo fuerza a `idle`.
- La escritura RX usa `dlFIFO_full_s`, el flag de la FIFO TX (L243–246), y no el de RX; `check_bit` se evalúa con el valor del ciclo anterior porque es una señal VHDL. Debe verificarse la intención de diseño.
- `rd_en => '1'` en RX (L355–368) consume continuamente, mientras la FSM solo conserva una respuesta. No garantiza una captura por evento ni ausencia de pérdidas.

**INFERIDO:** una reconfiguración completa puede restaurar un estado que un reset parcial no restablece. Esto es compatible con algunas formas de «reiniciar lo arregla», pero requiere demostrar entidad activa y alcance del reinicio. No se prescribe escribir un ACK: `ctrlACK_s` se conecta al mapa y no se usa en las transiciones mostradas.

### F3 — Un timeout IC no limita la operación completa

**VERIFICADO / estática, B06 y B10.** `readRegister()` limpia IRQ, la habilita, envía `0x10004`, espera IRQ y vacía FIFO. `clearIntr()` L221–230 puede repetir indefinidamente mientras el flag no se limpie. `readICRxFifo()` L109–125 repite hasta que `empty` se active y añade elementos a un vector sin límite de tamaño. Cada vuelta hace MMIO; si el estado nunca progresa, puede consumir CPU/memoria. `waitIntr(...,1)` no limita ninguno de esos dos bucles.

Una respuesta corta lleva además a `readValues[6]` sin comprobar longitud. El resultado es comportamiento indefinido, no un error bien diagnosticado. El timeout provoca excepción; no afirmar que siempre continúa después de expirar.

**Separación crucial:** la CLI de payload lee registros directamente y no espera IRQ. Añadir polling de IRQ a esa CLI no está justificado por estos hallazgos. `read()` sobre `/dev/uioN` espera un evento de interrupción; no equivale a leer el payload mapeado [K1].

### F4 — Watchdog de la FSM IC con prioridad problemática

**VERIFICADO / estática, R10.** En `reading_FIFO` de `emp_lpgbt.vhd` L731–768, el contador se decrementa antes del `if`. Si `status_empty_flag='1'`, siempre se toma la primera rama y se omite el `elsif lpgbt_resp_timeout = 0`. Con FIFO permanentemente vacía, el cero no conduce a `finish`; la siguiente resta sale del rango declarado `0 to 100000000`. Un simulador con chequeo de rango debe denunciarlo. No predecimos cómo se manifiesta el circuito sintetizado sin informes y simulación de esa build.

**Límite que reduce su prioridad:** el control `0x10004` usado por `LpGbtSw` deja el bit 4 (`single_write_read`) en cero, según `emp_lpgbt_ic_clerk_regs_pkg.vhd` L94–100. Selecciona la ruta de gestión por PS, no esta FSM de operación única. Por tanto, este defecto no explica directamente las llamadas recuperadas de `readRegister()` y tampoco el payload FE.

### F5 — Hipótesis de acumulación IC descartada en su forma simple

`ic_rx_fifo.vhd` incrementa punteros sin wrap ni control de lleno (L96–108), pero `ic_top.vhd` L206–217 resetea RX cuando inicia una lectura o escritura. **VERIFICADO / estática, R11.** No se puede deducir «se llena después de muchas transacciones correctas» ignorando ese reset. Queda por validar longitud máxima por transacción, CDC de punteros y tráfico anómalo; eso es una investigación diferente.

### F6 — Nombre de reset engañoso, no inversión demostrada

El puerto del core se llama `uplinkRst_n_i`, pero el código modificado asigna directamente `rst_pattsearch_s <= uplinkRst_n_i` (L263) y el wrapper entrega `reset_general` por esa cadena. **VERIFICADO / estática, R09/R10.** El nombre heredado no basta para diagnosticar una inversión de polaridad ni para proponer un parche. Seguir la lógica efectiva hasta su consumidor.

## 4. Procedimiento F0 — conservar el fallo sin tocar MMIO

**Objetivo:** determinar qué se congeló y conservar evidencia antes de cualquier reinicio.

**Condiciones previas:** una sesión Linux aún operativa. No iniciar nuevas herramientas hardware si otra está atascada. Estos comandos son **propuesta diagnóstica Linux**, no comandos históricos del experimento. Comprobar disponibilidad y permisos; si fallan, conservar el error.

```bash
# Terminal de diagnóstico; no ejecuta devmem ni abre /dev/uioN.
date -u '+%Y-%m-%dT%H:%M:%SZ'
cat /proc/uptime
uname -a
ps -eo pid,ppid,stat,etime,time,wchan:24,comm
# Si ps no soporta estas opciones, usar: ps
```

Seleccionar manualmente el PID del proceso que ya estaba ejecutándose; no inferirlo de `uioN`:

```bash
printf 'PID del proceso detenido: '
read -r pid
case "$pid" in
  ''|*[!0-9]*) printf 'PID no válido\n' ;;
  *)
    for f in status wchan syscall; do
      printf '\n--- /proc/%s/%s ---\n' "$pid" "$f"
      cat "/proc/$pid/$f"
    done
    readlink "/proc/$pid/exe"
    ;;
esac
# Si está permitido; no cambiar permisos del sistema para obtenerlo:
dmesg | tail -n 100
```

**Qué hacen:** consultan estado del kernel, procesos, ejecutable y mensajes. No leen registros del dispositivo. `/proc/PID/syscall` puede fallar por permisos o mostrar `running`; no traduce el PC a una línea de código ni demuestra MMIO. `D` o un `wchan` particular son pistas, no diagnóstico AXI definitivo [K2].

**Resultado esperado:** timestamp, uptime y estado del proceso fallido. Si el proceso ya terminó, conservar salida completa, stderr y código de salida de esa ejecución, sin repetirla para recrear el fallo.

**Alternativas:** si Linux no responde, usar la consola ya disponible al ingeniero para observar, sin inducir reset desde esta guía. Si tampoco existe acceso, registrar último instante operativo y alcance de la pérdida de respuesta.

**Riesgos:** los logs pueden contener identificadores internos; revisar antes de compartir. La inspección usa CPU y puede alterar marginalmente la temporización. No contiene escritura hardware intencional.

**Siguiente decisión:** comando completo con datos repetidos → F1; comando sin finalizar → analizar ejecutable/bucle/acceso antes de nuevos sondeos. No usar `timeout` como protección eléctrica: envía señales a procesos y no garantiza completar o abortar una transacción del interconnect [K3].

**Intento de refutación:** un programa que no imprime puede estar esperando entrada o salida, no al FPGA. No equiparar ausencia de texto con acceso bloqueado. `strace` no observa cada carga `volatile` como syscall y adjuntarlo modifica la temporización; no es la prueba inicial prescrita.

## 5. Procedimiento F1 — demostrar repetición sin confundirla con falta de datos

**Objetivo:** comparar dos lecturas completas y el estímulo registrado.

**Condiciones previas:** todas las condiciones de [P0 etapa C](00_GUIA_CAMPO.md#etapa-c--consultar-los-datos-expuestos-por-la-fpga), mapa y semántica validados, lecturas ya autorizadas, ausencia de proceso hardware bloqueado. Un solo operador/lector. `LECTOR` debe contener la ruta absoluta del ejecutable identificado; no usar el nombre de otro binario como sustituto.

```bash
# Propuesta de envoltorio de registro; LECTOR se fija con la ruta validada en A2.
# Ejecutar desde un directorio nuevo de la sesión para no sobrescribir evidencia.
date -u '+ANTES %Y-%m-%dT%H:%M:%SZ'
"$LECTOR" > muestra_A.out 2> muestra_A.err
rc=$?
printf 'RC=%s\n' "$rc"
date -u '+DESPUES %Y-%m-%dT%H:%M:%SZ'
cat muestra_A.out
cat muestra_A.err
```

**Qué hace:** ejecuta el lector existente una sola vez, separa sus flujos de salida y registra si retorna. Si no retorna, detener el procedimiento; no lanzar la muestra B. No modifica intencionalmente registros si el ejecutable y su semántica son los verificados en P0; una lectura con efecto lateral sigue siendo un riesgo.

**Resultado esperado:** todas las etiquetas `data_group_0` a `data_group_8`, `data_header`, `clk_thresh` y `magic`, o la salida específica del ejecutable realmente validado. Después de un estímulo externo documentado, repetir manualmente el envoltorio con nombres `muestra_B.*`, preservando A. Usar el comparador local de la web o `diff -u muestra_A.out muestra_B.out`.

**Alternativas:** diferencias solo en bits altos explican un script que espera cambios del byte bajo. Nueve palabras iguales pueden representar muestras nuevas idénticas; sin contador/trigger verificable no prueban bloqueo. Palabras diferentes tampoco prueban coherencia ni origen FE. Una línea faltante es una lectura incompleta, no cero.

**Riesgos:** MMIO condicionado; dos lectores pueden consumir datos o interferir. Los timestamps son tiempos de software, no timestamps del frame. No barrer `clk_thresh`, no escribir patrones internos ni recargar firmware para esta comparación.

**Siguiente decisión:** si A/B no responde al cambio externo verificado, solicitar captura simultánea del límite `UserData`→capturador. Si el FE no tiene estímulo homologado, el resultado permanece inconcluso.

**Intento de refutación:** confirmar que el patrón alcanzó físicamente el e-link y que no se sigue observando loopback. Una comparación local de textos no resuelve esto.

## 6. Qué conservar antes de una recuperación autorizada

Registrar qué significa exactamente «reiniciar»: nuevo proceso, reset de capturador, reset de `emp_lpgbt`, MGT, reconfiguración PL, reboot de PS o corte completo de alimentación. Esas acciones no tienen el mismo alcance. No ejecutar una secuencia de resets exploratorios desde este documento.

Conservar: build/DTBO/ELF y hashes; configuración FE/lpGBT; tiempo desde arranque y número de transacciones; última lectura buena y primera mala; salida y retorno de la aplicación; observaciones de enlace obtenidas bajo las condiciones ya validadas; alcance exacto de recuperación. Repetir el ensayo controlado al menos tres veces si es viable, manteniendo la misma configuración. **No hay tiempos observados suficientes para deducir un overflow periódico.**

Si existe una ILA en la build, pedir captura de `uplinkStrobe320`, `lpgbtfpga_uplinkData_320`, `lpgbtfpga_uplinkData_40`, `cdc_rx_ready`, reset/enable del capturador y sus señales de actualización, junto con AXI AR/R. Verificar los nombres en esa build. Una ILA nueva implica otra build y autorización; no se ha creado ni cargado aquí.

## 7. Evidencia reproducible y límites

`analisis/contraejemplos.py` reproduce en Python **fragmentos de transición extraídos del RTL**, con precondiciones artificiales explícitas: ready sin strobe, reset sin cambiar FSM, lectura parcial y prioridad del watchdog. No compila ni simula el diseño VHDL completo, no incluye temporización física, y no prueba la causa histórica. La salida esperada está en `analisis/resultado_contraejemplos.json`.

Fuentes del repositorio fijadas a `c02a33b645dc70fb4076add25b78c5246589676e`; extractos numerados R07–R12 y B10–B11 disponibles offline en la web y en `evidencias.json`. No se ha corregido el firmware ni el tooling original.

Referencias de sistema operativo, consultadas el 24-10-2026:

- [K1 — Linux UIO HOWTO](https://docs.kernel.org/driver-api/uio-howto.html): separación entre mmap, eventos IRQ y atributos sysfs.
- [K2 — Linux, /proc](https://docs.kernel.org/filesystems/proc.html): estado de procesos y límites de observación.
- [K3 — GNU timeout](https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html): límite mediante señales, no watchdog AXI.
