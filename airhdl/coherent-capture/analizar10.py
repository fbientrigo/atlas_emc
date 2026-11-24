#!/usr/bin/env python3
"""Ejecuta estabilidad, desvíos del patrón y asociación entre canales."""

import argparse
from pathlib import Path
import subprocess
import sys

from ruido10 import reference


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("corrida", type=Path, help="carpeta de corrida o data.csv")
    parser.add_argument("--g0", default="C4:00")
    parser.add_argument("--g1", default="0C:40")
    parser.add_argument("--intervalo", type=int, default=60)
    args = parser.parse_args()
    reference(args.g0)
    reference(args.g1)
    if args.intervalo < 1:
        parser.error("--intervalo debe ser positivo")
    base = Path(__file__).resolve().parent
    for script in ("graficar10.py", "ruido10.py", "crosstalk10.py"):
        print(f"Ejecutando {script}", flush=True)
        command = [
            sys.executable,
            str(base / script),
            str(args.corrida),
            "--intervalo",
            str(args.intervalo),
        ]
        if script != "graficar10.py":
            command += ["--g0", args.g0, "--g1", args.g1]
        result = subprocess.run(command)
        if result.returncode:
            return result.returncode
    return 0


if __name__ == "__main__":
    sys.exit(main())
