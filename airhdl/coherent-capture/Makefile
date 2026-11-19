# Makefile — emp_acq_capture y test_coherent
# En la placa (o cruzado):  make CXX=aarch64-linux-gnu-g++
CXX      ?= g++
CXXFLAGS ?= -O2 -std=c++17 -Wall -Wextra -pthread

all: emp_acq_capture test_coherent

emp_acq_capture: emp_acq_capture.cpp uplink_capture_regs.cpp uplink_capture_regs.hpp fw_sim.hpp snapshot_checks.hpp
	$(CXX) $(CXXFLAGS) -o $@ emp_acq_capture.cpp uplink_capture_regs.cpp

test_coherent: test_coherent.cpp uplink_capture_regs.cpp uplink_capture_regs.hpp fw_sim.hpp snapshot_checks.hpp
	$(CXX) $(CXXFLAGS) -o $@ test_coherent.cpp uplink_capture_regs.cpp

test: test_coherent emp_acq_capture
	./test_coherent
	./emp_acq_capture --simulate --check --check-seconds 3

clean:
	rm -f emp_acq_capture test_coherent

.PHONY: all test clean
