# ***epos*** Repository

Author: Paris Moschovakos [paris.moschovakos@cern.ch](mailto:paris.moschovakos@cern.ch)

This repository contains a collection of directories, each housing a different tool designed for specific functionalities within the ***epos*** project. They are organized as follows:

## Prerequisites
Before starting, please ensure that you have the necessary permissions and prerequisites installed before attempting to use the tools and scripts provided in this repository. It is also crucial to understand that the steps should be followed in a particular order to ensure the correct setup.

## 1. [epos-bsp](./epos-bsp)

ℹ️  **This is the first step to set up the epos project needed to create the boot files**

The `epos-bsp` directory contains the Board Support Packages (BSPs) for our ***epos*** project. These BSPs are essential to run the ***epos*** operating system on our hardware. It provides instructions on how to set up the project using Petalinux and guides on how to create and boot from an SD card. Check out the [epos-bsp README](./epos-bsp/README.md) for detailed instructions.

## 2. [epos-rootfs](./epos-rootfs)

ℹ️ **This is the second step to create the root filesystem for epos project**

The `epos-rootfs` directory is tasked with the creation of ***epos*** root filesystem based on CERN standard Operating System that is also used for EMP. It provides a guide on how to create and deploy epos-rootfs and how to add PetaLinux kernel modules. Check out the [epos-rootfs README](./epos-rootfs/README.md) for more detailed instructions.

## 3. [etools](./etools)

ℹ️ **This is will help you load the firmware from the Processing System**

The `etools` directory contains tools to deploy the firmware from within the PS and the operating system. These tools include `xsa-to-overlays`, which processes a .xsa file to produce a .dtbo and a .bit.bin file, and `petalinux-load-firmware`, a script designed to load given .dtbo and .bit.bin files to a Zynq device. Visit the [etools README](./etools/README.md) for usage details.

## 4. [hw-description](./hw-description)
The `hw-description` directory houses different versions of xsa files for various development boards and versions of the firmware. Each xsa file provides a detailed description of the hardware configuration for a specific board, and can be used as a reference by e.g. the etools above, in case the user doesnt have a Vivado project to create their own.

For details on the exact structure and usage of the repository, refer to the README files in each directory. Please ensure that you have the necessary permissions and prerequisites installed before attempting to use the tools and scripts provided in this repository.

Contributions and bug reports are welcome.

---

## Next Steps: Deploy LpGbtSw
To continue with deploying the LpGbtSw, check out the [LpGbtSw Repository on GitLab](https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw).

---

##  Contact
For any support or questions related to the ***epos***, please contact me at [paris.moschovakos@cern.ch](mailto:paris.moschovakos@cern.ch).
