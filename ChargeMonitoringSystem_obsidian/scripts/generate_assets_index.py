#!/usr/bin/env python3
"""Generate the Markdown asset index required by the migration plan."""
from __future__ import annotations

import argparse
import csv
from pathlib import Path

VAULT_ROOT = Path(__file__).resolve().parents[1]
CATALOG_CSV = VAULT_ROOT / "logging" / "2025-week2_assets_catalog.csv"
INDEX_MD = VAULT_ROOT / "20_Documents" / "assets_index.md"
DEFAULT_AUTHOR = "Equipo ChaMS"


def format_use(notes_field: str) -> str:
    if not notes_field or notes_field.strip() == "—":
        return "Sin nota referenciada"
    first = notes_field.split(",", 1)[0].strip()
    name = Path(first).stem.replace("_", " ")
    return f"Nota {name}"


def format_date(year: str, month: str) -> str:
    month = month.zfill(2)
    return f"{year}-{month}"


def generate_markdown(rows: list[dict[str, str]]) -> str:
    lines = ["# Catálogo maestro de recursos gráficos", "", "| Imagen | Uso principal | Fecha | Autor |", "| --- | --- | --- | --- |"]
    for row in rows:
        imagen = row["image"]
        uso = format_use(row.get("notes", ""))
        fecha = format_date(row.get("year", ""), row.get("month", ""))
        autor = DEFAULT_AUTHOR
        lines.append(f"| `{imagen}` | {uso} | {fecha} | {autor} |")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate the Markdown asset index from the catalog CSV")
    parser.add_argument("--catalog", type=Path, default=CATALOG_CSV, help="catalog CSV path")
    parser.add_argument("--output", type=Path, default=INDEX_MD, help="Markdown file to write")
    args = parser.parse_args()

    with args.catalog.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        rows = list(reader)

    markdown = generate_markdown(rows)
    args.output.write_text(markdown, encoding="utf-8")


if __name__ == "__main__":
    main()
