"""Ráfagas, datos en disco y control local de una adquisición Linux."""
import fcntl
import json
import os
import shutil
import signal
import sys
import tempfile
import time
import traceback
from datetime import datetime
from pathlib import Path

from registers import ROOT

RUNS = ROOT / 'runs'
ACTIVE = ('programada', 'esperando', 'leyendo')


def save(path, obj):
    tmp = path.with_suffix('.tmp')
    tmp.write_text(json.dumps(obj, indent=2) + '\n')
    os.replace(tmp, path)


def local_time(epoch):
    return datetime.fromtimestamp(epoch).astimezone().isoformat(timespec='seconds')


def latest():
    return RUNS / (RUNS/'latest').read_text().strip()


def alive(run):
    with (run/'worker.lock').open('rb') as f:
        try:
            fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return True
        return False


def state(run):
    s = json.loads((run/'status.json').read_text())
    if s['state'] in ACTIVE and not alive(run):
        s = json.loads((run/'status.json').read_text())
        if s['state'] in ACTIVE:
            s['state'] = 'interrumpida sin cierre'
    return s


def report(run):
    s = state(run)
    size = (run/'data.csv').stat().st_size
    print(f"{s['state']} | {s['backend']} | ráfaga {s['burst']}/{s['bursts']} | "
          f"{s['rows']:,}/{s['target']:,} filas confirmadas")
    print(f"CSV: {size:,} bytes en disco | estimados al completar: {s['estimate']:,} bytes")
    if s['state'] in ACTIVE:
        print(f"Fin estimado: {local_time(s['eta'])} | último estado: {local_time(s['updated'])}")
    elif 'ended' in s:
        print(f"Fin: {local_time(s['ended'])}")
    if 'error' in s:
        print(s['error'])
    print(run / 'data.csv')
    return s


def start(cfg, a, read):
    period = a.every_min * 60
    interval = a.interval_ms / 1000
    span = (a.count - 1) * interval
    if a.bursts > 1 and (period <= 0 or period < span):
        raise ValueError('La ráfaga debe caber entre dos inicios; aumenta --every-min')
    RUNS.mkdir(exist_ok=True)
    with (RUNS/'.start.lock').open('a+') as gate:
        fcntl.flock(gate, fcntl.LOCK_EX)
        if (RUNS/'latest').exists() and alive(latest()):
            raise ValueError(f'Ya hay una captura activa en {latest()}')
        total = a.bursts * a.count
        header = 'burst,sample,unix_ns,read_ns,' + ','.join(cfg['registers']) + '\n'
        width = len(str(a.bursts)) + len(str(a.count)) + 19 + 10 + 4 + 11 * len(cfg['registers'])
        estimate = len(header) + width * total
        if shutil.disk_usage(RUNS).free < estimate:
            raise OSError(f'Espacio insuficiente para el CSV estimado ({estimate} bytes)')
        run = Path(tempfile.mkdtemp(prefix=time.strftime('%Y%m%dT%H%M%SZ_', time.gmtime()), dir=RUNS))
        worker = (run/'worker.lock').open('wb')
        try:
            fcntl.flock(worker, fcntl.LOCK_EX)
            origin = time.time()
            s = dict(state='programada', backend='SIMULADO' if a.mock else 'libuio',
                     burst=0, bursts=a.bursts, rows=0, target=total, estimate=estimate,
                     updated=origin, eta=origin + a.delay_min*60 + (a.bursts-1)*period + span)
            save(run/'plan.json', dict(map=cfg, backend=s['backend'], count=a.count, bursts=a.bursts,
                                       interval_ms=a.interval_ms, every_min=a.every_min,
                                       delay_min=a.delay_min, created=local_time(origin)))
            (run/'data.csv').write_text(header)
            save(run/'status.json', s)
            sys.stdout.flush()
            sys.stderr.flush()
            pointer = RUNS/'latest.tmp'
            pointer.write_text(run.name)
            os.replace(pointer, RUNS/'latest')
            pid = os.fork()
            if pid == 0:
                # El hijo conserva worker.lock; soltar la copia del cerrojo de arranque.
                gate.close()
                try:
                    os.setsid()
                    with open(os.devnull, 'rb') as null, (run/'worker.log').open('ab') as log:
                        for dest, src in ((0, null), (1, log), (2, log)):
                            os.dup2(src.fileno(), dest)
                    acquire(run, s, read, a.count, period, interval, a.delay_min * 60)
                except BaseException as exc:
                    s.update(state='error', error=str(exc), ended=time.time())
                    traceback.print_exc()
                    save(run/'status.json', s)
                    os._exit(1)
                os._exit(0)
        finally:
            worker.close()
    report(run)


class StopRequested(Exception):
    pass


def acquire(run, s, read, count, period, interval, delay):
    stopping = False
    def stop_signal(*unused):
        nonlocal stopping
        stopping = True
    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, stop_signal)
    stopfile = run/'stop.request'
    check_at = 0.0
    def wait_until(deadline):
        nonlocal check_at
        while True:
            now = time.monotonic()
            if stopping or (now >= check_at and stopfile.exists()):
                raise StopRequested()
            if now >= check_at:
                check_at = now + 0.1
            if now >= deadline:
                return
            time.sleep(min(deadline - now, 0.1))

    header_bytes = (run/'data.csv').stat().st_size
    rows = 0
    first = time.monotonic() + delay
    with (run/'data.csv').open('a') as stream:
        def publish():
            stream.flush()
            s.update(rows=rows, updated=time.time())
            if rows:
                s['estimate'] = header_bytes + round((stream.tell()-header_bytes) * s['target']/rows)
            save(run/'status.json', s)
        try:
            for b in range(1, s['bursts'] + 1):
                planned = first + (b-1)*period
                s.update(state='esperando', burst=b)
                publish()
                wait_until(planned)
                begin = time.monotonic()
                tick = begin
                refresh = begin + 1
                s.update(state='leyendo')
                publish()
                for i in range(1, count+1):
                    wait_until(tick)
                    stamp = time.time_ns()
                    before = time.monotonic_ns()
                    values = read()
                    duration = time.monotonic_ns() - before
                    words = ','.join(f'0x{v:08X}' for v in values)
                    stream.write(f'{b},{i},{stamp},{duration},{words}\n')
                    rows += 1
                    now = time.monotonic()
                    # Si se pierde una ranura no hacer una ráfaga de recuperación.
                    tick += interval
                    if now >= tick:
                        tick = now + interval
                    if now >= refresh or i == count:
                        pace = max(interval, (now-begin)/max(1, i-1))
                        remaining = s['bursts'] - b
                        end = now + (count-i)*pace
                        if remaining:
                            end = max(planned + remaining*period + (count-1)*pace,
                                      end + remaining*(count-1)*pace)
                        s['eta'] = time.time() + max(0, end-now)
                        publish()
                        refresh = now + 1
            s['state'] = 'completa'
        except StopRequested:
            s['state'] = 'detenida'
        finally:
            publish()
        os.fsync(stream.fileno())
    s['ended'] = time.time()
    save(run/'status.json', s)


def control(action):
    if not (RUNS/'latest').exists():
        print('Aún no hay capturas en', RUNS)
        return 0
    run = latest()
    if action == 'stop' and alive(run):
        (run/'stop.request').touch()
        deadline = time.monotonic() + 5
        while alive(run) and time.monotonic() < deadline:
            time.sleep(0.05)
        if alive(run):
            print('Parada solicitada; el lector sigue ocupado.')
            report(run)
            return 1
    s = report(run)
    return int(s['state'] in ('error', 'interrumpida sin cierre'))
