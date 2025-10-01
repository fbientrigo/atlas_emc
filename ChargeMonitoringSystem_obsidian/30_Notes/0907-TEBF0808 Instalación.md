---
title: "TEBF0808 ➜ ChaMS/EMP – Adaptación de la tarjeta al proyecto"
status: "draft"
tags: [project/ChaMS, board/trenz-tebf0808, som/te0807, os/epos, petalinux/2023.2]
updated: 2025-09-07
---

> **Objetivo.** Alinear el uso de la **Trenz TEBF0808 + TE0807** con el flujo **EMP/EPOS** del proyecto ChaMS. Este archivo hace *double-check* entre el **Setup EMP** y el **TRM TEBF0808** y enlaza a notas locales.

---

# 1) Vista rápida

- **Soporte:** TEBF0808 (baseboard) + TE0807-03-4BE21-A (SoM). Requiere **Vivado/PetaLinux 2023.2**.
- **Boot:** SD (front) o **microSD (back)**. Bootables: `BOOT.BIN`, `image.ub`, `boot.src`.
- **RootFS:** SD (ext4, p2) **o** NFS (Alma9 con *mkrootfs.py*).
- **Consola serie (Trenz):** dos conversores USB-serial: **JTAG=/dev/ttyUSB0**, **UART=/dev/ttyUSB1** @ **115200**.
- **MAC:** se lee del **eMMC** del SoM en boot → primer acceso por **UART**.
- **Red/DHCP:** ver [[docs_hardware/0408_posibleDHCP]] para incidencias y mitigación.

---

# 2) Mapa hardware mínimo (TEBF0808)

- **Alimentación:**
  - ATX-24 (suministro principal 12V/5V) y **jack 12V 2.1 mm**. Botón de *Power* en placa.
- **Almacenamiento de arranque:**
  - **SD frontal** y **microSD trasera** (ambas bootables). Elegir una y fijar *boot mode* en *switches* si aplica.
- **Conectividad:**
  - **SFP+ (2×)**, **GbE RJ45**, **USB3.0 (2×)**, **DisplayPort (1×)**, **SATA (1×)**.
  - **FMC HPC** (I/O PL) y **PMODs** (GPIO/I²C via SC CPLDs).
- **Programación/depuración:**
  - Micro‑USB: **JTAG** y **UART** (dos puertos enumerados en host).
  - 20‑pin ARM JTAG (PS) opcional.
- **Relojes/otros:**
  - SI5338A (PLL), 2× SMA clk, **eMMC 4 GB** on‑board, 2× CPLD MachXO2.

> Ver pinout/diagrama: [[docs_hardware/xc7z015clg485pkg]] (SoC) y TRM.

---

# 3) Flujo de software EMP/EPOS (resumen operativo)

## 3.1 Crear *bootables* con PetaLinux

```bash
# 0) Preparación
source <PetaLinuxDir>/settings.sh

git clone ssh://git@gitlab.cern.ch:7999/emci-emp/epos.git

# 1) Proyecto desde BSP Trenz
petalinux-create -t project \
  -s epos/epos-bsp/trenz-xV23-03-00-00/epos_trenz.bsp \
  -n epos-trenz.bsp
cd epos-trenz.bsp

# 2) Importar HW (XSA) de referencia Trenz
petalinux-config --get-hw-description=../epos/hw-description/trenz-xV23-03-00-00/

# 3) Build + package
petalinux-build
petalinux-package --boot --fsbl --fpga --u-boot --force
```

> **Nota EMP vs Trenz.** El reemplazo de `pmufw.elf` aplica **solo** a EMP; para Trenz no se reemplaza.

## 3.2 Preparar SD

**Opción A – RootFS en SD**

```text
p1  FAT32  ≥1 GB   → BOOT.BIN, image.ub, boot.src
p2  ext4   ≥8 GB   → rootfs (EPOS)
```

**Opción B – RootFS por NFS**

```text
p1  FAT32  ≥1 GB   → BOOT.BIN, image.ub, boot.src
```

Copiar a **p1**:

```text
BOOT.BIN
image.ub
boot.src
```

## 3.3 Construir RootFS EPOS (Alma9)

```bash
# Requisitos para QEMU estático
echo ':qemu-aarch64:...:/usr/local/bin/qemu-aarch64-static:' | sudo tee /etc/binfmt.d/qemu-aarch64.conf
sudo systemctl restart systemd-binfmt.service

# Crear FS (SD p2 o export NFS)
cd epos/epos-rootfs
sudo python3 mkrootfs.py --root=<PATH> --extra=epos_rpms.txt

# Añadir módulos del kernel de PetaLinux 2023.2
cd <MyBootProj>/images/linux/
mkdir -p /<PATH>/lib/modules/
tar -xvf rootfs.tar.gz
sudo cp -R lib/modules/6.1.30-xilinx-v2023.2 /<PATH>/lib/modules/
```

**NFS (si aplica):** en `petalinux-config → DTG Settings → Kernel bootargs` desactivar *auto* y usar:

```text
earlycon console=ttyPS0,115200 clk_ignore_unused \
root=/dev/nfs nfsroot=<NFS_IP>:<PATH>,tcp,nfsvers=3 ip=dhcp rw \
uio_pdrv_genirq.of_id=generic-uio
```

## 3.4 Primera consola (Trenz)

- Conectar micro‑USB. En el host aparecerán **dos** `/dev/ttyUSB*`:
  - **JTAG** (número menor, p.ej. `/dev/ttyUSB0`).
  - **UART** (número mayor, p.ej. `/dev/ttyUSB1`).
- Abrir UART a **115200** con `putty/minicom/screen`.

```bash
sudo screen /dev/ttyUSB1 115200
```

> **MAC & registro de red.** El MAC se inyecta desde el **eMMC** al *device tree* en boot. Si tu red exige registrar la MAC para DHCP/SSH, **primero** entra por UART y obtén la dirección.

---

# 4) Integración firmware (resumen)

1. **emp-firmware (Vivado 2023.2)**
   - `source <Vivado>/settings64.sh` → abrir Vivado → `source emp-firmware-2023.2.tcl`.
   - Ajuste de polaridades MGT (según baseboard):
     - **Trenz / EMP v1**: RX `0xFFF`, TX `0x000`.
     - **EMP v2**: RX `0xE07`, TX `0xFFF`.
   - *Generate Bitstream* → **Export Hardware** (con bitstream) a `.xsa`.
2. **Device Tree Overlay (DTO)**
   - `export PATH=$PATH:<PetaLinuxDir>/tools/xsct/bin/` y `dtc` disponible.
   - `epos/etools/xsa-to-overlays/emp-xsa-to-overlays.py <hw>.xsa` → copiar `.dtbo` y `.bit.bin` a `/lib/firmware`.
3. **Carga en runtime (PS → PL)**
   - `sudo epos/etools/loadFirmare.sh <firmware>.dtbo`.

---

# 5) Red, DHCP y *known issues*

- **DHCP que no asigna** (observado en [[docs_hardware/0408_posibleDHCP]]):
  - Confirmar `ip=dhcp` en *bootargs* si usas **NFS**.
  - Si booteas SD+rootfs local, revisar `systemd-networkd`/`NetworkManager` y la presencia de `eth0`.
  - Para pruebas *punto‑a‑punto*, configurar **IP estática** en ambos extremos; si hay *router/DHCP* corporativo, registrar **MAC**.
- **Ping deshabilitado** en imágenes mínimas: usar `nc`/`ssh` para validar TCP si ICMP está filtrado.
- **Sin cable → bloqueo**: capturar *logs* por UART; evitar `while` bloqueantes en usuariospace (p.ej. scripts que esperan DHCP indefinidamente).

```bash
# IP estática temporal (ejemplo)
sudo ip addr add 192.168.1.10/24 dev eth0
sudo ip route add default via 192.168.1.1
```

---

# 6) *Double‑check* (Setup EMP ↔ TRM TEBF0808)

| Ítem | Setup EMP/EPOS | TRM TEBF0808 | Nota |
|---|---|---|---|
| **Slots SD** | SD (front) soportado; **también microSD (back)** | **MicroSD/MMC bootable** | Coherente; usar uno a la vez. |
| **Puertos serie** | Trenz: **2 conversores** (JTAG=ttyUSB0, **UART=ttyUSB1**), 115200 | JTAG/UART headers y micro‑USB disponibles | Mapeo host práctico añadido aquí. |
| **Alimentación** | Requiere suministro estable antes de boot | **ATX‑24** y **12V jack** | Igual; priorizar ATX‑24 si usas muchas cargas. |
| **MAC** | Leída de **eMMC** y aplicada al DT | eMMC a bordo (4 GB) | Implica registrar MAC para red gestionada. |
| **Versionado** | **Vivado/PetaLinux 2023.2** | — | Mantener versiones alineadas. |

---

# 7) Checklist operativo (Trenz → ChaMS)

- [ ] PSU conectada (ATX‑24 o 12 V jack) y disipación/ventilación.
- [ ] SD/microSD preparada (p1 FAT32 + p2 ext4 **o** NFS) con *bootables*.
- [ ] UART accesible (detectar `/dev/ttyUSB1`) y baud **115200**.
- [ ] **MAC** registrada en la red (si usa DHCP corporativo).
- [ ] *Bootargs* verificados (NFS: `ip=dhcp`, `nfsroot=...`).
- [ ] RootFS EPOS con módulos `6.1.30-xilinx-v2023.2` en `/lib/modules`.
- [ ] Firmware Vivado exportado `.xsa` y DTO generado `.dtbo` + `.bit.bin` en `/lib/firmware`.
- [ ] Carga dinámica con `loadFirmare.sh` probada.

---

# 8) Snippets útiles

## 8.1 Detección de puertos serie (host Linux)
```bash
dmesg | egrep -i 'ttyUSB|FTDI|cp210|pl2303'
ls -l /dev/ttyUSB*
```

## 8.2 Copia de bootables a SD (p1)
```bash
sudo mount /dev/sdX1 /mnt/boot
sudo cp BOOT.BIN image.ub boot.src /mnt/boot/
sudo sync && sudo umount /mnt/boot
```

## 8.3 Enlace NFS (host)
```bash
# /etc/exports
aaa/bbb/epos-rootfs  *(rw,no_subtree_check,async,no_root_squash)
```

---

# 9) Enlaces locales y próximos pasos

- [[logging/0826-petalinux]] — bitácora de instalación y *builds*.
- [[20_Documents/Setup EMP development environment & reference project]] — guía completa.
- [[20_Documents/Instructions to connect Trenz 0715 SoM to computer]] — conexión básica.
- [[20_Documents/AXI4-Lite communication between PL and PS]] — notas AXI4‑Lite.

**Siguiente:** Validar red (DHCP/NFS) en laboratorio y documentar *bootlogs* UART en `logging/`.

