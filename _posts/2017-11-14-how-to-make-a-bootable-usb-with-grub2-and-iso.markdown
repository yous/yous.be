---
layout: post
title: "How to make a bootable USB with GRUB2 and ISO"
date: 2017-11-14 03:23:14 +0000
categories:
description:
keywords:
redirect_from: /p/20171114/
---

Do you have multiple ISO files to install, with quite enough storage of USB stick? You'll want to install all of them with a single USB stick. Here's how.

## Formatting USB disk

First, plug in your USB stick and find it from your Linux machine:

``` sh
$ sudo fdisk -l
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x4d149927

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sda1  *        2048 39845887 39843840   19G 83 Linux
/dev/sda2       39847934 41940991  2093058 1022M  5 Extended
/dev/sda5       39847936 41940991  2093056 1022M 82 Linux swap / Solaris


Disk /dev/sdb: 14.6 GiB, 15664676864 bytes, 30595072 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 4788154A-7BD2-4A06-945B-5980E828C8C5

Device      Start      End  Sectors  Size Type
/dev/sdb1      40   409639   409600  200M EFI System
/dev/sdb2  411648 30593023 30181376 14.4G Microsoft basic data
```

In my case, it's `/dev/sdb`. Let's format it with `fdisk`. When you run `fdisk /dev/sdb`, you can print help menu:

``` sh
$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.27.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): m

Help:

  Generic
   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit
   q   quit without saving changes

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table
```

Now we can start!

``` sh
$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.27.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): o
Created a new DOS disklabel with disk identifier 0x8c9faeb0.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-30595071, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-30595071, default 30595071):

Created a new partition 1 of type 'Linux' and of size 14.6 GiB.

Command (m for help): t
Selected partition 1
Partition type (type L to list all types): c
Changed type of partition 'Linux' to 'W95 FAT32 (LBA)'.

Command (m for help): a
Selected partition 1
The bootable flag on partition 1 is enabled now.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

We've just created one bootable FAT partition, and that'll be `/dev/sdb1`. Let's
create an MS-DOS filesystem in it. This will take a while.

``` sh
$ sudo mkfs.vfat -F 32 /dev/sdb1
mkfs.fat 3.0.28 (2015-05-16)
```

Now you can mount that partition and we're ready to install GRUB2 in it.

``` sh
sudo make /mnt/usb
sudo mount /dev/sdb1 /mnt/usb
```

## Installing GRUB2

Since we're installing GRUB2 into USB stick, we specify `--removable` flag. Also
specify `--boot-directory` so that GRUB2 is installed to there instead of
`/boot/grub`.

``` sh
$ sudo grub-install --removable --boot-directory=/mnt/usb/boot /dev/sdb
Installing for i386-pc platform.
Installation finished. No error reported.
```

We'll add `grub.cfg` file under `/mnt/usb/boot/grub/` directory. It defines
selectable menus and the booting method of each entry. This time I'll add Ubuntu
Desktop ISO for i386 platform.

``` grub
set timeout=5
set default=0

menuentry "Ubuntu Desktop 16.04.3 LTS i386" {
  set isofile="/iso/ubuntu-16.04.3-desktop-i386.iso"
  loopback loop $isofile
  linux (loop)/casper/vmlinuz boot=casper file=/preseed/ubuntu.seed iso-scan/filename=$isofile noeject noprompt splash --
  initrd (loop)/casper/initrd.lz
}

menuentry "Ubuntu Desktop 16.04.3 LTS amd64" {
  set isofile="/iso/ubuntu-16.04.3-desktop-amd64.iso"
  loopback loop $isofile
  linux (loop)/casper/vmlinuz.efi boot=casper file=/preseed/ubuntu.seed iso-scan/filename=$isofile noeject noprompt splash --
  initrd (loop)/casper/initrd.lz
}

menuentry "Ubuntu Server 16.04.3 LTS i386" {
  set isofile="/iso/ubuntu-16.04.3-server-i386.iso"
  loopback loop $isofile
  linux (loop)/install/vmlinuz boot=casper file=/preseed/ubuntu-server.seed iso-scan/filename=$isofile noeject noprompt splash --
  initrd (loop)/install/initrd.gz
}

menuentry "Ubuntu Server 16.04.3 LTS amd64" {
  set isofile="/iso/ubuntu-16.04.3-server-amd64.iso"
  loopback loop $isofile
  linux (loop)/install/vmlinuz boot=casper file=/preseed/ubuntu-server.seed iso-scan/filename=$isofile noeject noprompt splash --
  initrd (loop)/install/initrd.gz
}

menuentry "Linux Mint 18.2 Cinnamon 32-bit" {
  set isofile="/iso/linuxmint-18.2-cinnamon-32bit.iso"
  loopback loop $isofile
  linux (loop)/casper/vmlinuz boot=casper file=/preseed/linuxmint.seed iso-scan/filename=$isofile noeject noprompt splash --
  initrd (loop)/casper/initrd.lz
}

menuentry "Custom ELF" {
  elffile="/elf/custom.elf"
  multiboot $elffile
}
```

In the first menuentry, `isofile` points to
`/iso/ubuntu-16.04.3-desktop-i386.iso`, and it's relative path of the USB stick.
Create `/mnt/usb/iso/` directory, and put the ISO files under there.

You may need to look inside of ISO file to find where is `vmlinuz*` and
`initrd.*` files. Try this:

``` sh
isoinfo -l -i myimage.iso
```

As the similar way, you can also make it to boot from ELF file. Just put the ELF
file that supports
[Multiboot](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html)
under `/mnt/usb/elf/` directory, and edit the menuentry properly.

After editing is done, unmount the disk and use it right away!

``` sh
sudo umount /dev/sdb1
```

## Troubleshooting

If your screen goes black on boot, try with `nomodeset`:

``` grub
linux ... noeject noprompt splash nomodeset --
```

## See also

- [Grub2/ISOBoot/Examples](https://help.ubuntu.com/community/Grub2/ISOBoot/Examples)
- [Ubuntu Manpage: casper](http://manpages.ubuntu.com/manpages/xenial/man7/casper.7.html)
