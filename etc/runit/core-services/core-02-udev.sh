#!/bin/sh
# Start udev daemon for device management
# CRITICAL: This starts udevd as a daemon to populate /dev during boot
# The supervised udevd service will kill this daemon and run supervised

msg "Starting udev daemon"

# Start udevd in daemon mode (will be replaced by supervised version later)
udevd --daemon

# Trigger device events
msg "Triggering udev events"
udevadm trigger --action=add --type=subsystems
udevadm trigger --action=add --type=devices

# Wait for device events to settle
msg "Waiting for udev to settle"
udevadm settle --timeout=60 || msg_warn "udev settle timed out"
