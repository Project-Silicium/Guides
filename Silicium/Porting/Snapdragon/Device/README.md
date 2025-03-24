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
After Copying the `xbl` File or the `uefi` File, Extract all UEFI Binaries from it with [UEFIReader](https://github.com/WOA-Project/UEFIReader). <br />
A Compiled Version is Pinned in `#general` in our Discord. <br />
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

Now we create some files for the `.fdf` File

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
We will use uefiplat.cfg to create the Memory Map. <br />
Create a Folder Named `DeviceMemoryMapLib` in `Mu-Silicium/Platforms/<Device Vendor>/<Device Codename>Pkg/Library/`. <br />
After that create two Files called `DeviceMemoryMapLib.c` and `DeviceMemoryMapLib.inf`. <br />

You can either make the Memory Map by yourself or use an automated [Script](https://gist.github.com/N1kroks/0b3942a951a2d4504efe82ab82bc7a50) if your SoC is older than Snapdragon 8 Gen 3 (SM8650). <br />
>NOTE: script also create Configuration Map, remove it from Memory Map

If you want to make the Memory Map by yourself, here is a template for the .c File:
```c
#include <Library/DeviceMemoryMapLib.h>

STATIC
ARM_MEMORY_REGION_DESCRIPTOR_EX
gDeviceMemoryDescriptorEx[] = {
  // Name, Address, Length, HobOption, ResourceAttribute, ArmAttributes, ResourceType, MemoryType

  // DDR Regions

  // Other memory regions

  // Register regions

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

The INF can be copied from any other Device.

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
