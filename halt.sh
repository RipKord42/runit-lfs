#!/bin/sh
# Halt script for runit

# Handle -w/-B flag (write to wtmp only, don't actually halt)
case "$1" in
    -w|-B)
        exit 0
        ;;
esac

echo "System is going down for halt NOW!"

# Signal halt by writing "halt" to control file
# (Using file content instead of chmod because /run may be mounted noexec)
echo "halt" > /run/runit/reboot

# Execute stage 3 shutdown
exec /etc/runit/3
