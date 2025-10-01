De acuerdo con lo conversado en la reunión,
el acceso a los dispositivos i2c que no era posible, acaba siendo necesario ejecutarse con sudo para funcionar correctamente.

Por ejemplo usar herramientas para chequear los dispositivos
```
[tgc_cms@trenz-tgc ~]$ sudo i2cdetect -l
[sudo] password for tgc_cms:
i2c-0   i2c             Cadence I2C at ff020000                 I2C adapter
i2c-1   i2c             i2c-0-mux (chan_id 0)                   I2C adapter
i2c-2   i2c             i2c-0-mux (chan_id 1)                   I2C adapter
i2c-3   i2c             i2c-0-mux (chan_id 2)                   I2C adapter
i2c-4   i2c             i2c-0-mux (chan_id 3)                   I2C adapter
i2c-5   i2c             i2c-0-mux (chan_id 4)                   I2C adapter
i2c-6   i2c             i2c-0-mux (chan_id 5)                   I2C adapter
i2c-7   i2c             i2c-0-mux (chan_id 6)                   I2C adapter
i2c-8   i2c             i2c-0-mux (chan_id 7)                   I2C adapter
i2c-9   i2c             i2c-0-mux (chan_id 0)                   I2C adapter
i2c-10  i2c             i2c-0-mux (chan_id 1)                   I2C adapter
i2c-11  i2c             i2c-0-mux (chan_id 2)                   I2C adapter
i2c-12  i2c             i2c-0-mux (chan_id 3)                   I2C adapter
i2c-13  i2c             i2c-0-mux (chan_id 4)                   I2C adapter
i2c-14  i2c             i2c-0-mux (chan_id 5)                   I2C adapter
i2c-15  i2c             i2c-0-mux (chan_id 6)                   I2C adapter
i2c-16  i2c             i2c-0-mux (chan_id 7)                   I2C adapter
```

En cuanto a los temas relacionados con el reloj, a su vez es necesario el uso de sudo
```
[tgc_cms@trenz-tgc LpGbtSw]$ sudo clkProgrammer -i
[sudo] password for tgc_cms:
StdOutLog::initialize
2025-09-19 15:28:55.008696 [main_si5345.cpp:55, INF] Revision           3
2025-09-19 15:28:55.012911 [main_si5345.cpp:61, INF] LOS                OK (0000)
2025-09-19 15:28:55.013080 [main_si5345.cpp:66, INF] LOSXAXB            OK
2025-09-19 15:28:55.018661 [main_si5345.cpp:72, INF] LOS FLG            OK (0000)
2025-09-19 15:28:55.018821 [main_si5345.cpp:77, INF] LOSXAXB FLG        OK
2025-09-19 15:28:55.024445 [main_si5345.cpp:83, INF] OOF                OK (0000)
2025-09-19 15:28:55.028120 [main_si5345.cpp:89, INF] OOF FLG            OK (0000)
2025-09-19 15:28:55.028308 [main_si5345.cpp:94, INF] LOL                OK
2025-09-19 15:28:55.030332 [main_si5345.cpp:99, INF] LOL FLG            OK
```


Se probó el uso para las herramientas construidas con LpgbtSw
```


```


___

Utilizando el software

![[registarmapSimualtorWRN.png]]


Se encuentra un problema relacionado a la configuration file
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo ./build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration -r
StdOutLog::initialize
2025-09-19 16:49:25.179706 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_4
terminate called after throwing an instance of 'std::runtime_error'
  what():  LpGbtSw exception: Could not find UIO device emp_lpgbt_4
[/home/tgc_cms/LpGbtSw0.6/LpGbtUioBackend/LpGbtUioFunctions.cpp:37] in function "uio_info_t* LpGbtUio::initUio(const string&)"
Aborted
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo ./build/Demonstrators/LpGbtConfiguration/lpGbtConfiguration lpgbt-uio://emp_lpgbt_10 -r
StdOutLog::initialize
terminate called after throwing an instance of 'std::runtime_error'
  what():  The configuration file doesn't exist
Aborted
```




