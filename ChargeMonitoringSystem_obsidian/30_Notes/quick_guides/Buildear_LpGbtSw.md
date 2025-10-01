Lo primero será conseguir la API de gitlab
```bash
mkdir LpGbtSw
cd LpGbtSw/

git clone --branch 0.6.0 --single-branch --depth 1 https://gitlab.cern.ch/atlas-dcs-emp/LpGbtSw.git .
```
Y es importante para incluir los submodulos, si no se hace esto se encontrará un error en donde no encuentra el resto del material
```bash
git submodule update --init --recursive
```

Las librerias que usa y no vinen instaladas
```
sudo dnf install boost-devel boost-program-options boost-system boost-filesystem
```

Para ello se debe de ir hacia el root
```bash
sudo ./build.sh
```

Despues en build hacemos el make
```bash
cd build
make -j$(nproc)
```


El comando tipico para testear:
```bash
sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00
```


Se puede testear en masa
```bash
for i in $(seq 0 11); do
  echo "=== probando emp_lpgbt_$i ==="
  sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_$i -r 0x00
done
```