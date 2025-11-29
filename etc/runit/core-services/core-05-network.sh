#!/bin/sh
# Configure network interfaces (LFS style)

msg "Configuring network interfaces"

# Check if default route already exists (network already configured)
if ip route | grep -q "^default"; then
    msg "Network already configured, skipping"
    return 0 2>/dev/null || exit 0
fi

# Start all network interfaces using LFS ifup
for file in /etc/sysconfig/ifconfig.*; do
    interface=${file##*/ifconfig.}

    # Skip if no files found (glob returned literal *)
    [ "${interface}" = "*" ] && continue

    if [ -x /sbin/ifup ]; then
        msg "Bringing up ${interface}"
        /sbin/ifup ${interface} 2>/dev/null || msg_warn "Failed to bring up ${interface}"
    fi
done
