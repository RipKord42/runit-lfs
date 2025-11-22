#!/bin/sh
# Clean temporary directories

msg "Cleaning temporary directories"

# Clean /tmp (preserve some special files/directories)
find /tmp -mindepth 1 -maxdepth 1 ! -name '.X11-unix' ! -name '.ICE-unix' ! -name '.font-unix' -exec rm -rf {} + 2>/dev/null || true

# Clean /var/run if it's not a symlink to /run
if [ ! -L /var/run ] && [ -d /var/run ]; then
    find /var/run -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
fi
