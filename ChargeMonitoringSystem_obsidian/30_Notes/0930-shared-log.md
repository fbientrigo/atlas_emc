It is described how an IRQ related error was found and fixed, there's a description in order:
- the setup
- the software configuration
- process of reproducing
___

## The problem
In the EMP OS system we are using the `LpGbtSw/build/LpGbtRegister/lpGbtRegister` allowing to read different registers. 
The typical working of this program its
```bash
[tgc_cms@trenz-tgc LpGbtSw0.6]$ sudo build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00 
StdOutLog::initialize 2025-09-22 12:21:00.952966 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10 2025-09-22 12:21:01.126733 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_10' 2025-09-22 12:21:01.126986 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049 Read: Register Address: 0 Value: 0x00
```

But the LpGbt refused to give back and IRQ signal or this was missing somehow.

```bash
[tgc_cms@trenz-tgc ~]$ sudo LpGbtSw/build/Demonstrators/LpGbtRegister/lpGbtRegister -a lpgbt-uio://emp_lpgbt_10 -r 0x00
StdOutLog::initialize
2025-09-30 09:54:23.585097 [RegisterClerkFactory.cpp:27, INF] getClerk for lpgbt-uio://emp_lpgbt_10
2025-09-30 09:54:23.761750 [LpGbtUioBackend.cpp:21, INF] Initializing uio device 'emp_lpgbt_10'
2025-09-30 09:54:23.762205 [LpGbtUioBackend.cpp:24, INF] The magic number for this uio device is: 656d7049
terminate called after throwing an instance of 'std::runtime_error'
  what():  LpGbtSw exception: Failed to wait for IRQ for /dev/uio6
[/home/tgc_cms/LpGbtSw/LpGbtUioBackend/LpGbtUioFunctions.cpp:183] in function "void LpGbtUio::waitIntr(uio_info_t*, int)"
Aborted
```

## Setup
There's an EMP board emulator TE0808-04 with a Mezz TE0807-03, on which the OS system its loaded via an SD.
This its connected via SFP connector, using the PINs

B230_RX2_P: F2
B230_TX2_P: F6

this connecting to the emp_lpgbt_10

The LpGbt and PiGbt are feed by their corresponding voltages and its programmed in a locked state, having the `RDY` LED on.

![[LpGbt_rdy_state.png|300]] 
## Software Configuration

When the only two files are uploaded, this being 
- .bin.bin
- .dtbo
