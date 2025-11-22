#!/bin/sh
# Create runit control files

msg "Creating runit control files"

mkdir -p /run/runit

# Create reboot control file (mode 000 = halt, mode 100 = reboot)
touch /run/runit/reboot
chmod 000 /run/runit/reboot

# Do NOT create stopit file - it prevents shutdown
# Only create it manually in emergencies
