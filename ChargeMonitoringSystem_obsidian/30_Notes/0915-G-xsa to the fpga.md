
# Programar FPGA con Device Tree Overlay (EMP / EPOS)

## Referencias y repos

Para programar se referencia a:
- [[Setup EMP development environment & reference project]]

Los source code se obtienen de dos proyectos:
- [EMCI-EMP / emp-tools · GitLab](https://gitlab.cern.ch/emci-emp/emp-tools)
- [atlas-dcs-emp-software / epos · GitLab](https://gitlab.cern.ch/atlas-dcs-emp/epos)

---

## Contexto

Esta guía corresponde a la sección:
**Creating a Device Tree overlay to program the FPGA**

El flujo general:
1) Tener el `.xsa` listo  
2) Convertir `.xsa` → `*.dtbo` + `*.bit.bin` + `pl.dtsi`  
3) Subir a la máquina target  
4) Cargar firmware con `loadFirmare.sh`

---

## Prerrequisitos

- Repo `epos` clonado (incluye `etools/`).
- `dtc` (*device tree compiler*) instalado (Linux).
- `xsct` disponible (desde PetaLinux).
- `bootgen` disponible (desde Vivado/Vitis) y entorno cargado con `settings64`.

> [!warning] Windows vs WSL / Linux
> - Si corres el flujo en **Windows nativo**, normalmente usas `settings64.bat` (no `settings64.sh`).
> - Si corres el flujo en **WSL/Linux**, usas `settings64.sh`.
> - No sirve “cargar” el `.bat` de Windows dentro de WSL: son entornos distintos.

---

## Paso 0 — Tener el `.xsa`

El `.xsa` se obtiene desde:
- [[0912-compilando_empfirmwarev0.2]]

Luego se copia a la carpeta:
- `/etools/xsa-to-overlays/xsa-to-overlays`

En mi caso (ruta completa):
```bash
/home/fabi/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays
````

---

## Paso 1 — Obtener EPOS (versión estable)

```bash
git clone --branch 3.0.0 --depth 1 --single-branch https://gitlab.cern.ch/atlas-dcs-emp/epos.git .
```

> Nota: Tomé una versión terminada, buscando estabilidad. Hay varias versiones y no se especifica en la guía cómo cambian entre ellas.

---

## Paso 2 — Instalar `dtc` (Debian/Ubuntu)

```bash
sudo apt-get install device-tree-compiler
```

---

## Paso 3 — Exponer `xsct` (PetaLinux)
NOTA; me ha funcionado sin eso
Se debe referenciar el directorio de PetaLinux para acceder a `xsct`:

```bash
export PATH=$PATH:<Petalinuxdir>/tools/xsct/bin/
```

En mi caso:

```bash
export PATH=$PATH:/home/fabi/petainstaller/tools/xsct/bin/
```

---

## Paso 4 — Habilitar `bootgen` (Vivado/Vitis) según el OS

### 4A) Si corres en WSL / Linux: `settings64.sh`

> [!warning] Importante (no aparece en la guía)  
> Al ejecutar `emp-xsa-to-overlays.py` también se necesita `bootgen`, que viene con Vivado/Vitis.  
> Por tanto es obligatorio cargar `settings64.sh` en el MISMO entorno donde corres el script.

Ejemplo (mi caso, WSL/Linux):

```bash
cd /home/fabi/vivado_install/Vitis/2023.2
source settings64.sh
```

### 4B) Si corres en Windows nativo: `settings64.bat`

En Windows NO se usa `settings64.sh` (bash), se usa el equivalente:

- Ejemplo rutas típicas:
    
    - `C:\Xilinx\Vivado\2023.2\settings64.bat`
        
    - `C:\Xilinx\Vitis\2023.2\settings64.bat`
        

En `cmd`:

```bat
C:\Xilinx\Vivado\2023.2\settings64.bat
```

> Nota: ese `.bat` setea variables de entorno (PATH, etc.) para que exista `bootgen.exe` en esa sesión.

---

## Paso 5 — Ejecutar `emp-xsa-to-overlays.py`

Desde:

```bash
cd /home/fabi/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays
```

Ejecutar el script con el `.xsa`:

```bash
./emp-xsa-to-overlays.py hw_emp_TE0807.xsa
```

### Output esperado

```bash
ls /home/fabi/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays/output
```

Ejemplo:

- `hw_emp_TE0807.bit.bin`
    
- `hw_emp_TE0807.dtbo`
    
- `pl.dtsi`
    

---

# Subir a la máquina target

## Paso 6 — Copiar por `scp`

Desde local:

```bash
scp hw_emp_TE0807* tgc_cms@trenz-tgc:~/
```

Ejemplo output:

```text
hw_emp_TE0807.bit.bin  100% 7625KB  15.5MB/s  00:00
hw_emp_TE0807.dtbo     100% 6800     1.5MB/s   00:00
```

---

## Paso 7 — Mover a `/lib/firmware/`

En la máquina target:

```bash
mv hw_emp_TE0807* /lib/firmware/
```

---

## Paso 8 — Cargar firmware con `loadFirmare.sh`

Ir a:

```text
/home/tgc_cms/epos/etools
```

Listar firmwares disponibles:

```bash
./loadFirmare.sh -l
```

Ejemplo:

```text
Firmware files:
emp_fw_TE0807_wrapper.dtbo
hw_emp_TE0807.dtbo
```

Cargar firmware (requiere sudo; se referencia solo el nombre):

```bash
sudo ./loadFirmare.sh hw_emp_TE0807.dtbo
```

Ejemplo:

```text
Firmware 'hw_emp_TE0807.dtbo' was successfully loaded.
```

---

## Resultados / Validación

- **Fecha:** 09/15 2pm
    
- Se ha ejecutado sin errores.
    
- El sistema fue reiniciado.
    
- Todo funciona bien.
    

> [!note] Detalle interesante (LED en la Mezz)  
> Se encendió el único LED en la Mezz tras ejecutar `loadFirmware`, el cual de acuerdo al TMR:  
> ![[assets/hardware/2024/09/on-board-led.png]]

---

# Continuación: construir la API (LpGbtSw)

Repo:

- [atlas-dcs-emp-software / LpGbtSw · GitLab](https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw)
    

Notas relacionadas:

- [[0915b-LpGbtSw en FPGA]]