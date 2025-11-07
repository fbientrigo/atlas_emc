Basandome en
[EMCI-EMP / emp-firmware · GitLab](https://gitlab.cern.ch/emci-emp/emp-firmware)

Dentro existen distintos ficheros:
- emp_lpGBT: contains one instance of the lpGBT-fpga and GBT-SC (IC) IP cores with an AXI bus for PS communcation. It also includes one CDC TX instance and one CDC RX instance from the TClink library.
- emp_transceivers_TE0807_v3: contains 13 MGT's instances and common cores.
    - Firefly = 12
    - SFP+ = 1
- emp_transceiver_sfp_v1: contains 1 MGT's instances and common cores. (**Excluded from this emp-firmware**)
- empfw_debughub: IP block to interact with emp-firmware via an AXI bus from PS (send reset signals, read emp-emci link information).
- emp-firmware-2023.2: example of block diagram composed of 13 emp_lpGBT instances, emp_transceivers intances (for sfp+ and firefly) and empfw_debughub instance, together with the PS part of the Zynq already assembled.


Los primeros 4 proyectos son independientes, y deben ser exportados como IP cores para ser usadas.
Entonces emp-firmware-2023.2 usa los IP cores para el diseño final

Para el uso:
1. Clone the repository
2. Open Vivado from emp-firmware directory and execute emp-firmware-2023.2.tcl script (source emp-firmware-2023.2.tcl)
	1. Notar que el assembly utiliza los IP cores de los otros proyectos, por ello se debe verificar que esta buscnado en el fichero correcto que es (../emp-firmware/)
		1. se dice que puede buscarse ne Settings -> IP -> repository
3. The project is created (check the block diagram) and can be compiled
4. Compile the project to generate the bitstream or the XSA file

___

Vivado RUN

Luego de la synthesis
"""
 [BD 41-759] The input pins (listed below) are either not connected or do not have a source port, and they don't have a tie-off specified. These pins are tied-off to all 0's to avoid error in Implementation flow.
Please check your design and connect them as needed: 
/emp_lpgbt_0/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_1/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_2/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_3/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_5/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_6/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_7/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_8/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_9/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_10/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_11/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_4/lpgbtfpga_downlinkUserData_i
"""


Luego run implementation

![[assets/firmware/2024/09/implementation-warning-violation.png]]

![[assets/firmware/2024/09/implementation-criticalwarning.png]]

El critical Warning más detallado
![[assets/firmware/2024/09/implementation-criticalwarning-detailed.png]]


