# Installing Windows PE

> [!WARNING]
> This Guide is Outdated! A Remaster will come soon.

Make sure to check the Status of your Device [here](https://github.com/Robotix22/Mu-Qcom/blob/main/Status.md).

## Description

This Guide will show you how to Install Windows PE on your Device.

<table>
<tr><th>Table of Contents</th></th>
<tr><td>
  
- Installing Windows PE
    - [What's needed](#things-you-need)
    - [Installing](#installation)
        - [Method 1](#method-1-cust)
            - [Preparing](#preparing-step-1)
            - [Formatting](#formating-cust-partition-step-2)
            - [Copy Files](#copying-windows-pe-files-step-3)
        - [Method 2](#method-2-partitions)
            - [Preparing](#preparing-step-1-1)
            - [Partition](#partitions-step-2)
            - [Copy Files](#copying-winpe-files-step-3)

</td></tr> </table>

## Things you need:
   - PC / Laptop
   - [ADB and Fastboot](https://developer.android.com/studio/releases/platform-tools#downloads)
   - Custom Recovery
   - Unlocked Bootloader
   - [UEFI Image](https://github.com/Robotix22/Mu-Qcom)
   - Windows PE (Recommended: [Driverless WinPE](https://drive.google.com/drive/folders/1-k4LwTuVw48e3Es_CIKPNf68CA9HXYRb))

## Installation

## Method 1 (Cust)

## Preparing (Step 1)

First of we need to prepare some things before we install Windows PE on our Device. <br />
Make sure you have a Custom Recovery installed on your Device and have ADB on your PC / Laptop. <br />
Compile a UEFI Image and place it somewhere on your PC / Laptop where you can find it again. <br />
Download Windows PE and extract the zip File somewhere, where you can reach it.

## Formatting Cust Partition (Step 2)

We will now format the cust Partition to FAT32:
```
# NOTE: Not all Devices have a cust Partition
#       Some OnePlus Devices also have a cust Partition but under a diffrent Name
#       The Name is as we know this: oem_cust1_a/b
mkfs.fat -F32 -s1 /dev/block/by-name/cust
```

## Copying Windows PE Files (Step 3)

After that we copy the Windows PE Files into cust. <br />
First mount cust with ADB Shell:
```
mkdir /cust
mount /dev/block/by-name/cust /cust
```
then use `adb push` to copy all Windows PE Files to cust:
```
adb push <Path to Windows PE Files> /cust/
```
After that it should contain `sources`, `efi` and `boot`. <br />
You have now successfully installed Windows PE.

## Method 2 (Partitions)

## Preparing (Step 1)

First we need to prepare some things like Programs, etc. before we install Windows PE. <br />
Check if your Device has a Custom Recovery installed and if your PC / Laptop has ADB installed. <br />
Download [parted](https://renegade-project.tech/tools/parted.7z) and [gdisk](https://renegade-project.tech/tools/gdisk.7z), save them somewhere you can reach them again. <br />
Find a version of Windows PE that you want to download and save it somewhere, where it can be reached <br />

## Partitions (Step 2)

Boot into your Custom Recovery and plug your Device into the PC / Laptop. <br />
Create a Workspace where you put `parted` and `gdisk`:
```
adb shell mkdir /workspace
```
then push `parted` and `gdisk` into the workspace:
```
adb push parted gdisk /workspace/
adb shell chmod 744 /workspace/parted /workspace/gdisk
```
before we use parted unmount `userdata` or else some weird stuff is going to happen! <br />
After that enter ADB Shell and open sda with parted:
```
adb shell
cd /workspace
./parted /dev/block/by-name/sda
```

⚠️ ***This Section can break your Device if you are not careful!*** ⚠️ <br />

After you open sda with parted list all partitions and note all infos about userdata (Start, End and Number):
```
(parted) print
```
Something like this should show up:
```
# NOTE: Don't use these Values it just an Example!
Number  Start   End     Size    File system  Name             Flags
38      141GB   241GB   100GB                userdata
```
Once you noted `Start`, `End` and `Number` from Userdata we can move on to creating Partitions. <br />
First delete userdada (This will erase all your Data in Android) and create it again but smaller:
```
(parted) rm <Number>
(parted) mkpart userdata ext4 <Start> <End - 4GB>
```
After that create the Win PE Partition:
```
(parted) mkpart pe fat32 <End - 4GB> <End>
```

⚠️ ***End of Dangerous Section!*** ⚠️ <br />

After you created the new Partitions quit parted and format `userdata` and `pe`:
```
(parted) quit
mke2fs -t ext4 /dev/block/sda<Number>
mkfs.fat -F32 -s1 /dev/block/sda<Number + 1>
```

## Copying WinPE Files (Step 3)

Now mount `pe` and move all Windows PE Files in it:
```
mkdir /mnt/pe
mount /dev/block/by-name/pe /mnt/pe
exit
adb push <Path to WinPE Files> /mnt/pe/
```
Reboot into UEFI and thats it! You successfully installed Windows PE!
