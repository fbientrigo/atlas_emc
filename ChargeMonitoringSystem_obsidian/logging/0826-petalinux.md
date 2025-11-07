Perfecto 🙌. Te preparo tus notas en un formato **profesional**, como si fueran un informe técnico o documentación de laboratorio. Mantengo todo lo que ya hiciste, pero más claro, organizado y formal.

---

# **Informe de instalación y validación de PetaLinux 2023.2 para EPOS**

## 1. Instalación de PetaLinux

Se instaló **PetaLinux 2023.2** en el sistema.  
Para su utilización es necesario cargar las variables de entorno mediante:

```bash
source <ruta_de_instalación>/settings.sh
```

---

## 2. Prueba de sanidad con BSP de referencia

Como validación inicial del entorno se utilizó un **Board Support Package (BSP)** oficial de Xilinx para **Zynq7000**.  
El flujo fue:

1. Crear proyecto a partir del BSP.
    
2. Compilar con `petalinux-build`.
    
3. Ejecutar en **QEMU** para validar la imagen generada.
    

Resultado: el sistema arrancó correctamente en QEMU, confirmando que la instalación es funcional.

---

## 3. Proyecto EPOS

### 3.1 Contexto

La documentación original se encuentra en GitLab:  
[epos-bsp/README.md · master · atlas-dcs-emp-software / epos · GitLab](https://gitlab.cern.ch/atlas-dcs-emp/epos/-/blob/master/epos-bsp/README.md)

No obstante, la documentación está parcialmente desactualizada en cuanto a las rutas de carpetas. Se ajustaron los pasos de acuerdo a la estructura actual.

### 3.2 Creación del proyecto

Desde la carpeta principal de **epos**:

```bash
petalinux-create -t project \
  -s ../epos/epos-bsp/emp-03-00-00/epos_emp.bsp \
  -n epos-emp.bsp
```

**Salida esperada:**

```
INFO: Create project: epos-emp.bsp
INFO: New project successfully created in /home/ftrigofa/epos/epos-emp.bsp
```

---

## 4. Referencia al Hardware Description (XSA)

El hardware description se encuentra en `hw-description/emp-03-00-00/hw_desc.xsa`.

```bash
ls hw-description/
emp-01-00-00  emp-02-00-00  emp-03-00-00  trenz-01-00-00 ...
```


Se asocia al proyecto creado mediante:

```bash
cd epos-emp.bsp
petalinux-config --get-hw-description=../hw-description/emp-03-00-00/
```

**Salida típica:**

```
[INFO] Sourcing buildtools
[INFO] Getting hardware description...
INFO: Renaming hw_desc.xsa to system.xsa
[INFO] Extracting yocto SDK to components/yocto. This may take time!
[INFO] Generating Kconfig for project
[INFO] Menuconfig project
[INFO] Generating kconfig for rootfs
[INFO] Silentconfig rootfs
[INFO] Adding user layers
[INFO] Generating machine conf file
[INFO] Generating plnxtool conf file
[INFO] Generating workspace directory
[INFO] Successfully configured project
```

Al finalizar este paso aparece el menú de configuración (captura no disponible en el repositorio actual; se registró la referencia `petalinux_system_conf.png` como pendiente de recuperación).

---

## 5. Compilación del proyecto EPOS

Con el hardware ya vinculado, se procede a compilar:

```bash
cd epos-emp.bsp
petalinux-build
```

**Salida resumida:**

```
[INFO] Sourcing buildtools
[INFO] Building project
[INFO] Silentconfig project
[INFO] Silentconfig rootfs
[INFO] Generating workspace directory
INFO: bitbake petalinux-image-minimal
```

Luego de build

```
petalinux-package --boot --fsbl --fpga --u-boot
```

## Post Build - ZynqMP -> Zynq7000
Previamente se utilizó "emp-03-00-00" pues el codigo 03 indica la versión 2023.2 que se busca, sin embargo se cargó con ZynqMP

Por tanto se han hecho modificaciones para utilizar

Creación del proyecto:
```bash
petalinux-create -t project -s ../epos/epos-bsp/trenz-03-00-00/epos_trenz.bsp -n epos-zynq.bsp
```

Entrar al proyecto
```bash
cd epos-zynq.bsp/
```

Empezar a definir el hardware description y una vez se hace, dejé todo por default
```bash
petalinux-config --get-hw-description=../hw-description/trenz-03-00-00/
```

Luego se comienza a hacer build (proceso demoroso)
```
petalinux-build
```

Nivel de seguridad en lo que sige 0.3 (no conozco mucho, puedes corregirme)
Este proceso debe ser seguido en probar el sistema construido, ya sea llevandolo directamente a la SD o  usar QEMU para probar






---

## Estado actual

- PetaLinux 2023.2 instalado y probado con éxito.
- Proyecto **epos-emp.bsp** creado a partir del BSP entregado.
- Hardware description (`hw_desc.xsa`) asociado correctamente.
- Proyecto compilado satisfactoriamente (`petalinux-build`).

Los siguientes pasos consisten en:

- Empaquetar las imágenes con `petalinux-package --boot`.
- Preparar la SD (copiar `BOOT.BIN`, `image.ub`, `boot.scr`).
- Opcional: configurar **bootargs** para NFS si se desea montar **AlmaLinux 9** como rootfs.
