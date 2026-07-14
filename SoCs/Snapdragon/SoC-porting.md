# Adding SoCs
## Before you Begin

Make sure that the SoC you are trying to add isn't already supported. <br />
Otherwise skip this guide.

## Description

This Guide will show you how to make an UEFI port for an Snapdragon SoC.

<table>
<tr><th>Table of Contents</th></th>
<tr><td>
  
- Adding SoCs
    - [Structure for the platform package](#Structure-for-the-platform-package)
        - [Creating .dsc.inc file](#Creating-dscinc-file)
        - [Creating "PlatformSecLib" library](#Creating-PlatformSecLib-library)
          - ["PlatformHelper.S" file](#PlatformHelperS-file)
          - [PlatformSec](#PlatformSec)

</td></tr>
</table>

## Structure for the platform package
```
Mu-Silicium/Silicon/Qualcomm/<SoC Codename>Pkg/
├── Library
│   └── PlatformSecLib
│       ├── AArch64
│       │   └── PlatformHelper.S
│       ├── PlatformSec.c
│       └── PlatformSecLib.inf
└── <SoC Codename>.dsc.inc
```

Create `<SoC Codename>Pkg` in `Silicion/Qualcomm/` directory. That's where we are gonna start from.

> [!NOTE]
> You might want to use existing port of the platform that is similar to yours.
> Please do it only if you know what you are doing.

## Creating .dsc.inc file
Create `<SoC Codename>.dsc.inc` file with the next preset inside. We will edit this later on:
```
##
#  Copyright (c) 2011 - 2022, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2020, Intel Corporation. All rights reserved.
#  Copyright (c) 2018, Bingxing Wang. All rights reserved.
#  Copyright (c) Microsoft Corporation.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
##

[Defines]
  #
  # Timer
  #
  USE_PHYSICAL_TIMER                         = 0

  #
  # KEP
  #
  HAS_ACTLR_EL1_UNIMPLEMENTED_ERRATA         = 1
  HAS_AMCNTENSET0_EL0_UNIMPLEMENTED_ERRATA   = 1
  HAS_GIC_V3_WITHOUT_IRM_FLAG_SUPPORT_ERRATA = 1
  HAS_PSCI_MEMPROTECT_FAILING_ERRATA         = 0

!include QcomPkg/QcomPkg.dsc.inc

[BuildOptions]
  *_*_AARCH64_CC_FLAGS = <Cross-compiler flag>

[PcdsFixedAtBuild]
  #
  # CPU
  #
  gArmPlatformTokenSpaceGuid.PcdCoreCount|<CPU core count>
  gArmPlatformTokenSpaceGuid.PcdClusterCount|<CPU cluster count>

  #
  # GIC
  #
  gArmTokenSpaceGuid.PcdGicDistributorBase|<'interrupt-controller' node start address>
  gArmTokenSpaceGuid.PcdGicRedistributorsBase|<'interrupt-controller' node length>

  #
  # SMBIOS
  #
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosProcessorModel|"Snapdragon (TM) <SoC market name>"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosProcessorPartNumber|"<SoC part number>"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosMaxCpuFreq|<Max CPU frequency in MHz>
  
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosLevel1InstCacheSize|<Hex value of L1i cache per core>
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosLevel1DataCacheSize|<Hex value of L1d cache per core>
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosLevel2CacheSize|<Hex value of L2 cache>
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosLevel3CacheSize|0x2000                         # Unoffical Value
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosMemorySpeed|<RAM frequency in MHz>
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosMemoryType|<RAM type>

[LibraryClasses]
  #
  # SEC Libraries
  #
  PlatformSecLib|<SoC Codename>Pkg/Library/PlatformSecLib/PlatformSecLib.inf

[Components]
  #
  # Custom Drivers
  #
  QcomPkg/Drivers/IortDtDxe/IortDtDxe.inf
```
First of all, we need to get GIC Values. <br />
`PcdGicDistributorBase` and `PcdGicRedistributorsBase` are the two Values of the `interrupt-controller` Node in the Device Tree Source file. <br />
```
# NOTE: This is just an Example!
interrupt-controller@17a00000 {
  compatible = "arm,gic-v3";
  #interrupt-cells = <0x03>;
  interrupt-controller;
  #redistributor-regions = <0x01>;
  redistributor-stride = <0x00 0x20000>;
  reg = <0x17a00000 0x10000 0x17a60000 0x100000>;
            |                     |
            PcdGicDistributorBase |
                                  PcdGicRedistributorsBase
  interrupts = <0x01 0x09 0x04>;
  phandle = <0x01>;
};
```
`PcdGicInterruptInterfaceBase` is same Value as `PcdGicRedistributorsBase`. <br />

For `*_*_AARCH64_CC_FLAGS` you must specify cross-compiler flag for the ARM architechture of your SoC.

<details>
<summary><b><strong>List of available cross-compiler flags</strong></b></summary>

| FLAG                         | ARM version
|:-----------------------------|:-----------:
| -march=armv8-a+crypto+rcpc   | v8,   v8.1
| -march=armv8.2-a+crypto+rcpc | v8.2, v8.3
| -march=armv8.4-a+crypto+rcpc | v8.4, v8.5
| -march=armv9-a+crypto+rcpc   | v9,   v9.1
| -march=armv9.2-a+crypto+rcpc | v9.2, v9.3

</details></br>

Now update `PcdCoreCount` (amount of CPU cores) and `PcdClusterCount` (amount of CPU clusters) values according to your platform. <br />
You can simply refer to [NanoReview](https://nanoreview.net) site for these.

After that we need to change SmBios Values: <br />
`PcdSmbiosProcessorModel` - SoC market name (e.g. Snapdragon (TM) 8 Elite Gen 5). <br />
`PcdSmbiosProcessorPartNumber` - SoC part number (e.g. SM8850 for 8 Elite Gen 5). <br />
`PcdSmbiosMaxCpuFreq` - Max CPU frequency on prime cluster that's measured in MHz (for SM8850 it will be `4600` because of the `4.61 GHz` core speed).
`PcdSmbiosMemoryType` - In our case, it's a RAM type

<details>
<summary><b><strong>Memory types for "PcdSmbiosMemoryType"</strong></b></summary>

| TYPE                     | HEX    | DEC
|:-------------------------|:------:|----
| Other                    | 0x01   | 0
| Unknown                  | 0x02   | 1
| DRAM                     | 0x03   | 2
| EDRAM                    | 0x04   | 3
| VRAM                     | 0x05   | 4
| SRAM                     | 0x06   | 5
| RAM                      | 0x07   | 6
| ROM                      | 0x08   | 7
| Flash                    | 0x09   | 8
| EEPROM                   | 0x0A   | 9
| FEPROM                   | 0x0B   | 10
| EPROM                    | 0x0C   | 11
| CDRAM                    | 0x0D   | 12
| 3DRAM                    | 0x0E   | 13
| SDRAM                    | 0x0F   | 14
| SGRAM                    | 0x10   | 15
| RDRAM                    | 0x11   | 16
| DDR                      | 0x12   | 17
| DDR2                     | 0x13   | 18
| DDR2FBDIMM               | 0x14   | 19
| DDR3                     | 0x18   | 20
| FBD2                     | 0x19   | 21
| DDR4                     | 0x1A   | 22
| LPDDR                    | 0x1B   | 23
| LPDDR2                   | 0x1C   | 24
| LPDDR3                   | 0x1D   | 25
| LPDDR4 / LPDDR4X         | 0x1E   | 26
| LogicalNonVolatileDevice | 0x1F   | 27
| HBM                      | 0x20   | 28
| HBM2                     | 0x21   | 29
| DDR5                     | 0x22   | 30
| LPDDR5 / LPDDR5X         | 0x23   | 31
| HBM3                     | 0x24   | 32
| MRDIMM                   | 0x25   | 33

</details></br>

The next for configuration are L-caches. You can get information about them using [CPU info app](https://github.com/kamgurgul/cpu-info). <br />
`PcdSmbiosLevel1InstCacheSize` - Hexidecimal amount of L1i cache per core (usually 32KB or 0x20). <br />
`PcdSmbiosLevel1DataCacheSize` - Hexidecimal amount of L1d cache per core (usually 32KB or 0x20). <br />
`PcdSmbiosLevel2CacheSize` - Hexidecimal amount of L2 cache (usually 1024KB or 0x400). <br />

> [!NOTE]
> If Your SoC doesn't have L3 cache, remove `PcdSmbiosLevel3CacheSize` line.

Now the last thing you need to do is Update the `USE_PHYSICAL_TIMER` Define at the Top of the file. <br />
Leave it at 0 if your SoC uses a virtual timer, Otherwise set it to 1. <br />
Every older SoC like SM8150 and below have a physical timer. <br />
The Newer ones like SM8250 should have a virtual timer.

## Creating "PlatformSecLib" library
### "PlatformHelper.S" file
Create file `PlatformHelper.S` at `<SoC Codename>Pkg/Library/PlatformSecLib/AArch64/` direcotry with the next content inside:
```S
//
// Copyright (c) 2012-2013, ARM Limited. All rights reserved.
// SPDX-License-Identifier: BSD-2-Clause-Patent
//

#include <AsmMacroLib.h>

ASM_FUNC (PlatformAssemblyInitialize)
  // Nothing to do Here.
  ret
```

### PlatformSec
Create file `PlatformSecLib.inf` at `<SoC Codename>Pkg/Library/PlatformSecLib/` direcotry with the next content inside:
```inf
##
#  Copyright (c) 2011-2012, ARM Limited. All rights reserved.
#  SPDX-License-Identifier: BSD-2-Clause-Patent
##

[Defines]
  INF_VERSION                    = 0x00010005
  BASE_NAME                      = PlatformSecLib
  FILE_GUID                      = 2C33C03B-D643-4792-8A90-EEF53A555C7D
  MODULE_TYPE                    = SEC
  VERSION_STRING                 = 1.0
  LIBRARY_CLASS                  = PlatformSecLib

[Sources]
  PlatformSec.c

[Sources.AArch64]
  AArch64/PlatformHelper.S

[Packages]
  ArmPkg/ArmPkg.dec
  MdePkg/MdePkg.dec
  SiliciumPkg/SiliciumPkg.dec
  QcomPkg/QcomPkg.dec

[LibraryClasses]
  ArmSmmuDetachLib
```

Create file `PlatformSecLib.c` at `<SoC Codename>Pkg/Library/PlatformSecLib/` direcotry with the next content inside:
```c
/**
  Copyright (c) 2011-2012, ARM Limited. All rights reserved.
  SPDX-License-Identifier: BSD-2-Clause-Patent
**/

#include <Library/PlatformSecLib.h>
#include <Library/ArmSmmuDetachLib.h>

STATIC
ARM_CORE_INFO
mArmPlatformMpCoreInfoTable[] = {
  // Mpidr, MailboxSetAddress, MailboxGetAddress, MailboxClearAddress, MailboxClearValue

  // Cluster X
};

VOID
GetPlatformCoreTable (
  OUT ARM_CORE_INFO **ArmCoreTable,
  OUT UINTN          *CoreCount)
{
  // Pass Data
  *ArmCoreTable = mArmPlatformMpCoreInfoTable;
  *CoreCount    = ARRAY_SIZE (mArmPlatformMpCoreInfoTable);
}

VOID
PlatformInitialize ()
{
  // Set MDP SIDs
  CONST UINT16 MdpStreams[] = { 0x1C00, 0x1C01, 0x1C04, 0x1C06 };

  // Detach IOMMU Domains
  ArmSmmuDetach (MdpStreams, ARRAY_SIZE (MdpStreams));
}
```
Get an exact amount of your clusters and amount of cores in each cluster, then add next data:
```c
...
{ 0x000, 0, 0, 0, 0xFFFFFFFF },
...
```
Each line represents a certain core. The only thing you need to edit is `0x000` for every single core.

<details>
<summary><b><strong>Example for "PlatformSecLib.c", taken from SM7635</strong></b></summary>

```c
/**
  Copyright (c) 2011-2012, ARM Limited. All rights reserved.
  SPDX-License-Identifier: BSD-2-Clause-Patent
**/

#include <Library/PlatformSecLib.h>
#include <Library/ArmSmmuDetachLib.h>

STATIC
ARM_CORE_INFO
mArmPlatformMpCoreInfoTable[] = {
  // Mpidr, MailboxSetAddress, MailboxGetAddress, MailboxClearAddress, MailboxClearValue

  // Cluster 0, little cores
  { 0x000, 0, 0, 0, 0xFFFFFFFF }, // Core 1
  { 0x100, 0, 0, 0, 0xFFFFFFFF }, // Core 2
  { 0x200, 0, 0, 0, 0xFFFFFFFF }, // Core 3

  // Cluster 1, BIG cores
  { 0x300, 0, 0, 0, 0xFFFFFFFF }, // Core 4
  { 0x400, 0, 0, 0, 0xFFFFFFFF }, // Core 5
  { 0x500, 0, 0, 0, 0xFFFFFFFF }, // Core 6
  { 0x600, 0, 0, 0, 0xFFFFFFFF }, // Core 7

  // Cluster 2, Prime core
  { 0x700, 0, 0, 0, 0xFFFFFFFF } // Core 8
};

VOID
GetPlatformCoreTable (
  OUT ARM_CORE_INFO **ArmCoreTable,
  OUT UINTN          *CoreCount)
{
  // Pass Data
  *ArmCoreTable = mArmPlatformMpCoreInfoTable;
  *CoreCount    = ARRAY_SIZE (mArmPlatformMpCoreInfoTable);
}

VOID
PlatformInitialize ()
{
  // Set MDP SIDs
  CONST UINT16 MdpStreams[] = { 0x1C00, 0x1C01, 0x1C04, 0x1C06 };

  // Detach IOMMU Domains
  ArmSmmuDetach (MdpStreams, ARRAY_SIZE (MdpStreams));
}
```

</details></br>

Done! Now that you have a platform package, you can move to [device porting](Device-porting.md)
