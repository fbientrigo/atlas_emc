#!/bin/sh
# Sin argumentos lee data_group_0 del banco histórico en 0xA00E0000.
# Ejemplo: sudo ./raw.sh 0xA00E0004 0xA00E0008
set -eu
if [ "$#" -eq 0 ]; then set -- 0xA00E0004; fi
for address do
    printf '%s  ' "$address"
    busybox devmem "$address" 32
done
