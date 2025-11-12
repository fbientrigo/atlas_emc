# How to boot EMP using the BSPs

Withi this method we will create the necessary files that should be deployed in the SD card to boot EMP. This will not create the filesystem which can be followed in epos-rootfs but only the boot files.

## Prerequisites

This project requires Petalinux to be installed. 

:warning: **Important note**: The BSP used for this project was built with Petalinux 2020.1. For compatibility purposes, it is strongly recommended to use this version of Petalinux. Using a different version may cause unexpected issues.

From within our ***epos*** repository main directory you should do the following steps. Please ensure that petalinux (settings.sh) is sourced and avialable in the PATH.

## Step 1
```
petalinux-create -t project -s petalinux/trenz-01-00-00/epos_trenz.bsp -n trenz_1.0.0
```

## Step 2
```
petalinux-config --get-hw-description=../hw-description/trenz-01-00-00/
```

## Step 3
```
petalinux-build
```

## Step 4
```
petalinux-package --boot --fsbl --fpga --u-boot --force
```

## Step 5
After that we have all the needed files for the boot partition of the SD card. Just copy BOOT.BIN, image.ub and boot.scr in the boot partition and that should be enough.

## Step 6 - Load the CentOS 8 Stream NFS (Optional)
```
setenv bootargs earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/nfs nfsroot=128.141.94.155:/tftpboot/s8-emp-dev,tcp,nfsvers=3 ip=dhcp rw uio_pdrv_genirq.of_id=generic-uio
```
Bear in mind that the ip of our current NFS server is not static and for that can change e.g. after a power cut or reboot

---

# Nest Steps: Creating epos root filesystem for EMP
To continue to how to create the root filesystem for EMP check out [epos-rootfs](../epos-rootfs)

---

##  Contact
For any support or questions related to the ***epos***, please contact me at [paris.moschovakos@cern.ch](mailto:paris.moschovakos@cern.ch).
