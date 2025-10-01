El const agregado lo dejamos como downlink

![[dout_constvalue.png|700]]

Entonces se procede a hacer la compilación

### xsa_to_dt
Los pasos para tomar el bitstream son directos
[[CargarXSA_DeviceTree]]

Una vez hecho esto se carga con el script

## Testing comunicación
Luego hay que probar la comunicación una vez se encuentre el lpgbt

```bash
for i in $(seq 0 11); do
  echo "=== probando emp_lpgbt_$i ==="
   sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_$i -r 0x00
done
```

Explorar los registros de palabras
```bash
for i in $(seq 0 11); do
  echo "=== probando emp_lpgbt_$i ==="
   sudo ./build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_$i -r 0x12e
done
```


