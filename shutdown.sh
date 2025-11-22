#!/bin/sh
# Shutdown script for runit
# Simple implementation - handles basic shutdown and reboot

ACTION="halt"

# Parse basic arguments
case "$1" in
    -r|--reboot) ACTION="reboot" ;;
    -h|--halt|-P|--poweroff) ACTION="halt" ;;
    -H) ACTION="halt" ;;
    --help)
        echo "Usage: shutdown [-r|--reboot] [-h|--halt] [-P|--poweroff]"
        echo "  -r, --reboot    Reboot the system"
        echo "  -h, --halt      Halt the system"
        echo "  -P, --poweroff  Power off the system"
        exit 0
        ;;
esac

echo "System is going down NOW!"

if [ "$ACTION" = "reboot" ]; then
    chmod 100 /run/runit/reboot
else
    chmod 000 /run/runit/reboot
fi

# Execute stage 3 shutdown
exec /etc/runit/3
