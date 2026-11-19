"""Mapa editable y acceso a map0 con la API libuio instalada en el EMP."""
import ctypes as C
import json
import os
import pwd
import re
from contextlib import contextmanager
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SYS = Path('/sys/class/uio')


def user_home():
    return Path(pwd.getpwuid(int(os.environ.get('SUDO_UID', os.getuid()))).pw_dir)


def drop_sudo():
    if os.geteuid() == 0 and 'SUDO_UID' in os.environ:
        uid = int(os.environ['SUDO_UID'])
        gid = int(os.environ['SUDO_GID'])
        os.initgroups(pwd.getpwuid(uid).pw_name, gid)
        os.setgid(gid)
        os.setuid(uid)


def number(value):
    if type(value) is int:
        return value
    if isinstance(value, str):
        return int(value, 0)
    raise ValueError('Se esperaba un entero o una cadena 0x…')


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'Clave repetida: {key}')
        result[key] = value
    return result


def config(path):
    obj = json.loads(Path(path).read_text(), object_pairs_hook=unique_pairs)
    regs = obj['registers']
    if not isinstance(regs, dict) or not regs:
        raise ValueError('registers debe ser un objeto con al menos una palabra')
    for key, value in regs.items():
        if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', key) or key in ('burst','sample','unix_ns','read_ns'):
            raise ValueError(f'Nombre de registro inválido: {key}')
        offset = number(value)
        if offset < 0 or offset % 4:
            raise ValueError(f'Offset inválido para {key}: {value}')
        regs[key] = offset
    keys = obj['compare']
    if not isinstance(keys, list) or not keys or not set(keys) <= regs.keys() or len(keys) != len(set(keys)):
        raise ValueError('compare debe enumerar registros existentes sin repetir')
    if not isinstance(obj['device'], str) or not obj['device']:
        raise ValueError('Falta el nombre UIO')
    obj['expected_base'] = number(obj['expected_base'])
    return obj


def devices():
    return [(p, (p/'name').read_text().strip()) for p in sorted(SYS.glob('uio[0-9]*'))]


def libuio():
    lib = C.CDLL('libuio.so', use_errno=True)
    ptr, integer, size, ulong = C.c_void_p, C.c_int, C.c_size_t, C.c_ulong
    for name, result, args in [
        ('uio_find_by_uio_name', ptr, [C.c_char_p]),
        ('uio_open', integer, [ptr]), ('uio_close', integer, [ptr]),
        ('uio_free_info', None, [ptr]),
        ('uio_get_mem_addr', ulong, [ptr, integer]),
        ('uio_get_mem_size', size, [ptr, integer]),
        ('uio_get_offset', size, [ptr, integer]),
        ('uio_read32', integer, [ptr, integer, ulong, C.POINTER(C.c_uint32)])
    ]:
        fn = getattr(lib, name)
        fn.restype, fn.argtypes = result, args
    return lib


@contextmanager
def reader(cfg, mock=False):
    offsets = list(cfg['registers'].values())
    if mock:
        seq = 0
        def simulated():
            nonlocal seq
            # Tripletas idénticas; retorno a cero incluido.
            base = (seq // 3) % 2
            seq += 1
            return tuple(base * (1 + off) for off in offsets)
        yield simulated
        return
    matches = [p for p, name in devices() if name == cfg['device']]
    if len(matches) != 1:
        raise ValueError(f"{cfg['device']}: {len(matches)} coincidencias en {SYS}")
    node, = matches
    map0 = node / 'maps/map0'
    layout = tuple(number((map0/k).read_text().strip()) for k in ('addr','size','offset'))
    base, size, offset = layout
    if base != cfg['expected_base'] or offset % 4 or max(offsets) + offset + 4 > size:
        raise ValueError(f'{node.name}: mapa incompatible base={base:#x} tamaño={size:#x} offset={offset:#x}')
    lib = libuio()
    info = lib.uio_find_by_uio_name(cfg['device'].encode())
    if not info:
        raise OSError(f'libuio no encontró {node.name}')
    try:
        reported = (lib.uio_get_mem_addr(info, 0), lib.uio_get_mem_size(info, 0), lib.uio_get_offset(info, 0))
        if reported != layout:
            raise ValueError('libuio y sysfs difieren en map0')
        if lib.uio_open(info):
            raise OSError(f'No se pudo abrir /dev/{node.name}; revisar permisos y libuio')
        try:
            buf = C.c_uint32()
            ref = C.byref(buf)
            read32 = lib.uio_read32
            def snapshot():
                words = []
                for off in offsets:
                    if read32(info, 0, off, ref):
                        raise OSError(f'Error de lectura en +{off:#x}')
                    words.append(buf.value)
                return tuple(words)
            yield snapshot
        finally:
            lib.uio_close(info)
    finally:
        lib.uio_free_info(info)
