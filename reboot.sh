#!/bin/sh
# Reboot script for runit

# Handle -w/-B flag (write to wtmp only, don't actually reboot)
case "$1" in
    -w|-B)
        exit 0
        ;;
esac

echo "System is going down for reboot NOW!"

# Signal reboot by writing "reboot" to control file
# (Using file content instead of chmod because /run may be mounted noexec)
echo "reboot" > /run/runit/reboot

# Execute stage 3 shutdown
exec /etc/runit/3
