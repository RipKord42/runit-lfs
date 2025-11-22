#!/bin/sh
# Save system time to hardware clock

if command -v hwclock >/dev/null 2>&1; then
    msg "Saving system time to hardware clock"
    hwclock --systohc --utc 2>/dev/null || msg_warn "Failed to save hardware clock"
fi
