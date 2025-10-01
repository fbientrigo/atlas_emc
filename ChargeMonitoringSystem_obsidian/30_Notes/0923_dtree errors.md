Se presentan errores a la hora de cargar emp_firmwares generados previamente, estos ya funcionaban anterior

```bash


[tgc_cms@trenz-tgc etools]$ grep -in "overlay" "loadFirmare.sh"
10:    echo "Load a device tree overlay firmware into a running Zynq system."
78:if [ -d "/configfs/device-tree/overlays/emp-firmware" ]; then
80:    rmdir /configfs/device-tree/overlays/emp-firmware
87:mkdir -p /configfs/device-tree/overlays/emp-firmware
91:    echo "Error: Failed to create /configfs/device-tree/overlays/emp-firmware"
95:echo -n "$1" > /configfs/device-tree/overlays/emp-firmware/path
[tgc_cms@trenz-tgc etools]$ clear
[tgc_cms@trenz-tgc etools]$ grep -in "overlay" "loadFirmare.sh"
10:    echo "Load a device tree overlay firmware into a running Zynq system."
78:if [ -d "/configfs/device-tree/overlays/emp-firmware" ]; then
80:    rmdir /configfs/device-tree/overlays/emp-firmware
87:mkdir -p /configfs/device-tree/overlays/emp-firmware
91:    echo "Error: Failed to create /configfs/device-tree/overlays/emp-firmware"
95:echo -n "$1" > /configfs/device-tree/overlays/emp-firmware/path



[tgc_cms@trenz-tgc etools]$ sudo ./loadFirmare.sh latest_emp_fw_0919.dtbo
Existing firmware detected. Unloading...
[  184.353884] OF: overlay: remove: Could not find overlay #0
[  184.371613] OF: overlay: Invalid overlay_fdt header
[  184.376518] create_overlay: Failed to create overlay (err=-22)
Firmware 'latest_emp_fw_0919.dtbo' was successfully loaded.
[tgc_cms@trenz-tgc etools]$ sudo ./loadFirmare.sh -l
Firmware files:
emp_fw_TE0807_wrapper.dtbo
hw_emp_TE0807.dtbo
latest_emp_fw_0919.dtbo
[tgc_cms@trenz-tgc etools]$ sudo ./loadFirmare.sh hw_emp_TE
Usage: loadFirmare.sh <firmware.dtbo-name>
       loadFirmare.sh -l or --list to list available firmware
[tgc_cms@trenz-tgc etools]$ sudo ./loadFirmare.sh hw_emp_TE0807.dtbo
Existing firmware detected. Unloading...
[  226.798532] OF: overlay: remove: Could not find overlay #0
[  226.811492] fpga_manager fpga0: writing hw_emp_TE0807.bit.bin to Xilinx ZynqMP FPGA Manager
[  227.273885] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /fpga-full/firmware-name
[  227.283997] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /fpga-full/resets
[  227.293979] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/afi0
[  227.303472] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/clocking0
[  227.313398] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_0
[  227.323496] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_1
[  227.333590] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_10
[  227.343771] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_11
[  227.353952] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_12
[  227.364135] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_2
[  227.374229] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_3
[  227.384334] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_4
[  227.394430] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_5
[  227.404529] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_6
[  227.414628] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_7
[  227.424723] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_8
[  227.434817] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_9
[  227.444912] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/empfw_debughub_0
Firmware 'hw_emp_TE0807.dtbo' was successfully loaded.
[tgc_cms@trenz-tgc etools]$ sudo ./loadFirmare.sh hw_emp_TE0807.dtbo
Existing firmware detected. Unloading...
[  254.140370] fpga_manager fpga0: writing hw_emp_TE0807.bit.bin to Xilinx ZynqMP FPGA Manager
[  254.282077] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /fpga-full/firmware-name
[  254.292191] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /fpga-full/resets
[  254.302164] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/afi0
[  254.311658] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/clocking0
[  254.321577] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_0
[  254.331672] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_1
[  254.341767] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_10
[  254.351949] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_11
[  254.362130] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_12
[  254.372312] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_2
[  254.382406] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_3
[  254.392503] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_4
[  254.402599] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_5
[  254.412692] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_6
[  254.422786] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_7
[  254.432882] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_8
[  254.442976] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/emp_lpgbt_9
[  254.453071] OF: overlay: WARNING: memory leak will occur if overlay removed, property: /__symbols__/empfw_debughub_0
Firmware 'hw_emp_TE0807.dtbo' was successfully loaded.
[tgc_cms@trenz-tgc etools]$

```

Para explorar esto comenzamos a revisar la capreta de los overlays
```
/configfs/device-tree/overlays/
```

Se probará cargar el hw_emp, v0.2
y ver si corre lo demás, osea si los warnings son ignorables

Para cargar una o la otra aqui comandos rapidos
```bash
sudo ./epos/etools/loadFirmare.sh hw_emp_TE0807.dtbo
```

```bash
sudo ./epos/etools/loadFirmare.sh latest_emp_fw_0919.dtbo
```

De acuerdo a GPT:
- hay simbolos de sistema que no estan siendo eliminados, que son parte del deviceTreeOverlay
