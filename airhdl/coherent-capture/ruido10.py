#!/usr/bin/env python3
"""Analiza desvíos del patrón de g0/c0 y g1/c0 en el CSV del uplink 10."""
import argparse
import csv
from collections import Counter, defaultdict
from datetime import datetime, timezone
from math import nan
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZIP_DEFLATED, ZipFile


def reference(value):
    try:
        first, second = (int(part, 16) for part in value.split(":"))
        if first != second and 0 <= first <= 255 and 0 <= second <= 255:
            return first, second, first, second
    except ValueError:
        pass
    raise argparse.ArgumentTypeError("Usa dos bytes hexadecimales distintos, por ejemplo 18:80.")


def classify(word, pattern):
    observed = tuple(int(word, 16).to_bytes(4, "little"))
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
            last = now
            count = bins[(now - first) // (seconds * 10**9)]
            count["filas"] += 1
            count["omitidos_seq"] += max(0, gap - 1)
            if (row["rdy_a"], row["rdy_b"]) != ("1", "1"):
                count["sin_ready"] += 1
                previous = None
                continue

            count["validos"] += 1
            result = [classify(row[key], pattern) for key, pattern in zip(("d0", "d1"), patterns)]
            flags = tuple(category == "desvio" for category, _ in result)
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
    return [bins.get(index, Counter()) for index in range(max(bins) + 1)], first, times


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


def report(folder, rows, first, times, patterns, seconds):
    columns = ["filas", "validos", "sin_ready", "omitidos_seq",
               "g0_ok", "g0_fase", "g0_desvio", "g0_desvios_previos", "g0_desvio_despues_de_desvio",
               "g1_ok", "g1_fase", "g1_desvio", "g1_desvios_previos", "g1_desvio_despues_de_desvio",
               "coincidencias", "coincidencias_mismo_frame", "coincidencias_fase_ambigua"]
    with (folder / "ruido_por_intervalo.csv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(["desde_s", *columns, "coincidencias_esperadas"])
        for i, row in enumerate(rows):
            writer.writerow([i * seconds, *(row[key] for key in columns), expected(row)])
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
    target = source.parent / "ruido_g0_g1.zip"
    patterns = (args.g0, args.g1)
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        rows, first, times = analyze(source, patterns, args.intervalo)
        with TemporaryDirectory(dir=source.parent) as temporary:
            folder = Path(temporary)
            plot(rows, args.intervalo, folder / "ruido_g0_g1.png", source.parent.name, plt)
            report(folder, rows, first, times, patterns, args.intervalo)
            archive = folder / target.name
            with ZipFile(archive, "w", ZIP_DEFLATED) as output:
                for name in ("ruido_g0_g1.png", "ruido_por_intervalo.csv", "resumen_ruido.txt"):
                    output.write(folder / name, name)
            archive.replace(target)
    except (OSError, ValueError, OverflowError, ImportError) as exc:
        parser.exit(1, f"Error: {exc}\n")
    print(target)


if __name__ == "__main__":
    main()
