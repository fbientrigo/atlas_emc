#!/usr/bin/env bash
set -euo pipefail

script=$(realpath -- "${BASH_SOURCE[0]}")
base=$(dirname -- "$script")
raiz=${EMP_CAPTURE_DIR:-"$HOME/capturas/uplink10"}
lector=${EMP_CAPTURE_BIN:-"$base/emp_acq_capture"}
modo=()
privilegio=()
if [[ ${EMP_CAPTURE_SIMULATE:-0} == 1 ]]; then
    modo=(--simulate)
    raiz=${EMP_CAPTURE_DIR:-"$HOME/capturas/uplink10-simulacion"}
elif (( EUID != 0 )); then
    privilegio=(sudo -n)
fi

ayuda() {
    cat <<'USO'
captura10.sh check
captura10.sh prueba [segundos]     # 600 por defecto
captura10.sh noche                 # 28800 segundos
captura10.sh estado [corrida]
captura10.sh resumen [corrida]

Sin una ruta explícita, estado y resumen consultan la última corrida.
EMP_CAPTURE_BIN permite indicar la ruta a emp_acq_capture.
EMP_CAPTURE_SIMULATE=1 usa el firmware simulado y su propia carpeta.
USO
}

validar_lector() {
    if [[ ! -x "$lector" ]]; then
        printf 'Compila emp_acq_capture con make o indica EMP_CAPTURE_BIN. Falta %s\n' "$lector" >&2
        exit 1
    fi
}

leer_corrida() {
    if [[ -n ${1:-} ]]; then
        corrida=$1
    elif [[ -r "$raiz/ultima" ]]; then
        IFS= read -r corrida < "$raiz/ultima"
    else
        printf 'Todavía no hay una corrida en %s\n' "$raiz" >&2
        exit 1
    fi
    [[ -d "$corrida" ]] || { printf 'Corrida inexistente: %s\n' "$corrida" >&2; exit 1; }
}

iniciar() {
    local etiqueta=$1 segundos=$2 disponible minimo
    [[ "$segundos" =~ ^[1-9][0-9]{0,4}$ ]] || { printf 'Usa segundos enteros positivos.\n' >&2; exit 2; }
    validar_lector
    mkdir -p -- "$raiz"
    raiz=$(realpath -- "$raiz")
    disponible=$(df -Pk "$raiz" | awk 'END {print $4}')
    minimo=$(( segundos * 40 + 16384 ))
    if (( disponible < minimo )); then
        printf 'Espacio insuficiente en %s: se requieren %d KiB libres.\n' "$raiz" "$minimo" >&2
        exit 1
    fi
    exec 9>"$raiz/.captura.lock"
    flock -n 9 || { printf 'Ya hay una captura en curso en %s\n' "$raiz" >&2; exit 1; }
    if (("${#privilegio[@]}")); then sudo -v; fi

    corrida=$(mktemp -d "$raiz/$etiqueta.XXXXXX")
    touch "$corrida/data.csv"
    nohup bash "$script" _worker "$corrida" "$segundos" \
        </dev/null >"$corrida/captura.log" 2>&1 &
    printf '%s\n' "$!" > "$corrida/pid"
    printf '%s\n' "$corrida" > "$corrida/enlace-ultima"
    mv -f -- "$corrida/enlace-ultima" "$raiz/ultima"
    printf 'Corrida: %s\nPID: %s\n' "$corrida" "$!"
}

case ${1:-ayuda} in
    check)
        validar_lector
        if (("${#privilegio[@]}")); then sudo -v; fi
        exec "${privilegio[@]}" "$lector" "${modo[@]}" --check --check-seconds 10
        ;;
    prueba) iniciar prueba "${2:-600}" ;;
    noche) iniciar noche 28800 ;;
    _worker)
        corrida=$2
        rc=0
        "${privilegio[@]}" "$lector" "${modo[@]}" --seconds "$3" \
            --poll-us 1000 --out "$corrida/data.csv" || rc=$?
        printf '%s\n' "$rc" > "$corrida/exit.tmp"
        mv -- "$corrida/exit.tmp" "$corrida/exit"
        exit "$rc"
        ;;
    estado)
        leer_corrida "${2:-}"
        printf 'Corrida: %s\n' "$corrida"
        if [[ -r "$corrida/exit" ]]; then
            printf 'Terminó con código %s\n' "$(<"$corrida/exit")"
        elif [[ -r "$corrida/pid" ]] && kill -0 "$(<"$corrida/pid")" 2>/dev/null; then
            printf 'En curso\n'
        else
            printf 'Interrumpida o sin estado final\n'
        fi
        ls -lh -- "$corrida/data.csv"
        tail -n 3 -- "$corrida/captura.log"
        ;;
    resumen)
        leer_corrida "${2:-}"
        LC_ALL=C awk -F, '
        NF == 30 && $1 ~ /^[0-9]+$/ {
            if (!n++) first=$1
            last=$1
            if ($3>1) perdidos+=$3-1
            if ($6!=1 || $7!=1) sin_ready++
            for (i=24;i<=30;i++) {
                b0=substr($i,9,2); b1=substr($i,7,2)
                b2=substr($i,5,2); b3=substr($i,3,2)
                if (b0==b2 && b1==b3) {
                    if (b0==b1) fijo[i]++
                    else alterna[i]++
                }
                if (n>1 && anterior[i]!=$i) cambio[i]++
                anterior[i]=$i
            }
        }
        END {
            if (!n) {print "Sin snapshots completos"; exit 1}
            printf "Filas: %d | duración: %.1f s | saltos SEQ: %d | sin READY: %d\n",
                n,(last-first)/1e9,perdidos,sin_ready
            for (i=24;i<=30;i++)
                printf "d%d | AAAA %.2f%% | ABAB %.2f%% | cambia entre snapshots %.2f%%\n",
                    i-24,100*fijo[i]/n,100*alterna[i]/n,(n>1 ? 100*cambio[i]/(n-1) : 0)
        }' "$corrida/data.csv"
        ;;
    ayuda|-h|--help) ayuda ;;
    *) ayuda >&2; exit 2 ;;
esac
