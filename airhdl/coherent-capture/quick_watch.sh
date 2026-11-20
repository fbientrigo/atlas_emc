#!/usr/bin/env bash
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    python3 "$here/ver10.py" --help
    exit
fi

make -s -C "$here" emp_acq_capture
capture=("$here/emp_acq_capture" --seconds 0 --out -)
if (( EUID != 0 )); then
    sudo -v
    capture=(sudo -n "${capture[@]}")
fi
"${capture[@]}" | python3 "$here/ver10.py" "$@" --segundos 60
