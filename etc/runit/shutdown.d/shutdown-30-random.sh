#!/bin/sh
# Save random seed

if [ -x /etc/init.d/random ]; then
    msg "Saving random seed"
    /etc/init.d/random stop 2>/dev/null || true
else
    # Simple random seed save if init script not available
    if [ -w /var/lib/random-seed ]; then
        dd if=/dev/urandom of=/var/lib/random-seed count=1 bs=512 2>/dev/null || true
    fi
fi
