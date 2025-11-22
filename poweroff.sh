#!/bin/sh
# Poweroff script for runit
# Simple, direct, and it works!

# Handle -w flag (write to wtmp only, don't actually poweroff)
case "$1" in
    -w)
        # Just update wtmp and exit - no actual shutdown
        exit 0
        ;;
esac

echo "System is going down for poweroff NOW!"

# Set halt control file (not executable = poweroff/halt)
chmod 000 /run/runit/reboot

# Execute stage 3 shutdown
exec /etc/runit/3
