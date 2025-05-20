# Using TWRP Mass Storage

## Video Guide

> [!NOTE]
> No Video Guide here yet.

## Text Guide [Recommended]

<table>
<tr><th>Guide Sections</th></th>
<tr><td>
  
- Using TWRP Mass Storage
   - [Requirements](#requirements)
   - [Mass Storage Scripts](#mass-storage-scripts)
   - [Preparing](#preparing)
   - [Running Mass Storage](#running-mass-storage)

</td></tr>
</table>

## Requirements

- A Windows PC (Linux and MacOS work too)
- A Device
- TWRP Recovery

## Mass Storage Scripts

| SoC     | Script                                      |
|:--------|:--------------------------------------------|
| SM8635  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM8550  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM8450  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM8350  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM8250  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM8150  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SDM845  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| MSM8998 | [MassStorage.sh](0x0A800000/MassStorage.sh) |
| SM7325  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM7150  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM7125  | [MassStorage.sh](0x0A600000/MassStorage.sh) |
| SM6225  | [MassStorage.sh](0x04E00000/MassStorage.sh) |
| SM6125  | [MassStorage.sh](0x04E00000/MassStorage.sh) |
| SM6115  | [MassStorage.sh](0x04E00000/MassStorage.sh) |
| SDM660  | [MassStorage.sh](0x0A800000/MassStorage.sh) |

## Preparing

Before you can use Mass Storage in TWRP, You must prepare some Things before using it. <br>
Make sure that all Partitions are Unmounted, If not Unmount all Partitions in the TWRP GUI.

Now you need the Mass Storage Script for your Device, Download the right one from [Mass Storage Scripts](#mass-storage-scripts). <br>
Save it somewhere where you can find it again, The Download Folder would be good. <br>
After that you can now Connect your Device to your PC.

## Running Mass Storage

Once you Downloaded the Script and Connected your Device, Psuh the Script to your Device:
```cmd
adb push MassStorage.sh /cache/
```
If you get a File Not Found Error make sure your cmd Shows this:
```cmd
C:\Users\[User Name]\Downloads>
```
If not, Enter the Folder using this Command and try to push the Script again:
```cmd
cd %USERPROFILE%\Downloads
```

After you Pushed the Script to your Device, You can now Start Mass Storage using these 2 Commands:
```cmd
: Makes the Script Executable
adb shell chmod 744 /cache/MassStorage.sh

: Runs the Script
adb shell ./cache/MassStorage.sh
```
Now you should see a New Disk with many Partitions on your PC.
