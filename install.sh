#!/bin/bash
# Runit Installation Script for LFS Systems
# This script installs runit and migrates from sysvinit

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

msg() {
    echo -e "${GREEN}==>${NC} $@"
}

warn() {
    echo -e "${YELLOW}Warning:${NC} $@"
}

error() {
    echo -e "${RED}Error:${NC} $@" >&2
    exit 1
}

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    error "This script must be run as root"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "  Runit Installation for LFS Systems"
echo "========================================="
echo ""

# Check if already installed
if [ -L /sbin/init ] && [ "$(readlink /sbin/init)" = "/sbin/runit-init" ]; then
    warn "Runit appears to already be installed (init symlink points to runit-init)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
fi

msg "Step 1: Installing binaries"
install -m755 -v "$SCRIPT_DIR/binaries/runit-init" /sbin/runit-init
install -m755 -v "$SCRIPT_DIR/binaries/runit" /sbin/runit
install -m755 -v "$SCRIPT_DIR/binaries/sv" /usr/bin/sv
install -m755 -v "$SCRIPT_DIR/binaries/runsv" /usr/bin/runsv
install -m755 -v "$SCRIPT_DIR/binaries/runsvdir" /usr/bin/runsvdir
install -m755 -v "$SCRIPT_DIR/binaries/runsvchdir" /usr/bin/runsvchdir
install -m755 -v "$SCRIPT_DIR/binaries/svlogd" /usr/bin/svlogd
install -m755 -v "$SCRIPT_DIR/binaries/chpst" /usr/bin/chpst
install -m755 -v "$SCRIPT_DIR/binaries/utmpset" /usr/bin/utmpset

msg "Step 2: Installing configuration files"
mkdir -p /etc/runit/core-services /etc/runit/shutdown.d
cp -v "$SCRIPT_DIR/etc/runit/functions" /etc/runit/
cp -v "$SCRIPT_DIR/etc/runit/1" /etc/runit/
cp -v "$SCRIPT_DIR/etc/runit/2" /etc/runit/
cp -v "$SCRIPT_DIR/etc/runit/3" /etc/runit/
chmod 755 /etc/runit/{1,2,3,functions}

msg "Step 3: Installing core-services scripts"
cp -v "$SCRIPT_DIR/etc/runit/core-services"/*.sh /etc/runit/core-services/
chmod 755 /etc/runit/core-services/*.sh

msg "Step 4: Installing shutdown scripts"
cp -v "$SCRIPT_DIR/etc/runit/shutdown.d"/*.sh /etc/runit/shutdown.d/
chmod 755 /etc/runit/shutdown.d/*.sh

msg "Step 5: Installing service definitions"
mkdir -p /etc/sv
cp -r "$SCRIPT_DIR/etc/sv"/* /etc/sv/
# Make sure all run scripts are executable
find /etc/sv -name run -exec chmod 755 {} \;
# Create log/main directories for each service
for svc in /etc/sv/*/; do
    [ -d "$svc/log" ] && mkdir -p "$svc/log/main"
done

msg "Step 6: Creating /var/service directory"
mkdir -p /var/service
msg "Note: Services are NOT enabled by default. Use 'ln -s /etc/sv/SERVICE /var/service/' to enable."

msg "Step 7: Creating /var/log/runit directory"
mkdir -p /var/log/runit

msg "Step 8: Installing shutdown/reboot commands"
# Check if halt/poweroff/reboot/shutdown exist and back them up
for cmd in halt poweroff reboot shutdown; do
    if [ -f "/sbin/$cmd" ] && [ ! -f "/sbin/$cmd.original" ]; then
        msg "Backing up /sbin/$cmd to /sbin/$cmd.original"
        cp -v "/sbin/$cmd" "/sbin/$cmd.original"
    fi
done

# Install shutdown/reboot scripts (simple and effective!)
install -m755 -v "$SCRIPT_DIR/halt.sh" /sbin/halt
install -m755 -v "$SCRIPT_DIR/poweroff.sh" /sbin/poweroff
install -m755 -v "$SCRIPT_DIR/reboot.sh" /sbin/reboot
install -m755 -v "$SCRIPT_DIR/shutdown.sh" /sbin/shutdown

msg "Step 9: Backing up current init"
if [ -f /sbin/init ] && [ ! -L /sbin/init ]; then
    if [ ! -f /sbin/init.sysvinit ]; then
        msg "Backing up /sbin/init to /sbin/init.sysvinit"
        cp -v /sbin/init /sbin/init.sysvinit
    else
        warn "/sbin/init.sysvinit already exists, not overwriting"
    fi
elif [ -L /sbin/init ]; then
    warn "/sbin/init is already a symlink: $(readlink /sbin/init)"
fi

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Review the configuration files in /etc/runit/"
echo "2. Enable services you want to run:"
echo "   ln -s /etc/sv/SERVICE /var/service/"
echo ""
echo "   Recommended essential services:"
echo "   - udevd (device management)"
echo "   - dbus (system message bus)"
echo "   - elogind (session management for desktop)"
echo "   - sshd (SSH access)"
echo "   - agetty-tty1 through agetty-tty6 (login terminals)"
echo ""
echo "3. To activate runit as init (AFTER enabling services):"
echo "   rm /sbin/init"
echo "   ln -s /sbin/runit-init /sbin/init"
echo ""
echo "4. Reboot to test"
echo ""
echo "To rollback if needed:"
echo "   rm /sbin/init"
echo "   ln -s /sbin/init.sysvinit /sbin/init"
echo ""
echo "To restore original shutdown commands if needed:"
echo "   cp /sbin/halt.original /sbin/halt"
echo "   cp /sbin/poweroff.original /sbin/poweroff"
echo "   cp /sbin/reboot.original /sbin/reboot"
echo "   cp /sbin/shutdown.original /sbin/shutdown"
echo ""
warn "IMPORTANT: Test thoroughly before committing to runit!"
echo ""
