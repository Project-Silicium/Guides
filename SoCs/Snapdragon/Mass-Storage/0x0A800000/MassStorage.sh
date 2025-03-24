#!/sbin/sh

# Set SELinux Permisive
setenforce 0

# Set USB Attributes
echo 0xEF > /config/usb_gadget/g1/bDeviceClass
echo 0x02 > /config/usb_gadget/g1/bDeviceSubClass
echo 0x01 > /config/usb_gadget/g1/bDeviceProtocol

# Create Mass Storage Worksapce
ln -s /config/usb_gadget/g1/functions/mass_storage.0/ /config/usb_gadget/g1/configs/b.1/

# Set Target Storage
echo /dev/block/sda > /config/usb_gadget/g1/configs/b.1/mass_storage.0/lun.0/file

# Set Storage Attributes
echo 0 > /config/usb_gadget/g1/configs/b.1/mass_storage.0/lun.0/cdrom
echo 0 > /config/usb_gadget/g1/configs/b.1/mass_storage.0/lun.0/removable
echo 0 > /config/usb_gadget/g1/configs/b.1/mass_storage.0/lun.0/ro

# Start Mass Storage
sh -c 'echo > /config/usb_gadget/g1/UDC; echo a800000.dwc3 > /config/usb_gadget/g1/UDC' &
