#!/usr/bin/env python3
"""Estabilidad de c1..c3 y asociación con c0, perfil 320 Mb/s."""

import argparse
import csv
from datetime import datetime, timezone
from pathlib import Path

import numpy as np

from graficar10 import HEADER
from ruido10 import reference


def fraction(count, total):
    return count / total if total else float("nan")


def read_capture(source, seconds, patterns, folder):
    bins = {}
    totals = dict(rows=0, unready=0, inconsistent=0, missing=0, events=0)
    first = previous = previous_gap = None
    with source.open(encoding="utf-8", newline="") as stream, (
        folder / "saltos_seq.csv"
    ).open("w", encoding="utf-8", newline="") as gaps:
        writer = csv.writer(gaps)
        writer.writerow(
            [
                "t_unix_ns",
                "utc",
                "desde_s",
                "seq",
                "seq_gap",
                "omitidos",
                "dt_snapshot_ms",
                "desde_salto_anterior_s",
            ]
        )
        reader = csv.reader(line for line in stream if not line.startswith("#"))
        if tuple(next(reader, [])) != HEADER:
            raise ValueError(
                "Se requiere el CSV de captura coherente con a0..b7 y d0..d6."
            )
        for line, row in enumerate(reader, 4):
            if len(row) != 30:
                raise ValueError(f"Fila incompleta {line}")
            now, seq, gap = map(int, (row[0], row[1], row[2]))
            if first is None:
                first = now
            if previous is not None and now < previous:
                raise ValueError(f"Tiempo decreciente en fila {line}")
            index = (now - first) // (seconds * 10**9)
            if index not in bins:
                # group, neighbor, A/B, c0 reference 0/1/other, byte
                bins[index] = np.zeros((2, 3, 2, 3, 256), dtype=np.int64)
            totals["rows"] += 1
            if previous is not None and gap > 1:
                totals["missing"] += gap - 1
                totals["events"] += 1
                writer.writerow(
                    [
                        now,
                        datetime.fromtimestamp(now / 1e9, timezone.utc).isoformat(),
                        (now - first) / 1e9,
                        seq,
                        gap,
                        gap - 1,
                        (now - previous) / 1e6,
                        "" if previous_gap is None else (now - previous_gap) / 1e9,
                    ]
                )
                previous_gap = now
            previous = now
            if row[5:7] != ["1", "1"]:
                totals["unready"] += 1
                continue
            words = [[int(row[offset + g], 16) for offset in (7, 15)] for g in range(2)]
            diag = [int(row[23 + g], 16) for g in range(2)]
            if any(
                (words[g][p] & 255) != ((diag[g] >> (8 * p)) & 255)
                for g in range(2)
                for p in range(2)
            ):
                totals["inconsistent"] += 1
                continue
            for g in range(2):
                for phase, word in enumerate(words[g]):
                    c0 = word & 255
                    state = patterns[g][:2].index(c0) if c0 in patterns[g][:2] else 2
                    for c in range(3):
                        bins[index][
                            g, c, phase, state, (word >> (8 * (c + 1))) & 255
                        ] += 1
    if first is None:
        raise ValueError("CSV vacío")
    return bins, totals, first, previous


def outputs(bins, totals, first, last, seconds, patterns, folder):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    plt.rcParams.update(
        {"font.size": 11, "axes.spines.top": False, "axes.spines.right": False}
    )
    counts = np.stack(
        [
            bins.get(i, np.zeros((2, 3, 2, 3, 256), dtype=np.int64))
            for i in range(max(bins) + 1)
        ]
    )
    pooled = counts.sum(axis=0)
    bits = (np.arange(256)[:, None] >> np.arange(8)) & 1
    times = (np.arange(len(counts)) + 0.5) * seconds / 3600
    measures = []
    findings = []
    with (folder / "histogramas_condicionales.csv").open(
        "w", newline="", encoding="utf-8"
    ) as f:
        writer = csv.writer(f)
        writer.writerow(
            ["desde_s", "grupo", "canal", "frame", "estado_c0", "byte_hex", "conteo"]
        )
        for i, g, c, phase, state, value in zip(*np.nonzero(counts)):
            label = f"0x{patterns[g][state]:02X}" if state < 2 else "otro"
            writer.writerow(
                [
                    i * seconds,
                    g,
                    c + 1,
                    "AB"[phase],
                    label,
                    f"0x{value:02X}",
                    counts[i, g, c, phase, state, value],
                ]
            )
    deltas = np.full((6, 8), np.nan)
    fig, axes = plt.subplots(2, 3, figsize=(14, 7), layout="constrained")
    fig.suptitle("Vecinos c1–c3 · distribución según el byte de c0")
    for g in range(2):
        for c in range(3):
            ax = axes[g, c]
            conditioned = pooled[g, c].sum(axis=0)[:2]
            ns = conditioned.sum(axis=1)
            values = np.argsort(-conditioned.sum(axis=0), kind="stable")[:8]
            values = sorted(v for v in values if conditioned[:, v].sum())
            for state, color in enumerate(("#0072B2", "#D55E00")):
                heights = [
                    100 * fraction(conditioned[state, v], ns[state]) for v in values
                ]
                heights.append(
                    100
                    * fraction(ns[state] - conditioned[state, values].sum(), ns[state])
                )
                ax.bar(
                    np.arange(len(heights)) + (state - 0.5) * 0.38,
                    heights,
                    width=0.38,
                    label=f"c0={patterns[g][state]:02X} · n={ns[state]:,}",
                    color=color,
                    hatch="" if state == 0 else "//",
                )
            ax.set(title=f"g{g}/c{c+1}", ylabel="% de frames", ylim=(0, 110))
            ax.set_xticks(
                range(len(values) + 1), [f"{v:02X}" for v in values] + ["otros"]
            )
            ax.legend(fontsize=8)
            if min(ns) > 0:
                deltas[g * 3 + c] = 100 * (
                    (conditioned[0] @ bits) / ns[0] - (conditioned[1] @ bits) / ns[1]
                )
            tv_global = (
                0.5 * np.abs(conditioned[0] / ns[0] - conditioned[1] / ns[1]).sum()
                if min(ns) > 0
                else float("nan")
            )
            max_delta = np.max(np.abs(deltas[g * 3 + c]))
            findings.append(
                f"g{g}/c{c+1} · n(ref0/ref1)={ns[0]}/{ns[1]} · "
                f"TV global={tv_global:.6f} · máximo |delta bit|={max_delta:.3f} pp"
            )
            phase_counts = pooled[g, c].sum(axis=-1)
            findings.append(
                f"  Ref0 en A/B={phase_counts[0,0]}/{phase_counts[1,0]} · "
                f"ref1 en A/B={phase_counts[0,1]}/{phase_counts[1,1]}"
            )
            # A/B baselines inferred from all valid frames in this run.
            modes = pooled[g, c].sum(axis=1).argmax(axis=1)
            for i, interval in enumerate(counts):
                hist = interval[g, c].sum(axis=0)[:2]
                n0, n1 = hist.sum(axis=1)
                tv = (
                    0.5 * np.abs(hist[0] / n0 - hist[1] / n1).sum()
                    if min(n0, n1) > 0
                    else float("nan")
                )
                all_frames = interval[g, c].sum()
                off_mode = sum(
                    interval[g, c, p].sum() - interval[g, c, p, :, modes[p]].sum()
                    for p in range(2)
                )
                measures.append(
                    [
                        i * seconds,
                        g,
                        c + 1,
                        int(n0),
                        int(n1),
                        int(interval[g, c, :, 2].sum()),
                        tv,
                        100 * fraction(off_mode, all_frames),
                        f"{modes[0]:02X}",
                        f"{modes[1]:02X}",
                    ]
                )
    fig.savefig(folder / "01_vecinos_histogramas.png", dpi=165)
    plt.close(fig)
    with (folder / "vecinos_por_intervalo.csv").open(
        "w", newline="", encoding="utf-8"
    ) as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "desde_s",
                "grupo",
                "canal",
                "n_c0_ref0",
                "n_c0_ref1",
                "n_c0_otro",
                "distancia_TV",
                "fuera_moda_AB_pct",
                "moda_A",
                "moda_B",
            ]
        )
        writer.writerows(measures)
    with (folder / "diferencias_bits.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["grupo", "canal", "bit", "delta_pp"])
        writer.writerows(
            [g, c + 1, b, deltas[g * 3 + c, b]]
            for g in range(2)
            for c in range(3)
            for b in range(8)
        )
    fig, ax = plt.subplots(figsize=(11, 5), layout="constrained")
    im = ax.imshow(deltas, cmap="RdBu_r", vmin=-100, vmax=100, aspect="auto")
    ax.set(
        xticks=range(8),
        xticklabels=[f"bit {b}" for b in range(8)],
        yticks=range(6),
        yticklabels=[f"g{g}/c{c}" for g in range(2) for c in range(1, 4)],
        title="Asociación con c0 · diferencia de ocupación de cada bit",
    )
    for y in range(6):
        for x in range(8):
            value = deltas[y, x]
            ax.text(
                x,
                y,
                "s/d" if np.isnan(value) else f"{value:+.1f}",
                ha="center",
                va="center",
                color="white" if abs(value) > 55 else "black",
            )
    ax.set_xlabel(
        f"g0 ref0/ref1 = {patterns[0][0]:02X}/{patterns[0][1]:02X}     "
        f"g1 ref0/ref1 = {patterns[1][0]:02X}/{patterns[1][1]:02X}"
    )
    fig.colorbar(
        im, ax=ax, label="P(bit=1 | ref0) − P(bit=1 | ref1) · puntos porcentuales"
    )
    fig.savefig(folder / "02_asociacion_bits.png", dpi=165)
    plt.close(fig)
    fig, axes = plt.subplots(2, 2, figsize=(13, 7), sharex=True, layout="constrained")
    fig.suptitle("Estabilidad de vecinos y asociación con c0 durante la corrida")
    for g in range(2):
        for c, color in enumerate(("#0072B2", "#D55E00", "#009E73")):
            series = [r for r in measures if r[1:3] == [g, c + 1]]
            axes[g, 0].plot(times, [r[7] for r in series], color=color, label=f"c{c+1}")
            axes[g, 1].plot(
                times, [100 * r[6] for r in series], color=color, label=f"c{c+1}"
            )
        axes[g, 0].set(
            title=f"g{g} · cambios respecto a la moda de cada fase",
            ylabel="% de frames",
        )
        axes[g, 1].set(
            title=f"g{g} · diferencia entre distribuciones", ylabel="Distancia TV × 100"
        )
        for ax in axes[g]:
            ax.set_ylim(-1, 101)
            ax.legend(ncols=3)
            ax.grid(alpha=0.2)
    for ax in axes[-1]:
        ax.set_xlabel("Horas desde el inicio")
    fig.savefig(folder / "03_vecinos_tiempo.png", dpi=165)
    plt.close(fig)
    with (folder / "saltos_seq.csv").open(encoding="utf-8", newline="") as f:
        gaps = list(csv.DictReader(f))
    fig, axes = plt.subplots(2, 1, figsize=(12, 6), layout="constrained")
    fig.suptitle(
        f"Continuidad de adquisición · {totals['missing']:,} snapshots omitidos en {len(gaps):,} saltos"
    )
    axes[0].vlines(
        [float(r["desde_s"]) / 3600 for r in gaps],
        0,
        [int(r["omitidos"]) for r in gaps],
        color="#D55E00",
    )
    axes[0].set(
        xlabel="Horas desde el inicio",
        ylabel="Snapshots omitidos por salto",
        xlim=(0, max((last - first) / 3.6e12, 0.001)),
        ylim=(0, max([int(r["omitidos"]) for r in gaps] + [1]) * 1.1),
    )
    waiting = [
        float(r["desde_salto_anterior_s"]) for r in gaps if r["desde_salto_anterior_s"]
    ]
    if waiting:
        axes[1].hist(
            waiting, bins=min(30, max(1, int(len(waiting) ** 0.5))), color="#0072B2"
        )
        axes[1].set_title(f"Mediana entre saltos · {np.median(waiting):.2f} s")
    else:
        axes[1].text(
            0.05,
            0.5,
            "Se requieren al menos dos saltos para medir su separación",
            transform=axes[1].transAxes,
        )
    axes[1].set(xlabel="Segundos entre saltos detectados", ylabel="Pares de saltos")
    for ax in axes:
        ax.grid(axis="y", alpha=0.2)
    fig.savefig(folder / "04_saltos_seq.png", dpi=165)
    plt.close(fig)
    report = [
        *findings,
        f"Inicio UTC {datetime.fromtimestamp(first/1e9,timezone.utc).isoformat()}",
        f"Duración {(last-first)/1e9:.3f} s",
        *(f"{k} = {v}" for k, v in totals.items()),
        "Mapa 320 Mb/s asumido: c0=bits 7:0, c1=15:8, c2=23:16, c3=31:24.",
        "A y B aportan dos frames por snapshot para los vecinos. Los bytes se conservan.",
        "READY incompleto y discrepancias entre c0 en A/B y d0/d1 excluyen el snapshot de vecinos.",
        "Histogramas condicionados por el valor de c0 del mismo frame.",
        "TV = 0.5 * suma_v |P(v|ref0)-P(v|ref1)|. Rango 0..1.",
        "Delta por bit = P(bit=1|ref0)-P(bit=1|ref1), en puntos porcentuales.",
        "Fuera de moda usa una referencia inferida por canal y fase A/B de toda la corrida.",
        "Las modas describen estabilidad. Confirmar el patrón transmitido para contar errores.",
        "El CSV conserva conteos por intervalo, fase y estado para auditar los denominadores.",
        "Las fases A/B pueden estar confundidas con el estado de c0. Asociación no prueba causalidad.",
        "Frames próximos y muestreo periódico pueden estar correlacionados.",
        "Para atribuir crosstalk comparar controles c0 fijo/alternante, mismos patrones vecinos y configuración.",
        "No se estiman p-valores ni BER. Sin ambos estados de c0, la comparación queda sin datos.",
    ]
    (folder / "resumen_crosstalk.txt").write_text(
        "\n".join(report) + "\n", encoding="utf-8"
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("corrida", type=Path)
    parser.add_argument("--g0", type=reference, default="C4:00")
    parser.add_argument("--g1", type=reference, default="0C:40")
    parser.add_argument("--intervalo", type=int, default=60)
    args = parser.parse_args()
    if args.intervalo < 1:
        parser.error("--intervalo debe ser positivo")
    source = args.corrida / "data.csv" if args.corrida.is_dir() else args.corrida
    folder = source.parent / "resultados_crosstalk"
    folder.mkdir(exist_ok=True)
    try:
        bins, totals, first, last = read_capture(
            source, args.intervalo, (args.g0, args.g1), folder
        )
        outputs(bins, totals, first, last, args.intervalo, (args.g0, args.g1), folder)
    except (OSError, ValueError) as exc:
        parser.exit(1, f"Error: {exc}\n")
    print(folder)


if __name__ == "__main__":
    main()
