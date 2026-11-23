import csv
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import fifo


class FifoTests(unittest.TestCase):
    def test_uio_lookup_checks_both_identity_fields_and_range(self):
        with tempfile.TemporaryDirectory() as temp:
            sysfs = Path(temp)
            device = sysfs / "uio42"
            map0 = device / "maps/map0"
            map0.mkdir(parents=True)
            (device / "name").write_text("cmb_event_regs\n")
            (map0 / "addr").write_text("0xa01b0000\n")
            (map0 / "offset").write_text("0x0\n")
            (map0 / "size").write_text("0x4000\n")
            with self.assertRaisesRegex(ValueError, "uio42 cmb_event_regs"):
                fifo.find_uio(sysfs)
            (device / "name").write_text(fifo.UIO_NAME)
            with self.assertRaisesRegex(ValueError, "size=0x4000"):
                fifo.find_uio(sysfs)
            (map0 / "size").write_text("0x10000\n")
            self.assertEqual(fifo.find_uio(sysfs), device)

    def test_reads_full_event_in_address_order_and_saves_csv(self):
        header = (fifo.MAGIC, 10, 42, 32768)
        payload = tuple(range(8192))
        device = Path("uio42")
        with patch.object(fifo, "read_words", side_effect=[
            (fifo.MAGIC,), header, header + payload + header,
        ]) as read:
            actual_header, words = fifo.read_event(device)
        self.assertEqual(actual_header, header)
        self.assertEqual(words, payload)
        offsets = read.call_args.args[1]
        self.assertEqual(offsets[4:12], tuple(range(0x1000, 0x1020, 4)))
        self.assertEqual(offsets[-5], 0x8FFC)

        with tempfile.TemporaryDirectory() as temp:
            path = fifo.save_event(Path(temp) / "runs", actual_header, words)
            with path.open(newline="") as saved:
                rows = list(csv.DictReader(saved))
        self.assertEqual(len(rows), 1024)
        self.assertEqual(rows[0]["w0"], "0x00000000")
        self.assertEqual(rows[1]["w0"], "0x00000008")
        self.assertEqual(rows[-1]["w7"], "0x00001fff")
        self.assertEqual(rows[-1]["event_id"], "42")

    def test_reads_only_magic_on_unknown_firmware(self):
        with patch.object(fifo, "read_words", return_value=(0,)) as read:
            with self.assertRaisesRegex(ValueError, "Firma CMB"):
                fifo.read_event(Path("uio42"))
        read.assert_called_once_with(Path("uio42"), (0,))

    def test_bypasses_ram_until_ready_and_full_size(self):
        for status, size in [(1, 0), (3, 32768), (2, 4)]:
            header = (fifo.MAGIC, status, 42, size)
            with self.subTest(status=status, size=size):
                with patch.object(fifo, "read_words", side_effect=[(fifo.MAGIC,), header]) as read:
                    with self.assertRaisesRegex(ValueError, "READY=1"):
                        fifo.read_event(Path("uio42"))
                self.assertEqual(read.call_count, 2)

    def test_rejects_event_changed_mid_read(self):
        header = (fifo.MAGIC, 10, 42, 32768)
        changed = (fifo.MAGIC, 10, 43, 32768)
        with patch.object(fifo, "read_words", side_effect=[
            (fifo.MAGIC,), header, header + (0,) * 8192 + changed,
        ]):
            with self.assertRaisesRegex(ValueError, "Cambió la cabecera"):
                fifo.read_event(Path("uio42"))


if __name__ == "__main__":
    unittest.main()
