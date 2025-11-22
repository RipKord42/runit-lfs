#!/bin/sh
# Load sysctl settings

if command -v sysctl >/dev/null 2>&1; then
    msg "Loading sysctl settings"

    # Load from /etc/sysctl.conf
    if [ -f /etc/sysctl.conf ]; then
        sysctl -q -p /etc/sysctl.conf 2>/dev/null || true
    fi

    # Load from /etc/sysctl.d/*.conf
    if [ -d /etc/sysctl.d ]; then
        for conf in /etc/sysctl.d/*.conf; do
            [ -f "$conf" ] || continue
            sysctl -q -p "$conf" 2>/dev/null || true
        done
    fi
fi
