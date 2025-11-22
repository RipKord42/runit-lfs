#!/bin/sh
# Enable swap

msg "Enabling swap"
swapon -a 2>/dev/null || msg_warn "No swap partitions found or already enabled"
