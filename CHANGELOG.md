# Changelog - Runit for LFS

All notable changes and fixes discovered during testing and deployment.

## Version 3.2 - Final Release (2025-11-17)

### The Pragmatic Solution - Simple Scripts That Work

**Problem with v3.1:**
- Compiled halt/reboot binaries from void-runit had dynamic linker issues on LFS
- "No such file or directory" errors despite binaries being present
- Complex solution fighting with library dependencies

**The Simple Solution:**
Sometimes the best solution is the simplest one. Instead of fighting with compiled binaries and dynamic linking, we created simple shell scripts that directly call `/etc/runit/3` with the appropriate control file settings.

**How it works:**
```bash
# For reboot:
chmod 100 /run/runit/reboot  # Make executable = reboot mode
exec /etc/runit/3

# For halt/poweroff/shutdown:
chmod 000 /run/runit/reboot  # Not executable = halt mode
exec /etc/runit/3
```

**New scripts:**
- `/sbin/halt` - Simple script, sets control file and calls stage 3
- `/sbin/poweroff` - Same as halt (poweroff = halt)
- `/sbin/reboot` - Sets reboot mode and calls stage 3
- `/sbin/shutdown` - Wrapper with argument parsing (-r for reboot, -h for halt)

**Philosophy:**
This is the LFS way - understand how the system works, keep it simple, and make it work for YOU. No unnecessary complexity, no fighting with pre-compiled binaries. Just clean, readable shell scripts that do exactly what they need to do.

### Credits
- Inspired by debugging Void Linux's implementation
- Perfected through pragmatic LFS problem-solving

## Version 3.1 - Attempted Release (2025-11-17) - DO NOT USE

### Critical Fix - Proper Shutdown Implementation

**Problem with v3.0:**
- Wrapper scripts called `/etc/runit/3` directly, causing shutdown loops
- System would boot directly into shutdown mode
- halt/shutdown commands were non-functional

**Solution:**
- Adopted Void Linux's proven approach
- Compiled `halt.c` from void-runit repository
- halt/poweroff/reboot binaries call `/bin/runit-init 0` or `/bin/runit-init 6`
- Adopted Void's shutdown shell script

**How it works:**
- halt/poweroff: Execute `/bin/runit-init 0` (runlevel 0 = halt)
- reboot: Executes `/bin/runit-init 6` (runlevel 6 = reboot)
- runit-init then properly initiates stage 3 shutdown
- Stage 3 checks `/run/runit/reboot` permissions (000=halt, 100=reboot)

**New binaries:**
- `/sbin/halt` - Compiled from void-runit/halt.c (statically linked)
- `/sbin/poweroff` - Same binary as halt (checks argv[0])
- `/sbin/reboot` - Same binary as halt (checks argv[0])
- `/sbin/shutdown` - Void's shell script wrapper

### Credits
- Source: https://github.com/void-linux/void-runit
- Void Linux team for the robust implementation

## Version 3.0 - Attempted Release (2025-11-17) - DO NOT USE

### Major Fixes

#### Shutdown System
- **Fixed kernel panic during shutdown** - Changed service stop method to avoid killing runit itself
- **Fixed hanging shutdown** - Reduced timeout from 196s to intelligent process-based killing
- **Fixed stopit file blocking shutdown** - Removed automatic creation of stopit file during boot
- **Added fallback shutdown methods** - Uses sysrq if reboot/halt commands unavailable

#### Service Management
- **Fixed getty/agetty naming inconsistency** - All getty services now properly named agetty-tty*
- **Added log supervision** - All services now have proper log/run scripts using svlogd
- **Excluded problematic services** - syslogd and avahi-dnsconfd not included (cause fork bombs/conflicts)

#### Boot Process
- **Fixed control file paths** - Stage 3 now correctly checks /run/runit/reboot
- **Improved error handling** - Better detection and handling of missing commands

### New Features

#### Wrapper Scripts
Added wrapper scripts for systems without reboot/shutdown commands:
- `/sbin/reboot` - Reboot system via runit
- `/sbin/halt` - Halt system via runit
- `/sbin/poweroff` - Power off system via runit
- `/sbin/shutdown` - Basic shutdown wrapper (supports -r and -h)

#### Installation
- **apply-fixes-v2.sh** - Automated script to update existing installations
- **Enhanced install.sh** - Better error checking and user feedback

### Testing
- Tested on fresh LFS system
- Boot verified working
- Shutdown/reboot cycles verified
- Service supervision verified
- Desktop environment compatibility confirmed (Qtile/Hyprland)

### Known Issues Resolved
- ✓ Fork bomb from syslogd (excluded from package)
- ✓ Service conflicts with stage 1 scripts (proper handoff implemented)
- ✓ Kernel panic on shutdown (fixed service stop procedure)
- ✓ Hanging shutdown on getty processes (aggressive but safe killing)
- ✓ Missing reboot/shutdown commands (wrapper scripts provided)

## Version 2.1 (2025-11-17)

### Fixes
- Updated shutdown timeout from 196s to 10s
- Fixed stopit file creation blocking shutdown
- Improved stage 3 shutdown script

## Version 2.0 (2025-11-16)

### Fixes
- Renamed getty services to agetty
- Fixed service symlinks
- Added reboot/shutdown wrappers

## Version 1.0 (2025-11-16)

### Initial Release
- Complete runit installation package
- 9 compiled binaries
- Stage scripts (1, 2, 3)
- 9 core-services boot scripts
- 7 shutdown scripts
- 10 pre-configured services
- Automated installation script

### Based On
- Successful sysvinit-to-runit migration
- Configuration adapted from Void Linux
- Runit 2.1.2 compiled from source
- Tested on LFS-based system
