"""Modelos reducidos de ramas RTL, NO simulación VHDL ni evidencia de hardware.
Ejecutar: python3 analisis/contraejemplos.py
No necesita archivos del hardware ni abre dispositivos. Precondiciones artificiales.
"""
import json

def ready_step(ready, reset, strobe):
    # cdc_rx.vhd:178-191; usa strobe_a_r ya registrado.
    if reset:
        return 0
    if strobe:
        return 1
    return ready

ready = ready_step(0, 0, 1)
for _ in range(32):
    ready = ready_step(ready, 0, 0)
assert ready == 1
assert ready_step(ready, 1, 0) == 0

# eLink_Interface.vhd:259-265: rama de reset no asigna fsm_state.
state = 'waiting_resp'
reg_status, intr, tx_write = 127, 1, 1
reg_status, intr, tx_write = 0, 0, 0
assert state == 'waiting_resp'

# eLink_Interface.vhd:295-318: las lecturas limpian bits individuales.
reg_status = 127
for group in [0, 1, 2, 3, 4, 6]:
    reg_status &= ~(1 << group)
assert reg_status == 32  # falta grupo 5; sin nueva escritura, no pasa a finish.
reg_status &= ~(1 << 5)
assert reg_status == 0

# emp_lpgbt.vhd:733-768: contador reducido para exhibir la prioridad.
# El contador real arranca en 100000000; cambiar su tamaño NO cambia esa prioridad.
count = 2
trace = []
for _ in range(3):
    count -= 1
    empty = 1
    branch = 'empty: next_FIFO_byte_available <= 1' if empty else ('timeout' if count == 0 else 'otra')
    trace.append({'contador_tras_resta': count, 'rama': branch, 'fuera_de_rango': count < 0})
assert trace[1]['contador_tras_resta'] == 0 and trace[1]['rama'].startswith('empty')
assert trace[2]['fuera_de_rango']
assert (0x10004 >> 4) & 1 == 0  # LpGbtSw no usa esa FSM single.

# read_lpgbt10.sh: byte bajo constante aunque cambie el resto de la palabra.
a, b = 0x000000AA, 0x123400AA
assert a != b and (a & 255) == (b & 255)

print(json.dumps({
    'alcance': 'Contraejemplos de modelos reducidos; sin simulación VHDL ni hardware',
    'resultado': 'OK',
    'casos': [
        {'id':'ready','precondicion':'Sin reset efectivo y sin nuevos strobes durante 32 ciclos', 'resultado':'ready conserva 1; reset posterior lo borra'},
        {'id':'fsm_reset','precondicion':'FSM en waiting_resp al ejecutar rama de reset', 'resultado':'La rama no asigna estado; conserva waiting_resp'},
        {'id':'lectura_parcial','precondicion':'Se omite grupo 5 y no hay nueva escritura downlink', 'resultado':'regStatus conserva un bit; lectura final lo limpia'},
        {'id':'watchdog','precondicion':'reading_FIFO y empty permanentemente 1', 'traza':trace, 'limite':'Esta FSM no es seleccionada por 0x10004'},
        {'id':'byte_bajo','precondicion':'Palabras construidas 0x000000AA y 0x123400AA', 'resultado':'El script no distingue ambas; no son datos experimentales'}
    ]},ensure_ascii=False,indent=2))
