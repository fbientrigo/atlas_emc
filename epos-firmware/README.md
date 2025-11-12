# :warning: Important Note :warning:

Before starting with this repository, you should be aware that the necessary tools for building the OS can be found in the [epos repository](https://gitlab.cern.ch/emci-emp/epos). This is vital for setting up your environment. However, the firmware and the software can be deployed independently. It is not mandatory to start with one or the other first. 

**EMP firmware**

This repository consists of the following Vivado projects:
- emp_lpGBT: contains one instance of the lpGBT-fpga and GBT-SC (IC) IP cores with an AXI bus for PS communcation. It also includes one CDC TX instance and one CDC RX instance from the TClink library.
- emp_transceivers_TE0807_v3: contains 13 MGT's instances and common cores.
    - Firefly = 12
    - SFP+ = 1
- emp_transceiver_sfp_v1: contains 1 MGT's instances and common cores. (**Excluded from this emp-firmware**)
- empfw_debughub: IP block to interact with emp-firmware via an AXI bus from PS (send reset signals, read emp-emci link information).
- emp-firmware-2023.2: example of block diagram composed of 13 emp_lpGBT instances, emp_transceivers intances (for sfp+ and firefly) and empfw_debughub instance, together with the PS part of the Zynq already assembled.

The first 4 projects are independent projects that need to be exported as an IP core to be used (for example, in a block diagram).
The emp-firmware-2023.2 project uses the IP cores to create the final design. This serves as an example for the user's design. This example uses up to 13 channels to interface up to 13 different EMCIs. The 13 EMCIs can be monitored by means of the IC channel of the lpGBT via the LpGbtSw. In order to use out-of-the-box, the Zynq must have previously installed a Linux OS. For more information on how set this up visit https://gitlab.cern.ch/emci-emp/epos

    
Steps for using the out-of-the-box assembly:
1. Clone the repository
2. Open Vivado from emp-firmware directory and execute emp-firmware-2023.2.tcl script (source emp-firmware-2023.2.tcl)
3. The project is created (check the block diagram) and can be compiled
4. Compile the project to generate the bitstream or the XSA file

Note: the assembly uses the IP cores from the other projects. Check that Vivado is searching in the right folder for the IP cores (../emp-firmware) in Settings -> IP -> repository

If the user wants to modify specific IP cores (such as emp_lpGBT), they can simply use the IP Packager to do so. Once the changes have been made, the IP must be repacked and regenerated.

**Use of new generic_transceiver: emp_transceivers_TE0807_v3**

The emp_transceivers_TE0807_v3 is merged a version of transceiver_firefly_v1 and transceiver_sfp_v1. 

Communication selector:
- The selector is used to access either Firefly or SFP+.

For Firefly:
- Click the dropdown list and select 'Firefly'. This will enable channel 0-11 as default.

For SFP+:
- Click the dropdown list and select 'SFP+'. This will enable channel 12 as default.

**Important Notice on polarity setting** 

Several lines were swapped on the EMP baseboard to improve the routing of the differential lines between SoM and Firefly. 
This results in a difference in the firmware settings regarding the polarity of the MGT TX & RX channels for the different baseboards.

For the EMP baseboard v2:
- MGT FF RX Polarity Inv: 0xE07
- MGT FF TX Polarity Inv: 0xFFF
- MGT SFP RX Polarity Inv: "0"
- MGT SFP TX Polarity Inv: "1"

For the Trenz baseboard & EMP baseboard v1:
- MGT RX Polarity Inv: 0xFFF
- MGT TX Polarity Inv: 0x000
The settings can be set in the customization parameter settings of the emp_transceiver ip block.
    
**When pushing:**
1. Generate tcl script for project re-built (File -> Project -> Write Tcl (all options unchecked) OR write_project_tcl)
2. Run gitgnore_update.py script. This will create gitignore file appropiately and will modify tcl file so the project can be re-built
3. Push repository 





**IP cores functionality description**

**emp_lpGBT**

This core consists of a single pipeline for interacting with one lpGBT (FEC5 and 10.24Gbps mode). It uses the cores lpGBT_FPGA (https://gitlab.cern.ch/gbt-fpga/lpgbt-fpga) and  GBT_SC (IC only) (https://gitlab.cern.ch/gbtsc-fpga-support/gbt-sc). It needs to work together with transceivers_X IP core.

The description of the ports is the following:

- AXI_ADDR_WIDTH (generic): should be 32
- BASEADDR (generic): used to specify the AXI base register address. Each emp_lpgbt instance should have a different address.

- MGT_RXUSRCLK_i (input): RX user clock for MGT coming from transceivers_x IP.
- MGT_TXUSRCLK_i (input): MGT 320 MHz reference clock.
- MGT_RXSlide_o (output): MGT slide signal for alignment going to transceivers_x IP.
- MGT_USRWORD_o (ouput): RX MGT paralelized word (not decoded) coming from transceivers_x IP.
- MGT_USRWORD_i (ouput): TX MGT paralelized word (already coded) going to transceivers_x IP.

- clk_uplink_40MHz_o (output): clock synq with the uplink word (40 MHz domain). Used to get data from lpgbtfpga_uplinkUserData_o, lpgbtfpga_uplinkEcData_o and lpgbtfpga_uplinkIcData_o
- clk_downlink_40MHz_o (output): clock synq with the downlink word (40 MHz domain). Used to provide data to lpgbtfpga_downlinkUserData_o
- logicCLK40_i (input): Input for 40 MHz logic clock from MGT and synq with the 320 MHz MGT reference clock.
- lpgbtfpga_uplinkUserData_o (output): uplink word containing all information of the elinks. Coding depends on uplink speed.
- lpgbtfpga_uplinkEcData_o (output): uplink EC channel output (not enabled)
- lpgbtfpga_downlinkIcData_s (output): uplink EC channel output. Normally not used. Use AXI interface with GBT_SC IC instead.
- lpgbtfpga_downlinkUserData_i (input): downlink word containing all information of the elinks. Coding depends on downlink speed.

- EXT_RST: reset signal controled via empfw_debughub from PS.
- AXI interface: connected to ZYNQ PS. Used to interface with the IC channel. The register map is defined via AirHDL (emp_lpgbt_ic_clerk).

- int_lpgbt_resp: high level interrupt triggered when the EMP receives back any IC channel message from lpGBT. It is cleared via AXI regmap.

**Regarding critical warnings:**

- The critical warning currently appearing is related to the channels not generated for both 'transceiver_firefly' and 'transceiver_sfp' where .xdc files isn't found and not read for any cell of the module where they are "not generated". There is a solution or fix to this, where the issues regarding the errors has been fixed for Vivado version 2023.1 and following versions. The link down below explains that if you use Vivado 2023.1 or newer, you can ignore these error messages.
- https://support.xilinx.com/s/article/000034045?language=en_US



