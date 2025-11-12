# Define asynchronous clock groups

# Group 1: PL Clock and MGT Reference Clocks
set_clock_groups -group [get_clocks -include_generated_clocks clk_pl_0] \
                 -group [get_clocks -include_generated_clocks MGT_REFCLK_P] \
                 -asynchronous

# Group 2: Network and RX Clocks
set_clock_groups -group [get_clocks -regexp {rxoutclk_out\[0\]_([0-9]|1[01])$}] \
                 -group [get_clocks rxoutclk_out[0]] \
                 -asynchronous

# Group 3: TX and RX Clocks
set_clock_groups -group [get_clocks -regexp {txoutclk_out\[0\]_([0-9]|1[01])$}] \
                 -group [get_clocks -regexp {rxoutclk_out\[0\]_([0-9]|1[01])$}] \
                 -asynchronous

# Group 4: Individual TX and RX Clocks
set_clock_groups -group [get_clocks txoutclk_out[0]] \
                 -group [get_clocks rxoutclk_out[0]] \
                 -asynchronous

# Group 7: MGT_REFCLK_P and TX Clocks
set_clock_groups -group [get_clocks MGT_REFCLK_P] \
                 -group [get_clocks -regexp {txoutclk_out\[0\]_([0-9]|1[01])$}] \
                 -group [get_clocks txoutclk_out[0]] \
                 -asynchronous
