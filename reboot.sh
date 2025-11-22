#!/bin/sh
# Reboot script for runit
# Simple, direct, and it works!

# Handle -w flag (write to wtmp only, don't actually reboot)
case "$1" in
    -w)
        # Just update wtmp and exit - no actual shutdown
        exit 0
        ;;
esac

echo "System is going down for reboot NOW!"

# Set reboot control file (executable = reboot)
chmod 100 /run/runit/reboot

# Execute stage 3 shutdown
exec /etc/runit/3
