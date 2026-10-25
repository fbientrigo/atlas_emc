#!/usr/bin/env python3
"""Diagnóstico EMP: inventario pasivo y envoltorio condicionado de la CLI existente.

Python >= 3.7, biblioteca estándar, Linux. No implementa acceso MMIO.
Leer 12_SCRIPT_DIAGNOSTICO.md antes de usar capturar.
"""
import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import signal
import stat
import subprocess
import sys
import time

VERSION = "1.0"
FIELDS = ["magic"] + ["data_group_%d" % n for n in range(9)] + ["data_header", "clk_thresh"]
GROUPS = FIELDS[1:10]
LIMIT = 65536
LOCK = Path("/tmp/atlas-tgc-diagnostico.lock")


def stamp():
    return {"utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "monotonic_ns": time.monotonic_ns()}


def read_text(path, limit=LIMIT):
    try:
        with open(str(path), "rb") as f:
            raw = f.read(limit + 1)
        return {"text": raw[:limit].decode("utf-8", "replace"), "truncated": len(raw) > limit}
    except OSError as e:
        return {"error": str(e)}


def link(path):
    try:
        return os.readlink(str(path))
    except OSError as e:
        return "ERROR: " + str(e)


def file_id(path):
    p = Path(path)
    if not p.is_absolute() or not p.is_file() or str(p).startswith(("/dev/", "/proc/", "/sys/")):
        raise ValueError("Se requiere un archivo regular con ruta absoluta: " + str(p))
    h = hashlib.sha256()
    with p.open("rb") as f:
        head = f.read(20)
        h.update(head)
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return {"path": str(p.resolve()), "sha256": h.hexdigest(), "bytes": p.stat().st_size,
            "elf": head[:4] == b"\x7fELF", "header_hex": head.hex()}


def uio_inventory(root=Path("/sys/class/uio")):
    result = []
    for dev in sorted(root.glob("uio[0-9]*")):
        item = {"id": dev.name, "name": read_text(dev / "name"),
                "version": read_text(dev / "version"), "device": link(dev / "device"), "maps": []}
        for m in sorted((dev / "maps").glob("map[0-9]*")):
            item["maps"].append(dict({"id": m.name}, **{k: read_text(m / k) for k in ("addr", "size", "offset", "name")}))
        result.append(item)
    return result


def uio_contract(inventory):
    matches = [d for d in inventory if d["name"].get("text", "").strip() == "tgc_readUplink_regs"]
    if len(matches) != 1:
        raise ValueError("Debe existir exactamente un UIO llamado tgc_readUplink_regs")
    dev = matches[0]
    maps = []
    for m in dev["maps"]:
        maps.append(dict({"id": m["id"]}, **{k: int(m[k]["text"].strip(), 0) for k in ("addr", "size", "offset")}))
    m0 = next((m for m in maps if m["id"] == "map0"), None)
    if not m0 or m0["size"] < 0x30 or m0["offset"] != 0 or m0["addr"] % 4:
        raise ValueError("map0 insuficiente/desalineado o con offset no soportado por este perfil")
    return {"id": dev["id"], "name": "tgc_readUplink_regs", "maps": maps}


def process_snapshot(pid):
    p = Path("/proc") / str(pid)
    return {"pid": pid, "exe": link(p / "exe"),
            **{k: read_text(p / k) for k in ("stat", "status", "wchan", "syscall", "maps")},
            "fds": {f.name: link(f) for f in sorted((p / "fd").glob("*"))}}


def possible_readers():
    """Pistas únicamente: permisos/carreras impiden certificar exclusividad."""
    found, inaccessible = [], 0
    for p in Path("/proc").glob("[0-9]*"):
        if p.name == str(os.getpid()):
            continue
        comm = read_text(p / "comm").get("text", "").strip()
        maps = read_text(p / "maps")
        if "error" in maps:
            inaccessible += 1
        refs = []
        try:
            for fd in (p / "fd").iterdir():
                target = link(fd)
                if re.match(r"/dev/(?:uio\d+|mem)(?:$| )", target):
                    refs.append(target)
        except OSError:
            pass
        mapped = any(re.search(r"/dev/(?:uio\d+|mem)(?:$| )", line)
                     for line in maps.get("text", "").splitlines())
        known = any(s in comm.lower() for s in ("readuplink", "lpgbtregister", "fwmonitor", "devmem", "readuio"))
        if refs or mapped or known:
            found.append({"pid": int(p.name), "comm": comm, "devices": refs, "mapped": mapped})
    return {"candidates": found, "unreadable_maps": inaccessible,
            "limit": "Inspección incompleta y no atómica; no prueba ausencia de otros lectores."}


def inventory(reader=None, pid=None):
    data = {"schema": 1, "script_version": VERSION, **stamp(), "uname": list(os.uname()),
            "python": sys.version, "uio": uio_inventory(), "possible_readers": possible_readers(),
            "files": {s: read_text(s) for s in ("/proc/uptime", "/proc/loadavg", "/proc/meminfo",
                "/proc/sys/kernel/random/boot_id", "/sys/firmware/devicetree/base/model",
                "/sys/firmware/devicetree/base/compatible")},
            "fpga": {}, "overlays": {},
            "environment": {k: os.environ.get(k, "") for k in ("LD_LIBRARY_PATH", "LD_PRELOAD", "LD_AUDIT")}}
    for p in Path("/sys/class/fpga_manager").glob("*"):
        data["fpga"][p.name] = {k: read_text(p / k) for k in ("name", "state", "firmware")}
    for p in Path("/sys/kernel/config/device-tree/overlays").glob("*"):
        data["overlays"][p.name] = {k: read_text(p / k) for k in ("path", "status")}
    if reader:
        data["reader"] = file_id(reader)
    if pid:
        data["process"] = process_snapshot(pid)
    return data


def save_new(path, obj):
    with Path(path).open("x", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write("\n")
        f.flush()
        os.fsync(f.fileno())


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def parse_capture(text):
    values, errors, ignored = {}, [], []
    for line in text.splitlines():
        m = re.fullmatch(r"\s*(magic|data_group_[0-9]+|data_header|clk_thresh):\s*(0x[0-9a-fA-F]{1,8})\s*", line)
        if m:
            name, raw = m.groups()
            if name not in FIELDS or name in values:
                errors.append("Etiqueta desconocida o duplicada: " + name)
            else:
                values[name] = int(raw, 16)
        elif re.match(r"\s*(magic|data_group_|data_header|clk_thresh)", line):
            errors.append("Línea malformada: " + line)
        elif line.strip():
            ignored.append(line)
    missing = [k for k in FIELDS if k not in values]
    return {"values": values, "errors": errors, "missing": missing,
            "ignored": ignored, "complete": not errors and not missing}


def delta(a, b):
    return {k: {"xor": a[k] ^ b[k], "bits": [n for n in range(31, -1, -1) if (a[k] ^ b[k]) & (1 << n)],
                "low_byte_same": (a[k] & 255) == (b[k] & 255)}
            for k in FIELDS if k in a and k in b and a[k] != b[k]}


def validate_plan(plan):
    if plan.get("schema") != 1 or plan.get("type") != "tgc_readuplink_cli_9_groups":
        raise ValueError("Perfil no soportado; no se ejecutarán comandos genéricos")
    validation = plan.get("validation", {})
    for k in ("build_map", "binary_dependencies", "read_semantics", "exclusive_operator", "hardware_authorization"):
        v = validation.get(k, {})
        if v.get("confirmed") is not True or not str(v.get("evidence", "")).strip():
            raise ValueError("Validación pendiente: " + k)
    if not plan.get("libraries"):
        raise ValueError("Faltan hashes de bibliotecas/intérprete; este perfil espera el lector dinámico recuperado")
    for expected in [plan["reader"]] + plan["libraries"]:
        actual = file_id(expected["path"])
        if actual["sha256"] != expected["sha256"] or not actual["elf"]:
            raise ValueError("ELF/hash incompatible: " + expected["path"])
    if not os.access(plan["reader"]["path"], os.X_OK):
        raise ValueError("Lector sin permiso de ejecución")
    if os.environ.get("LD_PRELOAD") or os.environ.get("LD_AUDIT"):
        raise ValueError("LD_PRELOAD/LD_AUDIT activos: no soportados")
    if os.environ.get("LD_LIBRARY_PATH", "") != plan.get("ld_library_path", ""):
        raise ValueError("LD_LIBRARY_PATH distinto del revisado")
    if uio_contract(uio_inventory()) != plan["uio"]:
        raise ValueError("Cambió el contrato sysfs UIO; volver a inventariar")
    candidates = possible_readers()["candidates"]
    if candidates:
        raise ValueError("Hay posibles lectores activos; no se detienen automáticamente: " + json.dumps(candidates))


def acquire_lock():
    fd = os.open(str(LOCK), os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW, 0o600)
    try:
        s = os.fstat(fd)
        if not stat.S_ISREG(s.st_mode) or s.st_uid != os.geteuid():
            raise ValueError("Lock no regular o de otro propietario: " + str(LOCK))
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        prior = os.read(fd, LIMIT).decode("utf-8", "replace")
        if prior.strip():
            raise ValueError("Sesión anterior sin cierre limpio; revisar antes de reintentar: " + prior)
        return fd
    except BaseException:
        os.close(fd)
        raise


def lock_state(fd, value):
    os.lseek(fd, 0, os.SEEK_SET)
    os.ftruncate(fd, 0)
    os.write(fd, value.encode("utf-8"))
    os.fsync(fd)


def run_reader(argv, timeout):
    """Límite de espera del supervisor, NO watchdog del bus. Nunca shell=True."""
    started = stamp()
    p = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, start_new_session=True)
    buffers = {"stdout": bytearray(), "stderr": bytearray()}
    sel = selectors.DefaultSelector()
    for name, pipe in (("stdout", p.stdout), ("stderr", p.stderr)):
        os.set_blocking(pipe.fileno(), False)
        sel.register(pipe, selectors.EVENT_READ, name)
    reason, snapshot = None, None
    deadline = time.monotonic() + timeout
    try:
        while sel.get_map() or p.poll() is None:
            if time.monotonic() >= deadline:
                reason = "timeout"
                break
            for key, _ in sel.select(min(0.05, max(0, deadline - time.monotonic()))):
                chunk = os.read(key.fileobj.fileno(), 8192)
                if not chunk:
                    sel.unregister(key.fileobj)
                    continue
                buf = buffers[key.data]
                room = LIMIT - len(buf)
                buf.extend(chunk[:room])
                if len(chunk) > room:
                    reason = "output_limit"
                    break
            if reason:
                break
    except KeyboardInterrupt:
        reason = "operator_interrupt"
    except BaseException:
        reason = "supervisor_error"
        raise
    finally:
        if reason:
            snapshot = process_snapshot(p.pid)
            for sig in (signal.SIGTERM, signal.SIGKILL):
                try:
                    os.killpg(p.pid, sig)
                except ProcessLookupError:
                    pass
                until = time.monotonic() + 0.25
                while p.poll() is None and time.monotonic() < until:
                    time.sleep(0.01)
        sel.close()
        p.stdout.close()
        p.stderr.close()
    ended = stamp()
    return {"start": started, "end": ended, "duration_s": (ended["monotonic_ns"] - started["monotonic_ns"]) / 1e9,
            "pid": p.pid, "returncode": p.poll(), "stop_reason": reason,
            "alive_after_signals": p.poll() is None, "process_at_failure": snapshot,
            **{name: bytes(buf).decode("utf-8", "replace") for name, buf in buffers.items()}}


def journal(f, kind, **payload):
    f.write(json.dumps({"kind": kind, **stamp(), **payload}, ensure_ascii=False) + "\n")
    f.flush()
    os.fsync(f.fileno())


def capture(args):
    if not args.autorizar_lecturas:
        raise ValueError("capturar requiere --autorizar-lecturas y las validaciones documentadas del plan")
    if args.muestras * (args.intervalo + args.timeout + 0.5) > 86400:
        raise ValueError("La sesión solicitada excede el presupuesto de 24 horas")
    plan = load(args.plan)
    validate_plan(plan)
    out = Path(args.salida)
    out.mkdir(mode=0o700, parents=False, exist_ok=False)
    lockfd = acquire_lock()
    blocked = True
    try:
        lock_state(lockfd, json.dumps({"supervisor": os.getpid(), "session": str(out.resolve()), **stamp()}))
        save_new(out / "plan.json", plan)
        save_new(out / "inventario_inicio.json", inventory(plan["reader"]["path"]))
        previous, repeated = None, 0
        with (out / "muestras.jsonl").open("x", encoding="utf-8") as f:
            journal(f, "session_start", phase=args.fase, script=file_id(str(Path(__file__).resolve())),
                    count=args.muestras, interval=args.intervalo, timeout=args.timeout)
            for i in range(args.muestras):
                validate_plan(plan)
                # Se persiste ANTES del lanzamiento por si también deja de responder Linux.
                journal(f, "attempt", index=i, command=[plan["reader"]["path"]])
                result = run_reader([plan["reader"]["path"]], args.timeout)
                for stream, suffix in (("stdout", "out"), ("stderr", "err")):
                    with (out / ("muestra_%05d.%s" % (i, suffix))).open("x", encoding="utf-8") as raw:
                        raw.write(result[stream])
                        raw.flush()
                        os.fsync(raw.fileno())
                parsed = parse_capture(result["stdout"])
                ok = result["returncode"] == 0 and not result["stop_reason"] and parsed["complete"] and not result["stderr"].strip()
                changes = delta(previous, parsed["values"]) if ok and previous else None
                if ok:
                    repeated = repeated + 1 if previous and all(previous[k] == parsed["values"][k] for k in GROUPS) else 0
                    previous = parsed["values"]
                journal(f, "sample", index=i, phase=args.fase, result=result, parsed=parsed,
                        usable=ok, changes=changes, repeated_payload_transitions=repeated)
                print("Muestra %d: %s; %.3f s; repeticiones payload=%d" %
                      (i, "completa" if ok else "DETENCIÓN", result["duration_s"], repeated), flush=True)
                if not ok:
                    journal(f, "session_stop", reason="error_or_incomplete", index=i)
                    save_new(out / "inventario_fallo.json", inventory(pid=result["pid"]))
                    return 2
                if changes and any(k in changes for k in ("magic", "clk_thresh")):
                    journal(f, "session_stop", reason="identity_or_configuration_changed", index=i)
                    return 2
                if args.detener_iguales and repeated >= args.detener_iguales:
                    journal(f, "session_stop", reason="repetition_threshold_not_proof_of_freeze", index=i)
                    blocked = False
                    return 0
                if i + 1 < args.muestras:
                    time.sleep(args.intervalo)
            journal(f, "session_stop", reason="count_completed")
            blocked = False
            return 0
    except KeyboardInterrupt:
        print("Interrumpido: se conserva el bloqueo preventivo y la evidencia.", file=sys.stderr)
        return 130
    finally:
        if not blocked:
            lock_state(lockfd, "")
        os.close(lockfd)


def make_report(folder):
    rows, warnings = [], []
    with (folder / "muestras.jsonl").open(encoding="utf-8") as f:
        for n, line in enumerate(f, 1):
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                warnings.append("Línea %d incompleta/corrupta; no se interpreta como muestra." % n)
    samples = [r for r in rows if r.get("kind") == "sample"]
    attempts = [r for r in rows if r.get("kind") == "attempt"]
    complete = [r for r in samples if r.get("usable")]
    high_only = sum(1 for r in complete for k, v in (r.get("changes") or {}).items()
                    if k in GROUPS and v["low_byte_same"])
    changed = sum(1 for r in complete if any(k in GROUPS for k in (r.get("changes") or {})))
    lines = ["# Informe de diagnóstico EMP", "", "Sesión: `" + str(folder.resolve()) + "`", "",
             "- Intentos registrados: %d; resultados: %d; completos sin stderr: %d." % (len(attempts), len(samples), len(complete)),
             "- Transiciones con cambios en algún grupo: %d." % changed,
             "- Cambios de grupo invisibles al observar solo el byte bajo: %d." % high_only,
             "- Máximo de transiciones consecutivas con payload idéntico: %d." % max([r.get("repeated_payload_transitions", 0) for r in complete] or [0]),
             "", "## Secuencia", "", "| Índice | Fase | UTC inicio | Duración s | Retorno | Estado |", "|---|---|---|---|---|---|"]
    for r in samples:
        x = r["result"]
        phase = str(r.get("phase", "")).replace("|", "/").replace("\n", " ")
        lines.append("| %s | %s | %s | %.6f | %s | %s |" % (r["index"], phase, x["start"]["utc"], x["duration_s"], x["returncode"], x["stop_reason"] or ("completa" if r["usable"] else "salida no utilizable")))
    events = folder / "eventos.jsonl"
    if events.exists():
        lines += ["", "## Anotaciones del operador (declaraciones, no mediciones)", "", "```jsonl", events.read_text(encoding="utf-8").replace("```", "'''"), "```"]
    if len(attempts) != len(samples):
        warnings.append("Hay un intento sin resultado: supervisor/proceso/sistema pudo interrumpirse; no localizar automáticamente en AXI.")
    if not any(r.get("kind") == "session_stop" for r in rows):
        warnings.append("No hay cierre registrado: sesión todavía activa o interrumpida; revisar el lock y los procesos.")
    lines += ["", "## Interpretación y límites", "",
              "Valores idénticos no prueban falta de muestras nuevas. Valores distintos no prueban origen FE ni coherencia entre grupos.",
              "Un timeout delimita la espera del supervisor, no demuestra un bloqueo AXI ni garantiza cancelar el acceso.",
              "Cada muestra relanza la CLI y vuelve a mapear UIO. Esto puede ocultar un defecto exclusivo de un proceso persistente.",
              "Revisar stdout/stderr, XOR por registro y las condiciones de cada intento en muestras.jsonl."]
    lines += ["", *["ADVERTENCIA: " + w for w in warnings], ""]
    return "\n".join(lines)


def bounded_number(low, high, integer=False):
    def convert(raw):
        value = int(raw) if integer else float(raw)
        if not low <= value <= high:
            raise argparse.ArgumentTypeError("Debe estar entre %s y %s" % (low, high))
        return value
    return convert


def main():
    os.umask(0o077)
    def interrupted(signum, frame):
        raise KeyboardInterrupt
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGHUP, interrupted)
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="action", required=True)
    inv = sub.add_parser("inventario", help="Solo archivos proc/sysfs y hash opcional; no ejecuta tooling hardware")
    inv.add_argument("--salida", required=True)
    inv.add_argument("--lector")
    inv.add_argument("--pid", type=bounded_number(1, 2**31 - 1, True))
    identity = sub.add_parser("identidad", help="Hash y cabecera ELF de archivo regular; no lo ejecuta")
    identity.add_argument("archivo")
    plan = sub.add_parser("preparar", help="Plantilla BLOQUEADA: completar evidencia antes de capturar")
    plan.add_argument("--inventario", required=True)
    plan.add_argument("--salida", required=True)
    cap = sub.add_parser("capturar", help="MMIO CONDICIONADO: ejecuta solo la CLI validada, sin argumentos")
    cap.add_argument("--plan", required=True)
    cap.add_argument("--salida", required=True)
    cap.add_argument("--autorizar-lecturas", action="store_true")
    cap.add_argument("--fase", required=True, help="Etiqueta manual: A, B, A2, fallo, post-reset…")
    cap.add_argument("--muestras", type=bounded_number(1, 3600, True), default=12)
    cap.add_argument("--intervalo", type=bounded_number(1, 3600), default=5)
    cap.add_argument("--timeout", type=bounded_number(0.1, 30), default=3)
    cap.add_argument("--detener-iguales", type=bounded_number(0, 3600, True), default=0,
                     help="Transiciones iguales para parar; 0 desactiva. No declara congelamiento.")
    note = sub.add_parser("anotar", help="Registra una observación manual sin operar hardware")
    note.add_argument("--sesion", required=True)
    note.add_argument("--texto", required=True)
    rep = sub.add_parser("informe", help="Análisis offline; no abre dispositivos")
    rep.add_argument("--sesion", required=True)
    rep.add_argument("--salida", required=True)
    args = p.parse_args()
    try:
        if args.action == "inventario":
            save_new(args.salida, inventory(args.lector, args.pid))
        elif args.action == "identidad":
            print(json.dumps(file_id(args.archivo), ensure_ascii=False, indent=2))
        elif args.action == "preparar":
            inv_data = load(args.inventario)
            data = {"schema": 1, "type": "tgc_readuplink_cli_9_groups", "reader": inv_data["reader"],
                    "uio": uio_contract(inv_data["uio"]), "libraries": [],
                    "ld_library_path": inv_data["environment"]["LD_LIBRARY_PATH"],
                    "validation": {k: {"confirmed": False, "evidence": ""} for k in
                        ("build_map", "binary_dependencies", "read_semantics", "exclusive_operator", "hardware_authorization")}}
            save_new(args.salida, data)
        elif args.action == "capturar":
            return capture(args)
        elif args.action == "anotar":
            folder = Path(args.sesion)
            if not (folder / "plan.json").is_file():
                raise ValueError("No es una sesión de captura")
            if len(args.texto) > 4000:
                raise ValueError("Anotación demasiado larga")
            with (folder / "eventos.jsonl").open("a", encoding="utf-8") as f:
                fcntl.flock(f, fcntl.LOCK_EX)
                journal(f, "operator_note", text=args.texto)
        elif args.action == "informe":
            with Path(args.salida).open("x", encoding="utf-8") as f:
                f.write(make_report(Path(args.sesion)))
        return 0
    except (OSError, ValueError, KeyError, TypeError) as e:
        print("DETENIDO: " + str(e), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
