La señal sale del modulo lpgbt, 

U0: uplinkReady_o
	uplinkReady_s
	cdc_rx: cdc_rx_ready
	uplinkReady_s
	ready_b_o
		funciona sincronizado al reloj con clk_a_i
		y requiere de strobe_a_r='1'
		strobe_a_i
	el cual se conecta nuevamente a U0 con un valor fijo de '1'

de manera que lo que manda aqui es la señal de reset
el proceso que lo maneja se encuentra dentro de `cdc_rx.vhd`

```vhdl
  -- This process is intended to ensure reset_a is de-asserted with a fixed-phase w.r.t. strobe B 
  p_reset_a_strobe_sync : process(clk_a_i)
  begin
    if (rising_edge(clk_a_i)) then
      if (reset_a_i='1') then
          reset_a_strobe_sync <= '1';      
      elsif(strobe_b_toggle_sync_r/=strobe_b_toggle_sync) then
          reset_a_strobe_sync <= '0';  
      end if;
    end if;
  end process p_reset_a_strobe_sync;
```

___

