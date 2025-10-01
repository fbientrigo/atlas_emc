Se quiere probar, basandonos en
[[Setup EMP development environment & reference project.pdf]]
cuales de estos programas son capaces de correr en el firmware de la rama master
[[0912-compilando_empfirmwarev0.2]]

Normalmente el que confirmamos su funcionalidad fue el v0.2,
la rama master no enciende una luz indicativa de ready pero se probará de todas formas

### Carga
```bash
[tgc_cms@trenz-tgc ~]$ sudo ./epos/etools/loadFirmare.sh -l
[sudo] password for tgc_cms:
Firmware files:
emp_fw_TE0807_wrapper.dtbo
hw_emp_TE0807.dtbo
latest_emp_fw_0919.dtbo
[tgc_cms@trenz-tgc ~]$ sudo ./epos/etools/loadFirmare.sh latest_emp_fw_0919.dtbo
Firmware 'latest_emp_fw_0919.dtbo' was successfully loaded.
```

## Configurando el PiGbt y EMCI
Ambos circuitos son alimentados por una fuente de voltaje a 10V/1A
Luego es necesario ingresar al sistema mediante su señal wifi para modificarlo
## Programas

### clkProgrammer
```bash
[tgc_cms@trenz-tgc ~]$ sudo clkProgrammer -c
StdOutLog::initialize
2025-09-23 11:43:27.544195 [main_si5345.cpp:115, INF] Configuring SI5345 - Exceptions are listed below
2025-09-23 11:43:29.423467 [main_si5345.cpp:117, INF] Configuration finished without exceptions!
[tgc_cms@trenz-tgc ~]$ sudo clkProgrammer -i
StdOutLog::initialize
2025-09-23 11:43:32.505341 [main_si5345.cpp:55, INF] Revision           3
2025-09-23 11:43:32.509561 [main_si5345.cpp:61, INF] LOS                OK (0000)
2025-09-23 11:43:32.509721 [main_si5345.cpp:66, INF] LOSXAXB            OK
2025-09-23 11:43:32.515262 [main_si5345.cpp:72, INF] LOS FLG            LOS flag set (1111)
2025-09-23 11:43:32.515415 [main_si5345.cpp:77, INF] LOSXAXB FLG        LOSXAXB flag set
2025-09-23 11:43:32.521041 [main_si5345.cpp:83, INF] OOF                OK (0000)
2025-09-23 11:43:32.524721 [main_si5345.cpp:89, INF] OOF FLG            OOF flag set (1111)
2025-09-23 11:43:32.524873 [main_si5345.cpp:94, INF] LOL                OK
2025-09-23 11:43:32.526893 [main_si5345.cpp:99, INF] LOL FLG            LOL flag set
```

En este caso las configs son:
- Loss of Signal (LOS) Status Monitoring  
	- LOS status monitor for IN3 (bit 3), IN2 (bit 2), IN1 (bit 1) and IN0 (bit 0), indicating if a valid clock is detected. If the bit is set the input is lost. 
	- LOSXAXB status monitor for the crystal or reference clock connected to the XA/XB pins. 
	- LOS FLG status monitor sticky bits for IN3, IN2, IN1 and IN0. Sticky bits will remain asserted when a LOS event occurs until cleared. Writing zero to the bit will clear it. 
	- LOSXAXB FLG status monitor sticky bits for XA/XB. Sticky bits will remain asserted when a LOS event occurs until cleared. Writing zero to the bit will clear it. 
- Out-of-Frequency (OOF) Status Monitoring 
	- OOF status monitor for IN3, IN2, IN1, IN0. Indicates if a valid clock is detected or if a OOF condition is detected. 
	- OOF FLG status monitor sticky bits for IN3, IN2, IN1, IN0. Stick bits will remain asserted when an OOF event occurs until cleared. Writing zero to the bit will clear it. 
- Loss of Lock (LOL) Status Monitoring
	- LOL status bit that indicates if the DSPLL is locked to an input clock
	- LOL FLG sticky bits for LOL register. Writing 0 to a sticky bit will clear it.

### tempSensor
No funciona correctamente 
```bash
[tgc_cms@trenz-tgc ~]$ sudo ./clk_files/EMPToolsArtifacts/bin_EMP/tempSensor -h
Options:
  -h [ --help ]             show help
  -d [ --device ] arg (=-1) Select Sensor 0-2
                            Sensor 0: Close under SoM
                            Sensor 1: Between Fireflies
                            Sensor 2: Close to DCDCs

  -c [ --configure ]        Sensor auto configuration for conversion rate,
                            timeout and resolution.
  -r [ --read_temp ]        Sensor temperature readout

[tgc_cms@trenz-tgc ~]$ sudo ./clk_files/EMPToolsArtifacts/bin_EMP/tempSensor -d 0 -r
StdOutLog::initialize
2025-09-23 11:52:50.110357 [main_max31827.cpp:67, INF] Reading temperature of sensor 0
2025-09-23 11:52:50.110728 [main_max31827.cpp:69, INF] Temperature:
2025-09-23 11:52:50.111326 [main_max31827.cpp:78, ERR] Failed to write to I2C device
2025-09-23 11:52:50.111478 [main_max31827.cpp:79, ERR] --help to check options
[tgc_cms@trenz-tgc ~]$ sudo ./clk_files/EMPToolsArtifacts/bin_EMP/tempSensor -d 0 -c
StdOutLog::initialize
2025-09-23 11:52:52.610958 [main_max31827.cpp:61, INF] Configuring sensor 0
2025-09-23 11:52:52.611776 [main_max31827.cpp:78, ERR] Failed to write to I2C device
2025-09-23 11:52:52.611932 [main_max31827.cpp:79, ERR] --help to check options
[tgc_cms@trenz-tgc ~]$
```

### fireflyI2C
```bash
[tgc_cms@trenz-tgc ~]$ find . -type f -name "fireflyI2C"
./clk_files/EMPToolsArtifacts/bin_EMP/fireflyI2C
[tgc_cms@trenz-tgc ~]$ sudo ./clk_files/EMPToolsArtifacts/bin_EMP/fireflyI2C -h
Options:
  -h [ --help ]              show help
  -m [ --module ] arg (=-1)  Select 0 (TX) or 1 (RX)
  -i [ --read_ddm ]          Read Digital Diagnostic Monitoring from FF.
                             Requires to select a device
  -c [ --channel ] arg (=-1) Select channel. Required for activating,
                             deactivating and setting the output amplitude
                             [0-11].
  -d [ --disable ]           Deactivates a selected channel on both modules.
  -e [ --enable ]            Activates a selected channel on both modules.
  -a [ --amplitude ] arg     Select the amplitude output mode ['low', 'med',
                             'high'].
  -r [ --reset ]             Resets the Firefly modules.

[tgc_cms@trenz-tgc ~]$ sudo ./clk_files/EMPToolsArtifacts/bin_EMP/fireflyI2C -m 1 --read_temp
terminate called after throwing an instance of 'boost::wrapexcept<boost::program_options::unknown_option>'
  what():  unrecognised option '--read_temp'
        ^CAborted
[tgc_cms@trenz-tgc ~]$ sudo ./clk_files/EMPToolsArtifacts/bin_EMP/fireflyI2C -m 1 -i
StdOutLog::initialize
2025-09-23 11:55:20.564988 [main_firefly.cpp:171, ERR] Failed to read from I2C device
2025-09-23 11:55:20.565393 [main_firefly.cpp:172, ERR] --help to check options
[tgc_cms@trenz-tgc ~]$
```

### sfpI2C
```bash
[tgc_cms@trenz-tgc ~]$ find . -type f -name "sfpI2C"
./clk_files/EMPToolsArtifacts/bin_EMP/sfpI2C
./clk_files/EMPToolsArtifacts/bin_TRENZ/sfpI2C
./artifacts_TRENZ/sfpI2C
[tgc_cms@trenz-tgc ~]$ which sfpI2C
/usr/bin/sfpI2C
[tgc_cms@trenz-tgc ~]$ sfpI2C -h
Options:
  -h [ --help ]            show help
  -d [ --disable_tx ]      Disable TX.
  -e [ --enable_tx ]       Enable TX.
  -i [ --read_ddm ]        Read Digital Diagnostic Monitoring information of
                           SFP
  -n [ --device ] arg (=0) Select SFP 0 or SFP 1 [0,1]
  -v [ --verbose ]         Show more monitoring Information

[tgc_cms@trenz-tgc ~]$ sudo sfpI2C -i
StdOutLog::initialize
Segmentation fault (core dumped)
[tgc_cms@trenz-tgc ~]$ sudo sfpI2C -vi
StdOutLog::initialize
Segmentation fault (core dumped)
```


### fwReset
""
The fwReset tool can be used to interface the empfw_debughub IP inside the emp-firmware in order to send a reset signal. This means that the user can send a reset signal to a dedicated emp-emci pipeline to reset the emp_lpgbt IP (including the lpgbt_fpga IP and the GBTx IP) as well as the TX and RX unit of a transmission channel. When using the emp_lpgbt option, the emp_lpgbt fabric is reset first, followed by the transmitter and then the receiver. If the tx_path option is used, only the sender is reset, while the rx_path option resets the
""


```bash
[tgc_cms@trenz-tgc ~]$ sudo fwReset --id 11
StdOutLog::initialize
2025-09-23 12:00:22.254108 [uioFunctions.cpp:25, ERR] Could not find UIO device

uio_open: Invalid argument
2025-09-23 12:00:22.254515 [uioFunctions.cpp:29, ERR] Could not open UIO device

2025-09-23 12:00:22.254766 [fwReset.cpp:91, INF] Reseting emp_lpgbt_11
2025-09-23 12:00:22.254938 [uioFunctions.cpp:50, ERR] Failed to write RESET to emp_lpgbt ip
2025-09-23 12:00:22.255262 [fwReset.cpp:98, ERR] uio_write32 failed
2025-09-23 12:00:22.255435 [fwReset.cpp:99, ERR] --help to check options
terminate called after throwing an instance of 'std::logic_error'
  what():  basic_string::_M_construct null not valid
Aborted
```

### fwMonitor
"""
The fwMonitor is a tool that allows the user to check the status of each emp-emci pipeline. If the program is called without options and arguments, an overview of all pipelines is displayed. 
"""

```bash
[tgc_cms@trenz-tgc ~]$ sudo fwMonitor -h
Options:
  -h [ --help ]         show help
  --id arg (=-1)        Select the specific emp_lpgbt pipeline [0-12]

[tgc_cms@trenz-tgc ~]$ sudo fwMonitor --id 11
StdOutLog::initialize
2025-09-23 12:01:37.495504 [uioFunctions.cpp:25, ERR] Could not find UIO device

uio_open: Invalid argument
2025-09-23 12:01:37.495862 [uioFunctions.cpp:29, ERR] Could not open UIO device

2025-09-23 12:01:37.496027 [uioFunctions.cpp:98, ERR] Failed to read TX-ALIGNMENT
terminate called after throwing an instance of 'std::runtime_error'
  what():  uio_read32 failed
Aborted
```

___

## Testeo

Utilizando la versión de firmware de la branch Master
```bash
[tgc_cms@trenz-tgc Demonstrators]$ sudo LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_11 -r 0x00
StdOutLog::initialize
2025-09-23 12:59:14.256242 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_11
terminate called after throwing an instance of 'std::runtime_error'
  what():  LpGbtSw exception: Could not find UIO device emp_lpgbt_11
[/home/tgc_cms/LpGbtSw0.6/LpGbtUioBackend/LpGbtUioFunctions.cpp:37] in function "uio_info_t* LpGbtUio::initUio(const string&)"
Aborted
[tgc_cms@trenz-tgc Demonstrators]$ sudo LpGbtConfiguration/lpGbtConfiguration -a lpgbt-uio://emp_lpgbt_10
StdOutLog::initialize
2025-09-23 12:59:43.641688 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10
terminate called after throwing an instance of 'std::runtime_error'
  what():  LpGbtSw exception: Could not find UIO device emp_lpgbt_10
[/home/tgc_cms/LpGbtSw0.6/LpGbtUioBackend/LpGbtUioFunctions.cpp:37] in function "uio_info_t* LpGbtUio::initUio(const string&)"
Aborted
```


Utilizando la versión de firmware de la tag 0.2v
```bash
[tgc_cms@trenz-tgc Demonstrators]$ sudo ./LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00
StdOutLog::initialize
2025-09-23 14:38:47.234172 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt                                                           -uio://emp_lpgbt_10
2025-09-23 14:38:47.413190 [LpGbtUioBackend.cpp:21, INF] Initializing uio device                                                            'emp_lpgbt_10'
2025-09-23 14:38:47.413473 [LpGbtUioBackend.cpp:24, INF] The magic number for th                                                           is uio device is: 656d7049
Read: Register Address: 0 Value: 0x00

[tgc_cms@trenz-tgc Demonstrators]$ sudo ./LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_11 -r 0x00
StdOutLog::initialize
2025-09-23 14:38:58.615665 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_11
2025-09-23 14:38:58.787698 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_11'
2025-09-23 14:38:58.787978 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049
terminate called after throwing an instance of 'std::runtime_error'
  what():  LpGbtSw exception: Failed to wait for IRQ for /dev/uio7
[/home/tgc_cms/LpGbtSw0.6/LpGbtUioBackend/LpGbtUioFunctions.cpp:183] in function "void LpGbtUio::waitIntr(uio_info_t*, int)"
[18225.324175] Pid 4269(systemd-coredum) over core_pipe_limit
[18225.329672] Skipping core dump
Aborted

```

Por lo que se observa la rama 0.2v logra pedir datos y se queda esperando el IRQ, que encontramos radicaba en un problema de la conexión.
