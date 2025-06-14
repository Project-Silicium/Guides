# Adding Devices

> [!WARNING]
> This Guide is Outdated! A Remaster will come soon.

## Description

This Guide will show you how to create a UEFI Port for your Device. <br />

## WARNING

**Booting Windows/Linux on Sony/Google Device will wipe your UFS Clean! (Unable to recover)**

<table>
<tr><th>Table of Contents</th></th>
<tr><td>
  
- Adding Devices
    - [Requirements](#requirements)
    - [Copying Files](#copying-files-step-1)
    - [Creating Config](#creating-the-config-file-step-2)
    - [Creating Files](#creating-files-step-3)
         - [Creating .dsc & .dec & .fdf File](#creating-dsc--dec--fdf-file-step-31)
              - [Creating .dsc](#creating-dsc-file-step-311)
              - [Creating .dec](#creating-dec-file-step-312)
              - [Creating .fdf](#creating-fdf-file-step-313)
         - [Creating fdf.inc Files](#creating-fdfinc-files-step-32)
              - [Creating ACPI.inc](#creating-acpiinc-step-321)
              - [Creating APRIORI.inc](#creating-aprioriinc-step-322)
              - [Creating DXE.inc](#creating-dxeinc-step-323)
              - [Creating RAW.inc](#creating-rawinc-step-324)
         - [Creating Config Map](#creating-configurationmap-library-step-33)
         - [Creating MemoryMap](#creating-devicememorymap-library-step-34)
         - [Creating Boot Script](#creating-android-boot-image-script-step-35)
    - [Building](#building)
    - [Troubleshooting](#troubleshooting)

</td></tr> </table>

## Requirements

To Port UEFI to your Phone, It needs the following things:

- An Snapdragon SoC
- `xbl` or `uefi` in `/dev/block/by-name/`
- `fdt` in `/sys/firmware/`
- `xbl_config` in `/dev/block/by-name/` [Required for Snapdragon 8(s) Gen 3 (SM8650/SM8635) or newer devices] 

It's also recommended to have already some Knowledge about Linux and Windows. <br />
~~Also a Brain is required to do this.~~ <br />

> [!WARNING]
> Don't edit any Files using Programs like Notepad/++. <br>
> It will break the Files while Porting!

## Copying Files (Step 1)

Lets begin with Copying Files. <br />
Copy the `fdt` File from
`/sys/firmware/` <br />
you can get it using adb with root
```bash
adb shell "dd if=/sys/firmware/fdt of=/sdcard/<Device Codename>.img"

adb pull /sdcard/<Device Codename>.img .
```
Rename `<Device Codename>.img` to `<Device Codename>.dtb` <br />
> NOTE: If it doesn't works for some devices(i.e. stuck on download mode with Samsung logo) try extracting dtb from boot.img

unpack stock boot.img with AIK(Android Image Kitchen) and go to split_img directory. Here you can see boot.img-dtb. <br />
Rename `boot.img-dtb` to `<Device Codename>.dtb` <br />
and make a Humam Readable Format. <br />
> NOTE: This can be maked only on Wsl or an Linux Distro
```
dtc -I dtb -O dts -o <Device Codename>.dts <Device Codename>.dtb
```
Now copy .dts and .dtb to `Mu-Silicium/Resources/DTBs/`. <br />

Now extract your `xbl` or `uefi` from `/dev/block/by-name/` and Place it somewhere you can reach it:
```bash
adb shell

dd if=/dev/block/by-name/<UEFI Partition> of=/<UEFI Partition>.img
exit

adb pull /<UEFI Partition>.img
```
For Snapdragon 8(s) Gen 3 or newer devices `xbl_config.img` is also required from now on, since MemoryMap (which we will work later on) has been moved to there. <br />
Here is how you get it:
```bash
adb shell

dd if=/dev/block/by-name/<xbl_config Partition> of=/<xbl_config Partition>.img
exit

adb pull /<xbl_config Partition>.img
```

After Copying the `xbl` File or the `uefi` File, Extract all UEFI Binaries from it with [UEFIReader](https://github.com/WOA-Project/UEFIReader). <br />
A Compiled Version is pinned in `#general` in our Discord server. <br />
Also you can compile it yourself:
```
# Linux
# Install dotnet-sdk-8.0 for your distribution
git clone https://github.com/WOA-Project/UEFIReader.git
cd UEFIReader/
dotnet build UEFIReader.sln
# Now here you have a compiled version. Go to UEFIReader/bin/Debug/net8.0/
```
Here is how you Use it:
```
# Windows
UEFIReader.exe <UEFI Partition>.img out
# Linux
./UEFIReader <UEFI Partition>.img out
```
Now Move all the output Files from UEFI Reader in `Mu-Silicium/Binaries/<Device Codename>/`. <br />
Then Execute `CleanUp.sh` in the Binaries Folder once.

## Creating the Config File (Step 2)

Every Device has its own config file to define some device specific things like: SoC. <br />
Create a File called `<Device Codename>.conf` in `Mu-Silicium/Resources/Configs/`. <br />
It should contain at least this:
```
# General Configs
TARGET_DEVICE_VENDOR="<Device Vendor>"
TARGET_MULTIPLE_MODELS=0
TARGET_NUMBER_OF_MODELS=0

# Arch Config
TARGET_ARCH="AARCH64"

# UEFI FD Configs
TARGET_REQUIRES_BOOTSHIM=1
TARGET_FD_BASE="<FD Base>"
TARGET_FD_SIZE="<FD Size>"
TARGET_FD_BLOCKS="<FD Blocks>"

# FDT Configs
TARGET_CREATE_POINTER=0
TARGET_POINTER_ADDRESS=0x0
```
`<FD Base/Size Value>` is the UEFI FD Value in the MemoryMap (uefiplat.cfg). <br />
`<FD Blocks>` is the Number of Blocks UEFI FD has, `<UEFI FD Size> / 0x1000`.<br />
`TARGET_ARCH` modify according to your arch.

## Creating Files (Step 3)

Struckture of the Device Files:
```
./Platforms/<Device Vendor>/<Device Codename>Pkg/
├── Include
│   ├── ACPI.inc
│   ├── APRIORI.inc
│   ├── DXE.inc
│   └── RAW.inc
├── Library
│   ├── DeviceMemoryMapLib
│   │   ├── DeviceMemoryMapLib.c
│   │   └── DeviceMemoryMapLib.inf
│   └── DeviceConfigurationMapLib
│       ├── DeviceConfigurationMapLib.c
│       └── DeviceConfigurationMapLib.inf
├──FdtBlob
|  └── <SoC Codename>-<Device Vendor>-<Device Codename>.dtb
├── PlatformBuild.py
├── <Device Codename>.dec
├── <Device Codename>.dsc
└── <Device Codename>.fdf
```

## Creating .dsc & .dec & .fdf File (Step 3.1)

## Creating .dsc File (Step 3.1.1)

Lets begin with the `.dsc` File <br />
Create a File called `<Device Codename>.dsc` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>Pkg/`. <br />
Here is a template:
```
##
#
#  Copyright (c) 2011 - 2022, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2020, Intel Corporation. All rights reserved.
#  Copyright (c) 2018, Bingxing Wang. All rights reserved.
#  Copyright (c) Microsoft Corporation.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = <Device Codename>
  PLATFORM_GUID                  = <GUID>
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/<Device Codename>Pkg
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = RELEASE|DEBUG
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = <Device Codename>Pkg/<Device Codename>.fdf
  USE_CUSTOM_DISPLAY_DRIVER      = 0
  HAS_BUILD_IN_KEYBOARD          = 0

  # If your SoC has multimple variants define the Number here
  # If not don't add this Define
  SOC_TYPE                       = 2

# If your SoC has multiple variants keep these Build Options
# If not don't add "-DSOC_TYPE=$(SOC_TYPE)" to the Build Options.
[BuildOptions]
  *_*_*_CC_FLAGS = -DSOC_TYPE=$(SOC_TYPE) -DHAS_BUILD_IN_KEYBOARD=$(HAS_BUILD_IN_KEYBOARD)

[LibraryClasses]
  DeviceMemoryMapLib|<Device Codename>Pkg/Library/DeviceMemoryMapLib/DeviceMemoryMapLib.inf
  DeviceConfigurationMapLib|<Device Codename>Pkg/Library/DeviceConfigurationMapLib/DeviceConfigurationMapLib.inf

[PcdsFixedAtBuild]
  # DDR Start Address
  gArmTokenSpaceGuid.PcdSystemMemoryBase|<Start Address>

  # Device Maintainer
  gSiliciumPkgTokenSpaceGuid.PcdDeviceMaintainer|"<Your Github Name>"

  # CPU Vector Address
  gArmTokenSpaceGuid.PcdCpuVectorBaseAddress|<CPU Vector Base Address>

  # UEFI Stack Addresses
  gEmbeddedTokenSpaceGuid.PcdPrePiStackBase|<UEFI Stack Base Address>
  gEmbeddedTokenSpaceGuid.PcdPrePiStackSize|<UEFI Stack Size>

  # SmBios
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemManufacturer|"<Device Vendor>"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemModel|"<Device Model>"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailModel|"<Device Codename>"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"<Device_Model>_<Device_Codename>"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosBoardModel|"<Device Model>"

  # Simple FrameBuffer
  gSiliciumPkgTokenSpaceGuid.PcdMipiFrameBufferWidth|<Display Width>
  gSiliciumPkgTokenSpaceGuid.PcdMipiFrameBufferHeight|<Display Height>
  gSiliciumPkgTokenSpaceGuid.PcdMipiFrameBufferColorDepth|<Display Color Depth>

  # Dynamic RAM Start Address
  gQcomPkgTokenSpaceGuid.PcdRamPartitionBase|<Free DDR Region Start Address>

  # SD Card Slot
  gQcomPkgTokenSpaceGuid.PcdInitCardSlot|TRUE            # If your Phone has no SD Card Slot, Set it to FALSE.
  
  # USB Controller
  gQcomPkgTokenSpaceGuid.PcdStartUsbController|TRUE            # This should be TRUE unless your UsbConfigDxe is Patched to be Dual Role.

[PcdsDynamicDefault]
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoHorizontalResolution|<Display Width>
  gEfiMdeModulePkgTokenSpaceGuid.PcdVideoVerticalResolution|<Display Height>
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupVideoHorizontalResolution|<Display Width>
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupVideoVerticalResolution|<Display Height>
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupConOutColumn|<Setup Con Column>
  gEfiMdeModulePkgTokenSpaceGuid.PcdSetupConOutRow|<Setup Con Row>
  gEfiMdeModulePkgTokenSpaceGuid.PcdConOutColumn|<Con Column>
  gEfiMdeModulePkgTokenSpaceGuid.PcdConOutRow|<Con Row>

!include <SoC Codename>Pkg/<SoC Codenmae>.dsc.inc
```

`<GUID>` is a Value to identify your Device, Generate one [here](https://guidgenerator.com/), Make sure its Uppercase. <br />
`<Start Address>` is the Start Address of the MemoryMap (uefiplat.cfg). <br />
`<CPU Vector Base Address>` is the Base Address of `CPU Vectors` in the MemoryMap (uefiplat.cfg). <br />
`<UEFI Stack base/Size>` is the Base/Size Address of `UEFI Stack` in the MemoryMap (uefiplat.cfg). <br />
`<Display Color Depth>` is the Value of your Display Color Depth, It can be Found in the Specs of your Phone, For Example on [www.devicespecifications.com](https://www.devicespecifications.com/). <br />
`<Free DDR Region Start Address>` is the End Address of that Last DDR Memory Region. `<Base Addr> + <Size Addr> = <End Addr>`. <br />
`<Setup Con Column> / <Con Column>` is the Value of `<Display Width> / 8`. <br />
`<Setup Con Row> / <Con Row>` is the Value of `<Display Height> / 19`.

## Creating .dec File (Step 3.1.2)

After we created the .dsc File we will now continue with the .dec File. <br />
Create a File called `<Device Codename>.dec` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>/`. <br />
This File should be left Empty.

## Creating .fdf File (Step 3.1.3)

Once the .dec File is complete we can move on to the .fdf File. <br />
Create File called `<Device Codename>.fdf` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>/`. <br />
The .fdf File contains Specific Stuff about your Device, Here is a template how it should look:
```
## @file
#
#  Copyright (c) 2018, Linaro Limited. All rights reserved.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# FD Section
# The [FD] Section is made up of the definition statements and a
# description of what goes into  the Flash Device Image.  Each FD section
# defines one flash "device" image.  A flash device image may be one of
# the following: Removable media bootable image (like a boot floppy
# image,) an Option ROM image (that would be "flashed" into an add-in
# card,) a System "Flash"  image (that would be burned into a system's
# flash) or an Update ("Capsule") image that will be used to update and
# existing system flash.
#
################################################################################

[FD.<Device Codename>_UEFI]
BaseAddress   = $(FD_BASE)|gArmTokenSpaceGuid.PcdFdBaseAddress # The base address of the FLASH Device.
Size          = $(FD_SIZE)|gArmTokenSpaceGuid.PcdFdSize        # The size in bytes of the FLASH Device
ErasePolarity = 1

# This one is tricky, it must be: BlockSize * NumBlocks = Size
BlockSize     = 0x1000
NumBlocks     = $(FD_BLOCKS)

################################################################################
#
# Following are lists of FD Region layout which correspond to the locations of different
# images within the flash device.
#
# Regions must be defined in ascending order and may not overlap.
#
# A Layout Region start with a eight digit hex offset (leading "0x" required) followed by
# the pipe "|" character, followed by the size of the region, also in hex with the leading
# "0x" characters. Like:
# Offset|Size
# PcdOffsetCName|PcdSizeCName
# RegionType <FV, DATA, or FILE>
#
################################################################################

0x00000000|$(FD_SIZE)
gArmTokenSpaceGuid.PcdFvBaseAddress|gArmTokenSpaceGuid.PcdFvSize
FV = FVMAIN_COMPACT

################################################################################
#
# FV Section
#
# [FV] section is used to define what components or modules are placed within a flash
# device file.  This section also defines order the components and modules are positioned
# within the image.  The [FV] section consists of define statements, set statements and
# module statements.
#
################################################################################

[FV.FvMain]
FvNameGuid         = 631008B0-B2D1-410A-8B49-2C5C4D8ECC7E
BlockSize          = 0x1000
NumBlocks          = 0        # This FV gets compressed so make it just big enough
FvAlignment        = 8        # FV alignment and FV attributes setting.
ERASE_POLARITY     = 1
MEMORY_MAPPED      = TRUE
STICKY_WRITE       = TRUE
LOCK_CAP           = TRUE
LOCK_STATUS        = TRUE
WRITE_DISABLED_CAP = TRUE
WRITE_ENABLED_CAP  = TRUE
WRITE_STATUS       = TRUE
WRITE_LOCK_CAP     = TRUE
WRITE_LOCK_STATUS  = TRUE
READ_DISABLED_CAP  = TRUE
READ_ENABLED_CAP   = TRUE
READ_STATUS        = TRUE
READ_LOCK_CAP      = TRUE
READ_LOCK_STATUS   = TRUE

  !include Include/APRIORI.inc
  !include Include/DXE.inc
  !include Include/RAW.inc

   # SmBios
  INF MdeModulePkg/Universal/SmbiosDxe/SmbiosDxe.inf
  INF QcomPkg/Drivers/SmBiosTableDxe/SmBiosTableDxe.inf

  # ACPI
  INF MdeModulePkg/Universal/Acpi/AcpiTableDxe/AcpiTableDxe.inf
  INF MdeModulePkg/Universal/Acpi/AcpiPlatformDxe/AcpiPlatformDxe.inf

  !include Include/ACPI.inc

  # Device Tree
  #INF EmbeddedPkg/Drivers/DtPlatformDxe/DtPlatformDxe.inf
  #FILE FREEFORM = 25462CDA-221F-47DF-AC1D-259CFAA4E326 {
  #  SECTION RAW = <Device Codename>Pkg/FdtBlob/<SoC Codename>-<Device Vendor>-<Device Codename>.dtb
  #  SECTION UI = "DeviceTreeBlob"
  #}

  !include QcomPkg/Extra.fdf.inc

[FV.FVMAIN_COMPACT]
FvAlignment        = 8
ERASE_POLARITY     = 1
MEMORY_MAPPED      = TRUE
STICKY_WRITE       = TRUE
LOCK_CAP           = TRUE
LOCK_STATUS        = TRUE
WRITE_DISABLED_CAP = TRUE
WRITE_ENABLED_CAP  = TRUE
WRITE_STATUS       = TRUE
WRITE_LOCK_CAP     = TRUE
WRITE_LOCK_STATUS  = TRUE
READ_DISABLED_CAP  = TRUE
READ_ENABLED_CAP   = TRUE
READ_STATUS        = TRUE
READ_LOCK_CAP      = TRUE
READ_LOCK_STATUS   = TRUE

  INF SiliciumPkg/PrePi/PrePi.inf

  FILE FREEFORM = dde58710-41cd-4306-dbfb-3fa90bb1d2dd {
    SECTION UI = "uefiplat.cfg"
    SECTION RAW = Binaries/<Device Codename>/RawFiles/uefiplat.cfg
  }

  FILE FV_IMAGE = 9E21FD93-9C72-4c15-8C4B-E77F1DB2D792 {
    SECTION GUIDED EE4E5898-3914-4259-9D6E-DC7BD79403CF PROCESSING_REQUIRED = TRUE {
      SECTION FV_IMAGE = FVMAIN
    }
  }

  !include SiliciumPkg/Common.fdf.inc
```

## Creating .fdf.inc Files (Step 3.2)

Now we create some files for the `.fdf` File. For easier work with drivers, here is the sheet with necessary information.
### LG Drivers

| UEFITool Driver Name | New Driver  Name | Driver Path                                                    | Should be Added |
|:---------------------|:-----------------|:---------------------------------------------------------------|:---------------:|
| AkmuDxe              | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/AkmuDxe/AkmuDxe.inf | ✅              |
| SidDxe               | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/SidDxe/SidDxe.inf   | ✅              |

### Motorola Drivers

| UEFITool Driver Name | New Driver  Name | Driver Path                                                                              | Should be Added |
|:---------------------|:-----------------|:-----------------------------------------------------------------------------------------|:---------------:|
| AbDxe                | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/AbDxe/AbDxe.inf                           | ✅              |
| BacklightDxe         | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/BacklightDxe/BacklightDxe.inf             | ✅              |
| MbmModeDxe           | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MbmModeDxe/MbmModeDxe.inf                 | ✅              |
| MotBootFlagsDxe      | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotBootFlagsDxe/MotBootFlagsDxe.inf       | ✅              |
| MotCoreServicesDxe   | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotCoreServicesDxe/MotCoreServicesDxe.inf | ✅              |
| MotHwIdDxe           | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotHwIdDxe/MotHwIdDxe.inf                 | ✅              |
| MotSolDxe            | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotSolDxe/MotSolDxe.inf                   | ✅              |
| MotStorageDxe        | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotStorageDxe/MotStorageDxe.inf           | ✅              |
| MotUtagsDictDxe      | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotUtagsDictDxe/MotUtagsDictDxe.inf       | ✅              |
| MotUtagsDxe          | ...              | Binaries/[Device Codename]/MbmPkg/Core/Drivers/MotUtagsDxe/MotUtagsDxe.inf               | ✅              |

### Nothing Drivers

| UEFITool Driver Name   | New Driver  Name | Driver Path                                                                              | Should be Added |
|:-----------------------|:-----------------|:-----------------------------------------------------------------------------------------|:---------------:|
| BootloaderLoggingDxe   | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/BootloaderLoggingDxe/BootloaderLoggingDxe.inf | ❌              |
| DeviceInfoDxeDriver    | DeviceInfoDxe    | Binaries/[Device Codename]/QcomPkg/Drivers/DeviceInfoDxe/DeviceInfoDxe.inf               | ✅              |
| NT_DeviceInfoDxeDriver | NT_DeviceInfoDxe | Binaries/[Device Codename]/QcomPkg/Drivers/NT_DeviceInfoDxe/NT_DeviceInfoDxe.inf         | ✅              |
| SoftSKUDxe             | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/SoftSKUDxe/SoftSKUDxe.inf                     | ✅              |

### OnePlus Drivers

| UEFITool Driver Name | New Driver  Name | Driver Path                                                                      | Should be Added |
|:---------------------|:-----------------|:---------------------------------------------------------------------------------|:---------------:|
| OGaugeAuthDxe        | OGaugeAuth       | Binaries/[Device Codename]/QcomPkg/Drivers/OGaugeAuthDxe/OGaugeAuth.inf          | ✅              |
| OplusProject         | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/OcdtDxe/OplusProject.inf              | ✅              |
| OplusOrdump          | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/OplusOrdumpDxe/OplusOrdump.inf        | ❌              |
| OplusSecurityDxe     | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/OplusSecurityDxe/OplusSecurityDxe.inf | ✅              |
| OplusVibrDxe         | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/OplusVibrDxe/OplusVibrDxe.inf         | ✅              |
| PhoenixDxe           | ...              | Binaries/[Device Codename]/QcomPkg/Drivers/PhoenixDxe/PhoenixDxe.inf             | ✅              |
| UFSUpgradeDxe        | ...              | Binaries/[Device Codename]/QcomPkg/OnePlusPkg/OnePlusUFS/UFSUpgradeDxe.inf       | ✅              |

### Project Mu Drivers

| UEFITool Driver Name     | New Driver  Name                 | Driver Path                                                                                   | Should be Added |
|:-------------------------|:---------------------------------|:----------------------------------------------------------------------------------------------|:---------------:|
| ArmCpuDxe                | CpuDxe                           | ArmPkg/Drivers/CpuDxe/CpuDxe.inf                                                              | ✅              |
| ArmGicDxe                | ...                              | ArmPkg/Drivers/ArmGic/ArmGicDxe.inf                                                           | ✅              |
| ArmTimerDxe              | TimerDxe                         | ArmPkg/Drivers/TimerDxe/TimerDxe.inf                                                          | ✅              |
| CapsuleRuntimeDxe        | ...                              | MdeModulePkg/Universal/CapsuleRuntimeDxe/CapsuleRuntimeDxe.inf                                | ✅              |
| ConPlatformDxe           | ...                              | MdeModulePkg/Universal/Console/ConPlatformDxe/ConPlatformDxe.inf                              | ✅              |
| ConSplitterDxe           | ...                              | MdeModulePkg/Universal/Console/ConSplitterDxe/ConSplitterDxe.inf                              | ✅              |
| DevicePathDxe            | ...                              | MdeModulePkg/Universal/DevicePathDxe/DevicePathDxe.inf                                        | ✅              |
| DiskIoDxe                | ...                              | MdeModulePkg/Universal/Disk/DiskIoDxe/DiskIoDxe.inf                                           | ✅              |
| DxeCore                  | DxeMain                          | MdeModulePkg/Core/Dxe/DxeMain.inf                                                             | ✅              |
| EmbeddedMonotonicCounter | ...                              | EmbeddedPkg/EmbeddedMonotonicCounter/EmbeddedMonotonicCounter.inf                             | ✅              |
| FvSimpleFileSystem       | FvSimpleFileSystemDxe            | MdeModulePkg/Universal/FvSimpleFileSystemDxe/FvSimpleFileSystemDxe.inf                        | ❌              |
| EnglishDxe               | ...                              | MdeModulePkg/Universal/Disk/UnicodeCollation/EnglishDxe/EnglishDxe.inf                        | ✅              |
| Fat                      | ...                              | FatPkg/EnhancedFatDxe/Fat.inf                                                                 | ✅              |
| GraphicsConsoleDxe       | ...                              | MdeModulePkg/Universal/Console/GraphicsConsoleDxe/GraphicsConsoleDxe.inf                      | ✅              |
| HiiDatabase              | HiiDatabaseDxe                   | MdeModulePkg/Universal/HiiDatabaseDxe/HiiDatabaseDxe.inf                                      | ✅              |
| MetronomeDxe             | ...                              | EmbeddedPkg/MetronomeDxe/MetronomeDxe.inf                                                     | ✅              |
| PartitionDxe             | ...                              | MdeModulePkg/Universal/Disk/PartitionDxe/PartitionDxe.inf                                     | ✅              |
| PrintDxe                 | ...                              | MdeModulePkg/Universal/PrintDxe/PrintDxe.inf                                                  | ✅              |
| QcomBds                  | BdsDxe                           | MdeModulePkg/Universal/BdsDxe/BdsDxe.inf                                                      | ✅              |
| RealTimeClock            | RealTimeClockRuntimeDxe          | EmbeddedPkg/RealTimeClockRuntimeDxe/RealTimeClockRuntimeDxe.inf                               | ✅              |
| ResetRuntimeDxe          | ResetSystemRuntimeDxe            | MdeModulePkg/Universal/ResetSystemRuntimeDxe/ResetSystemRuntimeDxe.inf                        | ✅              |
| RscRtDxe                 | ReportStatusCodeRouterRuntimeDxe | MdeModulePkg/Universal/ReportStatusCodeRouter/RuntimeDxe/ReportStatusCodeRouterRuntimeDxe.inf | ✅              |
| RuntimeDxe               | ...                              | MdeModulePkg/Core/RuntimeDxe/RuntimeDxe.inf                                                   | ✅              |
| SCHandlerRtDxe           | StatusCodeHandlerRuntimeDxe      | MdeModulePkg/Universal/StatusCodeHandler/RuntimeDxe/StatusCodeHandlerRuntimeDxe.inf           | ✅              |
| SecurityStubDxe          | ...                              | MdeModulePkg/Universal/SecurityStubDxe/SecurityStubDxe.inf                                    | ✅              |
| SimpleTextInOutSerial    | ...                              | EmbeddedPkg/SimpleTextInOutSerial/SimpleTextInOutSerial.inf                                   | ✅              |
| VariableDxe              | VariableRuntimeDxe               | MdeModulePkg/Universal/Variable/RuntimeDxe/VariableRuntimeDxe.inf                             | ✅              |
| WatchdogTimer            | ...                              | MdeModulePkg/Universal/WatchdogTimerDxe/WatchdogTimer.inf                                     | ✅              |
| UsbBusDxe                | ...                              | MdeModulePkg/Bus/Usb/UsbBusDxe/UsbBusDxe.inf                                                  | ✅              |
| UsbKbDxe                 | ...                              | MdeModulePkg/Bus/Usb/UsbKbDxe/UsbKbDxe.inf                                                    | ✅              |
| UsbMassStorageDxe        | ...                              | MdeModulePkg/Bus/Usb/UsbMassStorageDxe/UsbMassStorageDxe.inf                                  | ✅              |

### Qualcomm Drivers

| UEFITool Driver Name  | New Driver  Name    | Driver Path                                                                            | Should be Added |
|:----------------------|:--------------------|:---------------------------------------------------------------------------------------|:---------------:|
| AdcDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/AdcDxe/AdcDxe.inf                           | ✅              |
| ASN1X509Dxe           | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ASN1X509Dxe/ASN1X509Dxe.inf                 | ❌              |
| ButtonsDxe            | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ButtonsDxe/ButtonsDxe.inf                   | ✅              |
| ChargerExDxe          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ChargerExDxe/ChargerExDxe.inf               | ✅              |
| ChipInfo              | ChipInfoDxe         | Binaries/[Device Codename]/QcomPkg/Drivers/ChipInfoDxe/ChipInfoDxe.inf                 | ✅              |
| CipherDxe             | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/CipherDxe/CipherDxe.inf                     | ✅              |
| ClockDxe              | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ClockDxe/ClockDxe.inf                       | ✅              |
| CmdDbDxe              | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/CmdDbDxe/CmdDbDxe.inf                       | ✅              |
| CPRDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/CPRDxe/CPRDxe.inf                           | ✅              |
| DALSys                | DALSYSDxe           | Binaries/[Device Codename]/QcomPkg/Drivers/DALSYSDxe/DALSYSDxe.inf                     | ✅              |
| DALTLMM               | TLMMDxe             | Binaries/[Device Codename]/QcomPkg/Drivers/TLMMDxe/TLMMDxe.inf                         | ✅              |
| DDRInfoDxe            | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/DDRInfoDxe/DDRInfoDxe.inf                   | ✅              |
| DisplayDxe            | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/DisplayDxe/DisplayDxe.inf                   | ✅              |
| EnvDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/EnvDxe/EnvDxe.inf                           | ✅              |
| FeatureEnablerDxe     | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/FeatureEnablerDxe/FeatureEnablerDxe.inf     | ✅              |
| FontDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/FontDxe/FontDxe.inf                         | ✅              |
| FvDxe                 | FvUtilsDxe          | Binaries/[Device Codename]/QcomPkg/Drivers/FvUtilsDxe/FvUtilsDxe.inf                   | ✅              |
| GlinkDxe              | GLinkDxe            | Binaries/[Device Codename]/QcomPkg/Drivers/GLinkDxe/GLinkDxe.inf                       | ✅              |
| GpiDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/GpiDxe/GpiDxe.inf                           | ✅              |
| HashDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/HashDxe/HashDxe.inf                         | ✅              |
| HALIOMMU              | HALIOMMUDxe         | Binaries/[Device Codename]/QcomPkg/Drivers/HALIOMMUDxe/HALIOMMUDxe.inf                 | ✅              |
| HWIODxeDriver         | HWIODxe             | Binaries/[Device Codename]/QcomPkg/Drivers/HWIODxe/HWIODxe.inf                         | ✅              |
| I2C                   | I2CDxe              | Binaries/[Device Codename]/QcomPkg/Drivers/I2CDxe/I2CDxe.inf                           | ✅              |
| I2cHapticDxe          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/I2cHapticDxe/I2cHapticDxe.inf               | ✅              |
| ICBDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ICBDxe/ICBDxe.inf                           | ✅              |
| IPCCDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/IPCCDxe/IPCCDxe.inf                         | ✅              |
| LimitsDxe             | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/LimitsDxe/LimitsDxe.inf                     | ✅              |
| MacDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/MacDxe/MacDxe.inf                           | ✅              |
| MdtpDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/MdtpDxe/MdtpDxe.inf                         | ✅              |
| MinidumpTADxe         | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/MinidumpTADxe/MinidumpTADxe.inf             | ✅              |
| MpPowerDxe            | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/MpPowerDxe/MpPowerDxe.inf                   | ✅              |
| NpaDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/NpaDxe/NpaDxe.inf                           | ✅              |
| ParserDxe             | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ParserDxe/ParserDxe.inf                     | ✅              |
| PdcDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/PdcDxe/PdcDxe.inf                           | ✅              |
| PILDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/PILDxe/PILDxe.inf                           | ✅              |
| PILProxyDxe           | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/PILProxyDxe/PILProxyDxe.inf                 | ✅              |
| PlatformInfoDxeDriver | PlatformInfoDxe     | Binaries/[Device Codename]/QcomPkg/Drivers/PlatformInfoDxe/PlatformInfoDxe.inf         | ✅              |
| PmicDxe               | PmicDxeLa           | Binaries/[Device Codename]/QcomPkg/Drivers/PmicDxe/PmicDxeLa.inf                       | ✅              |
| PmicGlinkDxe          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/PmicGlinkDxe/PmicGlinkDxe.inf               | ✅              |
| PsStateDxe            | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/PsStateDxe/PsStateDxe.inf                   | ✅              |
| PwrUtilsDxe           | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/PwrUtilsDxe/PwrUtilsDxe.inf                 | ✅              |
| QcomChargerDxeLA      | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/QcomChargerDxe/QcomChargerDxeLA.inf         | ✅              |
| QcomMpmTimerDxe       | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/QcomMpmTimerDxe/QcomMpmTimerDxe.inf         | ✅              |
| QcomWDogDxe           | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/QcomWDogDxe/QcomWDogDxe.inf                 | ✅              |
| QdssDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/QdssDxe/QdssDxe.inf                         | ✅              |
| QRKSDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/QRKSDxe/QRKSDxe.inf                         | ✅              |
| RngDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/RNGDxe/RngDxe.inf                           | ✅              |
| RpmhDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/RpmhDxe/RpmhDxe.inf                         | ✅              |
| RscDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/RscDxe/RscDxe.inf                           | ✅              |
| ScmDxeCompat          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/TzDxe/ScmDxeCompat.inf                      | ✅              |
| ScmDxeLA              | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/TzDxe/ScmDxeLA.inf                          | ✅              |
| SdccDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/SdccDxe/SdccDxe.inf                         | ✅              |
| SecRSADxe             | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/SecRSADxe/SecRSADxe.inf                     | ❌              |
| SerialPortDxe         | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/SerialPortDxe/SerialPortDxe.inf             | ✅              |
| ShmBridgeDxeLA        | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ShmBridgeDxe/ShmBridgeDxeLA.inf             | ✅              |
| SmemDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/SmemDxe/SmemDxe.inf                         | ✅              |
| SPI                   | SPIDxe              | Binaries/[Device Codename]/QcomPkg/Drivers/SPIDxe/SPIDxe.inf                           | ✅              |
| SPMI                  | SPMIDxe             | Binaries/[Device Codename]/QcomPkg/Drivers/SPMIDxe/SPMIDxe.inf                         | ✅              |
| SPSSDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/SPSSDxe/SPSSDxe.inf                         | ✅              |
| TsensDxe              | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/TsensDxe/TsensDxe.inf                       | ✅              |
| TzDxeLA               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/TzDxe/TzDxeLA.inf                           | ✅              |
| UCDxe                 | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UCDxe/UCDxe.inf                             | ✅              |
| UFSDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UFSDxe/UFSDxe.inf                           | ✅              |
| ULogDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/ULogDxe/ULogDxe.inf                         | ✅              |
| UsbConfigDxe          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UsbConfigDxe/UsbConfigDxe.inf               | ✅              |
| UsbDeviceDxe          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UsbDeviceDxe/UsbDeviceDxe.inf               | ✅              |
| UsbfnDwc3Dxe          | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UsbfnDwc3Dxe/UsbfnDwc3Dxe.inf               | ✅              |
| UsbInitDxe            | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UsbInitDxe/UsbInitDxe.inf                   | ✅              |
| UsbMsdDxe             | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UsbMsdDxe/UsbMsdDxe.inf                     | ✅              |
| UsbPwrCtrlDxe         | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/UsbPwrCtrlDxe/UsbPwrCtrlDxe.inf             | ✅              |
| VcsDxe                | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/VcsDxe/VcsDxe.inf                           | ✅              |
| VerifiedBootDxe       | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/VerifiedBootDxe/VerifiedBootDxe.inf         | ❌              |
| XhciDxe               | ...                 | Binaries/[Device Codename]/QcomPkg/Drivers/XhciDxe/XhciDxe.inf                         | ✅              |
| XhciPciEmulation      | XhciPciEmulationDxe | Binaries/[Device Codename]/QcomPkg/Drivers/XhciPciEmulationDxe/XhciPciEmulationDxe.inf | ✅              |

### Samsung Drivers

| UEFITool Driver Name | New Driver  Name | Driver Path                                                                               | Should be Added |
|:---------------------|:-----------------|:------------------------------------------------------------------------------------------|:---------------:|
| BoardInfo            | BoardInfoDxe     | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/BoardInfoDxe/BoardInfoDxe.inf       | ✅              |
| Ccic                 | CcicDxe          | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/CcicDxe/CcicDxe.inf                 | ✅              |
| Chg                  | ChgDxe           | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/ChgDxe/ChgDxe.inf                   | ✅              |
| Expander             | GpioExpanderDxe  | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/GpioExpanderDxe/GpioExpanderDxe.inf | ✅              |
| GuidedFv             | GuidedFvDxe      | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/GuidedFvDxe/GuidedFvDxe.inf         | ✅              |
| Muic                 | MuicDxe          | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/MuicDxe/MuicDxe.inf                 | ✅              |
| SubPmic              | SubPmicDxe       | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/SubPmicDxe/SubPmicDxe.inf           | ✅              |
| Vib                  | VibDxe           | Binaries/[Device Codename]/QcomPkg/Drivers/SamsungDxe/VibDxe/VibDxe.inf                   | ✅              |

### Sony Drivers

| UEFITool Driver Name | New Driver  Name | Driver Path                                                                    | Should be Added |
|:---------------------|:-----------------|:-------------------------------------------------------------------------------|:---------------:|
| BootCounterDxe       | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/BootCounterDxe/BootCounterDxe.inf   | ✅              |
| MazeDetDxe           | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/MazeDetDxe/MazeDetDxe.inf           | ✅              |
| ResetCfgDxe          | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/ResetCfgDxe/ResetCfgDxe.inf         | ✅              |
| SobaDxe              | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/SobaDxe/SobaDxe.inf                 | ✅              |
| StartFlagDxe         | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/StartFlagDxe/StartFlagDxe.inf       | ✅              |
| TaDxe                | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/TaDxe/TaDxe.inf                     | ✅              |
| XBootPALDxe          | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/XBootPALDxe/XBootPALDxe.inf         | ✅              |
| XDeviceTreeDxe       | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/XDeviceTreeDxe/XDeviceTreeDxe.inf   | ✅              |
| XDisplayDxe          | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/XDisplayDxe/XDisplayDxe.inf         | ✅              |
| XHwresetDxe          | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/XHwresetDxe/XHwresetDxe.inf         | ✅              |
| XOemCertDxe          | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/XOemCertDxe/XOemCertDxe.inf         | ✅              |
| XResetReasonDxe      | ...              | Binaries/[Device Codename]/SomcOkg/Drivers/XResetReasonDxe/XResetReasonDxe.inf | ✅              |

### Xiaomi Drivers

| UEFITool Driver Name | New Driver  Name | Driver Path                                                                  | Should be Added |
|:---------------------|:-----------------|:-----------------------------------------------------------------------------|:---------------:|
| MiTokenDxe           | MiToken          | Binaries/[Device Codename]/MiPkg/Protocol/MiToken/MiToken.inf                | ❌              |
| ProjectInfoDxeDriver | ProjectInfoDxe   | Binaries/[Device Codename]/QcomPkg/Drivers/ProjectInfoDxe/ProjectInfoDxe.inf | ✅              |

## Creating ACPI.inc (Step 3.2.1)

For Now, Leave it Empty, When your UEFI is working stable then you can Follow the ACPI Guide.

## Creating APRIORI.inc (Step 3.2.2)

We continue with `APRIORI.inc`, Create `APRIORI.inc` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>Pkg/Include/`. <br />
Now we need the order of the Binaries in `APRIORI.inc`, Use UEFITool to get the Order:

![Preview](Pictures/APRIORI1.png)
![Preview](Pictures/APRIORI2.png)

Next we place all the Binaries in `APRIORI.inc` like this:
```
INF <Path to .inf File>
```
After you ordered and added all the Files you also need to add some extra stuff to `APRIORI.inc`:
```
INF MdeModulePkg/Universal/PCD/Dxe/Pcd.inf
INF ArmPkg/Drivers/ArmPsciMpServicesDxe/ArmPsciMpServicesDxe.inf
INF QcomPkg/Drivers/DynamicRAMDxe/DynamicRAMDxe.inf
INF QcomPkg/Drivers/ClockSpeedUpDxe/ClockSpeedUpDxe.inf
INF QcomPkg/Drivers/SimpleFbDxe/SimpleFbDxe.inf
```

`Pcd` should be under `DxeMain`. <br />
`ArmPsciMpServicesDxe` should be under `TimerDxe`. <br />
`DynamicRAMDxe` should be under `SmemDxe`. <br />
`ClockSpeedUpDxe` should be under `ClockDxe`. <br />
`SimpleFbDxe` dosen't Replace `DisplayDxe` Make an If case for it, Check other Devices for the if case.

Also make sure that you don't add `FvSimpleFileSystemDxe`.

Check other Devices APRIORI.inc File to get an Idea, What to replace with the Mu Driver and what not.

## Creating DXE.inc File (Step 3.2.3)

After that we can now move on to `DXE.inc`, Create `DXE.inc` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>Pkg/Include/`. <br />
Now again we need the Order, To get the order of `DXE.inc` Open `xbl` or `uefi` in UEFITool and Expand the FV(s), Then you see the Order. <br />

![Preview](Pictures/DXE.png)

Again we place all the Binaries like this:
```
INF <Path to .inf>
```
Also here again you need to add some extra Stuff:
```
INF ArmPkg/Drivers/ArmPsciMpServicesDxe/ArmPsciMpServicesDxe.inf
INF MdeModulePkg/Universal/PCD/Dxe/Pcd.inf
INF QcomPkg/Drivers/DynamicRAMDxe/DynamicRAMDxe.inf
INF QcomPkg/Drivers/ClockSpeedUpDxe/ClockSpeedUpDxe.inf
INF QcomPkg/Drivers/SimpleFbDxe/SimpleFbDxe.inf
INF MdeModulePkg/Bus/Usb/UsbMouseAbsolutePointerDxe/UsbMouseAbsolutePointerDxe.inf
```

`ArmPsciMpServicesDxe` should be under `TimerDxe`. <br />
`Pcd` should be under `DxeMain`. <br />
`DynamicRAMDxe` should be under `SmemDxe`. <br />
`ClockSpeedUpDxe` should be under `ClockDxe`. <br />
`SimpleFbDxe` dosen't Replace `DisplayDxe` Make an If case for it, Check other Devices for the if case. <br />
`UsbMouseAbsolutePointerDxe` should be under `UsbKbDxe`. <br />

Remove any EFI Applications from XBL in `DXE.inc`. <br />
Also again, Make sure that you don't add `FvSimpleFileSystemDxe`.

Check other Devices DXE.inc File to get an Idea, What to replace with the Mu Driver and what not.

## Creating RAW.inc (Step 3.2.4)

You can take the RAW Files Order from DXE.inc that UEFIReader generated. <br />
Thats how they should look:
```
FILE FREEFORM = <GUID> {
  SECTION RAW = Binaries/<Device Codename>/RawFiles/<File Name>.<File Extension>
  SECTION UI = "<Name>"
}
```
Just UEFIReader dosen't format the Lines correct, You need to Correct that. <br />
Also Remove any RAW Section that has a Picture.

## Creating DeviceConfigurationMap Library (Step 3.3)

Now, We move on to creating a Configuration Map for your Device. <br />
We need uefiplat.cfg from XBL to create This Map. <br />
Here is a Template for the .c File:
```c
#include <Library/DeviceConfigurationMapLib.h>

STATIC
CONFIGURATION_DESCRIPTOR_EX
gDeviceConfigurationDescriptorEx[] = {
  // NOTE: All Conf are located before Terminator!

  // Terminator
  {"Terminator", 0xFFFFFFFF}
};

CONFIGURATION_DESCRIPTOR_EX*
GetDeviceConfigurationMap ()
{
  return gDeviceConfigurationDescriptorEx;
}
```
Place all Configs from `[ConfigParameters]` (uefiplat.cfg) In the .c File. <br />
Here is an Example:
```
EnableShell = 0x1
```
Becomes this:
```c
{"EnableShell", 0x1},
```
Configs that have Strings instead of Decimal won't be added:
```
# This for Example
OsTypeString = "LA"
```
And don't add `ConfigParameterCount` to the .c File either.

The INF can be copied from any other Device.

## Creating DeviceMemoryMap Library (Step 3.4)

Lets move on making Memory Map. <br />
For Snapdragon 8 Gen 2 (SM8550) or older SoCs we will use uefiplat.cfg to create the Memory Map. <br />
Create a Folder Named `DeviceMemoryMapLib` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>Pkg/Library/`. <br />
After that create two Files called `DeviceMemoryMapLib.c` and `DeviceMemoryMapLib.inf`. <br />

You can either make the Memory Map by yourself or use an automated [Script](https://gist.github.com/N1kroks/0b3942a951a2d4504efe82ab82bc7a50)<br />
>NOTE: script also create Configuration Map, remove it from Memory Map

If you want to make the Memory Map by yourself, here is a template for the .c File:
```c
#include <Library/DeviceMemoryMapLib.h>

STATIC
ARM_MEMORY_REGION_DESCRIPTOR_EX
gDeviceMemoryDescriptorEx[] = {
  // Name                   Address     Length    HobOpt  ResType  ResAttribute MemType   ArmAttribute (Cache)
  // DDR Regions          ----------- ----------- ------- -------- ------------ ------- ------------------------


  // Name                   Address     Length    HobOpt  ResType  ResAttribute MemType   ArmAttribute (Cache)
  // Other memory regions ----------- ----------- ------- -------- ------------ ------- ------------------------


  // Name                   Address     Length    HobOpt  ResType  ResAttribute MemType   ArmAttribute (Cache)
  // Register regions     ----------- ----------- ------- -------- ------------ ------- ------------------------


  // Terminator for MMU
  {"Terminator", 0, 0, 0, 0, 0, 0, 0}
};

ARM_MEMORY_REGION_DESCRIPTOR_EX*
GetDeviceMemoryMap ()
{
  return gDeviceMemoryDescriptorEx;
}
```

Place all `DDR` Memory Regions under `DDR Regions` in `DeviceMemoryMapLib.c`, Example:
```
0xEA600000, 0x02400000, "Display Reserved",  AddMem, MEM_RES, SYS_MEM_CAP, Reserv, WRITE_THROUGH_XN
```
would become in the Memory Map:
```c
{"Display Reserved",  0xEA600000, 0x02400000, AddMem, MEM_RES, SYS_MEM_CAP, Reserv, WRITE_THROUGH_XN},
```
Do that with every Memory Region but if there's an `#` is infront of an Memory Region do not add it. <br />

After that it should look something like [this](https://github.com/Robotix22/Mu-Silicium/blob/main/Platforms/Xiaomi/limePkg/Library/DeviceMemoryMapLib/DeviceMemoryMapLib.c).


For Snapdragon 8(s) Gen 3 (SM8650/SM8635) or newer devices we will use `post-ddr-<platform codename>-1.0.dts` from `xbl_config.img`, since Qualcomm have changed MemoryMap format. <br />

You can either make the Memory Map by yourself or use an automated [Script](https://gist.github.com/N1kroks/0b3942a951a2d4504efe82ab82bc7a50)<br />
>NOTE: script also create Configuration Map, remove it from Memory Map

Unpack `xbl_config.img`, which we have extracted earlier from your device, using [XBLConfigReader](https://github.com/Project-Aloha/XBLConfigReader). <br />
A Compiled Version is pinned in `#general` in our Discord server. <br />
Also you can compile it yourself:
```
# Linux
# Install cmake for your distribution
git clone https://github.com/woa-msmnile/XBLConfigReader --depth=1
cd XBLConfigReader
mkdir build && cd build
cmake -S .. && cmake --build .
mkdir out
# Now here you have a compiled version. Go to XBLConfigReader/build/
```
Here is how you Use it:
```
# Windows
¯\_(ツ)_/¯
# Linux
./xcreader <xbl_config Partition>.img out
```
After you unpacked `xbl_config.img`, go into `out` directory and find a file called `post-ddr-<platform codename>-1.0.dtb`. convert it into `.dts` file:
```
dtc -I dtb -O dts -o post-ddr-<platform codename>-1.0.dts post-ddr-<platform codename>-1.0.dtb
```
Now lets take a closer look at new MemoryMap format:
```
# This is an example region.
memory@80000000 {
  device_type = "memory";
  reg = <0x00 0x80000000 0x00 0x16e0000>;
  MemLabel = "NOMAP";
  ResourceAttribute = <0x400>;
  BuildHob = [09];
  ResourceType = [05];
  MemoryType = [00];
  CacheAttributes = [25];
};
```
If you translate that into C it would look like this:
```c
// Name                   Address     Length    HobOpt  ResType  ResAttribute MemType   ArmAttribute (Cache)
// Register regions     ----------- ----------- ------- -------- ------------ ------- ------------------------
{"NOMAP",               0x80000000, 0x016e0000, AddMem, MEM_RES, UNCACHEABLE, Reserv, UNCACHED_UNBUFFERED_XN},
```
Also, If a Name has a `_`, Replace it with a Space. <br />
Here is a List What from the DTB Memory Region is what in your C Code:

> [!WARNING]
> Don't add Memory regions with BuildHop = `09` / `NoMap` <br>

**ResourceAttribute:** <br />
`0x400 `   = `UNCACHEABLE` <br />
`0x703C07` = `SYS_MEM_CAP` <br />
`0x02`     = `INITIALIZED` <br />


**BuildHob:** <br />
`0A` = `AddDynamicMem (Use AddMem instead)` <br />
`09` = `NoMap` (Don't add Memory Region if it has this) <br />
`05` = `AddDev` <br />
`04` = `NoHob` <br />
`00` = `AddMem` <br />


**ResourceType:** <br />
`05` = `MEM_RES` <br />
`01` = `MMAP_IO` <br />
`00` = `SYS_MEM` <br />


**MemoryType:** <br />
`0B` = `MmIO` <br />
`07` = `Conv` <br />
`04` = `BsData` <br />
`00` = `Reserv` <br />
`06` = `RtData` <br />


**CacheAttributes:** <br />
`25` = `UNCACHED_UNBUFFERED_XN` <br />
`22` = `WRITE_BACK_XN` <br />
`20` = `WRITE_THROUGH_XN` <br />
`02` = `WRITE_BACK` <br />
`09` = `NS_DEVICE` <br />

After that it should look something like [this](https://github.com/Project-Silicium/Mu-Silicium/blob/main/Platforms/Realme/balePkg/Library/DeviceMemoryMapLib/DeviceMemoryMapLib.c)

When you are done with MemoryMap, copy INF file from any other Device.

## Creating Android Boot Image Script (Step 3.5)

You also need to create a Script that creates the Boot Image. <br />
You can Copy a Device with similear/Same Boot Image Creation Script from `Mu-Silicium/Resources/Scripts/<Device Codename>.sh` and just replace the Code Name with yours. <br />
If there is no Device with similear Boot Image Creation Script, Extract the Original Android Boot Image with AIK (Android Image Kitchen). <br />
Then you just use the Info that the Tool Gives you and Put them into the Script.



## Building

Now Build your Device with:
```
./build_uefi.sh -d <Device Codename> -r DEBUG
```

## Troubleshooting

There are too Many Cases for Errors in UEFI, So if you have any Please contact us on [Discord](https://discord.gg/Dx2QgMx7Sv).
