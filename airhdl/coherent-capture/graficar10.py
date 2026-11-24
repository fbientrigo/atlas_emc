#!/usr/bin/env python3
"""Genera gráficos y tablas a partir de una corrida de emp_acq_capture."""
import argparse
import csv
from collections import Counter
from datetime import datetime, timezone
from math import nan
from pathlib import Path
from tempfile import TemporaryDirectory


GROUPS = tuple(f"d{i}" for i in range(7))
WORDS = tuple(f"w{i}" for i in range(8))
HEADER = (
    "t_unix_ns", "seq", "seq_gap", "tries", "status", "rdy_a", "rdy_b",
    *(f"a{i}" for i in range(8)), *(f"b{i}" for i in range(8)), *GROUPS,
)


class Window:
    def __init__(self):
        self.rows = self.missing = self.unready = self.transitions = 0
        self.fixed = [0] * 7
        self.alternating = [0] * 7
        self.changed = [0] * 7
        self.different_ab = [0] * 8


def read_capture(path, seconds):
    windows = {}
    histograms = [[Counter() for _ in range(4)] for _ in GROUPS]
    first = last = None
    previous = None
    with path.open(encoding="utf-8", newline="") as stream:
        rows = csv.reader(line for line in stream if not line.startswith("#"))
        if tuple(next(rows, [])) != HEADER:
            raise ValueError("Se esperaba un CSV de emp_acq_capture con a0…a7, b0…b7 y d0…d6.")
        for number, row in enumerate(rows, 1):
            if len(row) != len(HEADER):
                raise ValueError(f"Fila de datos {number} incompleta o inválida.")
            time_ns, gap = int(row[0]), int(row[2])
            if first is None:
                first = time_ns
            if last is not None and time_ns < last:
                raise ValueError(f"El reloj retrocedió en la fila de datos {number}.")
            last = time_ns
            index = (time_ns - first) // (seconds * 10**9)
            if index not in windows:
                windows[index] = Window()
            window = windows[index]
            window.rows += 1
            window.missing += max(0, gap - 1)
            window.unready += row[5] != "1" or row[6] != "1"
            for i in range(8):
                window.different_ab[i] += row[7 + i] != row[15 + i]

            current = [int(value, 16) for value in row[23:]]
            consecutive = previous is not None and gap == 1
            window.transitions += consecutive
            for group, raw in enumerate(current):
                b0 = raw & 255
                b1 = raw >> 8 & 255
                b2 = raw >> 16 & 255
                b3 = raw >> 24
                histograms[group][0][b0] += 1
                histograms[group][1][b1] += 1
                histograms[group][2][b2] += 1
                histograms[group][3][b3] += 1
                if b0 == b2 and b1 == b3:
                    if b0 == b1:
                        window.fixed[group] += 1
                    else:
                        window.alternating[group] += 1
                if consecutive:
                    window.changed[group] += raw != previous[group]
            previous = current
    if first is None:
        raise ValueError("El CSV no contiene snapshots.")
    empty = Window()
    return [windows.get(i, empty) for i in range(max(windows) + 1)], histograms, first, last


def percent(count, total):
    return 100 * count / total if total else nan


def save_outputs(plt, folder, windows, histograms, first, last, seconds, label):
    plt.rcParams.update({"font.size": 10, "axes.spines.top": False, "axes.spines.right": False})
    utc = datetime.fromtimestamp(first / 1e9, timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    step = seconds / 60
    edges = [i * step for i in range(len(windows) + 1)]
    centers = [(i + .5) * step for i in range(len(windows))]
    xlabel = f"Minutos desde el primer snapshot ({utc})"

    def heatmap(ax, values, names, title):
        ax.set_title(title, loc="left")
        colors = plt.get_cmap("viridis").with_extremes(bad="#e9edf1")
        raster = ax.pcolormesh(edges, range(len(names) + 1), list(zip(*values)),
                               cmap=colors, vmin=0, vmax=100, shading="flat")
        ax.set_yticks([i + .5 for i in range(len(names))], labels=names)
        ax.invert_yaxis()
        ax.figure.colorbar(raster, ax=ax, label="%")

    fig, axes = plt.subplots(2, 1, figsize=(10, 5.8), sharex=True, layout="constrained")
    fig.suptitle(f"{label} · adquisición")
    axes[0].stairs([w.rows for w in windows], edges, color="#234a75")
    axes[0].set_ylabel("Snapshots guardados")
    axes[1].plot(centers, [w.missing for w in windows], ".-", color="#a74727", label="Omitidos según SEQ")
    axes[1].plot(centers, [w.unready for w in windows], "x", color="#167360", label="Flag READY incompleto")
    axes[1].set(ylabel="Snapshots por intervalo", xlabel=xlabel, xlim=(edges[0], edges[-1]))
    axes[1].legend()
    for ax in axes:
        ax.grid(axis="y", alpha=.2)
        ax.set_ylim(bottom=0)
    fig.savefig(folder / "01_adquisicion.png", dpi=150)
    plt.close(fig)

    measures = (
        ("AAAA dentro del snapshot", "fixed", "rows"),
        ("ABAB dentro del snapshot (A distinto de B)", "alternating", "rows"),
        ("Cambios entre snapshots consecutivos (SEQ + 1)", "changed", "transitions"),
    )
    fig, axes = plt.subplots(3, 1, figsize=(10, 8), sharex=True, layout="constrained")
    fig.suptitle(f"{label} · estabilidad de c0 en d0…d6 (cuatro frames por snapshot)")
    for ax, (title, numerator, denominator) in zip(axes, measures):
        values = [[percent(x, getattr(w, denominator)) for x in getattr(w, numerator)] for w in windows]
        heatmap(ax, values, GROUPS, title)
    axes[-1].set_xlabel(xlabel)
    fig.savefig(folder / "02_estabilidad.png", dpi=150)
    plt.close(fig)

    fig, ax = plt.subplots(figsize=(10, 3.9), layout="constrained")
    fig.suptitle(f"{label} · A frente a B · palabras completas de 32 bits")
    heatmap(ax, [[percent(x, w.rows) for x in w.different_ab] for w in windows],
            WORDS, "Porcentaje de snapshots donde A y B difieren, aunque el valor sea estable en el tiempo")
    ax.set_xlabel(xlabel)
    fig.savefig(folder / "03_diferencias_A_B.png", dpi=150)
    plt.close(fig)

    fig, axes = plt.subplots(7, 1, figsize=(10, 10), sharex=True, layout="constrained")
    fig.suptitle(f"{label} · c0 de cada grupo, cuatro posiciones por snapshot\n"
                 "Color: porcentaje del byte en esa posición durante toda la corrida")
    total = sum(w.rows for w in windows)
    for group, (ax, phases) in enumerate(zip(axes, histograms)):
        values = [[percent(hist[value], total) for value in range(256)] for hist in phases]
        raster = ax.imshow(values, aspect="auto", interpolation="nearest",
                           vmin=0, vmax=100, cmap="viridis")
        ax.set_yticks(range(4), labels=("N", "N+1", "N+2", "N+3"))
        ax.set_ylabel(GROUPS[group], rotation=0, labelpad=18)
    ticks = (*range(0, 256, 32), 255)
    axes[-1].set_xticks(ticks, labels=[f"{x:02X}" for x in ticks])
    axes[-1].set_xlabel("Byte hexadecimal, sin invertir bits ni aplicar bitslip")
    fig.colorbar(raster, ax=axes, label="% de snapshots en cada posición")
    fig.savefig(folder / "04_distribucion_bytes.png", dpi=150)
    plt.close(fig)

    # Show departures from each position's most frequent byte on a useful scale.
    fig = plt.figure(figsize=(11, 6.5), layout="constrained")
    grid = fig.add_gridspec(2, 2)
    axes = (fig.add_subplot(grid[0, :]), fig.add_subplot(grid[1, 0]),
            fig.add_subplot(grid[1, 1]))
    colors = ("#0072B2", "#D55E00", "#009E73", "#CC79A7")
    positions = ("N", "N+1", "N+2", "N+3")
    for group, phases in enumerate(histograms):
        for phase, hist in enumerate(phases):
            _, count = hist.most_common(1)[0]
            deviation = total - count
            axes[0].bar(group + (phase - 1.5) * .19, 100 * deviation / total,
                        width=.18, color=colors[phase],
                        label=positions[phase] if group == 0 else None)
            if group in (4, 6):
                detail = axes[1 if group == 4 else 2]
                detail.bar(phase, 100 * deviation / total,
                            width=.18, color=colors[phase],
                            label=positions[phase])
    axes[0].set(xlim=(-.65, 6.65), xticks=range(7), xticklabels=GROUPS,
                ylabel="% distinto del byte más frecuente", title="Todos los grupos")
    for group, ax in ((4, axes[1]), (6, axes[2])):
        ax.set(xticks=range(4), xticklabels=positions,
               ylabel="% distinto del dominante", title=f"d{group} · escala propia")
    for ax in axes:
        ax.set_ylim(bottom=0)
        ax.grid(axis="y", alpha=.2)
    axes[0].legend(ncols=4, loc="upper center")
    fig.suptitle(f"{label} · variación de c0 en cada posición del frame")
    fig.savefig(folder / "05_bytes_minoritarios.png", dpi=160)
    plt.close(fig)

    with (folder / "por_intervalo.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["desde_s", "filas", "omitidos_seq", "sin_ready", "transiciones_seq1",
                         *(f"{g}_{kind}_pct" for _, kind, _ in measures for g in GROUPS),
                         *(f"{word}_A_distinto_B_pct" for word in WORDS)])
        for i, w in enumerate(windows):
            writer.writerow([i * seconds, w.rows, w.missing, w.unready, w.transitions,
                             *(percent(x, getattr(w, denominator)) for _, numerator, denominator in measures
                               for x in getattr(w, numerator)),
                             *(percent(x, w.rows) for x in w.different_ab)])

    with (folder / "distribucion_bytes.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["grupo", "frame_desde_N", "byte_hex", "ocurrencias", "porcentaje"])
        for group, phases in zip(GROUPS, histograms):
            for phase, hist in enumerate(phases):
                for value, count in hist.most_common():
                    writer.writerow([group, phase, f"0x{value:02X}", count, percent(count, total)])

    elapsed = (last - first) / 1e9
    omitted = sum(w.missing for w in windows)
    (folder / "resumen.txt").write_text(
        f"Corrida {label}\nPrimer snapshot {utc}\nDuración observada {elapsed:.3f} s\n"
        f"Snapshots guardados {total}\nSnapshots omitidos según SEQ {omitted}\n"
        f"Snapshots con flag READY incompleto {sum(w.unready for w in windows)}\n"
        f"Intervalo {seconds} s\n"
        "AAAA y ABAB comparan cuatro bytes del canal 0 de cada grupo dentro del snapshot.\n"
        "Los cambios temporales se cuentan sólo entre filas con SEQ + 1.\n"
        "A y B son los dos frames completos. Cada w es una palabra cruda del frame.\n"
        "El último intervalo puede ser parcial. El gris indica falta de datos.\n",
        encoding="utf-8",
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("corrida", type=Path, help="carpeta de la corrida o su data.csv")
    parser.add_argument("--intervalo", type=int, default=60, help="segundos por intervalo (60)")
    args = parser.parse_args()
    if args.intervalo < 1:
        parser.error("--intervalo debe ser positivo")
    source = args.corrida / "data.csv" if args.corrida.is_dir() else args.corrida
    target = source.parent / "graficos"
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        with TemporaryDirectory(dir=source.parent) as staging:
            folder = Path(staging)
            windows, histograms, first, last = read_capture(source, args.intervalo)
            save_outputs(plt, folder, windows, histograms, first, last, args.intervalo, source.parent.name)
            target.mkdir(exist_ok=True)
            for result in folder.iterdir():
                result.replace(target / result.name)
    except (OSError, ValueError, ImportError) as exc:
        parser.exit(1, f"Error: {exc}\n")
    print(target)


if __name__ == "__main__":
    main()
