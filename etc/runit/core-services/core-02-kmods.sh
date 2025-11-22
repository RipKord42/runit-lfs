#!/bin/sh
# Load kernel modules from configuration files

msg "Loading kernel modules"

# Load from /etc/modules-load.d/*.conf
if [ -d /etc/modules-load.d ]; then
    for conf in /etc/modules-load.d/*.conf; do
        [ -f "$conf" ] || continue
        while read module; do
            # Skip comments and empty lines
            case "$module" in
                \#*|"") continue ;;
            esac
            modprobe -q "$module" 2>/dev/null || msg_warn "Failed to load module: $module"
        done < "$conf"
    done
fi

# Load from /etc/modules (LFS compatibility)
if [ -f /etc/modules ]; then
    while read module; do
        case "$module" in
            \#*|"") continue ;;
        esac
        modprobe -q "$module" 2>/dev/null || msg_warn "Failed to load module: $module"
    done < /etc/modules
fi
