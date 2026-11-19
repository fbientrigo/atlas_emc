# CLIs para los mapas generados

Las fuentes corresponden a `read_all_lpgbt/` y `puzzled_working/` de la Trenz. Compila en la placa con GCC/G++, Make y libuio instalada. Los ejemplos parten de la raíz del repositorio.

| CLI | Mapa AirHDL | Qué hace |
|---|---|---|
| [tgc_readuplink_cli](tgc-uplink/) | [tgc_readUplink rev27](../tgc_readUplink_regs.json) | Lee el banco UIO `tgc_readUplink_regs` en `0xA00E0000`. |
| [readprbs_cli](prbs/) | [Read_PRBS rev9](../saved_json/Read_PRBS_regs.json) | Lee o escribe el bloque de prueba `Read_PRBS_regs` en `0xA00D0000`, según las opciones. |

```bash
g++ -std=c++17 -O2 -I puzzledWizards/compilados/tgc-uplink \
  puzzledWizards/compilados/tgc-uplink/tgc_readuplink_cli.cpp \
  puzzledWizards/compilados/tgc-uplink/TgcReadUplink.cpp \
  -luio -o puzzledWizards/compilados/tgc-uplink/tgc_readuplink_cli

make -C puzzledWizards/compilados/prbs cli
puzzledWizards/compilados/prbs/readprbs_cli --help
```

Si los headers viven en `~/libuio`, agrega `-I "$HOME/libuio"` a G++ y `UIO_HEADERS="$HOME/libuio"` a Make.

`readprbs_cli_minimal.cpp` es el ensayo histórico que escribe `0xAAAAEEEE` al ejecutarse. Para sólo consultar PRBS, usa `readprbs_cli --by-name Read_PRBS_regs --read-magic --read-status --read-data` con el mapa confirmado.

`tgc_readuplink_cli` abre el hardware al arrancar, incluso con `--help`. Para uso diario, [emp](../../capture/) añade diagnóstico, monitor y captura CSV. [AirHDL rev29](../../airhdl/) documenta la interfaz de eventos CMB.
