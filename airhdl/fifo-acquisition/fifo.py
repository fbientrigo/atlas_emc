"""Consulta y guarda un evento CMB publicado por el EMP."""

import argparse
import csv
from datetime import datetime, timezone
import os
from pathlib import Path
import subprocess

DIRECTORY = Path(__file__).resolve().parent
UIO_NAME = "cmb_event_regs_0"
BASE = 0xA01B0000
MAP_SIZE = 0x10000
MAGIC = 0x454D5001
HEADER = (0x00, 0x08, 0x10, 0x0C)  # magic, status, event_id, event_size
RAM = 0x1000
WORDS_PER_FRAME = 8
FRAMES = 1024
EVENT_SIZE = FRAMES * WORDS_PER_FRAME * 4


def find_uio(sysfs=Path("/sys/class/uio")):
    names = []
    for device in sorted(sysfs.glob("uio[0-9]*")):
        name = (device / "name").read_text().strip()
        map0 = device / "maps/map0"
        if not (map0 / "addr").is_file():
            continue
        addr = int((map0 / "addr").read_text(), 0)
        names.append((device, name, addr))

    matches = [device for device, name, addr in names if name == UIO_NAME and addr == BASE]
    if len(matches) != 1:
        related = [
            f"{device.name} {name} @ 0x{addr:08x}"
            for device, name, addr in names
            if name == UIO_NAME or addr == BASE or "cmb" in name.lower()
        ]
        found = ", ".join(related) if related else "ninguno"
        raise ValueError(
            f"Se esperaba un UIO único {UIO_NAME} @ 0x{BASE:08x}; candidatos: {found}"
        )

    device = matches[0]
    map0 = device / "maps/map0"
    size = int((map0 / "size").read_text(), 0)
    offset = int((map0 / "offset").read_text(), 0)
    if size != MAP_SIZE or offset != 0:
        raise ValueError(
            f"{device.name}: size=0x{size:x}, offset=0x{offset:x}; "
            f"se esperaba size=0x{MAP_SIZE:x}, offset=0x0"
        )
    return device


def read_words(device, offsets):
    result = subprocess.run(
        [
            str(DIRECTORY / "uio-read32"),
            device.name[3:],
            UIO_NAME,
            hex(BASE),
            hex(MAP_SIZE),
            *map(hex, offsets),
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode:
        detail = result.stderr.strip()
        raise ValueError(f"Falló uio-read32 ({result.returncode}). {detail}".rstrip())

    words = result.stdout.splitlines()
    if len(words) != len(offsets) or any(len(word) != 8 for word in words):
        raise ValueError("uio-read32 devolvió una lectura incompleta o inválida")
    return tuple(int(word, 16) for word in words)


def read_header(device):
    (magic,) = read_words(device, HEADER[:1])
    if magic != MAGIC:
        raise ValueError(f"Firma CMB 0x{magic:08x}, se esperaba 0x{MAGIC:08x}")
    header = read_words(device, HEADER)
    if header[0] != MAGIC:
        raise ValueError("La firma CMB cambió durante la lectura")
    return header


def read_event(device):
    before = read_header(device)
    _, status, _, size = before
    if status & 3 != 2 or size != EVENT_SIZE:
        raise ValueError(
            f"Se requiere READY=1, BUSY=0 y event_size={EVENT_SIZE}; "
            f"status=0x{status:08x}, event_size={size}"
        )

    offsets = tuple(range(RAM, RAM + size, 4))
    values = read_words(device, HEADER + offsets + HEADER)
    guard = len(HEADER)
    if values[:guard] != before or values[-guard:] != before:
        raise ValueError("Cambió la cabecera del evento durante la lectura")
    return before, values[guard:-guard]


def save_event(directory, header, words):
    _, status, event_id, _ = header
    directory.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    path = directory / f"{stamp}_event_{event_id}.csv"
    pending = path.with_suffix(".csv.part")
    output = pending.open("x", newline="", encoding="ascii")
    try:
        with output:
            writer = csv.writer(output)
            writer.writerow(
                ["frame", "event_id", "status", *[f"w{i}" for i in range(WORDS_PER_FRAME)]]
            )
            for offset in range(0, len(words), WORDS_PER_FRAME):
                frame = words[offset:offset + WORDS_PER_FRAME]
                writer.writerow(
                    [offset // WORDS_PER_FRAME, event_id, f"0x{status:08x}",
                     *[f"0x{word:08x}" for word in frame]]
                )
        os.link(pending, path)
    finally:
        pending.unlink()
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("check", help="verificar sysfs sin acceder a MMIO")
    commands.add_parser("status", help="leer la cabecera CMB")
    capture = commands.add_parser("capture", help="guardar el evento publicado")
    capture.add_argument("--out-dir", type=Path, default=DIRECTORY / "runs")
    args = parser.parse_args()

    try:
        device = find_uio()
        if args.command == "check":
            print(f"/dev/{device.name} {UIO_NAME} @ 0x{BASE:08x} size=0x{MAP_SIZE:x}")
        elif args.command == "status":
            magic, status, event_id, size = read_header(device)
            print(
                f"magic=0x{magic:08x} event_id={event_id} event_size={size} "
                f"status=0x{status:08x} BUSY={status & 1} READY={(status >> 1) & 1} "
                f"OVERFLOW={(status >> 2) & 1} VETO={(status >> 3) & 1}"
            )
        else:
            header, words = read_event(device)
            path = save_event(args.out_dir, header, words)
            print(f"{len(words) // WORDS_PER_FRAME} frames guardados en {path.resolve()}")
    except (OSError, ValueError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
