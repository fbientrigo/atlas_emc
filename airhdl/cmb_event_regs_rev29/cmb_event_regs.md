# cmb_event

|||
| --- | --- |
| **Description** | Evento del ChargeMonitoring Board teniendo en cuenta ACK, FSM, VETO, Overflow y un buen almacenamiento de datos |
| **Default base address** | `0xA01B0000` |
| **Register width** | 32 bits |
| **Default address width** | 32 bits |
| **Register count** | 7 |
| **Range** | 45184 bytes |
| **Revision** | 29 |

## Overview

| Offset | Name | Description | Type |
| --- | --- | --- | --- |
| `0x0` | magic | Identificar el periférico | REG |
| `0x4` | control | Enable, ACK, reset, test_start | REG |
| `0x8` | status | Busy, ready, overflow, veto | REG |
| `0xC` | event_size | Bytes capturados | REG |
| `0x10` | event_id | Numero de evento | REG |
| `0x14` | overflow_count | Control de perdidas | REG |
| `0x1000` | data_mem | Memoria de datos | MEM[10272] |

## Registers

| Offset | Name | Description | Type | Access | Attributes | Reset |
| ---    | --- | --- | --- | --- | --- | --- |
| `0x0` | magic |Identificar el periférico | REG | R |  | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |
| `0x4` | control |Enable, ACK, reset, test_start | REG | R/W |  | `0x0` |
|        |  [0] enable |  |  |  |  | `0x0` |
|        |  [1] ack |  |  |  | self-clearing | `0x0` |
|        |  [2] soft_reset |  |  |  | self-clearing | `0x0` |
|        |  [3] test_start |  |  |  | self-clearing | `0x0` |
| `0x8` | status |Busy, ready, overflow, veto | REG | R |  | `0x0` |
|        |  [0] busy |  |  |  |  | `0x0` |
|        |  [1] ready |  |  |  |  | `0x0` |
|        |  [2] overflow |  |  |  |  | `0x0` |
|        |  [3] veto |  |  |  |  | `0x0` |
| `0xC` | event_size |Bytes capturados | REG | R |  | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |
| `0x10` | event_id |Numero de evento | REG | R |  | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |
| `0x14` | overflow_count |Control de perdidas | REG | R |  | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |
| `0x1000` | data_mem |Memoria de datos | MEM[10272] | R | read latency: 1 | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |

_Generated on 2026-11-17 at 04:50 (UTC) by airhdl version 2023.07.1-936312266_
