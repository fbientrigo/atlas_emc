"""Regression checks for byte order, gaps and conditional neighbor counts."""

import csv
from pathlib import Path
import tempfile
import unittest

import numpy as np

from crosstalk10 import read_capture
from graficar10 import HEADER
from ruido10 import analyze, reference


class AnalysisTests(unittest.TestCase):
    def test_snapshot_mapping_and_exclusions(self):
        # Actual user snapshot with synthetic timing, exclusions and one gap.
        fields = (
            "0,452442,0,1,0x06E75A03,1,1,"
            "0x00FFF0C4,0x0100FF0C,0xE6A2C480,0xFF00FEFE,"
            "0x00000020,0x00FFFF00,0x00FCFFEF,0x00000003,"
            "0x00FFF000,0x0100FF40,0xE6A2C480,0xFF00FEFE,"
            "0x00000020,0x00FFFF00,0x00FC00EF,0x00000003,"
            "0x00C400C4,0x400C400C,0x80808080,0xFEFEFEFE,"
            "0x20202020,0x00000000,0xEFEFEFEF"
        ).split(",")
        rows = []
        for i in range(4):
            row = fields.copy()
            row[0] = str(1795462267766809421 + i * 10000000)
            row[2] = "0" if i == 0 else "1"
            rows.append(row)
        rows[1][2] = "4"
        rows[1][7] = "0x00FFF1C4"  # c1 toggles bit 0 in A only
        rows[2][5] = "0"
        rows[3][23] = "0x00C40000"  # A/diag inconsistent
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            source = folder / "data.csv"
            with source.open("w", newline="") as f:
                writer = csv.writer(f)
                writer.writerow(HEADER)
                writer.writerows(rows)
            patterns = (reference("C4:00"), reference("0C:40"))
            bins, totals, _, _ = read_capture(source, 60, patterns, folder)
            self.assertEqual(
                totals, dict(rows=4, unready=1, inconsistent=1, missing=3, events=1)
            )
            hist = bins[0]
            self.assertEqual(hist[0, 0, 0, 0, 0xF0], 1)
            self.assertEqual(hist[0, 0, 0, 0, 0xF1], 1)
            self.assertEqual(hist[0, 0, 1, 1, 0xF0], 2)
            self.assertEqual(hist[1, 2, 0, 0, 0x01], 2)
            self.assertEqual(hist[1, 2, 1, 1, 0x01], 2)
            conditional = hist[0, 0].sum(axis=0)[:2]
            tv = 0.5 * np.abs(conditional[0] / 2 - conditional[1] / 2).sum()
            self.assertEqual(tv, 0.5)
            with (folder / "saltos_seq.csv").open() as f:
                gaps = list(csv.DictReader(f))
            self.assertEqual(gaps[0]["omitidos"], "3")
            # Byte histograms must retain C4 rather than bit-reversed 23.
            result = analyze(source, patterns, 60)
            self.assertEqual(result[3][0][0][0xC4], 2)
            self.assertEqual(result[3][0][0][0x23], 0)


if __name__ == "__main__":
    unittest.main()
