Esta sección se enfoco en encontrar precisamente el nombre exacto de la Zynq siendo usada en el proyecto, a modo de tener los esquematicos correctos.

[[TE0807-3 FPGA Mezz Connected]]

Se comenzó por bootear leyendo con PuTTY, a lo que salto el nombre
- U‑Boot vs ZynqMP, “Silicon: v3”, “Chip: zu4e"
	- sugiere un SoM de la familia
		- **ZU4EG / ZU4…** (UltraScale+ EG).
	- por tanto hay una variante: **XCZU4EG‑1FBVB900E**
		- **TE0807‑03‑4BE21** (o alguna variante con “4BE21‑X / 4BE21‑AK”

Tras identificar las caracteristicas:
En recursos públicos, el TE0807‑03‑4BE21‑A / AK aparece con ese chip (“XCZU4EG‑1FBVB900E”), memoria de 4 GB DDR4, Flash 128 MB

[TE0807-03-4BE21-AK Trenz Electronic GmbH | Integrated Circuits (ICs) | DigiKey](https://www.digikey.com/en/products/detail/trenz-electronic-gmbh/TE0807-03-4BE21-AK/20418082)


"""
[tgc_cms@trenz-tgc device-tree]$ hexdump -C /proc/device-tree/compatible
00000000  78 6c 6e 78 2c 7a 79 6e  71 6d 70 00              |xlnx,zynqmp.|
0000000c

"""

El árbol device-tree muestra “compatible” como `"xlnx,zynqmp"`, lo que confirma que es Zynq MPSoC, lo cual es lo que usa esa serie de TE0807.

Lo más probable es que el modulo preciso sea
TE0807‑03‑4BE21‑A

Se procede entonces a compilar
[[0912-compilando_empfirmwarev0.2]]