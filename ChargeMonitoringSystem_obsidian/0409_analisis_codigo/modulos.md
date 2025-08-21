## 1. Módulo TCP_COM (tcp_com.c / tcp_com.h)

### 1.1 Descripción General

El módulo **tcp_com** se encarga de gestionar la comunicación TCP mediante lwIP. Entre sus principales responsabilidades se encuentran:

- Inicialización del servidor TCP en un puerto definido (PORT 6543).
- Aceptar conexiones entrantes mediante callbacks.
- Gestionar la transmisión de grandes volúmenes de datos en trozos, comprobando la capacidad del buffer de envío TCP (tcp_sndbuf).
- Proveer funciones auxiliares para empaquetar (packer) y formatear los datos que se desean enviar (por ejemplo, utilizando una tabla de datos generada aleatoriamente).

### 1.2 Variables Globales y Definiciones

- `Char_per_line`: Número máximo de caracteres por línea (46).
- `PBUF_LENGTH`: Longitud del buffer de pbuf, definido como 50000.
- `buffer_length`: Tamaño del buffer principal para los datos a transmitir (49900).
- `N_lines`: Número de líneas calculado a partir del buffer.
- `unsigned char buffer[buffer_length]`: Buffer global para datos formateados.
- `flag_accept_conn`, `flag_ready2sent`, `flag_senddata`, `flag_tcp_done`: Flags de control para la comunicación.
- `static struct tcp_pcb *pcb`: Puntero a la estructura de control de la conexión TCP.
- `int *datos_PL`: Puntero a los datos (tabla de enteros) que se usarán para empaquetar y enviar información.

### 1.3 Funciones

#### 1.3.1 `rand_data()`

**Descripción:**  
Genera datos aleatorios para rellenar la matriz `datos_PL`. Se reserva memoria para 1017*9 enteros y se asignan valores aleatorios en el rango [1950, 2050].

**Formato NumPy-style (para C):**

```c
/**
 * rand_data
 *
 * Genera datos aleatorios para la variable global "datos_PL".
 *
 * No recibe parámetros.
 *
 * Ejemplo:
 *     rand_data();
 *
 * Nota: Se reserva memoria para 1017*9 enteros.
 */
void rand_data();
```

#### 1.3.2 `packer()`

**Descripción:**  
Empaqueta los datos contenidos en `datos_PL` en un buffer global `buffer`, formateando 9 enteros por línea con separación por tabulaciones. Utiliza una longitud fija de caracteres por línea definida por `Char_per_line`.

**Formato:**

```c
/**
 * packer
 *
 * Empaqueta la información de "datos_PL" en el buffer global "buffer".
 *
 * El buffer se llena con líneas formateadas a partir de 9 enteros por línea.
 *
 * No recibe parámetros.
 */
void packer();
```

#### 1.3.3 `hash(unsigned char *str)`

**Descripción:**  
Implementa el algoritmo djb2 para calcular un valor hash a partir de una cadena.

**Formato:**

```c
/**
 * hash
 *
 * Calcula el valor hash de la cadena dada utilizando el algoritmo djb2.
 *
 * Parameters
 * ----------
 * str : unsigned char*
 *     Cadena de caracteres a hashear.
 *
 * Returns
 * -------
 * unsigned long
 *     Valor hash calculado.
 */
unsigned long hash(unsigned char *str);
```

#### 1.3.4 `print_ip` y `print_ip_settings`

**Descripción:**  
Funciones auxiliares para imprimir direcciones IP utilizando `xil_printf`.

```c
/**
 * print_ip
 *
 * Imprime una dirección IP precedida de un mensaje.
 *
 * Parameters
 * ----------
 * msg : char*
 *     Mensaje a imprimir.
 * ip : ip_addr_t*
 *     Dirección IP a imprimir.
 */
void print_ip(char *msg, ip_addr_t *ip);

/**
 * print_ip_settings
 *
 * Imprime la configuración de la red (IP, máscara y gateway).
 *
 * Parameters
 * ----------
 * ip : ip_addr_t*
 *     Dirección IP.
 * mask : ip_addr_t*
 *     Máscara de subred.
 * gw : ip_addr_t*
 *     Gateway.
 */
void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw);
```

#### 1.3.5 `transfer_data()` y `transfer_data_bkup()`

**transfer_data_bkup() (versión de respaldo):**  
Utiliza la estructura pbuf para enviar el contenido del buffer global de una sola vez.

**transfer_data():**  
La función principal para enviar datos grandes. Divide el contenido del buffer en fragmentos según el espacio disponible en el buffer de envío TCP (tcp_sndbuf) y envía los datos en un bucle. Una vez finalizado el envío de los datos principales, añade una secuencia final (`"!#\n"`) para marcar el fin de la transmisión.

```c
/**
 * transfer_data
 *
 * Envía el contenido del buffer global a través de la conexión TCP.
 * Divide el buffer en paquetes si el espacio en tcp_sndbuf es insuficiente.
 *
 * Parameters
 * ----------
 * buffer : unsigned char*
 *     Buffer de datos a enviar.
 *
 * Returns
 * -------
 * int
 *     0 si la operación fue exitosa.
 */
int transfer_data(unsigned char *buffer);
```

#### 1.3.6 Funciones de Gestión del Servidor TCP

- **`tcp_server_close(struct tcp_pcb *pcb)`**  
  Cierra la conexión TCP de forma ordenada, liberando recursos o abortando en caso de error.

- **`tcp_server_err(void *arg, err_t err)`**  
  Callback para gestionar errores en la conexión TCP. Llama a `tcp_server_close` y notifica la finalización anómala de la conexión.

- **`accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)`**  
  Callback que se invoca cuando se acepta una nueva conexión TCP. Se configuran los callbacks para recibir datos, enviar datos y manejar errores. También se establecen flags para indicar que la conexión se ha aceptado y que los datos están listos para ser enviados.

- **`start_application()`**  
  Inicializa el servidor TCP creando un nuevo PCB, haciendo el bind al puerto definido (6543), pasando a modo listen y estableciendo la función `accept_callback` para conexiones entrantes.

- **`sent_callback(void *arg, struct tcp_pcb *tpcb, u16_t len)`**  
  Callback que se invoca cuando se confirma el envío de un paquete. Establece el flag `flag_ready2sent` para permitir el envío de nuevos datos.

Cada una de estas funciones sigue un formato similar:

```c
/**
 * start_application
 *
 * Inicializa y configura el servidor TCP para aceptar conexiones.
 *
 * Returns
 * -------
 * int
 *     0 si la inicialización fue exitosa, un valor negativo en caso de error.
 */
int start_application();
```

### 1.4 Diagrama de Flujo del Módulo tcp_com

A continuación se muestra un ejemplo de diagrama de flujo en formato Mermaid para visualizar la relación entre las funciones principales:

```mermaid
flowchart TD
    A[start_application] --> B[tcp_bind & tcp_listen]
    B --> C[tcp_accept --> accept_callback]
    C --> D[Configura callbacks: recv_callback, sent_callback, tcp_server_err]
    D --> E[Evento de recepción --> recv_callback__]
    D --> F[Evento de envío confirmado --> sent_callback]
    F --> G[flag_ready2sent habilitado]
    D --> H[Evento de error --> tcp_server_err]
    G --> I[transfer_data se invoca según flag_senddata]
```

---

## 2. Módulo Echo (echo.c)

### 2.1 Descripción General

Este módulo contiene funciones sencillas para imprimir encabezados informativos en la consola. Se utiliza al inicio de la aplicación para indicar el inicio del servidor TCP y mostrar algunos detalles del entorno lwIP.

### 2.2 Funciones

#### 2.2.1 `print_app_header()`

**Descripción:**  
Imprime el encabezado de la aplicación, diferenciando entre IPv4 y IPv6, y especifica el puerto al que se envían los paquetes TCP (6543).

```c
/**
 * print_app_header
 *
 * Imprime el encabezado informativo del servidor TCP.
 *
 * No recibe parámetros.
 */
void print_app_header();
```

---

## 3. Módulo Principal (main.c / main.h)

### 3.1 Descripción General

El archivo **main.c** actúa como punto de entrada del sistema. Se encarga de:
- Inicializar la plataforma y los periféricos (GPIO, DAC, ADC, DMA, timers).
- Configurar la red (iniciando lwIP, DHCP y la interfaz de red).
- Iniciar el servidor TCP mediante `start_application()`.
- Ejecutar un bucle principal (loop_routine) donde se gestionan las interrupciones temporales (TCP fast/slow timers), se procesan comandos recibidos a través de TCP y se interactúa con otros módulos del sistema (por ejemplo, control de señales, reinicio de DRS4, mediciones DTAP).

### 3.2 Variables y Configuraciones

En **main.h** se declaran variables globales para la configuración del sistema, tales como buffers para UART, parámetros de DAC y ADC, flags de control y definiciones de pines GPIO. Estas variables controlan el flujo de datos, la comunicación y las rutinas de inicialización de hardware.

### 3.3 Funciones Clave

#### 3.3.1 `main()`

**Descripción:**  
- Inicializa la plataforma, DMA, timers y la interfaz de red.
- Inicia el DHCP y establece la IP en la interfaz de red.
- Llama a `start_application()` para iniciar el servidor TCP.
- Ejecuta el bucle principal (`loop_routine()`), donde se gestionan las comunicaciones y la interacción con el hardware.

```c
/**
 * main
 *
 * Función principal de la aplicación. Inicializa todos los módulos,
 * configura la red, inicia el servidor TCP y entra en el bucle principal.
 *
 * Returns
 * -------
 * int
 *     Código de retorno (0 para éxito).
 */
int main();
```

#### 3.3.2 `loop_routine()`

**Descripción:**  
Contiene el bucle de ejecución principal del sistema. Verifica los flags de los timers TCP, gestiona la recepción y envío de datos y procesa comandos recibidos (como reinicios, apagados o solicitudes de estado). Se encarga de:
- Ejecutar `tcp_fasttmr()` y `tcp_slowtmr()` cuando corresponda.
- Llamar a `transfer_data()` para enviar datos cuando `flag_senddata` y `flag_ready2sent` estén activos.
- Procesar comandos especiales recibidos a través de TCP en `recv_callback()`.

```c
/**
 * loop_routine
 *
 * Bucle principal de la aplicación.
 *
 * Gestiona la recepción y envío de datos, además de procesar comandos de control.
 *
 * Returns
 * -------
 * int
 *     XST_SUCCESS si el bucle se ejecuta correctamente.
 */
int loop_routine(void);
```

#### 3.3.3 `shutdown_all()`

**Descripción:**  
Apaga de forma segura los módulos críticos del sistema (por ejemplo, DRS4) y cierra la conexión TCP.

```c
/**
 * shutdown_all
 *
 * Realiza el apagado seguro de los módulos críticos y cierra la conexión TCP.
 */
void shutdown_all();
```

#### 3.3.4 Funciones Auxiliares de Inicialización

- **`setup_system()`**: Inicializa GPIO, DAC, ADC, DRS4 y otros periféricos.  
- **`ADC_SPI_init()`**: Configura el ADC a través de SPI.  
- **`init_DACs()` y `setup_DACs()`**: Inicializan y configuran las salidas de los DACs para la señalización requerida.

#### 3.3.5 `DRS4_restart_ROI()`

**Descripción:**  
Reinicia el módulo DRS4 (responsable de la adquisición de datos) reconfigurando y reactivando sus señales de control, y comprobando el estado de su máquina de estados.

#### 3.3.6 `recv_callback()`

**Descripción:**  
Función callback que se invoca cuando se reciben datos vía TCP. Interpreta comandos (como "-DRS4GetState", "-Shutdown", "-get_event", etc.) y realiza acciones asociadas, actualizando el buffer de respuesta global y configurando flags para el envío de datos.

#### 3.3.7 `DRS4_DTAP_meas(int sel_mezz)`

**Descripción:**  
Realiza una medición de frecuencia o contador a partir de registros de monitoreo de reloj (CLK MON), según el mezzanine seleccionado, y devuelve una frecuencia calculada.

```c
/**
 * DRS4_DTAP_meas
 *
 * Realiza la medición DTAP para un mezzanine dado.
 *
 * Parameters
 * ----------
 * sel_mezz : int
 *     Selección del mezzanine (valores del 1 al 5).
 *
 * Returns
 * -------
 * float
 *     Frecuencia calculada en función del contador leído.
 */
float DRS4_DTAP_meas(int sel_mezz);
```


