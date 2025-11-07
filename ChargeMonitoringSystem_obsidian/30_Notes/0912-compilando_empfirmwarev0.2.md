Esta vez se tomó a partir del tag v0.2 para encontrar si así se tenian los nombres default buscados.
La polaridad fue modificada como se indicaba para Trenz CarrierBoard
![[assets/firmware/2024/09/mgt-polatiry-options-02v.png]]

la compilación acabó con unos avisos
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
/emp_lpgbt_12/lpgbtfpga_downlinkUserData_i
/emp_lpgbt_4/lpgbtfpga_downlinkUserData_i
"""

asumo que debido a como esta configurado, osea es un proyecto base para desarrollar encima, entenderé que estos pins se encuentran desconectados
- pero preguntaré de todas formas si esto puede tener un efecto importante
	- pues para temas de esteo puede no ser necesario
	- claramente lo será cuando conectemos más partes

Luego se procede a correr Implementación hasta tener el Hardware Description con el bitstream
[[0915-xsa to the fpga]]