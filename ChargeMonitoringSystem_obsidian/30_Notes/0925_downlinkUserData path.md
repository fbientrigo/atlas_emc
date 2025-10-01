El objevtio es ver en donde acaba el user data


emp_
lpgbtfpga_downlinkUserData_i
	U0: lpgbtfpga_downlinkUserData_s <= lpgbtfpga_downlinkUserData_i(32)
		lpgbtfpga_downlinkData_40(36)
			cdx_tx_inst: data_a_i(1)      => lpgbtfpga_downlinkData_40(36)
			data_a_reg(1)     <= data_a_i(1) 
			data_b_reg(1) <= data_a_reg(1);
			data_b_o(1)   <= data_b_reg(1)  ;
		sube a U0: data_b_o      => lpgbtfpga_downlinkData_320(36)
			lpgbtFpga_top_inst: downlinkData_i(36)              => lpgbtfpga_downlinkData_320(36)
				downlinkData320 <= downlinkData_i;
				downlink_inst:
					userData_i          => downlinkData320(31 downto 0),
					ECData_i            => downlinkData320(33 downto 32),
					ICData_i            => downlinkData320(35 downto 34),
				downlink_inst:			
					inputData_s(31 downto 0)    <= userData_i(32);
					inputData_s(33 downto 32)   <= ECData_i(2);
					inputData_s(35 downto 34)   <= ICData_i(2);
				lpgbtfpga_scrambler_inst:
					data_i               => inputData_s(36),
						data_o<=data_i(36)
					data_o(36)               => scrambledData_s(36),
				lpgbtfpga_encoder_inst:
						data_i(36)               => scrambledData_s(36),
							virtualFrame_C0	<= "000000" & data_i(8 downto 0);
							virtualFrame_C1	<= "000000" & data_i(17 downto 9);
							virtualFrame_C2	<= "000000" & data_i(26 downto 18);
							virtualFrame_C3	<= "000000" & data_i(35 downto 27);
					luego entrar a un grupo:
						RSE0_inst: rs_encoder_N7K5
						PORT MAP (
							msg				=> virtualFrame_C0,
							parity			=> FEC_s(5 downto 0)
						);
						--! Reed-Solomon N7K5 encoder (encodes data_i(17 downto 9))
						RSE1_inst: rs_encoder_N7K5
						PORT MAP (
							msg				=> virtualFrame_C1,
							parity			=> FEC_s(11 downto 6)
						);
						--! Reed-Solomon N7K5 encoder (encodes data_i(26 downto 18))
						RSE2_inst: rs_encoder_N7K5
						PORT MAP (
							msg				=> virtualFrame_C2,
							parity			=> FEC_s(17 downto 12)
						);
						--! Reed-Solomon N7K5 encoder (encodes data_i(35 downto 27))
						RSE3_inst: rs_encoder_N7K5
						PORT MAP (
							msg				=> virtualFrame_C3,
							parity			=> FEC_s(23 downto 18)
						);
						FEC_o 	<= 	FEC_s WHEN bypass = '0' ELSE (OTHERS => '0');
						FEC_o(24) es lo importante
				downlink_inst: FEC_o(24)
						FEC_o(24)                => FECData_s(24),
				lpgbtfpga_interleaver_inst( FECData_s)
						FEC_i(24)
						interleaved_data(64)
						data_o(64)
				downlink_inst(data_o(64))               => encodedFrame_s(64),
					lpgbtfpga_txGearbox_inst
						dat_inFrame_i(coW)
						in_txFrame_from_frameInverter_s(coW)
						txFrame_from_frameInverter_pipe_s(coW)
							txWord_beforeOversampling_s(coWR) y txFrame_from_frameInverter_reg_s(coW)
							desde: txFrame_from_frameInverter_reg_s(coW)
							txWord_beforeOversampling_s(coWR)
							dat_outFrame_s(coW)
						dat_outFrame_o(coW)
					mgt_word_o(coW) (llega de gearbox a downlink data con este nombre)
			lpgbtFpga_top_inst(mgt_word_o)
				downlink_mgtword_s(32)
				downlink_mgtword_o(32)
		U0(downlink_mgtword_o)
			MGT_USRWORD_o
			se expone al BD: MGT_USRWORD_o(32)


largos: (c_outputWidth - 1) downto 0 -> coW
c_inputWidth/c_clockRatio)-1 downto 0 -> coWR


- nota: observar que ocurre cuando no tiene datos
	- en cdx_tx_inst ocurre que la data se serializa en cada clock
	- 		MGT_RXUSRCLK_i               : in  std_logic; -- MGT IP 320MHz reference input clock


___
## Conexión interesante
Existe una conexión interesante
el lpgbt expone vacio por ahora, un downlinkUserData este eventualemnte sale por MGTUSRData hacia el MGT, y vuelve a entrar por la input (uplink) del lpgbt, en donde eventualmente puede provocar un interrupt al llenar la fifo.

