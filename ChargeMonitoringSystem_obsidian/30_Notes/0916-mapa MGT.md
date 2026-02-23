# Uplink: desde MGT hasta UserData (y camino hacia IC/FIFO/Interrupt)

## Propósito de esta página

Documentar **el camino de datos uplink** desde el **MGT** (transceiver) hasta el **UserData público**, y conectar ese camino con la **ruta de IC → FIFO → FSM → interrupt/reset** que estuvimos rastreando.

La idea pedagógica: pensar en esto como una **pipeline por capas**:

1) **Transporte físico / MGT**: entrega palabras de N bits a alta frecuencia.  
2) **Gearbox + alineación**: reempaqueta a frames grandes a 40 MHz.  
3) **Deinterleaver + FEC/decoder + descrambler**: recupera datos útiles y corrige/limpia.  
4) **CDC (Clock Domain Crossing)**: cruza relojes hacia lógica “lenta” / dominio local.  
5) **Demux (User/EC/IC)**: separa caminos (UserData, EC, IC).  
6) **IC path**: entra al bloque IC, pasa por deserialización y FIFO, y puede disparar flags/interrupt.

---

## Conceptos clave (mini-glosario)

- **MGT**: transceiver (Multi-Gigabit Transceiver). Entrega “palabras” (word) a alta tasa.
- **USR_WORD / MGT_USR_WORD**: el bus de palabra usuario que sale del MGT hacia lógica.
- **Gearbox**: reempaqueta bits: de *palabras chicas a alta frecuencia* → *frames grandes a baja frecuencia*.
- **Frame aligner**: busca el borde de frame (sync), a veces basta con 1 bit de control/flag.
- **Deinterleaver**: reordena bits/bytes según el esquema del frame (aquí la parte “más compleja”).
- **FEC (Forward Error Correction)**: codificación/corrección de errores.
- **Descrambler**: revierte el scrambling para recuperar los datos reales.
- **CDC**: cruce de dominio de reloj (registros A→B para seguridad temporal).

---

# 1) Top-level: el MGT expone canales y alimenta al lpGBT

**MGT** expone canales externos y conecta al lpGBT mediante **`MGT_USR_WORD`**.

En `U0`:

- `MGT_USRWORD_i(32 bools)`
- `uplink_mgtword_s(32 bools)`

`uplink_mgtword_s` conecta hacia `lpgbtFpga_10g24`.

---

# 2) Cadena principal (U0 → lpgbtFpga_10g24 → uplink → UserData)

## 2.1 U0 → lpgbtFpga_10g24

En `lpgbtFpga_10g24`:

- `uplink_mgtword_i(32)`
- `uplink_mgtword_s(32)`

Luego conecta hacia `lpgbtfpga_uplink`.

---

## 2.2 lpgbtfpga_uplink: entrada desde MGT

En `lpgbtfpga_uplink`:

- `mgt_word_i(32)`  ← **input frame coming from MGT**

Esta señal:

- conecta a **frame aligner** (pero “solo 1 bit”, probablemente señal de alineación/validación).
- conecta a **`lpgbtfpga_rxGearbox`** (camino pesado de datos).

---

## 2.3 rxGearbox: de MGT-word a lpGBT-frame

En `lpgbtfpga_rxGearbox`:

- `dat_inFrame_i(32)`
- `dat_inFrame_s(32)`
- `reg0 (32 * clockratio)`
  - `reg1`
    - `rxFrame_inverted_s`
      - `dat_outFrame_s`
        - `dat_outFrame_o`

Conexión posterior:

- `dat_outFrame_o`  
  → `uplink_inst : gbxFrame_s(256)`
  → `gbxFrame_5g12_s`
  → `frame_pipelined_s(256)`
  → **deinterleaver**
    → `data_i`

> [!note] Comentario del código (interpretación)
> `lpgbtfpga_rxGearbox` sirve para pasar desde tamaño de palabra MGT (ej: 32b @ 320MHz)
> a tamaño de frame lpGBT (ej: 256b @ 40MHz).
>
> Esto implica: mismo throughput, distinta granularidad + distinto reloj.

---

# 3) Deinterleaver → FEC/Decoder → Descrambler → UserData

## 3.1 Deinterleaver (reordenamiento)

El **deinterleaver** es más complejo (varias formas de ordenar), y transforma `data_i` hacia:

- `fec5_data_10g24_s`

Luego:

- MUX a `fec5_data_s(234)` → `fec5_data_o(234)`
  - ← `uplink_inst: fec5_data_from_deinterleaver_s`

---

## 3.2 Decoder (corrección de errores)

`fec5_data_o(234)` entra al decoder:

- `lpgbtfpga_decoder : fec5_data_i`

Salida del decoder:
- `fec5_data_s` → `fec5_data_o`
- ← `uplink_inst: fec5_data_from_decoder_s(234)`

---

## 3.3 Descrambler (recuperar datos reales)

Luego entra a descrambler:

- `lpgbtfpga_descrambler : fec5_data_i`

Salida:
- `fec5_data_o(234)` → `fec5_data_from_descrambler_s(234)`

Esto produce datos de usuario:

- ← `uplink_inst : UserData_10g24_s`
- ← `uplink_inst : UserData_5g12_s`
  - `uplink_inst : userData_o(230)`

---

## 3.4 UserData hacia arriba (hasta puerto público)

`uplink_inst : userData_o(230)`
→ `lpgbtFpga_10g24 : uplinkData320(234)`
  - `uplinkData_o`
  - ← `U0 : lpgbtfpga_uplinkData_320(234)`
    - entra en `cdc_rx(data_a_i)`
      - `data_a_reg`
      - `data_b_reg`
      - `data_b_o`
    - ← `U0 : lpgbtfpga_uplinkData_40(234)`
      - `lpgbtfpga_uplinkUserData_s`
      - `lpgbtfpga_uplinkUserData_o`  (**puerto público**)

> [!note] Pedagogía: por qué hay CDC aquí
> El pipeline MGT/lpGBT vive en dominios de reloj “rápidos/especializados”.
> El `cdc_rx` re-sincroniza para que la lógica de control/registro (U0) vea datos estables
> sin metastabilidad.

---

# 4) Conexiones “hacia abajo” para el reset / interrupt (IC path)

Ahora conectamos esta historia uplink con la ruta que dispara interrupt/flags.

Desde `U0: lpgbtfpga_uplinkData_40(234)` se derivan señales:

- `lpgbtfpga_uplinkUserData_s(230)`
- `lpgbtfpga_uplinkUserData_o`
- `lpgbtfpga_uplinkIcData_s`  ← **este es el camino relevante para IC**

## 4.1 IC: ic_top → rx_data_i → deserializer → FIFO → FSM

`lpgbtfpga_uplinkIcData_s`
→ `ic_top : rx_data_i(2)`
  - `data_ic_rx_inv(2)`
    - `rx_inst : byte_des`
    - `Deserializer : data_i (...)`
      - `reg`
        - `data_o`
        - ← `rx_inst(byte_des)`  // deserializado

El deserializado alimenta FIFO:

- `ic_rx_fifo(data_i)`
  - `mem_arr` (RAM interna)
    - `ic_rx_fifo(data_o)`
      - `rx_inst`
      - ← `rx_inst : data_o`
      - ← `ic_top_inst : rx_data_from_gbtx_o`
      - ← `U0 : data_rx_data_FIFO`
        - entra a la **FSM** de `U0`

---

# 5) Interrupt enable / reg_map y flags desde FSM

En esta parte tocamos `reg_map`:

- `interrupt_enable_ic_resp : INTERRUPT_ENABLE_IC_RESP_RESET`

y desde la FSM:

- `U0 : interrupt_flags_ic_resp`
  - ocurre cuando `FIFO_cnt = 7`
    - FSM: `reading_FIFO`

---

# 6) Condición que activa lectura de FIFO (gatillante)

Para activar lectura (y eventualmente llegar a `FIFO_cnt=7`), se requiere:

```vhdl
if status_empty_flag(0) = '0' and (data_rx_data_FIFO = x"E0" or data_rx_data_FIFO = x"E1") then -- start reading FIFO
  IC_rx_rd_s               <= '1'; --start pulling from FIFO
  FIFO_cnt                 <= 0;
  next_FIFO_byte_available <= 0;
  parity_check             <= x"00";
  lpgbt_resp_timeout       := 100000000;
  fsm_state_ic             <= reading_FIFO;
end if;
```

## RAW Map
MGT expone canales externos,
y conecta al lpgbt
mediante MGT_USR_WORD

U0
```
- MGT_USRWORD_i(32 bools)
- uplink_mgtword_s(32 bools)
	- conecta a lpgbtFpga_10g24
	- uplink_mgtword_i(32)
	- uplink_mgtword_s(32)
		- conecta a lpgbtfpga_uplink
			- mgt_word_i(32) # input frame coming from MGT
				- conecta a frame aligner, pero solo 1 bit
				- conecta a lpgbtfpga_rxGearbox
					- dat_inFrame_i(32)
					- dat_inFrame_s(32)
					- reg0 (32 * clockratio)
						- reg1
							- rxFrame_inverted_s
								- dat_outFrame_s
									- dat_outFrame_o
								- <- uplink_inst : gbxFrame_s(256)
									- gbxFrame_5g12_s
									- frame_pipelined_s(256)
										- conecta a deinterleaver
											- data_i
```
El deinterleaver, es más complejo, tiene varias formas de ordenar los datos de data_i hacia:
```
- fec5_data_10g24_s
	- hace mux a fec5_data_s(234) -> fec5_data_o(234)
		- <- uplink_inst: fec5_data_from_deinterleaver_s
		- luego conecta a decoder por errores lpgbtfpga_decoder:fec5_data_i
			- fec5_data_s -> fec5_data_o
			- <- uplink_inst: fec5_data_from_decoder_s(234)
			- luego entra a descrambler lpgbtfpga_descrambler:fec5_data_i
				- fec5_data_o(234) -> fec5_data_from_descrambler_s(234)
					- <- uplink_inst : UserData_10g24_s 
					- <- uplink_inst: UserData_5g12_s
						- uplink_inst: userData_o(230)
							- <- lpgbtFpga_10g24: uplinkData320(234)
								- uplinkData_o
								- <- U0: lpgbtfpga_uplinkData_320(234)
									- entra en cdc_rx(data_a_i)
									- data_a_reg
									- data_b_reg
									- data_b_o
									- <- U0: lpgbtfpga_uplinkData_40(234)
									- lpgbtfpga_uplinkUserData_s
									- -> lpgbtfpga_uplinkUserData_o a puerto publico
```

comentarios de rxGearbox en el codigo
    -- lpgbtfpga_rxGearbox is used to pass from mgt word size (e.g.: 32b @ 320MHz)
    -- to lpgbt frame size (e.g.: 256b at 40MHz)


Y conexiones hacia abajo, para ver la señal de reset
U0: lpgbtfpga_uplinkData_40(234)
```
- lpgbtfpga_uplinkUserData_s(230)
- lpgbtfpga_uplinkUserData_o
- lpgbtfpga_uplinkIcData_s
	- ic_top: rx_data_i(2)
		- data_ic_rx_inv(2)
			- rx_inst: byte_des
			- Decerializer: data_i ()
				- reg
					- data_o
					- <- rx_inst(byte_des) // descerializado
						- ic_rx_fifo(data_i)
							- mem_arr
								- ic_rx_fifo(data_o)
									- rx_inst
					- <- rx_inst: data_o
					- <-ic_top_inst: rx_data_from_gbtx_o
					- <-U0: data_rx_data_FIFO
						- entramos a la FSM de U0
```
aqui tocamos con reg_map
- interrupt_enable_ic_resp: INTERRUPT_ENABLE_IC_RESP_RESET

y de la FSM:
- U0: interrupt_flags_ic_resp
	- ocurre cuando FIFO_cnt7
		- FSM: reading_FIFO

para activar la fifo
```
if status_empty_flag(0) = '0' and (data_rx_data_FIFO = x"E0" or data_rx_data_FIFO = x"E1") then -- start reading FIFO
	IC_rx_rd_s               <= '1'; --start pulling from FIFO
	FIFO_cnt                 <= 0;
	next_FIFO_byte_available <= 0;
	parity_check             <= x"00";
	lpgbt_resp_timeout       := 100000000;
	fsm_state_ic             <= reading_FIFO;
```