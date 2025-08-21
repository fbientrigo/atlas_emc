# Guia del codigo

Este sistema implementa un **servidor TCP embebido** en una plataforma Zynq, permitiendo la adquisición, configuración y monitoreo de datos desde un sistema DAQ por red. Se comunica con hardware analógico mediante DACs, ADCs y CPLDs, todo orquestado desde un **bucle de control centralizado en `main.c`**. Su diseño está orientado a control y adquisición remota de forma robusta, aunque con algunos puntos a mejorar en cuanto a gestión de memoria y modularidad.


---

## 🔧 **Resumen general del sistema**

Este código está diseñado para una **DAQ (Data Acquisition Board)** con un sistema embebido en un SoC **Zynq**. Utiliza un **servidor TCP** embebido (con lwIP), comunicación con hardware mediante **GPIO, I2C, SPI**, y control de periféricos como ADCs, DACs, y CPLDs.

---

## 📁 Archivos y Modulos Analizados

### 1. `tcp_com.c / tcp_com.h`
**Objetivo principal**: Implementa un **servidor TCP** usando lwIP, encargado de recibir comandos desde un cliente y enviar datos de adquisición.

#### 🔹 Funciones claves
- `start_application()`: Inicializa el servidor TCP en el puerto 6543.
- `accept_callback()`: Callback al aceptar una conexión entrante.
- `recv_callback()`: Procesa los mensajes recibidos, interpreta comandos y actualiza flags para ejecutar acciones.
- `transfer_data()`: Envía datos vía TCP, usando `tcp_write` y gestionando fragmentación de paquetes si es necesario.
- `packer()`: Formatea los datos de adquisición en texto plano para enviarlos en paquetes TCP.
- `rand_data()`: Llena `datos_PL[]` con valores aleatorios simulando datos del ADC.

#### 🔹 Variables importantes
- `pcb`: Estructura lwIP para gestionar la conexión TCP.
- `buffer`: Buffer de salida para datos a enviar (texto formateado).
- `flag_ready2sent`, `flag_senddata`, `flag_tcp_done`: Flags de control para el estado del envío de datos.
- `datos_PL`: Apuntador a los datos adquiridos que se deben empaquetar y enviar.

#### 🔹 Consideraciones
- Usa funciones bloqueantes como `usleep()`, lo cual puede afectar tiempo real.
- Puede tener **riesgos de uso de memoria dinámica sin liberar** (`datos_PL = malloc(...)`).
- La implementación es robusta para control remoto por TCP.

---

### 2. `main.c / main.h`
**Objetivo principal**: Es el punto de entrada del sistema. Configura periféricos (GPIO, SPI, I2C), inicia red, servidor TCP, y ejecuta un **loop principal de eventos** que responde a flags y comandos entrantes.

#### 🔹 Fases del flujo
1. **Inicialización de red y servidor**:
   - `lwip_init()`, `dhcp_start()`, `start_application()`
   - Configura dirección IP por DHCP o por defecto (192.168.1.10).
   - Usa `xemac_add()` para agregar interfaz de red.

2. **Inicialización de hardware**:
   - `setup_system()`: Configura DACs, CPLD, ADCs, y demás periféricos.
   - `ADC_SPI_init()`: Envia configuración por SPI al ADC.

3. **Loop principal (`loop_routine()`)**:
   - Evalúa flags como: `flag_senddata`, `shutdown`, `dac_set`, etc.
   - Llama a funciones como `transfer_data()` o `setup_DACs()`.
   - Recibe comandos desde el TCP por `recv_callback()`.

#### 🔹 Comandos TCP soportados
- `-DRS4GetState`, `-Shutdown`, `-DRS4Restart`
- `-get_event`: Adquiere un evento desde los ADCs y lo prepara para envío.
- `-check`, `-VETO 0`, `-cleanup`, `-soft_trig`, `-auto_trig_on/off`, etc.

#### 🔹 Variables importantes
- `RecvBuffer[]`, `SendBuffer[]`: Buffers de UART.
- `dac_values[]`, `trigger_values[]`: Configuración de salida analógica.
- `flag_ready2sent`, `flag_senddata`: Controlan el flujo de envío TCP.

#### 🔹 Funciones auxiliares
- `command_is()`: Verifica si un comando específico fue recibido.
- `DRS4_restart_ROI()`: Reinicia la región de interés del DRS4.

---

### 3. `echo.c`
**Objetivo principal**: Es un archivo auxiliar que imprime un encabezado de presentación para el servidor TCP.

#### 🔹 Función clave
- `print_app_header()`: Muestra por UART la información de conexión TCP al arrancar.


---

## Visualizar la interconexion



---

## ⚠️ Puntos de atención

1. **Falta de manejo de memoria en `rand_data()`**:
   - Se hace `malloc()` pero no hay `free()`. Podría haber **fugas de memoria** si se llama muchas veces.

2. **Dependencia directa de `usleep()` en `transfer_data()`**:
   - Puede impactar el rendimiento si se usa en contexto de tiempo real o dentro de interrupciones.

3. **Dependencia en `global flags` para lógica de control**:
   - Variables como `flag_senddata`, `soft_trigg_en`, etc., son compartidas por muchas funciones → puede haber condiciones de carrera si se usa en entornos multihilo o interrupciones.

---

## 🔌 **Dependencias Externas y Middleware**
- **lwIP**: Implementación de pila TCP/IP ligera.
- **Xilinx GPIO/IP Drivers**: `xgpio.h`, `xil_printf.h`, `xuartps.h`
- **Periféricos personalizados**: `AXI_ADC`, `CPLD`, `DRS4`, DACs (vía I2C)

