# Installing Windows

> [!WARNING]
> This Guide is Outdated! A Remaster will come soon.

Make sure to check the Status of your Device [here](https://github.com/Robotix22/Mu-Qcom/blob/main/Status.md).

## Description

This Guide will show you how to install full Windows on your Device.

<table>
<tr><th>Table of Contents</th></th>
<tr><td>
  
- Installing Windows
    - [What's needed](#needed-things)
    - [Prepare](#preparing-step-1)
        - [ISO](#windows-image-step-11)
        - [Drivers](#windows-drivers-step-12)
    - [Partition UFS](#partition-ufs-step-2)
    - [Install](#installing-step-3)
    - [Apply Drivers](#applying-drivers-step-4)
- [Reinstall Windows](#reinstalling-windows)

</td></tr> </table>

## Needed Things:
   - PC / Laptop with Windows (Recommended: Windows 10 or higher)
   - [ADB](https://developer.android.com/studio/releases/platform-tools#downloads)
   - Custom Recovery
   - Unlocked Bootloader
   - [UEFI Image](https://github.com/Robotix22/Mu-Qcom)
   - install.wim from an Windows 10/11 ISO
   - [Parted](https://renegade-project.tech/tools/parted.7z)
   - [GDisk](https://renegade-project.tech/tools/gdisk.7z)

## Preparing (Step 1)

## Windows Image (Step 1.1)

[UUP Dump](https://uupdump.net/) is recommended to get a Windows 10/11 ARM64 ISO Image. <br /> 
<b> It's not recommended to choose Windows 24H2 Builds or Higher as they Might Brick your Device!
Unless its Noted that the Device Requires 24H2 Builds or higher </b> <br />
Choose a Build and select all Options you prefer. <br />
After that download the zip File and extract it on your PC / Laptop. (The Path should not contain any spaces) <br />
Then Open the extracted Folder and run the Build script, wait once it is finished. (Some AntiVirus Programs stop the Build) <br />
A ISO will appear in the Folder, open the ISO File and extract the install.wim from `sources` and place it somewhere, where you can reach it.

## Windows Drivers (Step 1.2)

TODO: Add this Section if any Drivers are created for a Device

## Partition UFS (Step 2)

***⚠️ In this Section of the Guide you can easly brick your Device! ⚠️***

Boot into your Custom Recovery and unmount `userdata`, then open Command Promt on your PC / Laptop and enter ADB Shell. <br />
Once in ADB Shell create a directory called `worksapce` in `/`:
```
mkdir /workspace/
```
Then extract the .7z Files and push the content with `adb push` into the workspace folder:
```
adb push parted gdisk /workspace/
```
After you copied parted and gdisk to workspace make it executeable and run parted:
```
# NOTE: If your device has memory type eMMC, instead of sda use mmcblk0!
chmod 744 parted gdisk
./parted /dev/block/sda
```
Once you executed parted print the partition table:
```
(parted) print
```
Find userdata in output and note the Number, Start and End Address. <br />
Example:
```
# NOTE: Don't use these Values it just an Example!
Number  Start   End     Size    File system  Name             Flags
38      141GB   241GB   100GB                userdata
```
Once you noted the Number, Start and End Address delete userdata and create is again but smaller: <br />
```
# NOTE: Some devices use f2fs filesystem for userdata, ext4 won't suit them!
# If you have a problem with the number of partitions
# (can’t create another partition), you can try:
# NOTE: If your device has memory type eMMC, instead of sda use mmcblk0!
sgdisk --resize-table 99 /dev/block/sda # 99 number of maximum allowed partitions
# Deleting userdata will wipe all your data in Android!
(parted) rm <Number>
(parted) mkpart userdata ext4 <Start> <End / 2>
```
After shrinking userdata We can move on to creating the other Partitions:
```
(parted) mkpart esp fat32 <End / 2> <End / 2 + 512MB>
(parted) mkpart win ntfs <End / 2 + 512MB> <End>
```
Now we set esp to active by running: `set <Number> esp on`. <br />
Once that is done we exit parted and reboot again to recovery:
```
(parted) quit
reboot recovery
```
After that format the partitions:
```
mke2fs -t ext4 /dev/block/by-name/userdata        # Userdata
mkfs.fat -F32 -s1 /dev/block/by-name/esp          # ESP
mkfs.ntfs -f /dev/block/by-name/win               # Windows
```
If formating userdata gives a error reboot to recovery and format userdata in the Custom Recovery GUI. <br />

***⚠️ End of the Dangerous Section! ⚠️***

## Installing (Step 3)

If your Device has an Mass Storage Guide use that. <br />
If Not Use [Mass-Storage.zip](https://github.com/Robotix22/Mu-Qcom-Guides/files/11005130/Mass-Storage.zip) and copy it contents to a FAT32 Partition on your Device. <br />
After that boot the UEFI Image then it enters Windows Boot Manager select `Developer Menu` -> `USB Mass Storage Mode`. <br />

Then connect your Device to the PC / Laptop and find the Windows and esp partition. <br />
Open diskpart in Command Promt and Find all needed Partitions:
```
# NOTE: Most likely, your system itself will assign a letter to the win partition.
DISKPART> lis dis
# you can findout the Device ID by looking at the Sizes you may regonize your Device Internal Storage Size.
DISKPART> sel dis <Device ID>
DISKPART> lis par
DISKPART> sel par <Number + 1>
# Use a other Letter if "X" is not availbe.
DISKPART> assign letter X
DISKPART> sel par <Number + 2>
# Use a other Letter if "R" is not availbe.
DISKPART> assign letter R
DISKPART> exit
```
Now we will apply install.wim using dism:
```
# R: Is what we assigned in the diskpart part, replace the letter if you used another letter.
dism /apply-image /ImageFile:<Path to install.wim> /index:1 /ApplyDir:R:\
```
After that we need to create the Boot Files other wise our UEFI won't regonise Windows:
```
# R: and X: Is what we assigned in the diskpart part, replace the letter if you used another letter.
bcdboot R:\Windows /s X: /f UEFI
```

## Applying Drivers (Step 4)

TODO: Add this Sections if there are any Drivers for a Device.

## Configure BCD (Step 5)

cd into the EFI Partition of your Device and edit some BCD Values:
```
# Start CMD as Admin if you can't access The ESP Partition.
# X: Is what we assinged in the diskpart part, replace the letter if you used another letter.
cd X:\EFI\Microsoft\Boot
bcdedit /store BCD /set "{default}" testsigning on
bcdedit /store BCD /set "{default}" nointegritychecks on
bcdedit /store BCD /set "{default}" recoveryenabled no
```
After that reboot to recovery and remove Mass Storage, then reboot into UEFI and enjoy your Windows Installation.

## Fixing work USB (Step 6)

After you boot into the system, you will be taken to OOBE or the desktop (depending on the image) and find that the USB does not work. In order to fix this you must:

Boot into custom recovery and run them mass storage script according to the instructions that can be found for your device here [Mu-Qcom Guides](/Mu-Qcom/README.md)

After that, in the command line of your PC, enter:
 ```
# R: Is what we assigned in the diskpart part, replace the letter if you used another letter.
 reg load HKLM\OFFLINE R:\Windows\System32\Config\System 
 regedit
```
In HKEY_LOCAL_MACHINE/OFFLINE/ControlSet001/Control/USB/OsDefaultRoleSwitchMode change value to 1
After, in the command line of your PC, enter
```reg unload HKLM\OFFLINE```
Done!

## Reinstalling Windows

To reinstall you need Mass Storage again. <br />
Boot into Mass Storage, plug in your Phone into the PC / Laptop and format the Windows Partition on your Phone to NTFS using the GUI. <br />
After that apply again the install.wim and then, create the boot files again. <br />
Then also apply the BCD Settings again.
