/* Internal helper: libuio performs volatile 32-bit reads; Python owns the allowlist. */
#include <libuio.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int number(const char *text, unsigned long *value)
{
    char *end;
    errno = 0;
    *value = strtoul(text, &end, 0);
    return !*text || *text == '-' || *end || errno;
}

int main(int argc, char **argv)
{
    unsigned long dev, base, size, off;
    struct uio_info_t *info;
    int result = 0;
    if (argc < 6) return 2;
    if (number(argv[1], &dev) || dev > INT_MAX || number(argv[3], &base)
        || number(argv[4], &size) || size < 4) return 2;
    /* Check every offset before opening any UIO device. */
    for (int i = 5; i < argc; ++i)
        if (number(argv[i], &off) || off % 4 || off > size - 4) {
            fprintf(stderr, "offset outside map\n"); return 2;
        }
    info = uio_find_by_uio_num((int)dev);
    if (!info || uio_get_maxmap(info) != 1 || !uio_get_name(info)
        || strcmp(uio_get_name(info), argv[2]) || uio_get_mem_addr(info, 0) != base
        || uio_get_mem_size(info, 0) != size || uio_get_offset(info, 0) != 0) {
        fprintf(stderr, "UIO identity or range changed; refusing read\n"); return 1;
    }
    if (uio_open(info)) return 1;
    for (int i = 5; i < argc; ++i) {
        uint32_t value;
        if (number(argv[i], &off) || uio_read32(info, 0, off, &value)) {
            result = 1; break;
        }
        printf("%08x\n", value);
    }
    uio_close(info);
    return result;
}
