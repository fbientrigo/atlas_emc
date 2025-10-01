Aqui el reporte de busqueda de variables de hoy:
"""
Comenzamos con la busqueda de encontrar una señal que interactuara con el IQR, 
tras hacer un mapeo y encontrar condiciones, se halló que habia una condición para activarla, la cual era cuando la memoria se llenaba.
Sin embargo encontramos que la forma de activarlo solo ocurre cuando llenamos la memoria

Por tanto buscamos donde se llena data_i
Partimos por el modulo visible


emp_fw_TE0807 (lpgbtfpga_downlinkUserData_i) -> U0 (lpgbtfpga_downlinkUserData_i)
U0(lpgbtfpga_downlinkUserData_i) -> U0(lpgbtfpga_downlinkUserData_s)

	lpgbtfpga_downlinkData_40 <= lpgbtfpga_downlinkIcData_s & lpgbtfpga_downlinkEcData_s & lpgbtfpga_downlinkUserData_s;

U0(lpgbtfpga_downlinkData_40) -> cdc_tx_inst(data_a_i)

	  data_a_reg     <= data_a_i   when rising_edge(clk_a_i);
	data_b_reg <= data_a_reg
	data_b_o   <= data_b_reg

cdc_tx_inst(data_b_o) -> U0(lpgbtfpga_downlinkData_320)
	-> lpgbtFpga_top_inst(downlinkData_i)
		-> downlinkData320

aqui se divide en varios, en
			userData_i          => downlinkData320(31 downto 0),
			ECData_i            => downlinkData320(33 downto 32),
			ICData_i            => downlinkData320(35 downto 34),

Lo cual llega hasta allí.

Por otro lado sabemos que hay modificaciones del FIFO en
- rd_ptr

donde en ic_rx_fifo_inst llega a data_o
donde se extrae desde
- mem_arr
	- en este mismo modulo, esta tiene modificaciones, pues es usada
		- mem_arr(wr_ptr) <= data_i
	- data_i viene del Descerializer



## Lower to top
comencemos a buscar desde el top hasta abajo como se generó el reset

En 
int_lpgbt_resp
lo que nos lleva a U0
en donde se modifica por
int_lpgbt_resp <= interrupt_flags_ic_resp(0) and interrupt_enable_ic_resp(0);

lo cual nos lleva a reg_map[interrupt_enable_ic_resp]

se conecta a s_reg_interrupt_enable_ic_resp_r

donde es conectado a:
- s_axi_wdata_reg_r(0)
	- 93 matchs para todo
	- 8 matches si vamos con el (0)
		- -- register 'data_tx' at address offset 0x10
			- s_reg_data_tx_data_r(0) <= s_axi_wdata_reg_r(0); -- data(0)
		- -- register 'register_addr' at address offset 0x14
			-  s_reg_register_addr_addr_r(0) <= s_axi_wdata_reg_r(0); -- addr(0)
		- -- register 'lpGBT_addr' at address offset 0x18
			- s_reg_lpgbt_addr_addr_r(0) <= s_axi_wdata_reg_r(0); -- addr(0)
		- -- register 'interrupt_enable' at address offset 0x1C
			- s_reg_interrupt_enable_ic_resp_r(0) <= s_axi_wdata_reg_r(0); -- IC_resp(0)
		- -- register 'interrupt_clear' at address offset 0x24
			-  s_reg_interrupt_clear_ic_resp_r(0) <= s_axi_wdata_reg_r(0); -- IC_resp(0)
		-  -- register 'reset' at address offset 0x28
			- s_reg_reset_reset_r(0) <= s_axi_wdata_reg_r(0); -- reset(0)
		- -- register 'counter_lhc_clock' at address offset 0x100
			-  s_reg_counter_lhc_clock_value_r(0) <= s_axi_wdata_reg_r(0); -- value(0)
		-  -- register 'control' at address offset 0x4
			- s_reg_control_fifoctrl_r(0) <= s_axi_wdata_reg_r(0); -- FIFOCtrl(0)
- INTERRUPT_ENABLE_IC_RESP_RESET
	- conectada a nada tal parece

y para interrupt_flags_ic_resp
	ocurre cuando FIFO_cnt =7
		lo que se relaciona a when reading_FIFO (FSM de U0)
	ocurre si
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
	por tanto 


conecta U0 a ic_top_inst mediante 
	rx_data_from_gbtx_o => data_rx_data_FIFO, --! Data from the FIFO

en ic_top_inst buscamos rx_data_from_gbtx_o
lo que se conecta al modulo rx_inst con puerto data_o

ic_top_inst(data_o) -> ic_rx_fifo_inst(data_o)

dentro de ic_rx_fifo_inst
"""
    ram_proc_rd: process(reset_i, rd_clk_i)
    begin
        if reset_i = '1' then
            rd_ptr              <= 0;
            rx_empty_o          <= '1';

        elsif rising_edge(rd_clk_i) then
            if read_i = '1' and rd_ptr < word_in_mem_size then
                rd_ptr          <= rd_ptr + 1;
            end if;

            if word_in_mem_size > rd_ptr then
                rx_empty_o         <= '0';
            else
                rx_empty_o         <= '1';
            end if;

            data_o          <= mem_arr(rd_ptr);
        end if;
    end process;
"""

donde mem_arr
- recibe: data_i con wr_ptr
- escribe: data_o con rd_prt


Ahora estamos en lo más bajo, queda encontrar quien instancia ic_rx_fifo_inst(data_i)
subiendo a mod: ic_top_inst
encuentro la referencia de ic_rx como rx_inst

en rx_inst(byte_des) ->byte_des

byte_des es una señal:

Deserializer_inst(data_o) -> rx_inst(byte_des)

dentro
Deserializer_inst(data_o) <-> reg <-> Deserializer_inst(data_i)

donde
Deserializer_inst(data_i) -> rx_inst(rx_data_i)

se conecta a
rx_inst(rx_data_i) -> ic_top_inst(data_ic_rx_inv)

donde 
"""
    gbtx_connectivity: if g_ToLpGBT = 0 generate
        tx_data_o(0)            <= data_ic_tx_inv(1);
        tx_data_o(1)            <= data_ic_tx_inv(0);
        data_ic_rx_inv(0)       <= rx_data_i(1);
        data_ic_rx_inv(1)       <= rx_data_i(0);
    end generate;

    lpgbt_connectivity: if g_ToLpGBT = 1 generate
        tx_data_o       <= data_ic_tx_inv;
        data_ic_rx_inv  <= rx_data_i;
    end generate;
"""

luego en modulo arriba
U0 busqué ic_top_inst

en donde se conecta mediante
lpgbtfpga_uplinkIcData_s

osea:
ic_top_inst(rx_data_i) -> U0(lpgbtfpga_uplinkIcData_s)

aqui
U0(lpgbtfpga_uplinkIcData_s) <-> U0(lpgbtfpga_uplinkData_40)

seguir buscando las conexiones dentro de U0
- data_b_o
"""
