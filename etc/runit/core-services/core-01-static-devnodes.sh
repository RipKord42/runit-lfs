#!/bin/sh
# Load kernel modules for static device nodes

if command -v kmod >/dev/null 2>&1; then
    msg "Loading kernel modules for static device nodes"
    kmod static-nodes --format=tmpfiles --output=/run/tmpfiles.d/kmod.conf 2>/dev/null || true

    if [ -f /run/tmpfiles.d/kmod.conf ]; then
        while read type path mode user group age arg; do
            [ "$type" = "c" -o "$type" = "b" ] || continue
            modprobe -q "$arg" 2>/dev/null || true
        done < /run/tmpfiles.d/kmod.conf
    fi
fi
