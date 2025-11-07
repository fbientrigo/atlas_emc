#!/usr/bin/env python3
"""Relocate image assets into the normalized taxonomy and update Markdown references."""
from __future__ import annotations

import argparse
import csv
import re
import shutil
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

VAULT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ASSETS_ROOT = VAULT_ROOT / "assets"
AUDIT_CSV = VAULT_ROOT / "logging" / "2025-Week1_image_audit.csv"

IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg"}
DEFAULT_YEAR = 2024


@dataclass
class Reference:
    note: Path
    line: int


@dataclass
class AssetPlan:
    source: Path
    target: Path
    category: str
    year: int
    month: int
    slug: str
    references: List[Reference]

    @property
    def catalog_row(self) -> Dict[str, str]:
        note_display = ", ".join(sorted(str(ref.note) for ref in self.references)) or "—"
        return {
            "image": str(self.target.relative_to(VAULT_ROOT)),
            "source": str(self.source.relative_to(VAULT_ROOT)),
            "category": self.category,
            "year": str(self.year),
            "month": f"{self.month:02d}",
            "slug": self.slug,
            "notes": note_display,
        }


_slug_cleanup = re.compile(r"[^a-z0-9]+")
_date_token = re.compile(r"^(?P<month>0[1-9]|1[0-2])(?P<day>[0-3][0-9])")


CATEGORY_RULES: List[Tuple[Iterable[str], str]] = [
    (("oscilo", "saturation", "scope", "measurement"), "mediciones"),
    (("bergm", "clps", "letvscross", "technical_design_report", "report"), "documentacion"),
    (("pigbt", "com8", "mattermost", "opcua", "welcome", "uplink", "interface"), "interfaces"),
    (("schem", "diagram", "table", "map", "mermaid", "flow", "frame", "graph"), "diagramas"),
    (("firmware", "vivado", "prbs", "xlconcat", "register", "bit", "xsa", "elink"), "firmware"),
    (("pin", "board", "connector", "setup", "hardware", "fpga", "connection", "clock"), "hardware"),
]


def load_references(audit_csv: Path) -> Dict[str, List[Reference]]:
    refs: Dict[str, List[Reference]] = defaultdict(list)
    if not audit_csv.exists():
        return refs
    with audit_csv.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            image = row["image_name"].strip()
            note = row["note"].strip()
            line = row.get("line", "")
            line_no = int(line) if line else 0
            refs[image].append(Reference(note=Path(note), line=line_no))
    return refs


def list_assets(root: Path) -> List[Path]:
    return [path for path in root.rglob("*") if path.suffix.lower() in IMAGE_EXTENSIONS and path.is_file()]


def infer_category(path: Path) -> str:
    lower_name = path.name.lower()
    lower_parts = "/".join(part.lower() for part in path.parts)
    for keywords, category in CATEGORY_RULES:
        if any(keyword in lower_name or keyword in lower_parts for keyword in keywords):
            return category
    return "firmware"


def infer_month_from_note(note: Path) -> Optional[int]:
    match = _date_token.match(note.name)
    if match:
        return int(match.group("month"))
    return None


def infer_month(path: Path, references: List[Reference]) -> int:
    months: List[int] = []
    for ref in references:
        month = infer_month_from_note(ref.note)
        if month:
            months.append(month)
    if not months:
        for part in path.parts[::-1]:
            match = _date_token.match(part)
            if match:
                return int(match.group("month"))
        return 1
    return min(months)


def infer_slug(name: str) -> str:
    stem = Path(name).stem.lower()
    slug = _slug_cleanup.sub("-", stem).strip("-")
    return slug or "asset"


def build_plan(assets: List[Path], references: Dict[str, List[Reference]], assets_root: Path) -> Dict[Path, AssetPlan]:
    plan: Dict[Path, AssetPlan] = {}
    used_targets: Dict[str, int] = defaultdict(int)
    for source in sorted(assets):
        category = infer_category(source)
        refs = references.get(source.name, [])
        month = infer_month(source, refs)
        slug_base = infer_slug(source.name)
        key = (category, month, source.suffix.lower(), slug_base)
        used_targets[str(key)] += 1
        index = used_targets[str(key)]
        slug = slug_base if index == 1 else f"{slug_base}-v{index}"
        target = assets_root / category / f"{DEFAULT_YEAR}" / f"{month:02d}" / f"{slug}{source.suffix.lower()}"
        plan[source] = AssetPlan(
            source=source,
            target=target,
            category=category,
            year=DEFAULT_YEAR,
            month=month,
            slug=slug,
            references=refs,
        )
    return plan


def ensure_directory(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def move_assets(plan: Dict[Path, AssetPlan], dry_run: bool = True) -> None:
    for source, item in plan.items():
        target = item.target
        if source.resolve() == target.resolve():
            continue
        if dry_run:
            print(f"DRY-RUN move {source.relative_to(VAULT_ROOT)} -> {target.relative_to(VAULT_ROOT)}")
            continue
        ensure_directory(target)
        if target.exists():
            target.unlink()
        ensure_directory(target)
        shutil.move(str(source), str(target))


def build_reference_mapping(plan: Dict[Path, AssetPlan]) -> Dict[str, str]:
    mapping: Dict[str, str] = {}
    for source, item in plan.items():
        new_rel = str(item.target.relative_to(VAULT_ROOT)).replace("\\", "/")
        mapping[source.name] = new_rel
    return mapping


MARKDOWN_PATTERN = re.compile(r"!\[\[(?P<target>[^|\]]+)(?P<suffix>\|[^\]]*)?]]")


def update_markdown(mapping: Dict[str, str], dry_run: bool = True) -> None:
    md_files = list(VAULT_ROOT.rglob("*.md"))
    for md_file in md_files:
        text = md_file.read_text(encoding="utf-8")
        updated = False

        def repl(match: re.Match) -> str:
            nonlocal updated
            target = match.group("target").strip()
            suffix = match.group("suffix") or ""
            basename = Path(target).name
            new_path = mapping.get(target) or mapping.get(basename)
            if not new_path:
                return match.group(0)
            updated = True
            return f"![[{new_path}{suffix}]]"

        new_text = MARKDOWN_PATTERN.sub(repl, text)
        if updated and not dry_run:
            md_file.write_text(new_text, encoding="utf-8")
        elif updated:
            print(f"DRY-RUN update {md_file.relative_to(VAULT_ROOT)}")


def write_catalog(plan: Dict[Path, AssetPlan], destination: Path, dry_run: bool = True) -> None:
    headers = ["image", "source", "category", "year", "month", "slug", "notes"]
    if dry_run:
        print(f"DRY-RUN catalog -> {destination}")
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=headers)
        writer.writeheader()
        for item in sorted(plan.values(), key=lambda value: str(value.target)):
            writer.writerow(item.catalog_row)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Relocate Obsidian image assets into the normalized taxonomy")
    parser.add_argument("--apply", action="store_true", help="apply the relocation instead of performing a dry run")
    parser.add_argument("--assets-root", type=Path, default=DEFAULT_ASSETS_ROOT, help="destination assets root directory")
    parser.add_argument("--catalog", type=Path, default=VAULT_ROOT / "logging" / "2025-week2_assets_catalog.csv", help="CSV catalog output")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    references = load_references(AUDIT_CSV)
    assets = list_assets(VAULT_ROOT)
    plan = build_plan(assets, references, args.assets_root)
    move_assets(plan, dry_run=not args.apply)
    update_mapping = build_reference_mapping(plan)
    update_markdown(update_mapping, dry_run=not args.apply)
    write_catalog(plan, args.catalog, dry_run=not args.apply)


if __name__ == "__main__":
    main()
