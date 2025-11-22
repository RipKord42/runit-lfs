#!/bin/sh
# Mount pseudo-filesystems

msg "Mounting pseudo-filesystems"

# Mount /proc if not already mounted
mountpoint -q /proc || mount -t proc proc /proc

# Mount /sys if not already mounted
mountpoint -q /sys || mount -t sysfs sysfs /sys

# Mount /run if not already mounted
mountpoint -q /run || mount -t tmpfs tmpfs /run

# Mount /dev if not already mounted
mountpoint -q /dev || mount -t devtmpfs devtmpfs /dev

# Mount /dev/pts if not already mounted
mountpoint -q /dev/pts || mount -t devpts devpts /dev/pts

# Mount /dev/shm if not already mounted
mountpoint -q /dev/shm || mount -t tmpfs tmpfs /dev/shm

# Mount cgroup2 if available
if [ -d /sys/fs/cgroup ]; then
    mountpoint -q /sys/fs/cgroup || mount -t cgroup2 cgroup2 /sys/fs/cgroup
fi

# Mount EFI variables if available
if [ -d /sys/firmware/efi/efivars ]; then
    mountpoint -q /sys/firmware/efi/efivars || mount -t efivarfs efivarfs /sys/firmware/efi/efivars
fi

# Create /run/runit directory
mkdir -p /run/runit
