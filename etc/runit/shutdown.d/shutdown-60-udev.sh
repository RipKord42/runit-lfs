#!/bin/sh
# Stop udev

if command -v udevadm >/dev/null 2>&1; then
    msg "Stopping udev"
    udevadm control --exit 2>/dev/null || true
fi
