# Creating Minimal ACPI Tables

> [!WARNING]
> This Guide is Outdated! A Remaster will come soon.

## Before you Begin

Make sure that there aren't already any Minimal ACPI Tables in the SoC Folder. <br />
Otherwise Skip this entire Guide.

## Description

This Guide will show you how to create minimal ACPI Tables for a SoC that Devices with that SoC can use.

<table>
<tr><th>Table of Contents</th></th>
<tr><td>
  
- Minimal ACPI Tables
    - [Requirements](#recuirements)
    - [Explanation](#explanation-for-acpi-tables)
    - [Creating ACPI Tables](#creating-acpi-tables-step-1)
      - [Creating APIC](#creating-apicdsl-step-11)
      - [Creating APIC UniCore](#creating-apicunicoredsl-step-12)
      - [Creating DSDT](#creating-dsdtminimaldsl-step-13)
      - [Creating FACP](#creating-facpdsl-step-14)
      - [Creating GTDT](#creating-gtdtdsl-step-15)
    - [Compiling](#compiling-acpi-tables-step-2)

</td></tr> </table>

## Requirements

To Create Minimal ACPI you need these following Things:

- Linux Terminal with `iasl` Command
- An Editor to edit the decompiled ACPI Tables
- DTB from your Device

## Explanation for ACPI Tables

For a Snapdragon Device To Boot Windows are only 4 ACPI Tables needed: APIC, FACP, GTDT and DSDT.

APIC (Multiple APIC Description Table) in a Descriptor ACPI Table wich Describes the CPU and Interrupt Controller (GIC). <br />
FACP (Fixed ACPI Description Table) is used to define Varios Static and Configuration Details about the System. <br />
GTDT (Generic Timer Description Table) stores the Generic Timer Infos about the System. <br />
DSDT (Differentiated System Description Table) stores all Device Specific Values of Devices like UFS for Windows Drivers to pick up. <br />
See it as the UEFI DTB Version for Example.

## Creating ACPI Tables (Step 1)

## Creating APIC.dsl (Step 1.1)

Lets Beginn with APIC ACPI Table first. <br />
Create a File called `APIC.dsl` in `Silicon/Qualcomm/<SoC Codename>Pkg/AcpiTables/`. <br />
That File should Contain this:
```
[000h 0000 004h]                   Signature : "APIC"    [Multiple APIC Description Table (MADT)]
[004h 0004 004h]                Table Length : 000002FC
[008h 0008 001h]                    Revision : 05
[009h 0009 001h]                    Checksum : 00
[00Ah 0010 006h]                      Oem ID : "QCOM  "
[010h 0016 008h]                Oem Table ID : "QCOMEDK2"
[018h 0024 004h]                Oem Revision : <Soc Codename Numbers>
[01Ch 0028 004h]             Asl Compiler ID : "INTL"
[020h 0032 004h]       Asl Compiler Revision : 20230628

[024h 0036 004h]          Local Apic Address : 00000000
[028h 0040 004h]       Flags (decoded below) : 00000000
                         PC-AT Compatibility : 0

[02Ch 0044 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[02Dh 0045 001h]                      Length : 50
[02Eh 0046 002h]                    Reserved : 0000
[030h 0048 004h]        CPU Interface Number : 00000000
[034h 0052 004h]               Processor UID : 00000000
[038h 0056 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[03Ch 0060 004h]    Parking Protocol Version : 00000000
[040h 0064 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[044h 0068 008h]              Parked Address : 0000000000000000
[04Ch 0076 008h]                Base Address : 0000000000000000
[054h 0084 008h]    Virtual GIC Base Address : 0000000000000000
[05Ch 0092 008h] Hypervisor GIC Base Address : 0000000000000000
[064h 0100 004h]       Virtual GIC Interrupt : <inerrupt-controller Interrupt>
[068h 0104 008h]  Redistributor Base Address : 0000000000000000
[070h 0112 008h]                   ARM MPIDR : <CPU ID>
[078h 0120 001h]            Efficiency Class : <Cluster Num>
[079h 0121 001h]                    Reserved : 00
[07Ah 0122 002h]      SPE Overflow Interrupt : 0000

[07Eh 0126 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[07Fh 0127 001h]                      Length : 50
[080h 0128 002h]                    Reserved : 0000
[082h 0130 004h]        CPU Interface Number : 00000001
[086h 0134 004h]               Processor UID : 00000001
[08Ah 0138 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[08Eh 0142 004h]    Parking Protocol Version : 00000000
[092h 0146 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[096h 0150 008h]              Parked Address : 0000000000000000
[09Eh 0158 008h]                Base Address : 0000000000000000
[0A6h 0166 008h]    Virtual GIC Base Address : 0000000000000000
[0AEh 0174 008h] Hypervisor GIC Base Address : 0000000000000000
[0B6h 0182 004h]       Virtual GIC Interrupt : <interrupt-controller Interrupt>
[0BAh 0186 008h]  Redistributor Base Address : 0000000000000000
[0C2h 0194 008h]                   ARM MPIDR : <CPU ID>
[0CAh 0202 001h]            Efficiency Class : <Cluster Num>
[0CBh 0203 001h]                    Reserved : 00
[0CCh 0204 002h]      SPE Overflow Interrupt : 0000

[0D0h 0208 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[0D1h 0209 001h]                      Length : 50
[0D2h 0210 002h]                    Reserved : 0000
[0D4h 0212 004h]        CPU Interface Number : 00000002
[0D8h 0216 004h]               Processor UID : 00000002
[0DCh 0220 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[0E0h 0224 004h]    Parking Protocol Version : 00000000
[0E4h 0228 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[0E8h 0232 008h]              Parked Address : 0000000000000000
[0F0h 0240 008h]                Base Address : 0000000000000000
[0F8h 0248 008h]    Virtual GIC Base Address : 0000000000000000
[100h 0256 008h] Hypervisor GIC Base Address : 0000000000000000
[108h 0264 004h]       Virtual GIC Interrupt : <interrupt-controller Interrupt>
[10Ch 0268 008h]  Redistributor Base Address : 0000000000000000
[114h 0276 008h]                   ARM MPIDR : <CPU ID>
[11Ch 0284 001h]            Efficiency Class : <Cluster Num>
[11Dh 0285 001h]                    Reserved : 00
[11Eh 0286 002h]      SPE Overflow Interrupt : 0000

[122h 0290 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[123h 0291 001h]                      Length : 50
[124h 0292 002h]                    Reserved : 0000
[126h 0294 004h]        CPU Interface Number : 00000003
[12Ah 0298 004h]               Processor UID : 00000003
[12Eh 0302 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[132h 0306 004h]    Parking Protocol Version : 00000000
[136h 0310 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[13Ah 0314 008h]              Parked Address : 0000000000000000
[142h 0322 008h]                Base Address : 0000000000000000
[14Ah 0330 008h]    Virtual GIC Base Address : 0000000000000000
[152h 0338 008h] Hypervisor GIC Base Address : 0000000000000000
[15Ah 0346 004h]       Virtual GIC Interrupt : <interrupt-controller Interrupt>
[15Eh 0350 008h]  Redistributor Base Address : 0000000000000000
[166h 0358 008h]                   ARM MPIDR : <CPU ID>
[16Eh 0366 001h]            Efficiency Class : <Cluster Num>
[16Fh 0367 001h]                    Reserved : 00
[170h 0368 002h]      SPE Overflow Interrupt : 0000

[174h 0372 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[175h 0373 001h]                      Length : 50
[176h 0374 002h]                    Reserved : 0000
[178h 0376 004h]        CPU Interface Number : 00000004
[17Ch 0380 004h]               Processor UID : 00000004
[180h 0384 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[184h 0388 004h]    Parking Protocol Version : 00000000
[188h 0392 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[18Ch 0396 008h]              Parked Address : 0000000000000000
[194h 0404 008h]                Base Address : 0000000000000000
[19Ch 0412 008h]    Virtual GIC Base Address : 0000000000000000
[1A4h 0420 008h] Hypervisor GIC Base Address : 0000000000000000
[1ACh 0428 004h]       Virtual GIC Interrupt : <interrupt-controller Interrupt>
[1B0h 0432 008h]  Redistributor Base Address : 0000000000000000
[1B8h 0440 008h]                   ARM MPIDR : <CPU ID>
[1C0h 0448 001h]            Efficiency Class : <Cluster Num>
[1C1h 0449 001h]                    Reserved : 00
[1C2h 0450 002h]      SPE Overflow Interrupt : 0000

[1C6h 0454 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[1C7h 0455 001h]                      Length : 50
[1C8h 0456 002h]                    Reserved : 0000
[1CAh 0458 004h]        CPU Interface Number : 00000005
[1CEh 0462 004h]               Processor UID : 00000005
[1D2h 0466 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[1D6h 0470 004h]    Parking Protocol Version : 00000000
[1DAh 0474 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[1DEh 0478 008h]              Parked Address : 0000000000000000
[1E6h 0486 008h]                Base Address : 0000000000000000
[1EEh 0494 008h]    Virtual GIC Base Address : 0000000000000000
[1F6h 0502 008h] Hypervisor GIC Base Address : 0000000000000000
[1FEh 0510 004h]       Virtual GIC Interrupt : <interrupt-controller Interrupt>
[202h 0514 008h]  Redistributor Base Address : 0000000000000000
[20Ah 0522 008h]                   ARM MPIDR : <CPU ID>
[212h 0530 001h]            Efficiency Class : <Cluster Num>
[213h 0531 001h]                    Reserved : 00
[214h 0532 002h]      SPE Overflow Interrupt : 0000

[218h 0536 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[219h 0537 001h]                      Length : 50
[21Ah 0538 002h]                    Reserved : 0000
[21Ch 0540 004h]        CPU Interface Number : 00000006
[220h 0544 004h]               Processor UID : 00000006
[224h 0548 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[228h 0552 004h]    Parking Protocol Version : 00000000
[22Ch 0556 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[230h 0560 008h]              Parked Address : 0000000000000000
[238h 0568 008h]                Base Address : 0000000000000000
[240h 0576 008h]    Virtual GIC Base Address : 0000000000000000
[248h 0584 008h] Hypervisor GIC Base Address : 0000000000000000
[250h 0592 004h]       Virtual GIC Interrupt : <interrupt-controller Interrupt>
[254h 0596 008h]  Redistributor Base Address : 0000000000000000
[25Ch 0604 008h]                   ARM MPIDR : <CPU ID>
[264h 0612 001h]            Efficiency Class : <Cluster Num>
[265h 0613 001h]                    Reserved : 00
[266h 0614 002h]      SPE Overflow Interrupt : 0000

[26Ah 0618 001h]               Subtable Type : 0B [Generic Interrupt Controller]
[26Bh 0619 001h]                      Length : 50
[26Ch 0620 002h]                    Reserved : 0000
[26Eh 0622 004h]        CPU Interface Number : 00000007
[272h 0626 004h]               Processor UID : 00000007
[276h 0630 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
          Performance Interrupt Trigger Mode : 0
          Virtual GIC Interrupt Trigger Mode : 0
[27Ah 0634 004h]    Parking Protocol Version : 00000000
[27Eh 0638 004h]       Performance Interrupt : <cpu-pmu Interrupt>
[282h 0642 008h]              Parked Address : 0000000000000000
[28Ah 0650 008h]                Base Address : 0000000000000000
[292h 0658 008h]    Virtual GIC Base Address : 0000000000000000
[29Ah 0666 008h] Hypervisor GIC Base Address : 0000000000000000
[2A2h 0674 004h]       Virtual GIC Interrupt : <interrupt controller Interrupt>
[2A6h 0678 008h]  Redistributor Base Address : 0000000000000000
[2AEh 0686 008h]                   ARM MPIDR : <CPU ID>
[2B6h 0694 001h]            Efficiency Class : <Cluster Num>
[2B7h 0695 001h]                    Reserved : 00
[2B8h 0696 002h]      SPE Overflow Interrupt : 0000

[2BCh 0700 001h]               Subtable Type : 0C [Generic Interrupt Distributor]
[2BDh 0701 001h]                      Length : 18
[2BEh 0702 002h]                    Reserved : 0000
[2C0h 0704 004h]       Local GIC Hardware ID : 00000000
[2C4h 0708 008h]                Base Address : <Distributor Base Addr>
[2CCh 0716 004h]              Interrupt Base : 00000000
[2D0h 0720 001h]                     Version : <GIC Version>
[2D1h 0721 003h]                    Reserved : 000000

[2D4h 0724 001h]               Subtable Type : 0E [Generic Interrupt Redistributor]
[2D5h 0725 001h]                      Length : 10
[2D6h 0726 002h]                    Reserved : 0000
[2D8h 0728 008h]                Base Address : <Redistributors Base Addr>
[2E0h 0736 004h]                      Length : <Redistributors Size Addr>
```

Depending on how much Cores your SoC has, Add the Count of `Generic Interrupt Controller`. <br />
For Example your SoC has 4 Cores instead of 8, Then you Only add 4 of `eneric Interrupt Controller` to APIC.dsl. <br />

`<cpu-pmu Interrupt>` Is the Interrupt Value of the `cpu-pwm` Node in your DTB. <br />
More Infos How to get the Interrupt:
```
# NOTE: Just an Example, Use your own.
cpu-pmu {
  compatible = "arm,armv8-pmuv3";
  interrupts = <0x01 0x07 0x04>;
                 |    |
              GIC_PPI |
                  Interrupt
  phandle = <0x286>;
};
```
`GIC_PPI` (0x01) is `0x10`. <br />
So its like this: `0x07 + 0x10`, Thats your Interrupt in ACPI.

`<interrupt controller Interrupt>` is the Interrupt Value of the `interrupt-controller` Node in the DTB. <br />
More Infos How to get the Interrupt:
```
# NOTE: Just an Example, Use your own.
interrupt-controller@17100000 {
  compatible = "arm,gic-v3";
  #interrupt-cells = <0x03>;
  interrupt-controller;
  ranges;
  #redistributor-regions = <0x01>;
  redistributor-stride = <0x00 0x40000>;
  reg = <0x17100000 0x10000 0x17180000 0x200000>;
  interrupts = <0x01 0x09 0x04>;
                 |    |
              GIC_PPI |
                  Interrupt
  phandle = <0x01>;
};
```
`GIC_PPI` (0x01) is `0x10`. <br />
So its like this: `0x09 + 0x10`, Thats your Interrupt in ACPI.

`<CPU ID>` is the ID of the current CPU, These Values are in the `cpus` Node. <br />
Example:
```
# NOTE: Just an Example, Use your own.
cpus {
  #address-cells = <0x02>;
  #size-cells = <0x00>;

  cpu@0 {
    device_type = "cpu";
    compatible = "qcom,kryo";
    reg = <0x00 0x00>;
                 |
              CPU ID
    enable-method = "psci";
    next-level-cache = <0x03>;
    cpu-idle-states = <0x04>;
    power-domains = <0x05>;
    power-domain-names = "psci";
    qcom,freq-domain = <0x06 0x00 0x04>;
    capacity-dmips-mhz = <0x400>;
    dynamic-power-coefficient = <0x64>;
    #cooling-cells = <0x02>;
    phandle = <0x15>;

    l2-cache {
      compatible = "arm,arch-cache";
      cache-level = <0x02>;
      next-level-cache = <0x07>;
      phandle = <0x03>;

      l3-cache {
        compatible = "arm,arch-cache";
        cache-level = <0x03>;
        phandle = <0x07>;
      };
    };
  };
};
```
`CPU ID` is `0x00` there so its ID is 0

`<Cluster Num>` is the Current Cluster of the Current CPU Core. <br />
The Clusters and CPU Cores can be found in the `cpu-map` Node of the DTB.

`<Distributor Base Addr>` and `<Redistributors Base Addr>` can be taken from the SoC .dsc.inc File.

`<GIC Version>` is the Version of GIC, The `compatible` Part of the `interrupt-controller` Node tell you that.

`<Redistributors Size Addr>` is the Size Address of Redistributors, It can be taken from the `interrupt-controller` Node. <br />
Example:
```
# NOTE: Just an Example, Use your own.
interrupt-controller@17100000 {
  compatible = "arm,gic-v3";
  #interrupt-cells = <0x03>;
  interrupt-controller;
  ranges;
  #redistributor-regions = <0x01>;
  redistributor-stride = <0x00 0x40000>;
  reg = <0x17100000 0x10000 0x17180000 0x200000>;
                                           |
                                       Size Addr
  interrupts = <0x01 0x09 0x04>;
  phandle = <0x01>;
};
```

Now, There is extra Stuff in ACPI that only Some SoCs have. <br />
If your `interrupt-controller` Node has an subnode called `msi-controller` Then you need to add this too to APIC.dsl:
```
[2E4h 0740 001h]               Subtable Type : 0D [Generic MSI Frame]
[2E5h 0741 001h]                      Length : 18
[2E6h 0742 002h]                    Reserved : 0000
[2E8h 0744 004h]                MSI Frame ID : 00000000
[2ECh 0748 008h]                Base Address : <MSI Controller Base Addr>
[2F4h 0756 004h]       Flags (decoded below) : 00000001
                                  Select SPI : 1
[2F8h 0760 002h]                   SPI Count : 0080 # We still have no Idea where to get this Value.
[2FAh 0762 002h]                    SPI Base : 0340 # We still have no Idea where to get this Value.
```
It should be under the `Generic Interrupt Redistributor` Part.

`<MSI Controller Base Addr>` is the Base Address of the MSI Controller. <br />
Example:
```
# NOTE: Just an Example, Use your own.
interrupt-controller@17100000 {
  compatible = "arm,gic-v3";
  #interrupt-cells = <0x03>;
  interrupt-controller;
  ranges;
  #redistributor-regions = <0x01>;
  redistributor-stride = <0x00 0x40000>;
  reg = <0x17100000 0x10000 0x17180000 0x200000>;
                                           |
                                       Size Addr
  interrupts = <0x01 0x09 0x04>;
  phandle = <0x01>;

  msi-controller@17140000 {
    compatible = "arm,gic-v3-its";
    msi-controller;
    #msi-cells = <0x01>;
    reg = <0x17140000 0x20000>;
               |
           Base Addr
    phandle = <0xcb>;
  };
};
```

## Creating APIC.UniCore.dsl (Step 1.2)

This File is APIC but just with One Core Enabled, Its in some Cases usefull if Windows won't boot with 8 Cores. <br />
The Only thing that needs to be done here is Changing every:
```
[224h 0548 004h]       Flags (decoded below) : 00000001
                           Processor Enabled : 1
```
To 0, Just Core 0 Should stay 1.

## Creating DSDT_minimal.dsl (Step 1.3)

## TODO: Find out where to get the Values for DSDT ACPI Table

## Creating FACP.dsl (Step 1.4)

The FACP ACPI Tables are the Same on every Snapdragon SoC. (Well we think so) <br />
Copy any FACP.dsl from any other SoC with ACPI Tables and paste it in `Silicon/Qualcomm/<SoC Codename>Pkg/AcpiTables/`. <br />
The Only thing that needs to be Changed is `Oem Revision`. <br />
Like in APIC.dsl, Change it to the SoC Codename Numbers.

## Creating GTDT.dsl (Step 1.5)

Create a File called `GTDT.dsl` in `Silicon/Qualcomm/<SoC Codename>Pkg/AcpiTables/`. <br />
The Contents of the File should look like this:
```
[000h 0000 004h]                   Signature : "GTDT"    [Generic Timer Description Table]
[004h 0004 004h]                Table Length : 0000009C
[008h 0008 001h]                    Revision : 02
[009h 0009 001h]                    Checksum : 00
[00Ah 0010 006h]                      Oem ID : "QCOM  "
[010h 0016 008h]                Oem Table ID : "QCOMEDK2"
[018h 0024 004h]                Oem Revision : <Soc Codename Numbers>
[01Ch 0028 004h]             Asl Compiler ID : "INTL"
[020h 0032 004h]       Asl Compiler Revision : 20230628

[024h 0036 008h]       Counter Block Address : FFFFFFFFFFFFFFFF
[02Ch 0044 004h]                    Reserved : 00000000

[030h 0048 004h]        Secure EL1 Interrupt : <Timer 1 Interrupt>
[034h 0052 004h]   EL1 Flags (decoded below) : 00000000
                                Trigger Mode : 0
                                    Polarity : 0
                                   Always On : 0

[038h 0056 004h]    Non-Secure EL1 Interrupt : <Timer 2 Interrupt>
[03Ch 0060 004h]  NEL1 Flags (decoded below) : 00000000
                                Trigger Mode : 0
                                    Polarity : 0
                                   Always On : 0

[040h 0064 004h]     Virtual Timer Interrupt : <Timer 3 Interrupt>
[044h 0068 004h]    VT Flags (decoded below) : 00000000
                                Trigger Mode : 0
                                    Polarity : 0
                                   Always On : 0

[048h 0072 004h]    Non-Secure EL2 Interrupt : <Timer 4 Interrupt>
[04Ch 0076 004h]  NEL2 Flags (decoded below) : 00000000
                                Trigger Mode : 0
                                    Polarity : 0
                                   Always On : 0
[050h 0080 008h]  Counter Read Block Address : FFFFFFFFFFFFFFFF

[058h 0088 004h]        Platform Timer Count : 00000001
[05Ch 0092 004h]       Platform Timer Offset : 00000060

[060h 0096 001h]               Subtable Type : 00 [Generic Timer Block]
[061h 0097 002h]                      Length : 003C
[063h 0099 001h]                    Reserved : 00
[064h 0100 008h]               Block Address : <Base Addr of Timer>
[06Ch 0108 004h]                 Timer Count : 00000001
[070h 0112 004h]                Timer Offset : 00000014

[074h 0116 001h]                Frame Number : 00
[075h 0117 003h]                    Reserved : 000000
[078h 0120 008h]                Base Address : <1st Base Addr of Timer Frame 1>
[080h 0128 008h]            EL0 Base Address : <2nd Base Addr of Timer Frame 1>
[088h 0136 004h]             Timer Interrupt : <1st Interrupt of Timer Frame 1>
[08Ch 0140 004h] Timer Flags (decoded below) : 00000000
                                Trigger Mode : 0
                                    Polarity : 0
[090h 0144 004h]     Virtual Timer Interrupt : <2nd Interrupt of Timer Frame 1>
[094h 0148 004h] Virtual Timer Flags (decoded below) : 00000000
                                Trigger Mode : 0
                                    Polarity : 0
[098h 0152 004h] Common Flags (decoded below) : 00000002
                                      Secure : 0
                                   Always On : 1
```

`<Soc Codename Numbers>` Do it like in APIC.dsl and FACP.dsl. <br />
`<Timer 1/2/3/4 Interrupt>` can be found in the `timer` Node in the DTB. <br />
Example:
```
# NOTE: Just an Example, Use your own.
timer {
  compatible = "arm,armv8-timer";
  interrupts = <0x01 0x0d 0xff08 0x01 0x0e 0xff08 0x01 0x0b 0xff08 0x01 0x0c 0xff08>;
                 |    |           |    |           |    |           |    |
              GIC_PPI |        GIC_PPI |        GIC_PPI |        GIC_PPI |
                 1st Interrupt    2nd Interrupt    3rd Interrupt   4th Interrupt
  clock-frequency = <0x124f800>;
  phandle = <0x27e>;
  always-on;
};
```
Again Its `GIC_PPI` (0x01), And its Value is `0x10`. <br />
So its like this: `1st/2nd/3rf/4th Interrupt + 0x10`, These are then the Interrupts for your GTDT ACPI Table.

`<Base Addr of Timer>` is the Base Address of the `timer` Node in your DTB. <br />
Example:
```
# NOTE: Just an Example, Use your own.
timer@17420000 {
  #address-cells = <0x01>;
  #size-cells = <0x01>;
  ranges;
  compatible = "arm,armv7-timer-mem";
  reg = <0x17420000 0x1000>;
             |
         Base Addr
  clock-frequency = <0x124f800>;
  phandle = <0x27f>;
};
```

`<1st/2nd Base Addr of Timer Frame 1>` is the Base Address of the First Timer Frame Node in your DTB. <br />
Example:
```
# NOTE: Just an Example, Use your own.
timer@17420000 {
  #address-cells = <0x01>;
  #size-cells = <0x01>;
  ranges;
  compatible = "arm,armv7-timer-mem";
  reg = <0x17420000 0x1000>;
  clock-frequency = <0x124f800>;
  phandle = <0x27f>;

  frame@17421000 {
    frame-number = <0x00>;
    interrupts = <0x00 0x08 0x04 0x00 0x06 0x04>;
    reg = <0x17421000 0x1000 0x17422000 0x1000>;
               |                  |
         1st Base Addr      2nd Base Addr
  };
};
```

`<1st/2nd Interrupt of Timer Frame 1>` is the Interrupt of the Timer Frame Node in the DTB. <br />
Example:
```
# NOTE: Just an Example, Use your own.
timer@17420000 {
  #address-cells = <0x01>;
  #size-cells = <0x01>;
  ranges;
  compatible = "arm,armv7-timer-mem";
  reg = <0x17420000 0x1000>;
  clock-frequency = <0x124f800>;
  phandle = <0x27f>;

  frame@17421000 {
    frame-number = <0x00>;
    interrupts = <0x00 0x08 0x04 0x00 0x06 0x04>;
                   |    |         |    |
                GIC_SPI |      GIC_SPI |
                  1st Interrupt   2nd Interrupt
    reg = <0x17421000 0x1000 0x17422000 0x1000>;
  };
};
```
In that Case it is `GIC_SPI` (0x00) instead of `GIC_PPI` (0x00). <br />
The Value of `GIC_SPI` is `0x20`, So The Calc is: `1st/2nd Interrupt + 0x20`.

## Compiling ACPI Tables (Step 2)

Now as you finished all ACPI Tables, Its now Time to Compile them. <br />
Open a Linux Terminal in the `AcpiTables` Folder of your SoC Folder and run this command:
```bash
iasl *
```

After that Command was Executed, There should now be .aml Files in your Folder. <br />
If Some ACPI Tables don't have an .aml File, You made an Mistake in the ACPI Table.
