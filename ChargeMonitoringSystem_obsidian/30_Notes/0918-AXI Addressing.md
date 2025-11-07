El objetivo es encontrar como acceder a los datos que salen del lpgbt dentro del PS, osea dentro de Petalinux.

Se ha encontrado gracias al mapeo que hay interacción de AXI con reg_map instancia de emp_lpgbt_ic_clerk_regs
	en este archivo source de vivado es posible conocer como se componen los addres y como interactua con las operaciones de escritura.

___

## Explorando foros

se me indica que deberia buscar en /dev/mem, el cual es una representación de los espacios fisicos de memoria. En particular nos interesa la dirección, la cual se puede ver en ADDRES EDITOR de Vivado

| Módulo        | Dirección Base |
| ------------- | -------------- |
| `emp_lpgbt_0` | `0xA0000000`   |
| `emp_lpgbt_1` | `0xA0010000`   |
| `emp_lpgbt_2` | `0xA0020000`   |
| ...           | ...            |

Tras explorar el archivo de reg_map, para el lpgbt se observa como se componen los registros

| Nombre del Registro | Offset  | Acceso | Comentario                    |
| ------------------- | ------- | ------ | ----------------------------- |
| `magic`             | `0x00`  | RO     | Valor mágico del periférico   |
| `control`           | `0x04`  | WO     | Control del sistema lpGBT     |
| `status`            | `0x08`  | RO     | Flags: `ready`, `empty`, etc. |
| `data_rx`           | `0x0C`  | RO     | Lectura de dato               |
| `data_tx`           | `0x10`  | WO     | Escritura de dato             |
| `register_addr`     | `0x14`  | WO     | Dirección de registro lpGBT   |
| `lpGBT_addr`        | `0x18`  | WO     | Dirección de chip lpGBT       |
| `interrupt_enable`  | `0x1C`  | WO     | Habilitar interrupciones      |
| `interrupt_flags`   | `0x20`  | RO     | Flags de interrupción         |
| `interrupt_clear`   | `0x24`  | WO     | Borrar interrupciones         |
| `reset`             | `0x28`  | WO     | Reset                         |
| `counter_lhc_clock` | `0x100` | RW     | Contador                      |

Al intentar leerlo con el codigo de C, el de Paris LpgbtSw o incluso usar devmem2 para verificar el addres
el sistema acaba en un estado sin respuesta
"""
[tgc_cms@trenz-tgc devmem2]$ sudo ./devmem2 0xA0000000 w
[sudo] password for tgc_cms:
/dev/mem opened.
Memory mapped at address 0xffff8636e000.
[  420.405973] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
[  420.411897] rcu:     2-...0: (1 GPs behind) idle=14b4/1/0x4000000000000000 softirq=7452/7452 fqs=2570
[  420.420852]  (detected by 1, t=5255 jiffies, g=6245, q=392 ncpus=4)
[  420.427110] Task dump for CPU 2:
[  420.430322] task:devmem2         state:R  running task     stack:0     pid:569   ppid:565    flags:0x00000202
[  420.440226] Call trace:
[  420.442656]  ret_from_fork+0x0/0x20


"""

Podría no existir un clock valido u otra cosa
![[assets/hardware/2024/09/clock-connection.png]]

El acceso se intentó a su vez mediante codigo en C
```c

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdint.h>

#define BASE_ADDR     0xA0000000  // from Address Editor
#define MAP_SIZE      0x1000      // 4 KB shall be enough given the range of memory

// Offsets
#define MAGIC_OFFSET        0x00
#define STATUS_OFFSET       0x08
#define DATA_RX_OFFSET      0x0C

int main() {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("open /dev/mem");
        return -1;
    }

    void *map_base = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BASE_ADDR);
    if (map_base == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return -1;
    }

    volatile uint32_t *magic    = (volatile uint32_t *)((char *)map_base + MAGIC_OFFSET);
    volatile uint32_t *status   = (volatile uint32_t *)((char *)map_base + STATUS_OFFSET);
    volatile uint32_t *data_rx  = (volatile uint32_t *)((char *)map_base + DATA_RX_OFFSET);

    printf("MAGIC:      0x%08X\n", *magic);
    printf("STATUS:     0x%08X\n", *status);
    printf("DATA_RX:    0x%08X\n", *data_rx);

    munmap(map_base, MAP_SIZE);
    close(fd);
    return 0;
}


```

Pero tambien acaba resultando en CPU stalls al no obtener respuesta alguna de estas direcciones de memoria.

Sin embargo teorias como un reloj no implementado no son validas
![[assets/firmware/2024/09/routing-emp-clocl.png]]
Igual que la axi addrs
![[assets/firmware/2024/09/routing-s-axi-araddr.png]]

___

