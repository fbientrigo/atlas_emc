#!/usr/bin/env bash
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    printf 'Uso: %s [--simulate] [--g0 HH:HH] [--g1 HH:HH]\n' "$0"
    printf '  --simulate  Prueba el visor durante 3 s sin UIO ni sudo.\n\n'
    python3 "$here/ver10.py" --help
    exit
fi

make -s -C "$here" emp_acq_capture
simulate=false
capture=("$here/emp_acq_capture" --out -)
if [[ ${1:-} == --simulate ]]; then
    simulate=true
    shift
    capture+=(--simulate --seconds 3)
elif (( EUID != 0 )); then
    sudo -v
    capture=(sudo -n "${capture[@]}")
fi

if "${capture[@]}" | python3 "$here/ver10.py" "$@" --segundos 60; then
    if "$simulate"; then
        exit 0
    fi
    printf 'quick_watch: el capturador cerró la lectura en vivo.\n' >&2
    exit 1
else
    stages=("${PIPESTATUS[@]}")
fi

if (( stages[1] == 130 )); then
    exit 130
fi
if (( stages[0] != 0 && (stages[0] != 141 || stages[1] == 0) )); then
    printf 'quick_watch: emp_acq_capture terminó con código %d.\n' "${stages[0]}" >&2
    exit "${stages[0]}"
fi
exit "${stages[1]}"
