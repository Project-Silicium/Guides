# Arch Linux ARM

> [!WARNING]
> This Guide is Outdated! A Remaster will come soon.

Make sure to check the Status of your Device [here](https://github.com/Robotix22/Mu-Qcom/blob/main/Status.md).

## Description

This Guide will show you how to Arch Linux Arm on your Device.
You can either use built-in UFS storage, SD Card or external USB device.

<table>
<tr><th>Table of Contents</th></th>
<tr><td>
  
- Installing Arch Linux
    - [What's needed](#needed-things)
    - [Partition Device](#partition-device-step-1)
        - [Partition UFS](#partition-ufs)
        - [Partition USB](#partition-usb--sd-card-method-2)
    - [Install](#installing-system-step-2)
    - [Install Bootloader](#installing-and-configuring-refind-step-3)
    - [Things to do post install](#things-to-do-post-installation)

</td></tr> </table>

## Needed Things:
   - PC / Laptop with Linux (VM can be used / WSL to be tested)
   - Unlocked Bootloader
   - [UEFI Image](https://github.com/Robotix22/Mu-Qcom/releases)
   - [Generic Arch Linux Arm image](https://archlinuxarm.org/platforms/armv8/generic)
   - [rEFInd](https://sourceforge.net/projects/refind/files/0.14.0.2/refind-bin-0.14.0.2.zip/download)

## Partition Device (Step 1)

## Partition UFS (Method 1)

***⚠️ In this Section of the Guide you can easily brick your Device! ⚠️***

Boot into your Custom Recovery and unmount `userdata`, then open Command Promt on your PC / Laptop and enter ADB Shell. <br />
Once in ADB Shell create a directory called `worksapce` in `/`:
```
mkdir /workspace/
```
Then extract the .7z Files and push the content with `adb push` into the workspace folder:
```
adb push parted gdisk /workspace/
```
After you copied parted and gdisk to workspace make it executable and run parted:
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
(parted) mkpart arch ext4 <End / 2 + 512MB> <End>
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
mke2fs -t ext4 /dev/block/by-name/arch            # Arch
```
If formatting userdata gives an error reboot to recovery and format userdata in the Custom Recovery GUI. <br />

***⚠️ End of the Dangerous Section! ⚠️***

### Mounting UFS

If your Device has a Mass Storage Guide use that. <br />
If Not, Use [Mass-Storage.zip](https://github.com/Robotix22/Mu-Qcom-Guides/files/11005130/Mass-Storage.zip) and copy it contents to a FAT32 Partition on your Device. <br />
After that boot the UEFI Image then it enters Windows Boot Manager select `Developer Menu` -> `USB Mass Storage Mode`. <br />

Then connect your Device to the PC / Laptop and find the Arch and esp partition. <br />

Mount your device like this:
```
~/uefi » su root
[root@wisnia uefi]# mkdir tmp
[root@wisnia uefi]# mount /dev/sdx<number+2> tmp/
[root@wisnia uefi]# mkdir tmp/boot
[root@wisnia uefi]# mount /dev/sdx<number+1> tmp/boot/
```

## Partition USB / SD Card (Method 2)

Use your favourite way to partition the USB drive according to this scheme:

| Mount point   | Partition     | Partition Type| Suggested size    |
| ------------- | ------------- | ------------- | -------------     |
| mnt/boot      | Esp Part      | fat32         | 1 GiB             |
| mnt           | Arch Root     | ext4          | Rest of the device|

Then Create a temp folder somewhere on your pc and open a terminal.

You can also copy the `ArchLinuxARM-aarch64-latest.tar.gz` you got earlier as you are gonna need it later

Mount the External Storage Device according to the mount points above:

Like this:
```
~/uefi » su root
[root@wisnia uefi]# mkdir tmp
[root@wisnia uefi]# mount /dev/sdx2 tmp/
[root@wisnia uefi]# mkdir tmp/boot
[root@wisnia uefi]# mount /dev/sdx1 tmp/boot/
```

## Installing System (Step 2)

Unpack the rootfs onto the mounted device
> NOTE: You **NEED** to be logged in as root, sudo won't work

```
~/uefi » su root
[root@wisnia uefi]# bsdtar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C tmp/
```

## Installing and configuring Refind (Step 3)

Okay so now you have a system, now you need a bootloader I'm going to use refind but you could use something like GRUB2 if you wish.

Unpack `refind-bin-x.xx.x.x.zip` into `refind/` directory.

Copy over this files/folders from `refind/refind/` folder into the `tmp/boot/EFI/boot/` folder (if it dosen't exist create it)
```
drivers_aa64/
icons/
tools_aa64/
refind_aa64.efi
```

rename `refind_aa64.efi` to `bootaa64.efi`

Go back into the `tmp/boot` folder
Rename the `Image.gz` to `vmlinuz-linux.gz`

Create `refind_linux.conf` file and add this line:

> If you don't have mainline device tree add `acpi=force` after the UUID
```
"Boot with UUID"   "rw root=UUID=<Arch Linux Root Part UUID>"
```

You can get the UUID by using the blkid command:
```
~/uefi » sudo blkid /dev/sdx2
/dev/sdx2: UUID="cbcc0246-582a-4edf-933b-8a85011b7646" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="5f351c6d-8f34-4d6f-b958-f00646d5e640"
```

In this case UUID would be `cbcc0246-582a-4edf-933b-8a85011b7646`

> NOTE: You might want to add `acpi=force` to the command line, because at the time of writing this guide booting with mainline device tree isn't working

After that unmount device:

```
[root@wisnia tmp]# umount tmp/boot
[root@wisnia tmp]# umount tmp/
[root@wisnia tmp]# sync
```

## Things to do post installation

### Login

Username: `alarm`

Password: `alarm`

### Connect to the internet

1. Connect USB internet source (USB tethering or USB to Ethernet card)
2. Run `dhcpcd &` after logging in to get IP address
3. Check internet access by `ping 1.1.1.1`

### Initialize the pacman keyring and populate the Arch Linux ARM package signing keys

```
pacman-key --init
pacman-key --populate archlinuxarm
```
After doing this you can now use pacman to install packages

### Install Desktop Environment

> TODO: figure out how to force Xorg to use framebuffer provided by UEFI
