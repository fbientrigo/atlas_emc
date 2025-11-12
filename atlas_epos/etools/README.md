# Scripts

## loadFirmware

loadFirmware is a bash script designed to be run on a Zynq device, assuming that the FPGA-manager and device tree overlays are configured. The script loads a given .dtbo file into the system. This script is intended to be used along with "xsa-to-overlays".

### How to use:

1. Place the .dtbo file in the following location on the Zynq's rootFS: `/lib/firmware/`
2. Boot the Zynq device.
3. Run the script with the name of your .dtbo file as an argument.

You can also use the following optional arguments:

- `-l` or `--list`: Lists all the available firmware files in the `/lib/firmware/` directory.
- `-h` or `--help`: Displays help information related to script usage.

Please note that the script assumes the firmware files are located in the `/lib/firmware/` directory. If your firmware files are located elsewhere, you might need to adjust the script accordingly.

## Error Handling

The script has built-in error handling. If an error occurs during any of the execution steps, the script will display an appropriate error message and exit.

### Known bugs

- If you attempt to run the script while some firmware is already loaded, it may cause issues. It is recommended to unload any existing firmware before running the script.

---

## Next Steps: Deploy LpGbtSw
To continue with deploying the LpGbtSw, check out the [LpGbtSw Repository on GitLab](https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw).

---

##  Contact
For any support or questions related to the ***epos***, please contact me at [paris.moschovakos@cern.ch](mailto:paris.moschovakos@cern.ch).
