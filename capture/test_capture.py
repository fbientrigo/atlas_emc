"""python3 test_capture.py — pruebas de consola en una copia temporal."""
import csv
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest

import doctor

HERE = Path(__file__).resolve().parent


class CaptureTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        for name in ('emp','night.py','doctor.py','registers.py','registers.json','raw.sh'):
            shutil.copy2(HERE/name, self.root/name)
        self.addCleanup(self.cli, 'stop', check=False)

    def cli(self, *args, check=True):
        p = subprocess.run([str(self.root/'emp'), *args], cwd='/', capture_output=True,
                           text=True, timeout=6)
        if check:
            self.assertEqual(p.returncode, 0, p.stderr + p.stdout)
        return p

    def latest(self):
        runs = self.root/'runs'
        return runs/(runs/'latest').read_text()

    def wait_done(self):
        deadline = time.monotonic()+5
        while time.monotonic() < deadline:
            if 'completa |' in self.cli('status').stdout:
                return
            time.sleep(.04)
        self.fail(self.cli('status').stdout)

    def test_changes(self):
        p = self.cli('watch','--mock','--count','8')
        self.assertEqual([line.split()[0] for line in p.stdout.splitlines()[1:]], ['1','4','7'])
        self.assertTrue(p.stdout.splitlines()[-1].endswith('0x00000000'))
        self.assertEqual(len(self.cli('watch','--mock','--count','8','--all').stdout.splitlines()), 9)

    def test_config(self):
        path = self.root/'registers.json'
        cfg = json.loads(path.read_text())
        cfg.update(registers={'otro':'0x20'}, compare=['otro'])
        path.write_text(json.dumps(cfg))
        self.assertIn('otro', self.cli('read','--mock').stdout)
        self.assertIn('otro=', self.cli('doctor','--mock').stdout)
        cfg['registers']['otro'] = '0x21'
        path.write_text(json.dumps(cfg))
        self.assertNotEqual(self.cli('read','--mock',check=False).returncode, 0)

    def test_csv_and_timing(self):
        t0 = time.time_ns()
        self.cli('start','--mock','--delay-min','.002','--bursts','2','--every-min','.005',
                 '--count','12','--interval-ms','2')
        self.wait_done()
        run = self.latest()
        with (run/'data.csv').open() as f:
            rows = list(csv.DictReader(f))
        self.assertEqual([(int(r['burst']),int(r['sample'])) for r in rows],
                         [(b,i) for b in (1,2) for i in range(1,13)])
        self.assertGreaterEqual(int(rows[0]['unix_ns'])-t0, 120_000_000)
        self.assertGreater(int(rows[12]['unix_ns'])-int(rows[0]['unix_ns']), 240_000_000)
        self.assertEqual(rows[3]['data_group_0'], '0x00000005')
        s = json.loads((run/'status.json').read_text())
        self.assertEqual(s['rows'], 24)
        self.assertEqual(s['estimate'], (run/'data.csv').stat().st_size)

    def test_stop_delay_and_restart(self):
        self.cli('start','--mock','--delay-min','1')
        one = self.latest()
        p = self.cli('start','--mock',check=False)
        self.assertNotEqual(p.returncode, 0)
        self.assertEqual(one, self.latest())
        self.assertIn('detenida', self.cli('stop').stdout)
        self.assertEqual(len((one/'data.csv').read_text().splitlines()), 1)
        self.cli('start','--mock','--bursts','1','--count','3')
        self.wait_done()
        self.assertNotEqual(one, self.latest())

    def test_stop_during_burst(self):
        self.cli('start','--mock','--bursts','1','--count','10000','--interval-ms','10')
        time.sleep(.15)
        self.assertIn('detenida', self.cli('stop').stdout)
        run = self.latest()
        n = json.loads((run/'status.json').read_text())['rows']
        self.assertTrue(0 < n < 10000)
        self.assertEqual(len((run/'data.csv').read_text().splitlines()), n+1)

    def test_ic_reply(self):
        stub = self.root/'lpGbtRegister'
        stub.write_text('#!/bin/sh\necho "Reply payload: ' + '00000000'*6 +
                        '000000a5"\necho "Read: Register Address: 1d7 Value: 0xA5"\n')
        stub.chmod(0o755)
        self.assertTrue(doctor.probe(str(stub), 'emp_lpgbt_10'))
        stub.write_text(stub.read_text().replace('000000a5','00000001'))
        self.assertFalse(doctor.probe(str(stub), 'emp_lpgbt_10'))
        stub.write_text('#!/bin/sh\necho "Read: Register Address: 1d7 Value: 0x00"\n')
        self.assertFalse(doctor.probe(str(stub), 'emp_lpgbt_10'))

    def test_raw(self):
        stub = self.root/'busybox'
        stub.write_text('#!/bin/sh\nprintf "%s %s %s argc=%s\\n" "$1" "$2" "$3" "$#"\n')
        stub.chmod(0o755)
        result = subprocess.check_output([self.root/'raw.sh','0xA00E0004','0xA00E0008'],
                    env=dict(os.environ, PATH=str(self.root)+':'+os.environ['PATH']), text=True)
        for address in ('0xA00E0004','0xA00E0008'):
            self.assertIn(f'devmem {address} 32 argc=3', result)


if __name__ == '__main__':
    unittest.main(verbosity=2)
