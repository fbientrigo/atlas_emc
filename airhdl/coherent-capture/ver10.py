#!/usr/bin/env python3
"""Vista en vivo de g0/c0 y g1/c0. Lee el CSV de emp_acq_capture por stdin."""
import argparse
from collections import Counter, deque
from datetime import datetime
import os
import select
import sys
from time import monotonic


def reference(value):
    try:
        a, b = (int(part, 16) for part in value.split(":"))
        if a != b and 0 <= a <= 255 and 0 <= b <= 255:
            return (a, b, a, b), (b, a, b, a)
    except ValueError:
        pass
    raise argparse.ArgumentTypeError("Usa dos bytes distintos, por ejemplo 18:80.")


def inspect(word, phases):
    observed = tuple(int(word, 16).to_bytes(4, "little"))
    if observed == phases[0]:
        return "OK", 0, [f"{value:02X}" for value in observed]
    if observed == phases[1]:
        return "fase BABA", 0, [f"{value:02X}" for value in observed]
    masks = [[value != wanted for value, wanted in zip(observed, phase)] for phase in phases]
    lengths = [sum(mask) for mask in masks]
    if lengths[0] == lengths[1]:
        tags = ["*" if both else "?" if either else ""
                for both, either in zip(map(all, zip(*masks)), map(any, zip(*masks)))]
        label = "fase ambigua"
    else:
        tags = ["*" if wrong else "" for wrong in masks[lengths.index(min(lengths))]]
        label = "desvío"
    return label, min(lengths), [f"{value:02X}{tag}" for value, tag in zip(observed, tags)]


class Monitor:
    def __init__(self, phases, size):
        self.phases = phases
        self.size = size
        self.history = deque()
        self.total = Counter()
        self.recent = Counter()
        self.last = None
        self.last_error = None
        self.updated = monotonic()

    def consume(self, line):
        if not line or line.startswith(b"#") or line.startswith(b"t_unix_ns,"):
            return
        fields = line.split(b",")
        if len(fields) != 30:
            raise ValueError("Se esperaba una fila de 30 columnas de emp_acq_capture.")
        when, seq, gap = (int(value) for value in fields[:3])
        ready = fields[5:7] == [b"1", b"1"]
        readings = [inspect(word, phases) for word, phases in zip(fields[23:25], self.phases)]
        if self.last is not None:
            self.total["omitidas"] += max(0, gap - 1)
        self.last = (when, seq, ready, readings)
        self.updated = monotonic()
        if not ready:
            self.total["sin_ready"] += 1
            return

        counts = {"válidas": 1, "ambos": int(all(reading[1] for reading in readings))}
        for i, (label, wrong, _) in enumerate(readings):
            counts.update({f"g{i}_vent": int(wrong > 0), f"g{i}_bytes": wrong,
                           f"g{i}_fase": int(label == "fase BABA")})
        self.total.update(counts)
        self.recent.update(counts)
        self.history.append(counts)
        if len(self.history) > self.size:
            self.recent.subtract(self.history.popleft())
        if any(reading[1] for reading in readings):
            self.last_error = self.last

    def screen(self):
        if self.last is None:
            return "EMP · esperando ventanas de la captura…"
        when, seq, ready, readings = self.last
        stamp = datetime.fromtimestamp(when / 1e9).strftime("%H:%M:%S.%f")[:-3]
        age = monotonic() - self.updated
        state = f"sin datos nuevos por {age:.1f} s" if age > 2 else "en vivo"
        lines = [
            f"EMP uplink 10  |  SEQ {seq}  |  {stamp}  |  {state}",
            f"Ventanas válidas {self.total['válidas']}  |  sin READY {self.total['sin_ready']}"
            f"  |  omitidas según SEQ {self.total['omitidas']}",
            "",
            "Canal     N     N+1   N+2   N+3   Estado           Recientes   Total   Bytes",
        ]
        for group, (label, _, values) in enumerate(readings):
            key = f"g{group}"
            frames = "  ".join(f"{value:4}" for value in values)
            recent = f"{self.recent[key+'_vent']}/{len(self.history)}"
            total = self.total[key + "_vent"]
            byte_count = self.total[key + "_bytes"]
            lines.append(f"{key}/c0     {frames}  {label if ready else 'sin READY':16} {recent:11} {total:7} {byte_count}")
        lines += [
            "",
            f"Ambos en la misma ventana: {self.recent['ambos']}/{len(self.history)} recientes"
            f"  |  {self.total['ambos']} total",
            f"Fase BABA exacta: g0 {self.total['g0_fase']}  |  g1 {self.total['g1_fase']} (aparte)",
        ]
        if self.last_error is not None:
            _, last_seq, _, errors = self.last_error
            frames = "  |  ".join(f"g{i}/c0 " + " ".join(values)
                                 for i, (_, _, values) in enumerate(errors))
            lines.append(f"Último desvío · SEQ {last_seq}  |  {frames}")
        lines += ["* byte distinto · ? depende de la fase",
                  "Recientes = ventanas con desvío / ventanas válidas recientes",
                  "Bytes = diferencias acumuladas contra la fase más cercana",
                  "Ctrl+C para cerrar"]
        return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--g0", type=reference, default="18:80")
    parser.add_argument("--g1", type=reference, default="40:0C")
    parser.add_argument("--ventanas", type=int, default=1000, help="tamaño de la ventana móvil")
    args = parser.parse_args()
    if args.ventanas <= 0:
        parser.error("--ventanas debe ser positivo.")

    monitor = Monitor((args.g0, args.g1), args.ventanas)
    terminal = sys.stdout.isatty()

    def draw():
        prefix = "\033[H\033[J" if terminal else ""
        print(prefix + monitor.screen(), flush=True)

    pending = b""
    dirty = False
    draw()
    refresh = monotonic() + .5
    try:
        while True:
            ready, _, _ = select.select([sys.stdin], [], [], max(0, refresh - monotonic()))
            if ready:
                chunk = os.read(sys.stdin.fileno(), 65536)
                if not chunk:
                    if pending.strip():
                        raise ValueError("El CSV terminó con una línea incompleta.")
                    break
                lines = (pending + chunk).split(b"\n")
                pending = lines.pop()
                for line in lines:
                    monitor.consume(line)
                dirty = True
            if monotonic() >= refresh:
                if terminal or dirty:
                    draw()
                dirty = False
                refresh = monotonic() + .5
    except KeyboardInterrupt:
        pass
    except (ValueError, OverflowError) as exc:
        parser.exit(1, f"Error: {exc}\n")
    if dirty:
        draw()


if __name__ == "__main__":
    main()
