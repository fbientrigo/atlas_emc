CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -std=c11
PYTHON ?= python3
LIBUIO_INCLUDE ?= /home/tgc_cms/libuio

uio-read32: uio_read32.c
	$(CC) $(CPPFLAGS) -I$(LIBUIO_INCLUDE) $(CFLAGS) $< $(LDFLAGS) -luio -o $@

.PHONY: test
test:
	$(PYTHON) -m unittest -v
