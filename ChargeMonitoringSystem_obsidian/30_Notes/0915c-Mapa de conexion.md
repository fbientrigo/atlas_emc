## Objetivo de la sesión

Encontrar **qué señal activa el IQR / interrupt** y bajo qué condición, para poder reproducir y depurar el comportamiento.

---

## Hallazgo principal

Durante el mapeo de señales y condiciones se observó que:

- Existe una condición que **activa la señal** (asociada a IQR/interrupt).
- Esa condición ocurre **cuando la memoria se llena**.
- Por ahora, **la activación solo se reproduce llenando la memoria** (no se encontró un gatillante alternativo).

---

## Hipótesis operativa

> La activación del interrupt está correlacionada con la lógica de FIFO/memoria: cuando el buffer alcanza cierto nivel (ej. `FIFO_cnt = 7`), se levanta un flag de respuesta/interrupt.

---

# 1) Dónde se llena `data_i` (camino downlink → CDC → top)

## Cadena de señales (tracking “desde lo visible”)

1) **Top-level**
- `emp_fw_TE0807 (lpgbtfpga_downlinkUserData_i)`  
  → `U0 (lpgbtfpga_downlinkUserData_i)`

2) Dentro de `U0`
- `U0(lpgbtfpga_downlinkUserData_i)` → `U0(lpgbtfpga_downlinkUserData_s)`

3) Concatenación a 40-bit downlink
- `lpgbtfpga_downlinkData_40 <= lpgbtfpga_downlinkIcData_s & lpgbtfpga_downlinkEcData_s & lpgbtfpga_downlinkUserData_s;`

4) CDC TX
- `U0(lpgbtfpga_downlinkData_40)` → `cdc_tx_inst(data_a_i)`

Registro en CDC:
- `data_a_reg <= data_a_i when rising_edge(clk_a_i);`
- `data_b_reg <= data_a_reg`
- `data_b_o   <= data_b_reg`

5) 320-bit downlink
- `cdc_tx_inst(data_b_o)` → `U0(lpgbtfpga_downlinkData_320)`
  → `lpgbtFpga_top_inst(downlinkData_i)`
  → `downlinkData320`

6) Split de `downlinkData320`
- `userData_i => downlinkData320(31 downto 0)`
- `ECData_i   => downlinkData320(33 downto 32)`
- `ICData_i   => downlinkData320(35 downto 34)`

**Hasta aquí llega el tracking del tramo downlink.**

---

# 2) Observación: FIFO / memoria (`ic_rx_fifo_inst`) y `mem_arr`

Sabemos que hay modificaciones relevantes en:

- `rd_ptr`
- lectura/escritura de RAM interna `mem_arr`

En `ic_rx_fifo_inst`:

- `data_o` se extrae de `mem_arr(rd_ptr)`
- `mem_arr(wr_ptr) <= data_i`
- `data_i` proviene del **Deserializer**

Modelo mental:
- **write-side**: `data_i` → `mem_arr(wr_ptr)`
- **read-side**: `mem_arr(rd_ptr)` → `data_o`
- el estado “lleno/vacío” está controlado por contadores (`word_in_mem_size`, `rd_ptr`, flags)

---

# 3) Lower → Top: buscar el reset / interrupt desde arriba hacia abajo

## 3.1 Interrupt en `int_lpgbt_resp`

En `int_lpgbt_resp` llegamos a `U0`, donde:

- `int_lpgbt_resp <= interrupt_flags_ic_resp(0) and interrupt_enable_ic_resp(0);`

Esto lleva a:
- `reg_map[interrupt_enable_ic_resp]`
- conectado a `s_reg_interrupt_enable_ic_resp_r`

### Escritura por AXI (mapa rápido)

`S_reg_interrupt_enable_ic_resp_r(0)` viene de:
- `s_axi_wdata_reg_r(0)`

Matches relevantes (con `(0)`):

- `data_tx` @ `0x10`
  - `s_reg_data_tx_data_r(0) <= s_axi_wdata_reg_r(0);`
- `register_addr` @ `0x14`
  - `s_reg_register_addr_addr_r(0) <= s_axi_wdata_reg_r(0);`
- `lpGBT_addr` @ `0x18`
  - `s_reg_lpgbt_addr_addr_r(0) <= s_axi_wdata_reg_r(0);`
- `interrupt_enable` @ `0x1C`
  - `s_reg_interrupt_enable_ic_resp_r(0) <= s_axi_wdata_reg_r(0);`
- `interrupt_clear` @ `0x24`
  - `s_reg_interrupt_clear_ic_resp_r(0) <= s_axi_wdata_reg_r(0);`
- `reset` @ `0x28`
  - `s_reg_reset_reset_r(0) <= s_axi_wdata_reg_r(0);`
- `counter_lhc_clock` @ `0x100`
  - `s_reg_counter_lhc_clock_value_r(0) <= s_axi_wdata_reg_r(0);`
- `control` @ `0x4`
  - `s_reg_control_fifoctrl_r(0) <= s_axi_wdata_reg_r(0);`

Nota:
- `INTERRUPT_ENABLE_IC_RESP_RESET` parece no estar conectado a nada (por ahora).

---

## 3.2 ¿Cuándo se levanta `interrupt_flags_ic_resp`?

Se observó que:
- ocurre cuando `FIFO_cnt = 7`
- relacionado con el estado `reading_FIFO` del FSM de `U0`

Condición crítica encontrada:

```vhdl
when waiting_resp =>
  IC_tx_start_write_s <= '0';
  IC_tx_start_read_s  <= '0';
  lpgbt_resp_timeout  := lpgbt_resp_timeout - 1;

  if status_empty_flag(0) = '0' and (data_rx_data_FIFO = x"E0" or data_rx_data_FIFO = x"E1") then -- start reading FIFO
    IC_rx_rd_s               <= '1'; --start pulling from FIFO
    FIFO_cnt                 <= 0;
    next_FIFO_byte_available <= 0;
    parity_check             <= x"00";
    lpgbt_resp_timeout       := 100000000;
    fsm_state_ic             <= reading_FIFO;
  end if;
```

Interpretación:

- Si `status_empty_flag(0) = '0'` (no vacío) y el byte leido es `E0/E1`,  
    entonces se entra a `reading_FIFO` y comienza la extracción.
    
- El conteo `FIFO_cnt` crece durante lectura y al llegar a `7` se dispara el flag.
    

---

# 4) Conectividad hacia el FIFO: `ic_top_inst` → `ic_rx_fifo_inst`

Conectividad entre módulos:

- `U0` conecta con `ic_top_inst` mediante:
    
    - `rx_data_from_gbtx_o => data_rx_data_FIFO` (Data desde el FIFO)
        

En `ic_top_inst`, buscando `rx_data_from_gbtx_o`:

- se conecta al módulo `rx_inst` como puerto `data_o`
    

Cadena:

- `ic_top_inst(data_o)` → `ic_rx_fifo_inst(data_o)`
    

---

# 5) Detalle interno en `ic_rx_fifo_inst` (lectura)

Código observado:

```vhdl
ram_proc_rd: process(reset_i, rd_clk_i)
begin
  if reset_i = '1' then
    rd_ptr     <= 0;
    rx_empty_o <= '1';

  elsif rising_edge(rd_clk_i) then
    if read_i = '1' and rd_ptr < word_in_mem_size then
      rd_ptr <= rd_ptr + 1;
    end if;

    if word_in_mem_size > rd_ptr then
      rx_empty_o <= '0';
    else
      rx_empty_o <= '1';
    end if;

    data_o <= mem_arr(rd_ptr);
  end if;
end process;
```

Resumen:

- `data_o` siempre sale de `mem_arr(rd_ptr)`
    
- `rd_ptr` avanza si `read_i=1` y hay data (`rd_ptr < word_in_mem_size`)
    
- flag `rx_empty_o` depende de `word_in_mem_size > rd_ptr`
    

---

# 6) Subiendo: ¿quién alimenta `ic_rx_fifo_inst(data_i)`?

En `ic_top_inst` se ve `ic_rx` referenciado como `rx_inst`.

`rx_inst(byte_des)` y `Deserializer_inst`:

- `Deserializer_inst(data_o)` → `rx_inst(byte_des)`
    
- `Deserializer_inst(data_o)` ↔ regs ↔ `Deserializer_inst(data_i)`
    
- `Deserializer_inst(data_i)` → `rx_inst(rx_data_i)`
    

Luego:

- `rx_inst(rx_data_i)` → `ic_top_inst(data_ic_rx_inv)`
    

---

# 7) Mapeo de conectividad (gbtx vs lpgbt)

Bloque observado:

```vhdl
gbtx_connectivity: if g_ToLpGBT = 0 generate
  tx_data_o(0)      <= data_ic_tx_inv(1);
  tx_data_o(1)      <= data_ic_tx_inv(0);
  data_ic_rx_inv(0) <= rx_data_i(1);
  data_ic_rx_inv(1) <= rx_data_i(0);
end generate;

lpgbt_connectivity: if g_ToLpGBT = 1 generate
  tx_data_o      <= data_ic_tx_inv;
  data_ic_rx_inv <= rx_data_i;
end generate;
```

Luego, en el módulo arriba (`U0`):

- se conecta mediante `lpgbtfpga_uplinkIcData_s`
    

Cadena:

- `ic_top_inst(rx_data_i)` → `U0(lpgbtfpga_uplinkIcData_s)`
    

y después:

- `U0(lpgbtfpga_uplinkIcData_s)` ↔ `U0(lpgbtfpga_uplinkData_40)`
    

---

# 8) Pendiente / Próximo paso

## Pendiente inmediato

- Seguir buscando las conexiones dentro de `U0`, especialmente el tramo:
    
    - `uplinkData_40` / `data_b_o` y cómo se propaga hacia la lógica de flags/interrupt.
        

## Pregunta guía

- ¿Qué evento exacto incrementa `word_in_mem_size` y `wr_ptr` hasta “llenar memoria”?
    
- ¿Quién controla `read_i` y en qué condiciones se llega consistentemente a `FIFO_cnt = 7`?
    

---

## Notas rápidas

- El comportamiento observado sugiere que el interrupt ligado a `interrupt_flags_ic_resp` depende del “nivel” del FIFO.
    
- La condición `E0/E1` en `data_rx_data_FIFO` parece ser el marcador de inicio de lectura (handshake / framing).