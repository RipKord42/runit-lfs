#!/bin/sh
# Miscellaneous initialization tasks

msg "Miscellaneous initialization"

# Create /run/utmp
install -m 0664 -g utmp /dev/null /run/utmp 2>/dev/null || true

# Initialize wtmp
if command -v halt >/dev/null 2>&1; then
    halt -B 2>/dev/null || true
fi

# Seed random number generator
if [ -f /var/lib/random-seed ]; then
    cat /var/lib/random-seed > /dev/urandom 2>/dev/null || true
fi

# Bring up loopback interface
if command -v ip >/dev/null 2>&1; then
    ip link set lo up 2>/dev/null || true
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig lo up 2>/dev/null || true
fi

# Set hostname
if [ -f /etc/hostname ]; then
    read hostname < /etc/hostname
    hostname "$hostname" 2>/dev/null || true
fi
