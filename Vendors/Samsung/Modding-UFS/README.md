# Modifying your UFS

> [!CAUTION]
> This Guide is not Recommended for Basic Users! Only for Advanced Users!

## Video Guide

> [!NOTE]
> No Video Guide here yet.

## Text Guide [Recommended]

<table>
<tr><th>Guide Sections</th></th>
<tr><td>
  
- Modifying your UFS
   - [Requirements](#preparing)
   - [Preparing](#preparing)
   - [Setting UFS Online](#setting-ufs-online)
   - [Repairing UFS LUNs](#repairing-ufs-luns)

</td></tr>
</table>

## Requirements

- A Windows PC
- A Samsung Device with a Snapdragon SoC
- TWRP Recovery
- Android SDK Tools

## Preparing

Before you can beginn modding your UFS, You need to prepare some Things first. <br>
You will need the TWRP Recovery for your Device and [Mass Storage](../../../SoCs/Snapdragon/Mass-Storage/README.md) for your Device. <br>
Follow the Mass Storage Guide and come back here once you got it Running.

Once you have Mass Storage running on your Device, Download [gdisk](https://cdn.discordapp.com/attachments/1057409313381040261/1319684671486824478/gdisk?ex=67e765e0&is=67e61460&hm=a466cbcc47cbb5bd6b8971c8a8d1310341de355d15906d2fd01bf9c4471fa14b&) and save it somewhere where you will Find it again, Best would be the Download Folder. <br>
After you Downloaded the File, Push it to your Device using this Command:
```cmd
adb push gdisk /cache/
```

## Setting UFS Online

> [!CAUTION]
> This Section will Brick your Device if not Followed correctly!

Samsung sets their UFS on Snapdragon Devices Offline which breaks Windows/Linux Boot, So you need to set it Online. <br>
Open Disk Manager on your PC and Find the Disk with way to many Partitions. <br>
Right Click the Disk and Press `Online`.

![Preview](Pictures/Preview-1.png)

Now Windows set it to Online and it should now be one Large Unformated Partition. <br>
Whatever you do, ***Don't* Reboot your Device!** <br>
You need to Repair it now, Enter ADB Shell using this Command:
```cmd
adb shell
```
After that Run `gdisk` on the UFS using these Commands:
```bash
# Makes the File Executable
chmod 744 /cache/gdisk

# Runs "gdisk"
./cache/gdisk /dev/block/sda
```
Once you Executed the Commands you should see a GPT Corrupted Warning.

Run these Commands in gdisk to Repair your GPT, First Enter `r`, That will Enter the Recovery Options. <br>
Then Enter `c`, That will now Repair your GPT, Now just Enter `w` and Confirm with `y` to Write the Changes. <br>
After you ran all these Commands it should Exit, Once it did Disconnect your Device from the PC and Power it Off.

## Repairing UFS LUNs

> [!CAUTION]
> This Section will Brick your Device if not Followed correctly!

Now that you Fixed the GPT and Set the UFS to Online, It's time to Repair the UFS LUNs. <br>
Since Samsung Write-Protects most of them you need to use the UEFI Mass Storage as that Bypasses the Protection. <br>
Open the [UEFI Status Page](https://github.com/Project-Silicium/Mu-Silicium/blob/main/Status.md) and Check if your Device supportes Mass Storage, If not Contact us on Discord for Help.

Download the latest [UEFI Image](https://github.com/Project-Silicium/Mu-Silicium/releases) or [Compile](https://github.com/Project-Silicium/Mu-Silicium/blob/main/Building.md) your own UEFI Image and Flash it to your Device. <br>
Now Reboot your Device and Hold Volume Down during the Boot Delay in UEFI to enter Mass Storage.

You should see a Blue Phone with Instructions under it. <br>
First, Press Volume Up until you see `Current LUN: 0` at the Bottom of the Screen. <br>
Then Press the Power Button, Now your PC should see a new Disk:

![Preview](Pictures/Preview-1.png)

Now you need to check what Hard Drive Number you Device got, Open Disk Manager and take a look. <br>
In the Picture it got the Number `1`. <br>
Before you can use that Number, You need to Download gdisk for Windows from [here](https://sourceforge.net/projects/gptfdisk/files/gptfdisk/1.0.3/gdisk-binaries/gdisk-windows-1.0.3.zip/download).

Once you Downloaded and Extracted it, Open a Command Prompt Window as Admin and Execute this Command:
```cmd
: Chosse 32 if your PC is x86.
.\gdisk64.exe [Drive Number]:
```
After you Ran that Command, You should get gdisk Commands like you saw in TWRP before. <br>
If it says the GPT is Corrupted, Run the same gdisk Commands from [Setting UFS Online](#setting-ufs-online) and Open gdisk again. <br>
Enter `v` to Check for Problems, It You should see Problems saying to run `j` or/and `k`. <br>

You need to Fix that, So Enter `x` and then `j`. <br>
It will Prompt you to Enter a Value, Just Press Enter. <br>
Now Enter `k` and Press Enter again, That should Fix all the Issuess for this LUN. <br>
After that Write the Changes by Enetering `w` and Confirming with `y`.

Once you did that Press Volume Up on your Device to Return to the LUN Selection. <br>
Select the Next LUN and do the same Steps you did for LUN 0.
