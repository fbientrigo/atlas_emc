"""Pruebas sin hardware. Ejecutables sintéticos exclusivamente en directorios temporales."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("diag", Path(__file__).with_name("atlas_diagnostico.py"))
d = importlib.util.module_from_spec(spec)
spec.loader.exec_module(d)


def output(value=0):
    vals = {k: 0 for k in d.FIELDS}
    vals["data_group_0"] = value
    return "TgcReadUplink ctr. Found requested device with ids: 240,0\n" + "\n".join(
        "%16s0x%08X" % (k + ":", v) for k, v in vals.items()) + "\n0\n"


class DiagnosticTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def test_real_format_and_bit31(self):
        a, b = d.parse_capture(output()), d.parse_capture(output(0x80000000))
        self.assertTrue(a["complete"])
        change = d.delta(a["values"], b["values"])["data_group_0"]
        self.assertEqual(change["bits"], [31])
        self.assertTrue(change["low_byte_same"])

    def test_malformed_missing_and_duplicate_are_not_zero(self):
        for text in ("", output() + "data_group_0: 0x0", output().replace("magic:0x00000000", "magic:0x100000000"),
                     output().replace("data_group_0:0x00000000", "data_group_0:0xGG"),
                     output() + "data_group_9: 0x0"):
            self.assertFalse(d.parse_capture(text)["complete"], text)

    def test_every_bit(self):
        a = d.parse_capture(output())["values"]
        for n in range(32):
            self.assertEqual(d.delta(a, d.parse_capture(output(1 << n))["values"])["data_group_0"]["bits"], [n])

    def test_uio_ambiguity_offset_and_insufficient_size(self):
        dev = {"id": "uio7", "name": {"text": "tgc_readUplink_regs\n"}, "maps": [
            {"id": "map0", "addr": {"text": "0x12340000"}, "size": {"text": "0x1000"}, "offset": {"text": "0x0"}}]}
        self.assertEqual(d.uio_contract([dev])["maps"][0]["addr"], 0x12340000)
        for invalid in ([], [dev, dev]):
            with self.assertRaises(ValueError):
                d.uio_contract(invalid)
        dev["maps"][0]["offset"]["text"] = "0x4"
        with self.assertRaises(ValueError):
            d.uio_contract([dev])
        dev["maps"][0]["offset"]["text"] = "0"
        dev["maps"][0]["size"]["text"] = "0x20"
        with self.assertRaises(ValueError):
            d.uio_contract([dev])

    def test_no_authorization_never_launches(self):
        with patch.object(d, "run_reader") as run:
            with self.assertRaises(ValueError):
                d.capture(argparse.Namespace(autorizar_lecturas=False))
            run.assert_not_called()

    def test_unvalidated_plan_rejected(self):
        with self.assertRaisesRegex(ValueError, "build_map"):
            d.validate_plan({"schema": 1, "type": "tgc_readuplink_cli_9_groups"})

    def test_hash_mismatch_rejected(self):
        validation = {k: {"confirmed": True, "evidence": "SOLO PRUEBA SINTÉTICA"} for k in
                      ("build_map", "binary_dependencies", "read_semantics", "exclusive_operator", "hardware_authorization")}
        fake = {"path": str(Path(sys.executable).resolve()), "sha256": "0" * 64}
        with self.assertRaisesRegex(ValueError, "hash incompatible"):
            d.validate_plan({"schema": 1, "type": "tgc_readuplink_cli_9_groups", "validation": validation,
                             "reader": fake, "libraries": [fake]})

    def test_process_success_stderr_and_nonzero(self):
        x = d.run_reader([sys.executable, "-c", "import sys; print('salida'); print('error',file=sys.stderr); sys.exit(7)"], 2)
        self.assertEqual(x["returncode"], 7)
        self.assertEqual(x["stdout"], "salida\n")
        self.assertEqual(x["stderr"], "error\n")

    def test_timeout_no_unbounded_wait(self):
        start = time.monotonic()
        x = d.run_reader([sys.executable, "-c", "import signal,time; signal.signal(signal.SIGTERM, signal.SIG_IGN); time.sleep(20)"], 0.2)
        self.assertEqual(x["stop_reason"], "timeout")
        self.assertFalse(x["alive_after_signals"])
        self.assertLess(time.monotonic() - start, 2)
        self.assertIsNotNone(x["process_at_failure"])

    def test_output_flood_stops(self):
        x = d.run_reader([sys.executable, "-c", "import os;\nwhile True: os.write(1,b'x'*8192)"], 2)
        self.assertEqual(x["stop_reason"], "output_limit")
        self.assertEqual(len(x["stdout"]), d.LIMIT)

    def test_signal_return_is_preserved(self):
        x = d.run_reader([sys.executable, "-c", "import os,signal,resource; resource.setrlimit(resource.RLIMIT_CORE,(0,0)); os.kill(os.getpid(),signal.SIGBUS)"], 2)
        self.assertEqual(x["returncode"], -signal.SIGBUS)

    def test_lock_exclusion_and_sticky_failure(self):
        with patch.object(d, "LOCK", self.root / "lock"):
            fd = d.acquire_lock()
            try:
                with self.assertRaises(BlockingIOError):
                    d.acquire_lock()
                d.lock_state(fd, "FALLO SINTÉTICO")
            finally:
                os.close(fd)
            with self.assertRaisesRegex(ValueError, "sin cierre limpio"):
                d.acquire_lock()

    def test_session_error_stops_without_second_attempt(self):
        fake = self.root / "fake_reader"
        fake.write_text("#!" + sys.executable + "\nprint('incompleta')\n", encoding="utf-8")
        fake.chmod(0o700)
        plan = self.root / "plan.json"
        plan.write_text(json.dumps({"reader": {"path": str(fake)}}))
        args = argparse.Namespace(autorizar_lecturas=True, muestras=3, intervalo=1, timeout=1,
                                  plan=str(plan), salida=str(self.root / "session"), fase="SINTÉTICA", detener_iguales=0)
        with patch.object(d, "LOCK", self.root / "lock"), patch.object(d, "validate_plan"), patch.object(d, "inventory", return_value={}) as inv:
            self.assertEqual(d.capture(args), 2)
        rows = [json.loads(s) for s in (self.root / "session/muestras.jsonl").read_text().splitlines()]
        self.assertEqual(sum(r["kind"] == "attempt" for r in rows), 1)
        self.assertTrue((self.root / "lock").read_text())
        self.assertEqual(inv.call_count, 2)
        report = d.make_report(self.root / "session")
        self.assertIn("completos sin stderr: 0", report)

    def test_unfinished_journal_remains_inconclusive(self):
        (self.root / "muestras.jsonl").write_text('{"kind":"attempt","index":0}\n{"kind":')
        report = d.make_report(self.root)
        self.assertIn("intento sin resultado", report)
        self.assertIn("incompleta/corrupta", report)
        self.assertIn("No hay cierre registrado", report)

    def test_successful_session_keeps_raw_outputs_and_high_bit_changes(self):
        plan = self.root / "plan.json"
        plan.write_text(json.dumps({"reader": {"path": str(Path(sys.executable).resolve())}}))
        args = argparse.Namespace(autorizar_lecturas=True, muestras=2, intervalo=1, timeout=1,
                                  plan=str(plan), salida=str(self.root / "success"), fase="SINTÉTICA", detener_iguales=0)
        results = [{"stdout": output(v), "stderr": "", "returncode": 0, "stop_reason": None,
                    "pid": os.getpid(), "duration_s": 0.1, "start": d.stamp()} for v in (0, 1 << 31)]
        with patch.object(d, "LOCK", self.root / "lock"), patch.object(d, "validate_plan"), patch.object(d, "inventory", return_value={}), patch.object(d, "run_reader", side_effect=results), patch.object(d.time, "sleep"):
            self.assertEqual(d.capture(args), 0)
        self.assertEqual((self.root / "lock").read_text(), "")
        self.assertEqual((self.root / "success/muestra_00001.out").read_text(), output(1 << 31))
        report = d.make_report(self.root / "success")
        self.assertIn("solo el byte bajo: 1", report)
        self.assertIn("Transiciones con cambios en algún grupo: 1", report)

    def test_monitor_does_not_wait_forever_if_child_still_alive(self):
        from unittest.mock import Mock
        read1, write1 = os.pipe()
        read2, write2 = os.pipe()
        fake = Mock(pid=99999999, stdout=os.fdopen(read1, "rb"), stderr=os.fdopen(read2, "rb"))
        fake.poll.return_value = None
        try:
            start = time.monotonic()
            with patch.object(d.subprocess, "Popen", return_value=fake), patch.object(d.os, "killpg"), patch.object(d, "process_snapshot", return_value={}):
                result = d.run_reader(["SIMULADO"], 0.1)
            self.assertTrue(result["alive_after_signals"])
            self.assertLess(time.monotonic() - start, 2)
            fake.wait.assert_not_called()
        finally:
            os.close(write1)
            os.close(write2)

    def test_inventory_never_spawns(self):
        with patch.object(d.subprocess, "Popen", side_effect=AssertionError("No ejecutar")):
            data = d.inventory()
            self.assertIn("uio", data)

    def test_no_overwrite(self):
        p = self.root / "one.json"
        d.save_new(p, {"original": True})
        with self.assertRaises(FileExistsError):
            d.save_new(p, {})
        self.assertTrue(d.load(p)["original"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
