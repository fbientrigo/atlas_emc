# Scripts
## xsa-to-overlays
xsa-to-overlays is a Python script that takes a .xsa file and produces a .dtbo and a .bit.bin file.
The user is prompted if they wish to change the device tree to match the EMP requirements.

The script requires Vivado settings to be sourced and dtc (device tree compiler) to be in path.

Make sure the device-tree-xlnx folder corresponds to the Vivado version you are using or it may cause errors. I.e. errors has been found using version xilinx-v2020.1 and Vivado 2019.2.

The script may need minor need modifications depending on the version of the device tree you are using.
This repository ships with the device tree corresponding to Vivado v2020.1.

### How to use:
1. Change directory into the folder.
1. Copy .xsa file to the folder.
1. Run: `./emp-xsa-to-overlays.py <xsa-file>`.
1. When asked if you wish to "fix pl.dtsi to match EMP requirements?" answer "y".
1. When asked if you wish to "make device tree overlay binary?" answer "y".
1. When asked if you wish to "clean up your output directory?" answer "y".

Xilinx device tree repo: https://github.com/Xilinx/device-tree-xlnx/

### Small trick:
If you wish to modify the device tree overlay further, but still use the script, this is also possible.<br>
This can be done by opening a text editor and modifying the file "pl.dtsi" before answering if you wish to "make device tree overlay binary?".

---

## Next Steps: Deploy LpGbtSw
To continue with deploying the LpGbtSw, check out the [LpGbtSw Repository on GitLab](https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw).

---

##  Contact
For any support or questions related to the ***epos***, please contact me at [paris.moschovakos@cern.ch](mailto:paris.moschovakos@cern.ch).
