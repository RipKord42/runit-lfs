#!/bin/sh
# Mount filesystems from /etc/fstab

msg "Mounting filesystems"

# Remount root read-write
mount -o remount,rw / || msg_warn "Failed to remount root read-write"

# Mount all filesystems except network filesystems
mount -a -t no nfs,nfs4,cifs 2>/dev/null || msg_warn "Some filesystem mounts failed"
