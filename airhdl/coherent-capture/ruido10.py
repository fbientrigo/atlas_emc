#!/usr/bin/env python3
"""Analiza desvíos del patrón de g0/c0 y g1/c0 en el CSV del uplink 10."""
import argparse
import csv
from collections import Counter, defaultdict, deque
from datetime import datetime, timezone
from math import nan
from pathlib import Path
from tempfile import TemporaryDirectory


def reference(value):
    try:
        first, second = (int(part, 16) for part in value.split(":"))
        if first != second and 0 <= first <= 255 and 0 <= second <= 255:
            return first, second, first, second
    except ValueError:
        pass
    raise argparse.ArgumentTypeError("Usa dos bytes hexadecimales distintos, por ejemplo 18:80.")


def classify(observed, pattern):
    reverse = pattern[1:] + pattern[:1]
    if observed == pattern:
        return "ok", 0
    if observed == reverse:
        return "fase", 0
    masks = [sum((got != wanted) << i for i, (got, wanted) in enumerate(zip(observed, phase)))
             for phase in (pattern, reverse)]
    # Ambiguous phase: count the window, but do not assign its deviations to frames.
    sizes = [bin(mask).count("1") for mask in masks]
    return "desvio", masks[sizes.index(min(sizes))] if sizes[0] != sizes[1] else None


def analyze(path, patterns, seconds):
    columns = {"t_unix_ns", "seq_gap", "rdy_a", "rdy_b", "d0", "d1"}
    bins = defaultdict(Counter)
    distributions = defaultdict(lambda: [Counter() for _ in patterns])
    preview = deque(maxlen=16)
    detail = None
    histograms = [[Counter() for _ in range(4)] for _ in patterns]
    first = last = None
    previous = None
    times = {}
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(line for line in stream if not line.startswith("#"))
        if not columns.issubset(reader.fieldnames or []):
            raise ValueError("Faltan columnas de emp_acq_capture.")
        for row in reader:
            if None in row or any(row[key] is None for key in columns):
                raise ValueError(f"Fila de datos incompleta: {reader.line_num}.")
            now, gap = int(row["t_unix_ns"]), int(row["seq_gap"])
            if first is None:
                first = now
            if last is not None and now < last:
                raise ValueError(f"El reloj retrocedió en la fila {reader.line_num}.")
            index = (now - first) // (seconds * 10**9)
            count = bins[index]
            if last is not None:
                count["dt_max_ns"] = max(count["dt_max_ns"], now - last)
            last = now
            count["filas"] += 1
            count["omitidos_seq"] += max(0, gap - 1)
            if (row["rdy_a"], row["rdy_b"]) != ("1", "1"):
                count["sin_ready"] += 1
                previous = None
                continue

            count["validos"] += 1
            observed = [tuple(int(row[key], 16).to_bytes(4, "little")) for key in ("d0", "d1")]
            for phases, values in zip(histograms, observed):
                for counts, value in zip(phases, values):
                    counts[value] += 1
            for histogram, values in zip(distributions[index], observed):
                histogram.update(values)
            result = [classify(values, pattern) for values, pattern in zip(observed, patterns)]
            flags = tuple(category == "desvio" for category, _ in result)
            if detail is None:
                if any(flags):
                    detail = [*preview, (now, observed)]
                else:
                    preview.append((now, observed))
            elif len(detail) < 24:
                detail.append((now, observed))
            for i, (category, _) in enumerate(result):
                name = f"g{i}_{category}"
                count[name] += 1
                if flags[i]:
                    times.setdefault(name, [now, now])[1] = now
                if previous is not None and gap == 1:
                    count[f"g{i}_desvios_previos"] += previous[i]
                    count[f"g{i}_desvio_despues_de_desvio"] += previous[i] and flags[i]
            if all(flags):
                count["coincidencias"] += 1
                times.setdefault("coincidencias", [now, now])[1] = now
                masks = [mask for _, mask in result]
                if None in masks:
                    count["coincidencias_fase_ambigua"] += 1
                else:
                    count["coincidencias_mismo_frame"] += bool(masks[0] & masks[1])
            previous = flags
    if not bins:
        raise ValueError("El CSV está vacío.")
    indices = range(max(bins) + 1)
    empty = [Counter() for _ in patterns]
    return ([bins.get(index, Counter()) for index in indices], first, times, histograms,
            [distributions.get(index, empty) for index in indices], detail if detail is not None else list(preview))


def ratio(value, total):
    return value / total if total else nan


def expected(row):
    return row["g0_desvio"] * row["g1_desvio"] / row["validos"] if row["validos"] else 0


def plot(rows, seconds, output, title, plt):
    fig, axes = plt.subplots(3, 1, figsize=(10, 8.5), sharex=True, layout="constrained")
    t = [(i + .5) * seconds / 60 for i in range(len(rows))]
    colors = ("#206582", "#b25225")
    for i, color in enumerate(colors):
        for category, style in (("desvio", "-"), ("fase", ":")):
            y = [100 * ratio(r[f"g{i}_{category}"], r["validos"]) for r in rows]
            axes[0].plot(t, y, style, color=color, marker=".", label=f"g{i}/c0 · {category}")
        baseline = [100 * ratio(r[f"g{i}_desvio"], r["validos"]) for r in rows]
        after = [100 * ratio(r[f"g{i}_desvio_despues_de_desvio"], r[f"g{i}_desvios_previos"])
                 for r in rows]
        axes[2].plot(t, after, ".-", color=color, label=f"g{i}/c0 · tras otro desvío")
        axes[2].plot(t, baseline, ":", color=color, label=f"g{i}/c0 · tasa del intervalo")
    axes[1].plot(t, [r["coincidencias"] for r in rows], ".-", label="Misma ventana")
    axes[1].plot(t, [r["coincidencias_mismo_frame"] for r in rows], ".-", label="Mismo frame (fases resolubles)")
    axes[1].plot(t, [expected(r) for r in rows], "--", color="#55616c", label="Esperadas si son independientes")
    axes[0].set(title="Patrón de referencia", ylabel="% de ventanas válidas")
    axes[1].set(title="Desvíos en ambos canales", ylabel="Ventanas por intervalo")
    axes[2].set(title="¿Los desvíos se agrupan?", ylabel="% con desvío", xlabel="Minutos desde el primer snapshot")
    for ax in axes:
        ax.legend(loc="best", ncols=2, fontsize=8)
        ax.grid(axis="y", alpha=.22)
        ax.set_ylim(bottom=0)
        ax.spines[["top", "right"]].set_visible(False)
    fig.suptitle(f"{title} · g0/c0 y g1/c0 · intervalos de {seconds} s")
    fig.savefig(output, dpi=160)
    plt.close(fig)


def reversed_byte(value):
    return int(f"{value:08b}"[::-1], 2)


def plot_histograms(folder, histograms, patterns, title, plt):
    with (folder / "histograma_valores.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["canal", "valor_hex", "total", "N", "N+1", "N+2", "N+3", "porcentaje",
                         "valor_reverse_hex"])
        for group, phases in enumerate(histograms):
            counts = sum(phases, Counter())
            total = sum(counts.values())
            for value, count in sorted(counts.items()):
                writer.writerow([f"g{group}/c0", f"0x{value:02X}", count,
                                 *(phase[value] for phase in phases),
                                 f"{100 * count / total:.9g}", f"0x{reversed_byte(value):02X}"])

    modes = [
        ("histograma_valores.png", "Ocurrencias · escala logarítmica", "log"),
        ("fig4_hist_eje0.png", "Ocurrencias", "linear"),
        ("fig4_hist_pct.png", "% de bytes del canal", "percent"),
    ]
    for name, ylabel, mode in modes:
        fig, axes = plt.subplots(1, 2, figsize=(12, 4.6), layout="constrained")
        fig.suptitle(f"{title} · histograma de bytes · reverse\nAzul: referencia   ·   Naranja: otros valores")
        for group, (ax, phases, pattern) in enumerate(zip(axes, histograms, patterns)):
            counts = sum(phases, Counter())
            total = sum(counts.values())
            ax.set(title=f"g{group}/c0 · {total:,} bytes", xlabel="Valor observado", ylabel=ylabel)
            ax.grid(axis="y", alpha=.22)
            if not counts:
                ax.text(.5, .5, "Sin ventanas válidas", ha="center", transform=ax.transAxes)
                continue
            raw_values = sorted(counts, key=reversed_byte)
            heights = [counts[v] if mode != "percent" else 100 * counts[v] / total for v in raw_values]
            bottom = .7 if mode == "log" else 0
            if mode == "log":
                ax.set_yscale("log")
            ceiling = max(heights) * (2.5 if mode == "log" else 1.22)
            ax.set_ylim(bottom, ceiling)
            bars = ax.bar(range(len(heights)), [y - bottom for y in heights], bottom=bottom,
                          color=["#276a8b" if v in pattern[:2] else "#ba542c" for v in raw_values],
                          width=.68)
            stride = max(1, (len(heights) + 15) // 16)
            shown = sorted(set(range(0, len(heights), stride)) |
                           {i for i, value in enumerate(raw_values) if value in pattern[:2]})
            ax.set_xticks(shown, labels=[f"0x{reversed_byte(raw_values[i]):02X}" for i in shown],
                          rotation=45 if len(shown) > 7 else 0)
            if len(bars) <= 12:
                for bar, value in zip(bars, heights):
                    label = f"{value:.2f}%" if mode == "percent" else f"{value:,}"
                    ax.annotate(label, (bar.get_x() + bar.get_width()/2, value),
                                xytext=(0, 4), textcoords="offset points", ha="center", fontsize=8)
        fig.savefig(folder / name, dpi=165)
        plt.close(fig)


def plot_composition(folder, distributions, patterns, steps, title, plt):
    from matplotlib.colors import LogNorm

    t = [i * steps / 60 for i in range(len(distributions))]
    fig, axes = plt.subplots(2, 1, figsize=(11, 6), sharex=True, layout="constrained")
    composition_fig, composition_axes = plt.subplots(2, 1, figsize=(11, 6),
                                                     sharex=True, layout="constrained")
    for group, (ax, composition_ax, pattern) in enumerate(zip(axes, composition_axes, patterns)):
        counts = [row[group] for row in distributions]
        totals = [sum(row.values()) for row in counts]
        x, y, frequency = [], [], []
        for when, row, total in zip(t, counts, totals):
            for value, count in row.items():
                x.append(when)
                y.append(reversed_byte(value))
                frequency.append(100 * count / total)
        ax.set(title=f"g{group}/c0", ylabel="Byte · reverse", ylim=(-7, 263))
        ticks = sorted(set([0, 64, 128, 192, 255]) | {reversed_byte(value) for value in pattern[:2]})
        ax.set_yticks(ticks, labels=[f"0x{value:02X}" for value in ticks])
        if frequency:
            points = ax.scatter(x, y, c=frequency, s=14, cmap="viridis",
                                norm=LogNorm(vmin=min(min(frequency), 10), vmax=100), linewidths=0)
            fig.colorbar(points, ax=ax, label="% de bytes del intervalo")
        bottom = [0] * len(t)
        segments = [(f"0x{reversed_byte(value):02X}", [row[value] for row in counts], color)
                    for value, color in zip(pattern[:2], ("#276a8b", "#4e9683"))]
        segments.append(("Otros", [total - row[pattern[0]] - row[pattern[1]]
                                    for row, total in zip(counts, totals)], "#ba542c"))
        for label, values, color in segments:
            heights = [100 * value / total if total else 0 for value, total in zip(values, totals)]
            composition_ax.bar(t, heights, width=steps/60, align="edge", bottom=bottom,
                               color=color, label=label)
            bottom = [acc + value for acc, value in zip(bottom, heights)]
        composition_ax.set(title=f"g{group}/c0", ylabel="% de bytes", ylim=(0, 100))
        composition_ax.legend(loc="upper right", ncols=3, fontsize=8)
        for panel in (ax, composition_ax):
            panel.grid(axis="y", alpha=.2)
            panel.set_xlim(0, len(t) * steps / 60)
    axes[-1].set_xlabel("Minutos desde el primer snapshot")
    composition_axes[-1].set_xlabel("Minutos desde el primer snapshot")
    fig.suptitle(f"{title} · valor frente al tiempo")
    composition_fig.suptitle(f"{title} · composición por intervalo")
    fig.savefig(folder / "fig1B_valor_vs_hora.png", dpi=165)
    composition_fig.savefig(folder / "fig1A_composicion_apilada.png", dpi=165)
    plt.close(fig)
    plt.close(composition_fig)


def plot_detail(folder, detail, first, title, plt):
    fig, axes = plt.subplots(4, 1, figsize=(12, 8), sharex=True, layout="constrained")
    fig.suptitle(f"{title} · detalle de ventanas válidas")
    for group in range(2):
        for row, mode in enumerate(("crudo", "reverse")):
            ax = axes[2 * group + row]
            for phase in range(4):
                values = [observed[group][phase] for _, observed in detail]
                if row:
                    values = list(map(reversed_byte, values))
                ax.scatter(range(len(values)), values, label=("N" if phase == 0 else f"N+{phase}"), s=35, marker="osx^"[phase])
            ax.set_ylabel(f"g{group}/c0\n{mode}")
            ax.set_ylim(-8, 263)
            ax.set_yticks([0, 64, 128, 192, 255], labels=["0x00", "0x40", "0x80", "0xC0", "0xFF"])
            ax.grid(alpha=.18)
    if detail:
        axes[0].legend(loc="upper right", ncols=4, fontsize=8)
        axes[-1].set_xticks(range(len(detail)),
                            labels=[f"{(now-first)/1e9:.3f}" for now, _ in detail], rotation=45)
    else:
        axes[0].text(.5, .5, "Sin ventanas válidas", transform=axes[0].transAxes, ha="center")
    axes[-1].set_xlabel("Ventanas válidas seleccionadas · etiquetas en segundos desde el inicio")
    fig.savefig(folder / "fig2_bloques.png", dpi=165)
    plt.close(fig)


def plot_timing(folder, rows, seconds, title, plt):
    fig, axes = plt.subplots(2, 1, figsize=(11, 5.5), sharex=True, layout="constrained")
    t = [(i + .5) * seconds / 60 for i in range(len(rows))]
    axes[0].plot(t, [row.get("dt_max_ns", nan)/1e6 for row in rows], ".-", color="#276a8b")
    axes[0].set(title="Mayor separación entre snapshots registrados", ylabel="Intervalo máximo (ms)")
    axes[1].bar(t, [row["omitidos_seq"] for row in rows], width=.8 * seconds/60, color="#ba542c")
    axes[1].set(ylabel="Omitidos según SEQ", xlabel="Minutos desde el primer snapshot")
    for ax in axes:
        ax.grid(axis="y", alpha=.2)
        ax.set_ylim(bottom=0)
    fig.suptitle(f"{title} · tiempos y oportunidades de adquisición")
    fig.savefig(folder / "fig3_tiempos.png", dpi=165)
    plt.close(fig)


def report(folder, rows, first, times, patterns, seconds):
    columns = ["filas", "validos", "sin_ready", "omitidos_seq",
               "g0_ok", "g0_fase", "g0_desvio", "g0_desvios_previos", "g0_desvio_despues_de_desvio",
               "g1_ok", "g1_fase", "g1_desvio", "g1_desvios_previos", "g1_desvio_despues_de_desvio",
               "coincidencias", "coincidencias_mismo_frame", "coincidencias_fase_ambigua"]
    with (folder / "ruido_por_intervalo.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["desde_s", *columns, "coincidencias_esperadas", "dt_max_ms"])
        for i, row in enumerate(rows):
            writer.writerow([i * seconds, *(row[key] for key in columns), expected(row),
                             row["dt_max_ns"]/1e6 if "dt_max_ns" in row else ""])
    total = sum(rows, Counter())
    utc = datetime.fromtimestamp(first // 10**9, timezone.utc).isoformat()
    lines = [f"Primer snapshot: {utc}", f"Ventanas válidas: {total['validos']}/{total['filas']}",
             f"Ventanas sin READY: {total['sin_ready']}; omitidas según SEQ: {total['omitidos_seq']}"]
    for i, pattern in enumerate(patterns):
        group = f"g{i}"
        label = " ".join(f"{byte:02X}" for byte in pattern)
        rate = 100 * ratio(total[f"{group}_desvio"], total["validos"])
        lines.append(f"{group}/c0 · referencia cruda {label} · desvíos {total[f'{group}_desvio']} ({rate:.4f}%)"
                     f" · fase opuesta exacta {total[f'{group}_fase']}")
    lines += [f"Coincidencias en ventana: {total['coincidencias']} (esperadas por intervalos si son independientes: "
              f"{sum(map(expected, rows)):.2f})",
              f"Coincidencias en el mismo frame con fase resoluble: {total['coincidencias_mismo_frame']}",
              f"Coincidencias con fase ambigua en al menos un canal: {total['coincidencias_fase_ambigua']}"]
    for name, (start, stop) in times.items():
        lines.append(f"{name} · primer/último desde inicio: {(start-first)/1e9:.3f} / {(stop-first)/1e9:.3f} s")
    lines += [
        "Un desvío no coincide con ninguna de las dos fases del patrón alternante.",
        "La comparación entre ventanas consecutivas exige SEQ + 1 y READY en ambas.",
        "El conteo esperado usa la tasa de cada canal en cada intervalo y es descriptivo.",
        "Las ventanas están muestreadas. Estas tasas no son BER del enlace.",
    ]
    (folder / "resumen_ruido.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("corrida", type=Path, help="carpeta de la corrida o data.csv")
    parser.add_argument("--g0", type=reference, default="18:80", help="referencia cruda observada para g0/c0")
    parser.add_argument("--g1", type=reference, default="40:0C", help="referencia cruda observada para g1/c0")
    parser.add_argument("--intervalo", type=int, default=60, help="segundos por intervalo")
    args = parser.parse_args()
    if args.intervalo <= 0:
        parser.error("--intervalo debe ser positivo.")
    source = args.corrida / "data.csv" if args.corrida.is_dir() else args.corrida
    target = source.parent / "resultados_ruido"
    patterns = (args.g0, args.g1)
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        rows, first, times, histograms, distributions, detail = analyze(source, patterns, args.intervalo)
        with TemporaryDirectory(dir=source.parent) as temporary:
            folder = Path(temporary)
            plot(rows, args.intervalo, folder / "ruido_g0_g1.png", source.parent.name, plt)
            report(folder, rows, first, times, patterns, args.intervalo)
            plot_histograms(folder, histograms, patterns, source.parent.name, plt)
            plot_composition(folder, distributions, patterns, args.intervalo, source.parent.name, plt)
            plot_detail(folder, detail, first, source.parent.name, plt)
            plot_timing(folder, rows, args.intervalo, source.parent.name, plt)
            target.mkdir(exist_ok=True)
            for result in folder.iterdir():
                result.replace(target / result.name)
    except (OSError, ValueError, OverflowError, ImportError) as exc:
        parser.exit(1, f"Error: {exc}\n")
    print(target)


if __name__ == "__main__":
    main()
