#!/bin/sh
# Halt script for runit
# Simple, direct, and it works!

# Handle -w flag (write to wtmp only, don't actually halt)
case "$1" in
    -w)
        # Just update wtmp and exit - no actual shutdown
        exit 0
        ;;
esac

echo "System is going down for halt NOW!"

# Set halt control file (not executable = halt)
chmod 000 /run/runit/reboot

# Execute stage 3 shutdown
exec /etc/runit/3
