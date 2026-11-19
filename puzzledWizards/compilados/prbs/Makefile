# Makefile para puzzled/ (ReadPRBS + ejecutable CLI)
# Compila libs (C++/C) y el ejecutable readprbs_cli enlazado contra libReadPRBS.a

# ===================== Config =====================
CXX ?= g++
CC  ?= gcc
AR  ?= ar

OPTFLAGS   ?= -O2
WARNFLAGS  ?= -Wall -Wextra -Wpedantic
PICFLAGS   ?= -fPIC
INC_LOCAL  := -I.

CXXSTD ?= -std=gnu++17
CSTD   ?= -std=gnu11

# Detección/libuio
ifeq ($(USE_PKGCONFIG),1)
  LIBUIO_CFLAGS  := $(shell pkg-config --cflags libuio 2>/dev/null)
  LIBUIO_LDFLAGS := $(shell pkg-config --libs   libuio 2>/dev/null)
endif

ifeq ($(strip $(LIBUIO_CFLAGS)),)
  ifneq ($(strip $(UIO_HEADERS)),)
    LIBUIO_CFLAGS += -I$(UIO_HEADERS)
  endif
endif

ifeq ($(strip $(LIBUIO_LDFLAGS)),)
  ifneq ($(strip $(UIO_LIBDIRS)),)
    LIBUIO_LDFLAGS += -L$(UIO_LIBDIRS)
  endif
  LIBUIO_LDFLAGS += -luio
endif

# Nombres
CPP_SO := libReadPRBS.so
CPP_A  := libReadPRBS.a
C_SO   := libRead_PRBS.so
C_A    := libRead_PRBS.a

CLI_EXE := readprbs_cli
CLI_SRC := readprbs_cli.cpp
CLI_OBJ := $(CLI_SRC:.cpp=.o)

CPP_OBJS := ReadPRBS.o
C_OBJS   := Read_PRBS.o

CXXFLAGS_ALL := $(CXXSTD) $(OPTFLAGS) $(WARNFLAGS) $(PICFLAGS) $(INC_LOCAL) $(LIBUIO_CFLAGS)
CFLAGS_ALL   := $(CSTD)   $(OPTFLAGS) $(WARNFLAGS) $(PICFLAGS) $(INC_LOCAL) $(LIBUIO_CFLAGS)

# ===================== Reglas =====================
.PHONY: all clean info libs cli

all: info libs $(CLI_EXE)

info:
	@echo "== Configuración =="
	@echo "CXX=$(CXX)"
	@echo "CC=$(CC)"
	@echo "AR=$(AR)"
	@echo "LIBUIO_CFLAGS='$(LIBUIO_CFLAGS)'"
	@echo "LIBUIO_LDFLAGS='$(LIBUIO_LDFLAGS)'"
	@echo

# ---------- Libs C++ ----------
ReadPRBS.o: ReadPRBS.cpp ReadPRBS.hpp
	$(CXX) $(CXXFLAGS_ALL) -c $< -o $@

$(CPP_SO): $(CPP_OBJS)
	$(CXX) -shared -o $@ $^ $(LIBUIO_LDFLAGS)

$(CPP_A): $(CPP_OBJS)
	@rm -f $@
	$(AR) rcs $@ $^

# ---------- Libs C ----------
Read_PRBS.o: Read_PRBS.c Read_PRBS.h
	$(CC) $(CFLAGS_ALL) -c $< -o $@

$(C_SO): $(C_OBJS)
	$(CC) -shared -o $@ $^ $(LIBUIO_LDFLAGS)

$(C_A): $(C_OBJS)
	@rm -f $@
	$(AR) rcs $@ $^

libs: $(CPP_SO) $(CPP_A) $(C_SO) $(C_A)

# ---------- Ejecutable CLI ----------
$(CLI_OBJ): $(CLI_SRC) ReadPRBS.hpp
	$(CXX) $(CXXFLAGS_ALL) -c $(CLI_SRC) -o $(CLI_OBJ)

# Enlazamos con la lib estática C++ para evitar depender de rpath/LD_LIBRARY_PATH
$(CLI_EXE): $(CLI_OBJ) $(CPP_A)
	$(CXX) -o $@ $(CLI_OBJ) $(CPP_A) $(LIBUIO_LDFLAGS)

cli: $(CLI_EXE)

# ---------- Limpieza ----------
clean:
	@echo "Limpiando..."
	@rm -f *.o $(CPP_SO) $(CPP_A) $(C_SO) $(C_A) $(CLI_EXE)
