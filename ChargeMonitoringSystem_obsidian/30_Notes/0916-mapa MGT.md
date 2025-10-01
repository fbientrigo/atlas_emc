MGT expone canales externos,
y conecta al lpgbt
mediante MGT_USR_WORD

U0
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

El deinterleaver, es más complejo, tiene varias formas de ordenar los datos de data_i hacia:
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


comentarios de rxGearbox en el codigo
    -- lpgbtfpga_rxGearbox is used to pass from mgt word size (e.g.: 32b @ 320MHz)
    -- to lpgbt frame size (e.g.: 256b at 40MHz)


Y conexiones hacia abajo, para ver la señal de reset
U0: lpgbtfpga_uplinkData_40(234)
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

aqui tocamos con reg_map
- interrupt_enable_ic_resp: INTERRUPT_ENABLE_IC_RESP_RESET

y de la FSM:
- U0: interrupt_flags_ic_resp
	- ocurre cuando FIFO_cnt7
		- FSM: reading_FIFO

para activar la fifo
"""
if status_empty_flag(0) = '0' and (data_rx_data_FIFO = x"E0" or data_rx_data_FIFO = x"E1") then -- start reading FIFO
	IC_rx_rd_s               <= '1'; --start pulling from FIFO
	FIFO_cnt                 <= 0;
	next_FIFO_byte_available <= 0;
	parity_check             <= x"00";
	lpgbt_resp_timeout       := 100000000;
	fsm_state_ic             <= reading_FIFO;
"""