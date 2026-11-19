"""Pruebas por banco UIO y, a petición, por enlace IC."""
import multiprocessing as mp
import os
import re
import resource
import shutil
import subprocess
import time
from pathlib import Path

from registers import devices, reader, user_home

BANK = re.compile(r'tgc_readUplink_regs(?:_(\d+))?')
LINK = re.compile(r'emp_lpgbt_(\d+)')


def bank_test(cfg, mock):
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    with reader(cfg, mock) as read:
        first = read()
        changed = set()
        for _ in range(7):
            time.sleep(0.005)
            changed.update(k for k, a, b in zip(cfg['registers'], first, read()) if a != b)
        print('  ' + ' '.join(f'{k}=0x{v:08X}' for k,v in zip(cfg['registers'],first)), flush=True)
        print('  Cambiaron en 8 lecturas:', ', '.join(sorted(changed)) or 'ninguno', flush=True)


def inspect_bank(cfg, mock):
    print(f"{cfg['device']}  map0 esperado {cfg['expected_base']:#010x}", flush=True)
    # Un SIGBUS en un banco no impide comprobar los demás.
    p = mp.get_context('fork').Process(target=bank_test, args=(cfg, mock))
    p.start()
    p.join(3)
    if p.is_alive():
        p.kill()
        p.join(0.5)
        print('  ERROR: tiempo de lectura agotado', flush=True)
        return False
    if p.exitcode:
        print(f'  ERROR: proceso lector terminó con código {p.exitcode}', flush=True)
    return p.exitcode == 0


def probe(binary, link):
    try:
        proc = subprocess.run([binary, '-a', 'lpgbt-uio://' + link, '-r', '0x1D7', '-t', 'TRC'],
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              text=True, errors='replace', timeout=4)
    except subprocess.TimeoutExpired:
        print(link, 'sin respuesta verificable en 4 s')
        return False
    match = re.search(r'^Read: Register Address: (?:0x)?1d7 Value: (0x[0-9a-f]{2})\s*$',
                      proc.stdout, re.I | re.M)
    # El backend histórico devuelve el byte bajo de la séptima palabra de la FIFO.
    packet = re.search(r'Reply payload:[ \t]*([0-9a-f]+)[ \t]*$', proc.stdout, re.I | re.M)
    payload = packet[1] if packet else ''
    valid = (len(payload) >= 56 and len(payload) % 8 == 0 and match
             and int(payload[48:56], 16) & 0xff == int(match[1], 16))
    if proc.returncode == 0 and valid and not re.search(r'\bERR\]|Exception:', proc.stdout):
        print(f'{link}: la herramienta devolvió {match[1]} para 0x1D7')
        return True
    detail = proc.stdout.strip().splitlines()
    print(f'{link}: sin respuesta verificable (rc={proc.returncode});', detail[-1] if detail else '')
    return False


def run(cfg, args):
    entries = [] if args.mock else devices()
    links = sorted((n for _, n in entries if LINK.fullmatch(n)), key=lambda n:int(n.rsplit('_',1)[1]))
    if args.mock:
        print('SIMULADO')
    else:
        print('Interfaces IC enumeradas:', ', '.join(links) or 'ninguna')
        for p, name in entries:
            if BANK.fullmatch(name) or name == 'cmb_event_regs_0' or name == cfg['device']:
                print(f'  {p.name:<7} {name:<25} {(p/"maps/map0/addr").read_text().strip()}')
    banks = [cfg]
    if args.all and not args.mock:
        if not BANK.fullmatch(cfg['device']):
            raise ValueError('--all requiere un mapa tgc_readUplink_regs')
        for _, name in entries:
            m = BANK.fullmatch(name)
            if m and name != cfg['device']:
                index = int(m[1] or 0)
                if 0 <= index <= 12:
                    banks.append(dict(cfg, device=name, expected_base=0xA00E0000 + 0x10000*index))
    checks = [inspect_bank(bank, args.mock) for bank in banks]
    if args.probe is not None:
        if args.mock:
            raise ValueError('--probe requiere el EMP físico')
        if args.probe == 'all':
            selected = links
        elif args.probe.isdecimal() and f'emp_lpgbt_{int(args.probe)}' in links:
            selected = [f'emp_lpgbt_{int(args.probe)}']
        else:
            raise ValueError(f'Enlace no enumerado: {args.probe}')
        if not selected:
            raise ValueError('Ningún enlace IC enumerado')
        path = cfg.get('lpGbtRegister', '')
        if path.startswith('~/'):
            path = str(user_home()/path[2:])
        binary = path if os.access(path, os.X_OK) and Path(path).is_file() else shutil.which('lpGbtRegister')
        if not binary:
            raise ValueError('Indica la ruta al ejecutable lpGbtRegister en el JSON')
        results = [probe(binary, link) for link in selected]
        # En un barrido son esperables puertos sin FE.
        checks.append(any(results))
    return 0 if all(checks) else 1
