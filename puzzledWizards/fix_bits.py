import re
import sys

def patch_file(path):
    with open(path, "r", encoding="utf-8") as f:
        code = f.read()

    # Patrón para _isolateBitsForRead
    pattern_read = re.compile(
        r"(uint32_t\s+(\w+)::_isolateBitsForRead\s*\([^)]*\)\s*\{)([^}]*)\}",
        re.DOTALL
    )
    replacement_read = r"""\1
    // Patched: safe mask generation
    uint64_t bitMask = ((1ULL << bitWidth) - 1ULL);
    if (bitWidth >= 32) bitMask = 0xFFFFFFFFULL;
    bitMask <<= bitOffset;
    return static_cast<uint32_t>((value & bitMask) >> bitOffset);
}"""

    # Patrón para _isolateBitsForWrite
    pattern_write = re.compile(
        r"(uint32_t\s+(\w+)::_isolateBitsForWrite\s*\([^)]*\)\s*\{)([^}]*)\}",
        re.DOTALL
    )
    replacement_write = r"""\1
    // Patched: safe mask generation
    uint64_t bitMask = ((1ULL << bitWidth) - 1ULL);
    if (bitWidth >= 32) bitMask = 0xFFFFFFFFULL;
    bitMask <<= bitOffset;
    return static_cast<uint32_t>((oldValue & ~bitMask) | ((static_cast<uint64_t>(value) << bitOffset) & bitMask));
}"""

    code, n1 = pattern_read.subn(replacement_read, code)
    code, n2 = pattern_write.subn(replacement_write, code)

    if n1 or n2:
        with open(path, "w", encoding="utf-8") as f:
            f.write(code)
        print(f"Patched {path}: {n1} Read, {n2} Write")
    else:
        print(f"No matches found in {path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python patch_isolate.py <archivo.cpp>")
        sys.exit(1)
    patch_file(sys.argv[1])
