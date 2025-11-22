#!/bin/sh
# Configure network interfaces

if [ -x /etc/init.d/network ]; then
    msg "Configuring network"
    /etc/init.d/network start 2>/dev/null || msg_warn "Network configuration failed"
fi
