# Lecturas congeladas: qué sabemos y cómo localizar el fallo

Todavía no sabemos por qué se bloqueaban las lecturas. Sí sabemos lo suficiente para separar varios mecanismos y para no reiniciar sin guardar antes el estado del fallo. Lo primero es distinguir dos fallos diferentes: un comando que no termina, y un comando que termina pero muestra siempre la misma muestra.

Desde el 25-10-2026 hay un [script con los procedimientos S0–S4](12_SCRIPT_DIAGNOSTICO.md). Hace el inventario y guarda la evidencia; las lecturas esperan a que se confirme la compatibilidad. No reinicia ni recupera nada.

El 24-10-2026 el usuario confirmó que el sistema funcionaba un rato, dejaba de actualizar valores y volvía a funcionar al reiniciar. La nota `1028-1031-Testing.md`, líneas 93–96, cuenta lo mismo. Es una observación escrita, sin captura de señales y sin decir qué se reiniciaba. No sabemos qué ejecutable era ni si se colgaba el proceso, Linux o solo los valores.

## 1. Separar el síntoma antes de buscar la causa

| Qué ves durante el fallo | Qué puedes concluir | Qué no puedes concluir |
|---|---|---|
| Cada ejecución imprime todas las líneas y vuelve al prompt | Esa ejecución terminó sus accesos e imprimió | Que el capturador reciba eventos nuevos, que el dato sea del FE o que las nueve palabras sean coherentes |
| No vuelve al prompt, pero otra terminal funciona | Linux sigue atendiendo | Que lo bloqueado sea MMIO; puede ser una espera, un bucle, `sudo` o la salida a la terminal |
| No responde ninguna sesión | El problema es más amplio, o es de comunicación | Que venga del capturador; hay que separar red, CPU, kernel y alimentación con la consola que haya |
| Solo falla `lpGbtRegister` y el lector de payload validado sigue bien | La ruta de control IC merece mirarse aparte | Que el uplink entero esté muerto |
| Solo deja de imprimir `read_lpgbt10.sh` | No cambió el byte bajo, falló un acceso o se detuvo la ejecución | Que no cambien los 32 bits u otros grupos: el script solo mira `& 0xff` |

Si la CLI termina una y otra vez, es poco probable que AXI esté sin responder en esas mismas lecturas. Puede haber un capturador congelado detrás de un slave AXI que responde bien. Y un reset global toca tantas piezas que no dice cuál fallaba.

## 2. Hipótesis priorizadas por prueba discriminante

El orden es por utilidad para investigar, no por probabilidad.

| ID | Mecanismo | Qué hay y hasta dónde llega | Cómo comprobarlo o descartarlo |
|---|---|---|---|
| H1 | Captura sin trigger nuevo, contador o enable detenido, o FSM sin rearme | INFERIDO. La nota 1028–1031 (L66–67) liga la captura a una señal interna de envío y a contar relojes. Falta el RTL del capturador de nueve grupos. | Si `UserData` cambia y la señal de actualización del registro no, el problema está en el capturador. Si el registro se actualiza con cada evento documentado, H1 pierde peso. Consigue el RTL y la build antes de programar triggers. |
| H2 | La forma de mostrar o de detectar cambios engaña | Comprobado en el código. `read_lpgbt10.sh` (L5–15) solo espera cambios del byte bajo. `watch_devmem.sh` oculta stderr (L22) y no duerme (L25). El sweep convierte una salida vacía en cero. | Compara la salida completa, el código de salida y stderr del lector validado, con el mismo estímulo. Si cambian bits altos, no está «todo congelado». No lances una segunda lectura si la primera está bloqueada. |
| H3 | Se pierde reloj, alineación o avance en el uplink o el CDC | INFERIDO. El RTL depende de relojes, strobes y reset. Los bits de estado no cuentan muestras. | Captura a la vez `uplinkStrobe320`, `lpgbtfpga_uplinkData_320`, `lpgbtfpga_uplinkData_40`, relojes, reset y registro final, si hay instrumentación. Si el camino avanza hasta el registro, el problema está en cómo se muestra. |
| H4 | AXI sin respuesta, slave en reset o mapa equivocado | INFERIDO. El mapa del BD y el de los scripts no encajan, y `libuio` no comprueba la respuesta antes de acceder. | Si el lector no termina, hay que mirar bus y CPU: `ARVALID/ARREADY` y `RVALID/RREADY` separan la dirección aceptada de la respuesta. Hace falta un ILA ya existente o una build futura autorizada. Un `Bus error` no se parece a un dato repetido. |
| H5 | El control IC se queda atrapado en el software | Comprobado en el código, en ciertas condiciones. Hay dos bucles sin límite en `LpGbtUioFunctions.cpp`, y puede que ni se llegue a `waitIntr`. | Solo aplica si el comando que falló usa `LpGbtSw`. Mira en qué bucle está y el estado de IRQ y FIFO. La CLI de payload no llama a esas funciones. |
| H6 | La FSM de `eLink_Interface_v1` se queda retenida o el protocolo de lectura queda a medias | El mecanismo está en una fuente; no sabemos si está montada. Leer tiene efectos y hay un estado que el reset no reinicia. | Primero demuestra que esa entidad o su lógica están en la build. Si el capturador es otro y no comparte esa FSM, H6 no es la causa. |
| H7 | El FE o la fuente seleccionada dejan de producir el estímulo | DESCONOCIDO. No hay configuración en uso, reloj del FE ni método de estímulo aprobado. | A/B/A externo con medida eléctrica y la configuración en uso. Que cambie un generador interno no prueba que el FE funcione. |

## 3. Hallazgos nuevos en RTL y software

### F1. `ready` retenido no es un latido de recepción

Comprobado en el código (R07, R09). En `cdc_rx.vhd` L178–191, `ready_b_o` baja durante `reset_a_strobe_sync` y sube tras un `strobe_a_r`. No hay nada que lo baje solo porque dejen de llegar strobes, y con el reloj A parado ese proceso tampoco corre. La captura intermedia sigue un contador de fase, no cada strobe válido. El módulo necesita relojes relacionados por un factor entero (L36–39); no es una FIFO asíncrona cualquiera.

Pero el wrapper hace `cdc_uplink_reset <= not uplinkReady_s`, así que si el core pierde su ready, el CDC se resetea. Por eso no se puede decir que `ready` se quede siempre en 1 al perder el enlace. El caso que sí vale es «no llegan strobes y no hay reset»; hay que ver si eso puede pasar con la build y los relojes reales. Además, `fwMonitor` ni siquiera muestra `cdc_rx_ready`: su `RX locked` es la cabecera.

En la práctica, un bit de estado en 1 no libra de culpa a la cadena de captura. Registra a la vez el progreso y los datos, no solo niveles.

### F2. `eLink_Interface_v1` puede retener estado y leer tiene efectos

Comprobado en el código (R08). Esta entidad no está en el BD recuperado, así que esto no prueba nada sobre el capturador `tgc_readUplink_regs` de nueve grupos.

- La FSM sale de `idle` cuando se escribe en el downlink (L268–272). No recibe de forma continua por su cuenta.
- En `waiting_resp`, la respuesta se da por válida con `or rx_out`, sin mirar `ulFIFO_empty_s` (L278–293). Un payload de ceros no cuenta como respuesta. Qué devuelve `dout` con la FIFO vacía depende de la IP concreta; no lo damos por información nueva.
- Leer cada grupo borra su valor y su bit de `regStatus` (L295–318). Si se salta un grupo, esa condición no se completa, aunque hay una salida alternativa con otra escritura downlink (L319–324). No es un bloqueo inevitable ni necesariamente permanente.
- El reset limpia `regStatus`, `intr`, `TX_WrEN` y `tx_in`, pero no pone `fsm_state <= idle` (L259–265). El `:= idle` de la declaración no se aplica en cada reset. Si estaba en `waiting_resp`, un reset por ese puerto no la devuelve a `idle`.
- La escritura en RX usa `dlFIFO_full_s`, que es el flag de la FIFO TX (L243–246), no el de RX. Y `check_bit` se evalúa con el valor del ciclo anterior porque es una señal VHDL. Hay que confirmar si era intencional.
- `rd_en => '1'` en RX (L355–368) vacía la FIFO todo el rato, mientras la FSM guarda una sola respuesta. No garantiza una captura por evento ni que no se pierdan datos.

Una reconfiguración completa puede arreglar un estado que un reset parcial no arregla. Eso encaja con algunos «reiniciar lo arregla», pero hay que probar que la entidad está montada y qué se reinicia. No se recomienda escribir un ACK: `ctrlACK_s` está en el mapa pero no se usa en las transiciones.

### F3. Un timeout IC no limita la operación completa

Comprobado en el código (B06, B10). `readRegister()` limpia la IRQ, la habilita, manda `0x10004`, espera la IRQ y vacía la FIFO. `clearIntr()` (L221–230) puede repetirse para siempre si el flag no se limpia. `readICRxFifo()` (L109–125) repite hasta que se active `empty` y va llenando un vector sin límite. Cada vuelta hace MMIO, así que si el estado no avanza puede comerse CPU y memoria. `waitIntr(...,1)` no corta ninguno de esos dos bucles.

Además, una respuesta corta lleva a leer `readValues[6]` sin comprobar la longitud. Eso es comportamiento indefinido, no un error bien informado. El timeout lanza una excepción, así que no se puede decir que el programa siga siempre después.

Lo importante: la CLI de payload lee los registros directamente y no espera IRQ. Nada de esto justifica añadirle polling de IRQ. Un `read()` sobre `/dev/uioN` espera una interrupción; no lee el payload mapeado [K1].

### F4. El watchdog de la FSM IC tiene la prioridad mal puesta

Comprobado en el código (R10). En `reading_FIFO` de `emp_lpgbt.vhd` (L731–768), el contador se decrementa antes del `if`. Si `status_empty_flag='1'`, siempre entra en la primera rama y nunca llega al `elsif lpgbt_resp_timeout = 0`. Con la FIFO siempre vacía, llegar a cero no lleva a `finish`, y la siguiente resta se sale del rango `0 to 100000000`. Un simulador que compruebe rangos debería avisar. Sin los informes y la simulación de esa build no podemos decir qué hace el circuito sintetizado.

Esto pesa menos de lo que parece. El control `0x10004` que usa `LpGbtSw` deja en cero el bit 4 (`single_write_read`), según `emp_lpgbt_ic_clerk_regs_pkg.vhd` L94–100. Eso elige la ruta gestionada por el PS, no esta FSM de operación única. Así que este defecto no explica las llamadas a `readRegister()` recuperadas, ni tampoco el payload del FE.

### F5. La idea de que la FIFO IC se va llenando no se sostiene

`ic_rx_fifo.vhd` avanza los punteros sin dar la vuelta ni controlar si está llena (L96–108), pero `ic_top.vhd` (L206–217) resetea RX cada vez que empieza una lectura o escritura. Comprobado en el código (R11). Por eso no se puede decir que «se llena después de muchas transacciones correctas». Quedan por mirar la longitud máxima de una transacción, el CDC de los punteros y el tráfico anómalo, pero eso es otra investigación.

### F6. Un nombre de reset engañoso, sin inversión demostrada

El puerto del core se llama `uplinkRst_n_i`, pero el código modificado hace directamente `rst_pattsearch_s <= uplinkRst_n_i` (L263), y el wrapper le pasa `reset_general` por esa cadena. Comprobado en el código (R09, R10). El nombre heredado no basta para decir que la polaridad está invertida ni para proponer un parche. Sigue la señal hasta donde se usa.

## 4. F0: guardar el fallo sin tocar MMIO

Objetivo: ver qué se congeló y guardar la evidencia antes de cualquier reinicio.

Necesitas una sesión Linux que todavía responda. No abras más herramientas de hardware si hay otra atascada. Estos comandos son una propuesta para diagnosticar, no comandos del experimento original. Si fallan por permisos o porque no existen, guarda el error.

```bash
# Terminal de diagnóstico; no ejecuta devmem ni abre /dev/uioN.
date -u '+%Y-%m-%dT%H:%M:%SZ'
cat /proc/uptime
uname -a
ps -eo pid,ppid,stat,etime,time,wchan:24,comm
# Si ps no soporta estas opciones, usar: ps
```

Elige a mano el PID del proceso que ya estaba corriendo; no lo deduzcas de `uioN`:

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

Leen el estado del kernel, los procesos, el ejecutable y los mensajes, sin tocar registros del dispositivo. `/proc/PID/syscall` puede fallar por permisos o decir `running`; no traduce el PC a una línea de código ni prueba que haya MMIO. Un estado `D` o un `wchan` concreto son pistas, no un diagnóstico de AXI [K2].

Deberías obtener la hora, el uptime y el estado del proceso que falló. Si el proceso ya terminó, guarda su salida completa, stderr y el código de salida, sin repetirlo para provocar el fallo otra vez.

Si Linux no responde, usa la consola que tenga el ingeniero para mirar, sin forzar un reset desde esta guía. Si tampoco hay acceso, anota el último momento en que respondía y qué dejó de responder.

Los logs pueden tener identificadores internos; revísalos antes de compartirlos. Mirar consume algo de CPU y puede cambiar un poco los tiempos. No se escribe nada en el hardware.

Después: si el comando terminó con datos repetidos, sigue con F1. Si no terminó, estudia el ejecutable, el bucle o el acceso antes de volver a leer. `timeout` no protege el hardware: manda señales al proceso y no asegura que una transacción del interconnect termine o se corte [K3].

Ojo: un programa que no imprime puede estar esperando entrada o salida, no a la FPGA. Que no haya texto no significa que un acceso esté bloqueado. `strace` no ve cada lectura `volatile` como syscall y además cambia los tiempos, así que no es la primera prueba.

## 5. F1: comprobar si se repite, sin confundirlo con que no hay datos

Objetivo: comparar dos lecturas completas junto con el estímulo anotado.

Necesitas todas las condiciones de [P0, etapa C](00_GUIA_CAMPO.md#etapa-c-leer-los-datos-expuestos-por-la-fpga): mapa y efectos confirmados, lecturas autorizadas y ningún proceso de hardware bloqueado. Un solo operador y un solo lector. `LECTOR` tiene que ser la ruta absoluta del ejecutable identificado, no el nombre de otro binario.

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

Corre el lector una vez, separa la salida normal de los errores y anota si vuelve. Si no vuelve, para aquí y no lances la muestra B. Si el ejecutable y lo que hace son los confirmados en P0, no debería cambiar registros, aunque una lectura con efectos sigue siendo un riesgo.

Deberías ver `data_group_0` a `data_group_8`, `data_header`, `clk_thresh` y `magic`, o lo que imprima el ejecutable validado. Después de un estímulo externo documentado, repite con los nombres `muestra_B.*` sin pisar A. Compara con el comparador de la web o con `diff -u muestra_A.out muestra_B.out`.

Si solo cambian bits altos, eso explica que un script que mira el byte bajo no viera nada. Nueve palabras iguales pueden ser muestras nuevas idénticas: sin contador ni trigger comprobable no prueban un bloqueo. Palabras distintas tampoco prueban coherencia ni que vengan del FE. Una línea que falta es una lectura incompleta, no un cero.

Es MMIO con condiciones, y dos lectores a la vez pueden comerse datos o estorbarse. Las horas son del software, no del frame. No barras `clk_thresh`, no escribas patrones internos y no recargues firmware para esta comparación.

Si A y B no siguen un cambio externo comprobado, pide una captura simultánea en el paso `UserData`→capturador. Si el FE no tiene un estímulo aprobado, el resultado queda sin decidir.

Ojo: confirma que el patrón llegó de verdad al e-link y que no sigues viendo un loopback. Comparar textos no resuelve eso.

## 6. Qué guardar antes de una recuperación autorizada

Anota qué significa exactamente «reiniciar»: un proceso nuevo, reset del capturador, de `emp_lpgbt` o del MGT, reconfigurar el PL, reiniciar el PS o cortar la alimentación. No es lo mismo. No hagas una ronda de resets a ver qué pasa.

Guarda: build, DTBO y ELF con sus hashes; configuración del FE y del lpGBT; tiempo desde el arranque y número de transacciones; la última lectura buena y la primera mala; salida y retorno de la aplicación; las observaciones del enlace hechas con las condiciones ya validadas; y qué se reinició exactamente. Si se puede, repite el ensayo al menos tres veces con la misma configuración. No hay tiempos suficientes para hablar de un overflow periódico.

Si la build tiene un ILA, pide capturar `uplinkStrobe320`, `lpgbtfpga_uplinkData_320`, `lpgbtfpga_uplinkData_40`, `cdc_rx_ready`, el reset y el enable del capturador y sus señales de actualización, junto con AXI AR/R. Comprueba los nombres en esa build. Un ILA nuevo es otra build y necesita autorización; aquí no se creó ni se cargó ninguno.

## 7. Evidencia reproducible y límites

`analisis/contraejemplos.py` reproduce en Python trozos de transiciones sacados del RTL, con condiciones de partida puestas a propósito: ready sin strobe, reset que no cambia la FSM, lectura parcial y prioridad del watchdog. No compila ni simula el VHDL completo, no tiene tiempos físicos y no prueba la causa original. La salida esperada está en `analisis/resultado_contraejemplos.json`.

Las fuentes del repositorio están fijadas en `c02a33b645dc70fb4076add25b78c5246589676e`. Los extractos numerados R07–R12 y B10–B11 están en la web y en `evidencias.json`. No se corrigió ni el firmware ni las herramientas originales.

Referencias del sistema operativo, consultadas el 24-10-2026:

- [K1, Linux UIO HOWTO](https://docs.kernel.org/driver-api/uio-howto.html): diferencia entre mmap, eventos IRQ y atributos sysfs.
- [K2, Linux /proc](https://docs.kernel.org/filesystems/proc.html): estado de los procesos y lo que se puede ver.
- [K3, GNU timeout](https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html): corta con señales; no es un watchdog de AXI.
