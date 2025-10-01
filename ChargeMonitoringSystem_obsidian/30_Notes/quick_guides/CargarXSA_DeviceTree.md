Todo esto lo tengo en un Ubuntu20
```bash
wsl -d Ubuntu-20.04
```

Luego es necesario exportar algunas varaibles
```bash
export PATH=$PATH:/home/fabi/petainstaller/tools/xsct/bin/
source ~/vivado_install/Vitis/2023.2/settings64.sh
```


Entonces a cargar el xsa generado por vivado
En este ejemplo el .xsa generado se llama
```
0924_emp_const_E001.xsa
```

Entonces utilizamos el xsa generado, el cual debe de encontrarse en nuestro sistma Ubuntu20

Ocurren bugs si no esta junto al ejecutable.py
```bash
cd ~/atlas_epos/etools/xsa-to-overlays/xsa-to-overlays
mv /mnt/c/emp_firmware_02/emp-firmware-2023.2/*.xsa .
```


puede cambiar dependiendo del folder que se elija, por ejemplo, esto es desde un backup
```bash
mv /mnt/c/backup/emp_firmware_02_generateAll/emp-firmware-2023.2/*.xsa .
```

Entonces se procede a ejecutar esto
```bash

./emp-xsa-to-overlays.py <nombre_archivo>.xsa

```
	
Luego copiarlo hacia el sistema,
notar que se sobreescribe un archivo importante que podria tener relacion con que el lgpbt no responda correctamente
```bash
scp output/* tgc_cms@trenz-tgc:/lib/firmware/


```