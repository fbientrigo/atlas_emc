Aqui una lista con los distintos firmwares que se han hecho y cargado dentro del sistema
Tambien se encuentran sus contrapartes en el wsl de ubuntu 20.04
```
0924_emp_const_E001.xsa          dt_overlay.tcl          emp_fw_TE0807_boardchoosen.xsa  emp_prbs.xsa     latest_emp_fw_0919.xsa
 emp_fw_TE0807_wrapper.xsa       emp_tcl_gen.xsa  
```

Para probar las distintas configuraciones se hace conectado a PiGbt y ppr PuTTY

```bash
sudo epos/etools/loadFirmare.sh -l

sudo LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00
```

entre cada carga de firmware, se reinicia el sistema para evitar cualquier sesgo
##  emp_fw_TE0807_wrapper.dtbo
- version del firmware desconocida, este archivo se encontraba desde el inicio
- compilador xsa desconocido
- La programación es posible, funciona correctamente
- no presenta cambios significativos en el funcionamiento, lpgbt se programa correctamnete

## hw_emp_TE0807.dtbo
- versión del firmware 0.2v
- xsa master
- se ha comprobado que funcionó almenos una vez
- pero a vuelto a no marcar el IRQ

## emp_fw_TE0807_boardchoosen.dtbo
Se hizo cambiando la config default que viene y eligiendo una board especifica que calzara con TE0808-04 y la TE0807-03
- versión del firmware 0.2v (identica a la funcional)
- compilador xsa (master, sep 2025)
- La programación es posible, funciona correctamente
- no presenta cambios significativos en el funcionamiento, lpgbt se programa correctamnete
## emp_tcl_gen.dtbo
```bash
sudo epos/etools/loadFirmare.sh emp_tcl_gen.dtbo
```

- construido generando primero los distintos tcl
	- se genero emp_lpgbt, y emp_elinks antes de generar el base .tcl de todo el proyecto
- sin embargo parece que el haber cambiado nombres de proyecto para permitir la generación afecto alguna conexión


```
[tgc_cms@trenz-tgc LpGbtSw]$ sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r StdOutLog::initialize
2025-09-29 14:54:37.505025 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10
2025-09-29 14:54:37.682665 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_10'
2025-09-29 14:54:37.682943 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049
Read: Register Address: 12e Value: 0x00
```

![[firmware_using.png]]




___

### 0924_emp_const_E001.dtbo
- firmware 0.2v
- xsa master
- se envia una constante por downlink

### latest_emp_fw_0919
- firmware master
- xsa master