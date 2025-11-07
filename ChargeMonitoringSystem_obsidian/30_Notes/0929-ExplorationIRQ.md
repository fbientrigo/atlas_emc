Hipotesis:
H0: El problema puede radicar en la creación del firmware de Vivado, se ha probado:
- regenerar el firmware en distintas versiones
	- en donde la Master simplemente no hace el lock
	- Se ha cambiado a branch distintas de
		- LpGbtSw: 0.5.0, 0.6.0
			- la cual la 0.6.0 parece la más actualizada y con formato de codigo más comodo
		- emptools xsa to dto: master, 0.3.0
			- ambas dando resultados identicos a la hora de esperar el IRQ

Relacionado a este nivel se menciona de una señal `int_lpgbt_resp` en el README de [EMCI-EMP / emp-firmware · GitLab](https://gitlab.cern.ch/emci-emp/emp-firmware/-/tree/emp_fw_v0.2?ref_type=tags)

int_lpgbt_resp: 
	high level interrupt triggered when the EMP receives back any IC channel message from lpGBT. It is cleared via AXI regmap.

Si exploramos todo el codigo relacionado a esto:
existen los debidos puertos para cada lpgbt
```
        ]
      },
      "emp_lpgbt_10_int_lpgbt_resp": {
        "ports": [
          "emp_lpgbt_10/int_lpgbt_resp",
          "xlconcat_5/In1"
        ]
```


en https://gitlab.cern.ch/emci-emp/emp-firmware/-/blob/master/emp_lpgbt/emp_lpgbt.srcs/component.xml
```xml
    </spirit:busInterface>
    <spirit:busInterface>
      <spirit:name>int_lpgbt_resp</spirit:name>
      <spirit:busType spirit:vendor="xilinx.com" spirit:library="signal" spirit:name="interrupt" spirit:version="1.0"/>
      <spirit:abstractionType spirit:vendor="xilinx.com" spirit:library="signal" spirit:name="interrupt_rtl" spirit:version="1.0"/>
```
- se indica como una señal 

en
`emp_lpgbt/emp_lpgbt.srcs/component.xml` se describe:
```xml
        <spirit:parameter>
          <spirit:name>SENSITIVITY</spirit:name>
          <spirit:value spirit:id="BUSIFPARAM_VALUE.INT_LPGBT_RESP.SENSITIVITY" spirit:choiceRef="choice_list_99a1d2b9">LEVEL_HIGH</spirit:value>
        </spirit:parameter>
      </spirit:parameters>
```
- una señal que tiene un sensitivity LEVEL_HIGH

___
## Posibles Fixings
Regeneremos el proyecto, pero esta vez generando cada archivo.tcl
Se deben cambiar en los archivos 

```
# Set the project name
set _xil_proj_name_ "emp_lpgbt"
```

```
# Set the project name
set _xil_proj_name_ "emp_elink_memory_interface"
```
- este requiere que la carpeta y subcarpeta calcen


Puesto que el proyecto no encontrará los archivos correctos.

### Chequeo del ruteo
el routing desde el lpgbt va como

emp_lpgbt_10: int_lpgbt_resp
	xlconcat_1: In2[0:0]

donde llega al PS y tiene los parametros:
- NULL:LEVEL_HIGH:LEVEL_HIGH:LEVEL_HIGH:LEVEL_HIGH:LEVEL_HIGH
![[assets/firmware/2024/09/xlconcat-1.png|250]]
- 

Finalmente se arreglo:
