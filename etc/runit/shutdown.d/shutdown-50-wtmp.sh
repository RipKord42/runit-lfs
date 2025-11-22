#!/bin/sh
# Update wtmp for shutdown

if command -v halt >/dev/null 2>&1; then
    msg "Updating wtmp"
    halt -w 2>/dev/null || true
fi
