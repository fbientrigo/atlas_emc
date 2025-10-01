▒Zynq MP First Stage Boot Loader
Release 2023.2   Oct 12 2023  -  15:51:06
NOTICE:  BL31: Non secure code at 0x8000000
NOTICE:  BL31: v2.8(release):xlnx_rebase_v2.8_2023.2_ksb_sep
NOTICE:  BL31: Built : 12:21:43, Aug 31 2023


U-Boot 2023.01 (Sep 21 2023 - 11:02:37 +0000)

CPU:   ZynqMP
Silicon: v3
Chip:  zu4e
Board: Xilinx ZynqMP
DRAM:  2 GiB (effective 4 GiB)
PMUFW:  v1.1
PMUFW:  No permission to change config object
EL Level:       EL2
Secure Boot:    not authenticated, not encrypted
Core:  67 devices, 28 uclasses, devicetree: board
NAND:  0 MiB
MMC:   mmc@ff160000: 0, mmc@ff170000: 1
Loading Environment from FAT... *** Error - No Valid Environment Area found
*** Warning - bad env area, using default environment

In:    serial
Out:   serial
Err:   serial
Bootmode: SD_MODE1
Reset reason:   EXTERNAL
Net:
ZYNQ GEM: ff0e0000, mdio bus ff0e0000, phyaddr 1, interface rgmii-id
eth0: ethernet@ff0e0000
scanning bus for devices...
SATA link 0 timeout.
SATA link 1 timeout.
AHCI 0001.0301 32 slots 2 ports 6 Gbps 0x3 impl SATA mode
flags: 64bit ncq pm clo only pmp fbss pio slum part ccc apst
starting USB...
Bus usb@fe200000: Register 2000440 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus usb@fe200000 for devices... cannot reset port 1!?
1 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found
Hit any key to stop autoboot:  0
switch to partitions #0, OK
mmc1 is current device
Scanning mmc 1:1...
Found U-Boot script /boot.scr
3474 bytes read in 14 ms (242.2 KiB/s)
## Executing script at 20000000
Trying to load boot images from mmc1
9679856 bytes read in 630 ms (14.7 MiB/s)
## Loading kernel from FIT Image at 10000000 ...
   Using 'conf-system-top.dtb' configuration
   Trying 'kernel-1' kernel subimage
     Description:  Linux kernel
     Created:      2023-09-22  10:41:01 UTC
     Type:         Kernel Image
     Compression:  gzip compressed
     Data Start:   0x10000114
     Data Size:    9630563 Bytes = 9.2 MiB
     Architecture: AArch64
     OS:           Linux
     Load Address: 0x00200000
     Entry Point:  0x00200000
     Hash algo:    sha256
     Hash value:   a17de102eaa17d2a86e10cbdb6c26e4b473007337460befc0553b8cbff5b6                                                                             be5
   Verifying Hash Integrity ... sha256+ OK
## Loading fdt from FIT Image at 10000000 ...
   Using 'conf-system-top.dtb' configuration
   Trying 'fdt-system-top.dtb' fdt subimage
     Description:  Flattened Device Tree blob
     Created:      2023-09-22  10:41:01 UTC
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x1092f588
     Data Size:    39872 Bytes = 38.9 KiB
     Architecture: AArch64
     Hash algo:    sha256
     Hash value:   05526ce47fc088c824bacaea3081ba0e97d8a24fe9c3f203703c7b7a6574b                                                                             507
   Verifying Hash Integrity ... sha256+ OK
   Booting using the fdt blob at 0x1092f588
Working FDT set to 1092f588
Host not halted after 16000 microseconds.
   Uncompressing Kernel Image
   Loading Device Tree to 000000007bbe8000, end 000000007bbf4bbf ... OK
Working FDT set to 7bbe8000

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 6.1.30-xilinx-v2023.2 (oe-user@oe-host) (aarch64-xilinx-linux-gcc (GCC) 12.2.0, GNU ld (GNU Binutils) 2.39.0.20220819) #1 SMP Fri Sep 22 10:41:01 UTC 2023
[    0.000000] Machine model: xlnx,zynqmp
[    0.000000] earlycon: cdns0 at MMIO 0x00000000ff000000 (options '115200n8')
[    0.000000] printk: bootconsole [cdns0] enabled
[    0.000000] efi: UEFI not found.
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000087fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x000000007fefffff]
[    0.000000]   node   0: [mem 0x0000000800000000-0x000000087fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x000000087fffffff]
[    0.000000] On node 0, zone Normal: 256 pages in unavailable ranges
[    0.000000] cma: Reserved 256 MiB at 0x000000006ba00000
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv1.1 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: MIGRATE_INFO_TYPE not supported.
[    0.000000] psci: SMC Calling Convention v1.2
[    0.000000] percpu: Embedded 18 pages/cpu s35816 r8192 d29720 u73728
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: detected: ARM erratum 845719
[    0.000000] alternatives: applying boot alternatives
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 1031940
[    0.000000] Kernel command line: setenv bootargs earlycon console=ttyPS0,115200 clk_ignore_unused root=/dev/mmcblk1p2 ip=dhcp rw uio_pdrv_genirq.of_id=generic-uio
[    0.000000] Unknown kernel command line parameters "setenv bootargs", will be passed to user space.
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes, linear)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] mem auto-init: stack:all(zero), heap alloc:off, heap free:off
[    0.000000] software IO TLB: area num 4.
[    0.000000] software IO TLB: mapped [mem 0x000000007bf00000-0x000000007ff00000] (64MB)
[    0.000000] Memory: 3762212K/4193280K available (14336K kernel code, 1014K rwdata, 4128K rodata, 2240K init, 372K bss, 168924K reserved, 262144K cma-reserved)
[    0.000000] rcu: Hierarchical RCU implementation.
[    0.000000] rcu:     RCU event tracing is enabled.
[    0.000000] rcu:     RCU restricting CPUs from NR_CPUS=16 to nr_cpu_ids=4.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] GIC: Adjusting CPU interface base to 0x00000000f902f000
[    0.000000] Root IRQ handler: gic_handle_irq
[    0.000000] GIC: Using split EOI/Deactivate mode
[    0.000000] rcu: srcu_init: Setting srcu_struct sizes based on contention.
[    0.000000] arch_timer: cp15 timer(s) running at 33.33MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x7b0074340, max_idle_ns: 440795202884 ns
[    0.000001] sched_clock: 56 bits at 33MHz, resolution 30ns, wraps every 2199023255543ns
[    0.008324] Console: colour dummy device 80x25
[    0.012471] Calibrating delay loop (skipped), value calculated using timer frequency.. 66.66 BogoMIPS (lpj=133332)
[    0.022798] pid_max: default: 32768 minimum: 301
[    0.027605] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.034815] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.043767] rcu: Hierarchical SRCU implementation.
[    0.047422] rcu:     Max phase no-delay instances is 1000.
[    0.052898] EFI services will not be available.
[    0.057337] smp: Bringing up secondary CPUs ...
[    0.062108] Detected VIPT I-cache on CPU1
[    0.062178] CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
[    0.062619] Detected VIPT I-cache on CPU2
[    0.062678] CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
[    0.063094] Detected VIPT I-cache on CPU3
[    0.063152] CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
[    0.063199] smp: Brought up 1 node, 4 CPUs
[    0.097356] SMP: Total of 4 processors activated.
[    0.102055] CPU features: detected: 32-bit EL0 Support
[    0.107188] CPU features: detected: CRC32 instructions
[    0.112372] CPU: All CPU(s) started at EL2
[    0.116412] alternatives: applying system-wide alternatives
[    0.123060] devtmpfs: initialized
[    0.130357] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.135039] futex hash table entries: 1024 (order: 4, 65536 bytes, linear)
[    0.147813] pinctrl core: initialized pinctrl subsystem
[    0.148303] DMI not present or invalid.
[    0.151645] NET: Registered PF_NETLINK/PF_ROUTE protocol family
[    0.157922] DMA: preallocated 512 KiB GFP_KERNEL pool for atomic allocations
[    0.164285] DMA: preallocated 512 KiB GFP_KERNEL|GFP_DMA32 pool for atomic allocations
[    0.172141] audit: initializing netlink subsys (disabled)
[    0.177591] audit: type=2000 audit(0.116:1): state=initialized audit_enabled=0 res=1
[    0.177992] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.192086] ASID allocator initialised with 65536 entries
[    0.197542] Serial: AMBA PL011 UART driver
[    0.217672] HugeTLB: registered 1.00 GiB page size, pre-allocated 0 pages
[    0.218823] HugeTLB: 0 KiB vmemmap can be freed for a 1.00 GiB page
[    0.225099] HugeTLB: registered 32.0 MiB page size, pre-allocated 0 pages
[    0.231901] HugeTLB: 0 KiB vmemmap can be freed for a 32.0 MiB page
[    0.238143] HugeTLB: registered 2.00 MiB page size, pre-allocated 0 pages
[    0.244927] HugeTLB: 0 KiB vmemmap can be freed for a 2.00 MiB page
[    0.251192] HugeTLB: registered 64.0 KiB page size, pre-allocated 0 pages
[    0.257977] HugeTLB: 0 KiB vmemmap can be freed for a 64.0 KiB page
[    0.332307] raid6: neonx8   gen()  2259 MB/s
[    0.400368] raid6: neonx4   gen()  2218 MB/s
[    0.468429] raid6: neonx2   gen()  2121 MB/s
[    0.536489] raid6: neonx1   gen()  1810 MB/s
[    0.604555] raid6: int64x8  gen()  1415 MB/s
[    0.672621] raid6: int64x4  gen()  1568 MB/s
[    0.740676] raid6: int64x2  gen()  1395 MB/s
[    0.808753] raid6: int64x1  gen()  1034 MB/s
[    0.808792] raid6: using algorithm neonx8 gen() 2259 MB/s
[    0.880826] raid6: .... xor() 1651 MB/s, rmw enabled
[    0.880870] raid6: using neon recovery algorithm
[    0.885223] iommu: Default domain type: Translated
[    0.889633] iommu: DMA domain TLB invalidation policy: strict mode
[    0.896104] SCSI subsystem initialized
[    0.899779] usbcore: registered new interface driver usbfs
[    0.905145] usbcore: registered new interface driver hub
[    0.910442] usbcore: registered new device driver usb
[    0.915538] mc: Linux media interface: v0.10
[    0.919757] videodev: Linux video capture interface: v2.00
[    0.925237] pps_core: LinuxPPS API ver. 1 registered
[    0.930173] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.939321] PTP clock support registered
[    0.943245] EDAC MC: Ver: 3.0.0
[    0.946685] zynqmp-ipi-mbox mailbox@ff9905c0: Registered ZynqMP IPI mbox with TX/RX channels.
[    0.955095] FPGA manager framework
[    0.958392] Advanced Linux Sound Architecture Driver Initialized.
[    0.964693] Bluetooth: Core ver 2.22
[    0.967941] NET: Registered PF_BLUETOOTH protocol family
[    0.973239] Bluetooth: HCI device and connection manager initialized
[    0.979592] Bluetooth: HCI socket layer initialized
[    0.984463] Bluetooth: L2CAP socket layer initialized
[    0.989514] Bluetooth: SCO socket layer initialized
[    0.994743] clocksource: Switched to clocksource arch_sys_counter
[    1.000642] VFS: Disk quotas dquot_6.6.0
[    1.004418] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.016231] NET: Registered PF_INET protocol family
[    1.016416] IP idents hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    1.026272] tcp_listen_portaddr_hash hash table entries: 2048 (order: 3, 32768 bytes, linear)
[    1.032081] Table-perturb hash table entries: 65536 (order: 6, 262144 bytes, linear)
[    1.039802] TCP established hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    1.047917] TCP bind hash table entries: 32768 (order: 8, 1048576 bytes, linear)
[    1.055878] TCP: Hash tables configured (established 32768 bind 32768)
[    1.061704] UDP hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    1.068403] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    1.075618] NET: Registered PF_UNIX/PF_LOCAL protocol family
[    1.081418] RPC: Registered named UNIX socket transport module.
[    1.087042] RPC: Registered udp transport module.
[    1.091738] RPC: Registered tcp transport module.
[    1.096433] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.102875] PCI: CLS 0 bytes, default 64
[    1.107481] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    1.115632] Initialise system trusted keyrings
[    1.119066] workingset: timestamp_bits=46 max_order=20 bucket_order=0
[    1.126070] NFS: Registering the id_resolver key type
[    1.130469] Key type id_resolver registered
[    1.134632] Key type id_legacy registered
[    1.138647] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    1.145329] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
[    1.152981] jffs2: version 2.2. (NAND) (SUMMARY)  © 2001-2006 Red Hat, Inc.
[    1.195374] NET: Registered PF_ALG protocol family
[    1.195428] xor: measuring software checksum speed
[    1.203220]    8regs           :  2521 MB/sec
[    1.207559]    32regs          :  2522 MB/sec
[    1.212194]    arm64_neon      :  2351 MB/sec
[    1.212355] xor: using function: 32regs (2522 MB/sec)
[    1.217411] Key type asymmetric registered
[    1.221498] Asymmetric key parser 'x509' registered
[    1.226398] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
[    1.233770] io scheduler mq-deadline registered
[    1.238294] io scheduler kyber registered
[    1.276007] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.277804] Serial: AMBA driver
[    1.285392] brd: module loaded
[    1.288749] loop: module loaded
[    1.289429] mtdoops: mtd device (mtddev=name/number) must be supplied
[    1.295773] tun: Universal TUN/TAP device driver, 1.6
[    1.297811] CAN device driver interface
[    1.302174] usbcore: registered new interface driver asix
[    1.306995] usbcore: registered new interface driver ax88179_178a
[    1.313062] usbcore: registered new interface driver cdc_ether
[    1.318888] usbcore: registered new interface driver net1080
[    1.324542] usbcore: registered new interface driver cdc_subset
[    1.330459] usbcore: registered new interface driver zaurus
[    1.336040] usbcore: registered new interface driver cdc_ncm
[    1.341685] usbcore: registered new interface driver r8153_ecm
[    1.347673] VFIO - User Level meta-driver version: 0.3
[    1.353224] usbcore: registered new interface driver uas
[    1.357968] usbcore: registered new interface driver usb-storage
[    1.364674] rtc_zynqmp ffa60000.rtc: registered as rtc0
[    1.369171] rtc_zynqmp ffa60000.rtc: setting system clock to 1970-01-01T00:00:04 UTC (4)
[    1.377295] i2c_dev: i2c /dev entries driver
[    1.383051] usbcore: registered new interface driver uvcvideo
[    1.387631] Bluetooth: HCI UART driver ver 2.3
[    1.391689] Bluetooth: HCI UART protocol H4 registered
[    1.396820] Bluetooth: HCI UART protocol BCSP registered
[    1.402140] Bluetooth: HCI UART protocol LL registered
[    1.407260] Bluetooth: HCI UART protocol ATH3K registered
[    1.412665] Bluetooth: HCI UART protocol Three-wire (H5) registered
[    1.418950] Bluetooth: HCI UART protocol Intel registered
[    1.424327] Bluetooth: HCI UART protocol QCA registered
[    1.429556] usbcore: registered new interface driver bcm203x
[    1.435215] usbcore: registered new interface driver bpa10x
[    1.440779] usbcore: registered new interface driver bfusb
[    1.446264] usbcore: registered new interface driver btusb
[    1.451753] usbcore: registered new interface driver ath3k
[    1.457287] EDAC MC: ECC not enabled
[    1.460894] EDAC DEVICE0: Giving out device to module edac controller cache_err: DEV edac (POLLED)
[    1.469730] cortex_edac edac: cortex l1/l2 driver is deprecated
[    1.475802] EDAC DEVICE1: Giving out device to module zynqmp-ocm-edac controller zynqmp_ocm: DEV ff960000.memory-controller (INTERRUPT)
[    1.488156] sdhci: Secure Digital Host Controller Interface driver
[    1.494007] sdhci: Copyright(c) Pierre Ossman
[    1.498354] sdhci-pltfm: SDHCI platform and OF driver helper
[    1.504337] ledtrig-cpu: registered to indicate activity on CPUs
[    1.510060] SMCCC: SOC_ID: ID = jep106:0049:0000 Revision = 0x04721093
[    1.516603] zynqmp_firmware_probe Platform Management API v1.1
[    1.522409] zynqmp_firmware_probe Trustzone version v1.0
[    1.555017] securefw securefw: securefw probed
[    1.555312] zynqmp-aes zynqmp-aes.0: will run requests pump with realtime priority
[    1.561955] usbcore: registered new interface driver usbhid
[    1.567062] usbhid: USB HID core driver
[    1.573536] ARM CCI_400_r1 PMU driver probed
[    1.574174] fpga_manager fpga0: Xilinx ZynqMP FPGA Manager registered
[    1.581765] usbcore: registered new interface driver snd-usb-audio
[    1.588489] pktgen: Packet Generator for packet performance testing. Version: 2.75
[    1.596102] Initializing XFRM netlink socket
[    1.599651] NET: Registered PF_INET6 protocol family
[    1.605062] Segment Routing with IPv6
[    1.608227] In-situ OAM (IOAM) with IPv6
[    1.612188] sit: IPv6, IPv4 and MPLS over IPv4 tunneling driver
[    1.618372] NET: Registered PF_PACKET protocol family
[    1.623084] NET: Registered PF_KEY protocol family
[    1.627873] can: controller area network core
[    1.632236] NET: Registered PF_CAN protocol family
[    1.636998] can: raw protocol
[    1.639956] can: broadcast manager protocol
[    1.644136] can: netlink gateway - max_hops=1
[    1.648572] Bluetooth: RFCOMM TTY layer initialized
[    1.653357] Bluetooth: RFCOMM socket layer initialized
[    1.658497] Bluetooth: RFCOMM ver 1.11
[    1.662230] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[    1.667532] Bluetooth: BNEP filters: protocol multicast
[    1.672754] Bluetooth: BNEP socket layer initialized
[    1.677711] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[    1.683633] Bluetooth: HIDP socket layer initialized
[    1.688613] 8021q: 802.1Q VLAN Support v1.8
[    1.692858] 9pnet: Installing 9P2000 support
[    1.697073] Key type dns_resolver registered
[    1.701496] registered taskstats version 1
[    1.705381] Loading compiled-in X.509 certificates
[    1.710621] Btrfs loaded, crc32c=crc32c-generic, zoned=no, fsverity=no
[    1.716850] alg: No test for xilinx-zynqmp-rsa (zynqmp-rsa)
[    2.143374] ff000000.serial: ttyPS0 at MMIO 0xff000000 (irq = 24, base_baud = 6249999) is a xuartps
[    2.152464] printk: console [ttyPS0] enabled
[    2.152464] printk: console [ttyPS0] enabled
[    2.156765] printk: bootconsole [cdns0] disabled
[    2.156765] printk: bootconsole [cdns0] disabled
[    2.165987] of-fpga-region fpga-full: FPGA Region probed
[    2.180277]  domain8: domain8 request failed for node 28: -13
[    2.186024] ahci-ceva fd0c0000.ahci: error -EACCES: failed to add to PM domain domain8
[    2.193936] ahci-ceva: probe of fd0c0000.ahci failed with error -13
[    2.201013] spi-nor spi0.0: mt25qu512a (65536 Kbytes)
[    2.206155] 3 fixed-partitions partitions found on MTD device spi0.0
[    2.212506] Creating 3 MTD partitions on "spi0.0":
[    2.217294] 0x000000000000-0x000000100000 : "boot"
[    2.222921] 0x000000100000-0x000000140000 : "bootenv"
[    2.228696] 0x000000140000-0x000001740000 : "kernel"
[    2.234815] xilinx-axipmon ffa00000.perf-monitor: Probed Xilinx APM
[    2.241350] xilinx-axipmon fd0b0000.perf-monitor: Probed Xilinx APM
[    2.247845] xilinx-axipmon fd490000.perf-monitor: Probed Xilinx APM
[    2.254336] xilinx-axipmon ffa10000.perf-monitor: Probed Xilinx APM
[    2.281630] xhci-hcd xhci-hcd.1.auto: xHCI Host Controller
[    2.287121] xhci-hcd xhci-hcd.1.auto: new USB bus registered, assigned bus number 1
[    2.294867] xhci-hcd xhci-hcd.1.auto: hcc params 0x0238f625 hci version 0x100 quirks 0x0000000002010810
[    2.304278] xhci-hcd xhci-hcd.1.auto: irq 44, io mem 0xfe200000
[    2.310293] xhci-hcd xhci-hcd.1.auto: xHCI Host Controller
[    2.315778] xhci-hcd xhci-hcd.1.auto: new USB bus registered, assigned bus number 2
[    2.323430] xhci-hcd xhci-hcd.1.auto: Host supports USB 3.0 SuperSpeed
[    2.330074] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 6.01
[    2.338337] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.345554] usb usb1: Product: xHCI Host Controller
[    2.350430] usb usb1: Manufacturer: Linux 6.1.30-xilinx-v2023.2 xhci-hcd
[    2.357121] usb usb1: SerialNumber: xhci-hcd.1.auto
[    2.362307] hub 1-0:1.0: USB hub found
[    2.366076] hub 1-0:1.0: 1 port detected
[    2.370302] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 6.01
[    2.378562] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.385787] usb usb2: Product: xHCI Host Controller
[    2.390660] usb usb2: Manufacturer: Linux 6.1.30-xilinx-v2023.2 xhci-hcd
[    2.397358] usb usb2: SerialNumber: xhci-hcd.1.auto
[    2.402492] hub 2-0:1.0: USB hub found
[    2.406255] hub 2-0:1.0: 1 port detected
[    2.410667] cdns-i2c ff020000.i2c: can't get pinctrl, bus recovery not supported
[    2.418675] i2c i2c-0: Added multiplexed i2c bus 1
[    2.423605] i2c i2c-0: Added multiplexed i2c bus 2
[    2.428527] i2c i2c-0: Added multiplexed i2c bus 3
[    2.433449] i2c i2c-0: Added multiplexed i2c bus 4
[    2.438379] i2c i2c-0: Added multiplexed i2c bus 5
[    2.443302] i2c i2c-0: Added multiplexed i2c bus 6
[    2.448227] i2c i2c-0: Added multiplexed i2c bus 7
[    2.453148] i2c i2c-0: Added multiplexed i2c bus 8
[    2.457938] pca954x 0-0073: registered 8 multiplexed busses for I2C switch pca9548
[    2.465875] i2c i2c-0: Added multiplexed i2c bus 9
[    2.470816] i2c i2c-0: Added multiplexed i2c bus 10
[    2.475831] i2c i2c-0: Added multiplexed i2c bus 11
[    2.480844] i2c i2c-0: Added multiplexed i2c bus 12
[    2.486018] at24 13-0050: supply vcc not found, using dummy regulator
[    2.492888] at24 13-0050: 256 byte 24aa025 EEPROM, writable, 1 bytes/write
[    2.499802] i2c i2c-0: Added multiplexed i2c bus 13
[    2.504825] i2c i2c-0: Added multiplexed i2c bus 14
[    2.509840] i2c i2c-0: Added multiplexed i2c bus 15
[    2.514864] i2c i2c-0: Added multiplexed i2c bus 16
[    2.519738] pca954x 0-0077: registered 8 multiplexed busses for I2C switch pca9548
[    2.527336] cdns-i2c ff020000.i2c: 400 kHz mmio ff020000 irq 45
[    2.533615] cdns-wdt fd4d0000.watchdog: Xilinx Watchdog Timer with timeout 60s
[    2.541104] cdns-wdt ff150000.watchdog: Xilinx Watchdog Timer with timeout 10s
[    2.550502] macb ff0e0000.ethernet: Not enabling partial store and forward
[    2.558834] macb ff0e0000.ethernet eth0: Cadence GEM rev 0x50070106 at 0xff0e0000 irq 50 (fc:0f:e7:20:ec:4f)
[    2.571167] of_cfs_init
[    2.573623] of_cfs_init: OK
[    2.582383] mmc0: SDHCI controller on ff160000.mmc [ff160000.mmc] using ADMA 64-bit
[    2.586750] mmc1: SDHCI controller on ff170000.mmc [ff170000.mmc] using ADMA 64-bit
[    2.636044] mmc1: new high speed SDXC card at address 59b4
[    2.641960] mmcblk1: mmc1:59b4 ED2S5 119 GiB
[    2.647128] macb ff0e0000.ethernet eth0: PHY [ff0e0000.ethernet-ffffffff:01] driver [Marvell 88E1510] (irq=POLL)
[    2.648373]  mmcblk1: p1 p2
[    2.657302] macb ff0e0000.ethernet eth0: configuring for phy/rgmii-id link mode
[    2.669183] pps pps0: new PPS source ptp0
[    2.673282] macb ff0e0000.ethernet: gem-ptp-timer ptp clock registered.
[    2.680075] mmc0: new high speed MMC card at address 0001
[    2.685843] mmcblk0: mmc0:0001 Q2J54A 3.59 GiB
[    2.692697] mmcblk0boot0: mmc0:0001 Q2J54A 16.0 MiB
[    2.698545] mmcblk0boot1: mmc0:0001 Q2J54A 16.0 MiB
[    2.704256] mmcblk0rpmb: mmc0:0001 Q2J54A 512 KiB, chardev (241:0)
[    4.158750] usb 1-1: new high-speed USB device number 3 using xhci-hcd
[    4.310951] usb 1-1: New USB device found, idVendor=04b4, idProduct=650a, bcdDevice=50.00
[    4.319128] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    4.365878] hub 1-1:1.0: USB hub found
[    4.369663] hub 1-1:1.0: 4 ports detected
[   22.682745] Waiting up to 100 more seconds for network.
[   42.690745] Waiting up to 80 more seconds for network.
[   62.698745] Waiting up to 60 more seconds for network.
[   82.706745] Waiting up to 40 more seconds for network.
[  102.714744] Waiting up to 20 more seconds for network.
[  122.706746] Sending DHCP requests .
[  125.536794] macb ff0e0000.ethernet eth0: Link is Up - 1Gbps/Full - flow control tx
[  125.547886] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  125.562745] ., OK
[  126.580686] IP-Config: Got DHCP answer from 172.26.220.65, my address is 128.141.43.110
[  126.588687] IP-Config: Complete:
[  126.591902]      device=eth0, hwaddr=fc:0f:e7:20:ec:4f, ipaddr=128.141.43.110, mask=255.255.255.192, gw=128.141.43.65
[  126.602508]      host=trenz-tgc, domain=cern.ch, nis-domain=(none)
[  126.608680]      bootserver=0.0.0.0, rootserver=0.0.0.0, rootpath=
[  126.608685]      nameserver0=137.138.17.5, nameserver1=137.138.16.5
[  126.621121]      ntpserver0=137.138.18.69, ntpserver1=137.138.17.69, ntpserver2=137.138.16.69
[  126.629834] clk: Not disabling unused clocks
[  126.634348] ALSA device list:
[  126.637310]   No soundcards found.
[  127.438370] EXT4-fs (mmcblk1p2): recovery complete
[  127.446569] EXT4-fs (mmcblk1p2): mounted filesystem with ordered data mode. Quota mode: none.
[  127.455130] VFS: Mounted root (ext4 filesystem) on device 179:2.
[  127.462888] devtmpfs: mounted
[  127.466353] Freeing unused kernel memory: 2240K
[  127.470959] Run /sbin/init as init process
[  128.103757] systemd[1]: System time before build time, advancing clock.
[  128.188909] systemd[1]: systemd 252-32.el9_4.alma.1 running in system mode (+PAM +AUDIT +SELINUX -APPARMOR +IMA +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS -FIDO2 +IDN2 -IDN -IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY +P11KIT -QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -BPF_FRAMEWORK +XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified)
[  128.221862] systemd[1]: Detected architecture arm64.

Welcome to AlmaLinux 9.4 (Shamrock Pampas Cat)!

[  128.402439] systemd-rc-local-generator[180]: /etc/rc.d/rc.local is not marked executable, skipping.
[  129.088049] systemd[1]: Queued start job for default target Graphical Interface.
[  129.120310] systemd[1]: Created slice Slice /system/getty.
[  OK  ] Created slice Slice /system/getty.
[  129.143968] systemd[1]: Created slice Slice /system/modprobe.
[  OK  ] Created slice Slice /system/modprobe.
[  129.167864] systemd[1]: Created slice Slice /system/serial-getty.
[  OK  ] Created slice Slice /system/serial-getty.
[  129.191865] systemd[1]: Created slice Slice /system/sshd-keygen.
[  OK  ] Created slice Slice /system/sshd-keygen.
[  129.215534] systemd[1]: Created slice User and Session Slice.
[  OK  ] Created slice User and Session Slice.
[  129.239026] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[  OK  ] Started Dispatch Password …ts to Console Directory Watch.
[  129.262953] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[  OK  ] Started Forward Password R…uests to Wall Directory Watch.
[  129.286908] systemd[1]: Arbitrary Executable File Formats File System Automount Point was skipped because of an unmet condition check (ConditionPathExists=/proc/sys/fs/binfmt_misc).
[  129.303203] systemd[1]: Reached target Local Encrypted Volumes.
[  OK  ] Reached target Local Encrypted Volumes.
[  129.326862] systemd[1]: Reached target Local Integrity Protected Volumes.
[  OK  ] Reached target Local Integrity Protected Volumes.
[  129.350926] systemd[1]: Reached target Path Units.
[  OK  ] Reached target Path Units.
[  129.366861] systemd[1]: Reached target Remote Encrypted Volumes.
[  OK  ] Reached target Remote Encrypted Volumes.
[  129.386840] systemd[1]: Reached target Remote File Systems.
[  OK  ] Reached target Remote File Systems.
[  129.406846] systemd[1]: Reached target Slice Units.
[  OK  ] Reached target Slice Units.
[  129.422884] systemd[1]: Reached target Swaps.
[  OK  ] Reached target Swaps.
[  129.438865] systemd[1]: Reached target Local Verity Protected Volumes.
[  OK  ] Reached target Local Verity Protected Volumes.
[  129.464138] systemd[1]: Listening on RPCbind Server Activation Socket.
[  OK  ] Listening on RPCbind Server Activation Socket.
[  129.486843] systemd[1]: Reached target RPC Port Mapper.
[  OK  ] Reached target RPC Port Mapper.
[  129.512570] systemd[1]: Listening on Process Core Dump Socket.
[  OK  ] Listening on Process Core Dump Socket.
[  129.535022] systemd[1]: Listening on initctl Compatibility Named Pipe.
[  OK  ] Listening on initctl Compatibility Named Pipe.
[  129.559188] systemd[1]: Listening on Journal Socket (/dev/log).
[  OK  ] Listening on Journal Socket (/dev/log).
[  129.583173] systemd[1]: Listening on Journal Socket.
[  OK  ] Listening on Journal Socket.
[  129.599293] systemd[1]: Listening on udev Control Socket.
[  OK  ] Listening on udev Control Socket.
[  129.619085] systemd[1]: Listening on udev Kernel Socket.
[  OK  ] Listening on udev Kernel Socket.
[  129.654948] systemd[1]: Mounting Huge Pages File System...
         Mounting Huge Pages File System...
[  129.673603] systemd[1]: Mounting POSIX Message Queue File System...
         Mounting POSIX Message Queue File System...
[  129.718978] systemd[1]: Mounting Kernel Debug File System...
         Mounting Kernel Debug File System...
[  129.735210] systemd[1]: Kernel Trace File System was skipped because of an unmet condition check (ConditionPathExists=/sys/kernel/tracing).
[  129.748248] systemd[1]: Create List of Static Device Nodes was skipped because of an unmet condition check (ConditionFileNotEmpty=/lib/modules/6.1.30-xilinx-v2023.2/modules.devname).
[  129.767829] systemd[1]: Starting Load Kernel Module configfs...
         Starting Load Kernel Module configfs...
[  129.786412] systemd[1]: Starting Load Kernel Module drm...
         Starting Load Kernel Module drm...
[  129.810214] systemd[1]: Starting Load Kernel Module efi_pstore...
         Starting Load Kernel Module efi_pstore...
[  129.830253] systemd[1]: Starting Load Kernel Module fuse...
         Starting Load Kernel Module fuse...
[  129.847748] systemd[1]: Read and set NIS domainname from /etc/sysconfig/network was skipped because of an unmet condition check (ConditionPathExists=/etc/sysconfig/network).
[  129.864369] systemd[1]: systemd-journald.service: unit configures an IP firewall, but the local system does not support BPF/cgroup firewalling.
[  129.877238] systemd[1]: (This warning is only shown for the first unit using IP firewalling.)
[  129.907114] systemd[1]: Starting Journal Service...
         Starting Journal Service...
[  129.927975] systemd[1]: Starting Load Kernel Modules...
         Starting Load Kernel Modules...
[  129.946289] systemd[1]: Starting Generate network units from Kernel command line...
         Starting Generate network …ts from Kernel command line...
[  129.970925] systemd[1]: TPM2 PCR Machine ID Measurement was skipped because of an unmet condition check (ConditionPathExists=/sys/firmware/efi/efivars/StubPcrKernelImage-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f).
[  130.007177] systemd[1]: Starting Remount Root and Kernel File Systems...
         Starting Remount Root and Kernel File Systems...
[  130.031073] systemd[1]: Repartition Root Disk was skipped because no trigger condition checks were met.
[  130.043753] systemd[1]: Starting Coldplug All udev Devices...
         Starting Coldplug All udev Devices...
[  130.064523] systemd[1]: Started Journal Service.
[  OK  ] Started Journal Service.
[  OK  ] Mounted Huge Pages File System.
[  OK  ] Mounted POSIX Message Queue File System.
[  OK  ] Mounted Kernel Debug File System.
[  OK  ] Finished Load Kernel Module configfs.
[  OK  ] Finished Load Kernel Module drm.
[  OK  ] Finished Load Kernel Module efi_pstore.
[  OK  ] Finished Load Kernel Module fuse.
[  OK  ] Finished Load Kernel Modules.
[  OK  ] Finished Generate network units from Kernel command line.
[  OK  ] Finished Remount Root and Kernel File Systems.
         Mounting Kernel Configuration File System...
         Starting Flush Journal to Persistent Storage...
         Starting Load/Save OS Random Seed...
[  130.320462] systemd-journald[198]: Received client request to flush runtime journal.
         Starting Apply Kernel Variables...
         Starting Create Static Device Nodes in /dev...
[  OK  ] Mounted Kernel Configuration File System.
[  OK  ] Finished Flush Journal to Persistent Storage.
[  OK  ] Finished Apply Kernel Variables.
[  OK  ] Finished Create Static Device Nodes in /dev.
[  OK  ] Reached target Preparation for Local File Systems.
[  OK  ] Reached target Local File Systems.
         Starting Automatic Boot Loader Update...
         Starting Create Volatile Files and Directories...
         Starting Rule-based Manage…for Device Events and Files...
[  OK  ] Finished Automatic Boot Loader Update.
[  OK  ] Finished Create Volatile Files and Directories.
         Starting Security Auditing Service...
         Starting RPC Bind...
[  OK  ] Finished Coldplug All udev Devices.
[  OK  ] Started Rule-based Manager for Device Events and Files.
[  OK  ] Started RPC Bind.
[  OK  ] Found device /dev/ttyPS0.
[  131.566775] random: crng init done
[  OK  ] Finished Load/Save OS Random Seed.
[  OK  ] Started Security Auditing Service.
[  OK  ] Listening on Load/Save RF …itch Status /dev/rfkill Watch.
         Starting Record System Boot/Shutdown in UTMP...
[  OK  ] Finished Record System Boot/Shutdown in UTMP.
[  OK  ] Reached target System Initialization.
[  OK  ] Started dnf makecache --timer.
[  OK  ] Started Daily rotation of log files.
[  OK  ] Started Daily Cleanup of Temporary Directories.
[  OK  ] Reached target Timer Units.
[  OK  ] Listening on D-Bus System Message Bus Socket.
[  OK  ] Listening on SSSD Kerberos…ache Manager responder socket.
[  OK  ] Reached target Socket Units.
         Starting D-Bus System Message Bus...
[  OK  ] Started D-Bus System Message Bus.
[  OK  ] Reached target Basic System.
         Starting NTP client/server...
         Starting Restore /run/initramfs on shutdown...
         Starting firewalld - dynamic firewall daemon...
[  OK  ] Started irqbalance daemon.
         Starting RealtimeKit Scheduling Policy Service...
[  OK  ] Reached target sshd-keygen.target.
[  OK  ] Reached target User and Group Name Lookups.
         Starting User Login Management...
[  OK  ] Started Programming the Si5345 chip during startup..
         Starting Daemon for power management...
[  OK  ] Finished Restore /run/initramfs on shutdown.
[  OK  ] Started RealtimeKit Scheduling Policy Service.
[  OK  ] Started User Login Management.
[  OK  ] Started NTP client/server.
[  OK  ] Started Daemon for power management.
[  OK  ] Started firewalld - dynamic firewall daemon.
[  OK  ] Reached target Preparation for Network.
         Starting Network Manager...
         Starting Hostname Service...
[  OK  ] Started Hostname Service.
         Starting Network Manager Script Dispatcher Service...
[  OK  ] Started Network Manager.
[  OK  ] Reached target Network.
         Starting Network Manager Wait Online...
         Starting OpenSSH server daemon...
         Starting Permit User Sessions...
[  OK  ] Started Network Manager Script Dispatcher Service.
[  OK  ] Finished Permit User Sessions.
[  OK  ] Started Command Scheduler.
[  OK  ] Started Getty on tty1.
[  OK  ] Started Serial Getty on ttyPS0.
[  OK  ] Reached target Login Prompts.
[  OK  ] Finished Network Manager Wait Online.
[  OK  ] Started OpenSSH server daemon.
[  OK  ] Reached target Network is Online.
         Starting System Logging Service...
[  OK  ] Started System Logging Service.
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
         Starting Record Runlevel Change in UTMP...
[  OK  ] Finished Record Runlevel Change in UTMP.

AlmaLinux 9.4 (Shamrock Pampas Cat)
Kernel 6.1.30-xilinx-v2023.2 on an aarch64

trenz-tgc login: [  139.568023] systemd-journald[198]: Oldest entry in /run/log/journal/af1c2d0287cd408cb021ba11db3fbd14/system.journal is older than the configured file retention duration (1month), suggesting rotation.
[  139.585785] systemd-journald[198]: /run/log/journal/af1c2d0287cd408cb021ba11db3fbd14/system.journal: Journal header limits reached or header out-of-date, rotating.
