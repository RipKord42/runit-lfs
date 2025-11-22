#!/bin/sh
# Mount network filesystems

msg "Mounting network filesystems"
mount -a -t nfs,nfs4,cifs 2>/dev/null || msg_warn "No network filesystems or mount failed"
