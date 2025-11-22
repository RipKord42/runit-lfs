#!/bin/sh
# Unmount filesystems

msg "Disabling swap"
swapoff -a 2>/dev/null || true

msg "Unmounting filesystems"
umount -a -r 2>/dev/null || msg_warn "Some filesystems could not be unmounted"
