
# Runit Init Deployment Package for LFS Systems

This package contains a complete, distributable, tested (to an extent) runit init system installation for Linux From Scratch (LFS) systems, ready to replace sysvinit.  While intended for LFS systems, this could very likely work for many systems to replace the init system. Obviously, attempt carefully and at your own risk.

Notes and Disclaimers:

- This was built on installations using LFS version 12.4 instructions and software versions. It may work with others depending on GCC and glibc versions.
- The included Runit binaries were compiled from the Void Linux runit source - credit and attribution to that team.  Compliation was complicated, requiring many patches to build properly.  This was due to my LFS system having newer versions of glibc (2.42) and GCC (15.2) than the Void source expected so this is no reflection at all on the Void code. Therefore I'm currently only providing the binaries here. I will post another repository of the patched source for anyone interested.
- Construction full disclosure: I am not a developer, I am just a 30 year long Linux tinkerer.  This project was my stubborn brain hammering away with Claude writing the code to support it.  Please do feel free to ask any questions and the development team (Claude and me) will do our best.
- Contribution welcomed. Runit is a fantastic init system and I'd ultimately love to be able to plop this just about anywhere.
- In case it's not obvious, install at your own risk.  This may very well break your system.


## What's Included

- **Binaries**: All runit binaries compiled from source (runit-init, runit, sv, runsv, runsvdir, etc.)
- **Configuration**: Stage scripts (1, 2, 3) and boot/shutdown scripts
- **Services**: Pre-configured service definitions with logging
- **Installation script**: Automated installation with safety checks

## Prerequisites

- LFS or BLFS-based system (feel try to try on other types of test systems)
- Currently running sysvinit
- Root access
- Basic services already configured (udev, dbus, etc.)

## Quick Start

1. **Extract the package:**
   ```bash
   tar xzf runit-deployment-package.tar.gz
   cd runit-deployment-package
   ```

2. **Run the installation script:**
   ```bash
   sudo ./install.sh
   ```

3. **Enable essential services:**
   ```bash
   ln -s /etc/sv/udevd /var/service/
   ln -s /etc/sv/dbus /var/service/
   ln -s /etc/sv/elogind /var/service/
   ln -s /etc/sv/sshd /var/service/
   ln -s /etc/sv/getty-tty1 /var/service/
   ln -s /etc/sv/getty-tty2 /var/service/
   ```

Note: These are just the service files, the underlying software will be required. Many more service files are available. See etc/sv/extras. They should be generally standard and agnostic to the system but YMMV so check them out for accuracy. 

**WARNING: THIS IS THE BREAK YOUR SYSTEM PART. GRAB A COFFEE, THINK ABOUT IT, AND BE CAREFUL OUT THERE**

4. **Activate runit:**
   ```bash
   rm /sbin/init
   ln -s /sbin/runit-init /sbin/init
   ```

5. **Reboot and test**

## Service Definitions

### Essential Services Included

- **udevd** - Device management (REQUIRED)
- **dbus** - System message bus (REQUIRED for desktop)
- **elogind** - Session management (REQUIRED for desktop)
- **sshd** - SSH server
- **getty-tty1 to getty-tty6** - Login terminals

### Service Management

Enable a service:
```bash
ln -s /etc/sv/SERVICE /var/service/
```

Disable a service:
```bash
rm /var/service/SERVICE
```

Check service status:
```bash
sv status /var/service/SERVICE
```

Start/stop/restart service:
```bash
sv up /var/service/SERVICE
sv down /var/service/SERVICE
sv restart /var/service/SERVICE
```

## Boot Process

### Stage 1: System Initialization
Location: `/etc/runit/1`

Runs core-services scripts in order:
1. **core-00-pseudofs.sh** - Mount /proc, /sys, /dev, /run
2. **core-01-static-devnodes.sh** - Load kernel modules for device nodes
3. **core-02-kmods.sh** - Load kernel modules from /etc/modules*
4. **core-02-udev.sh** - Start udev daemon and trigger device events
5. **core-03-consolefont.sh** - Set console font
6. **core-03-filesystems.sh** - Mount filesystems from /etc/fstab
7. **core-04-swap.sh** - Enable swap
8. **core-05-misc.sh** - Miscellaneous initialization (utmp, random seed, loopback, hostname)
9. **core-05-network.sh** - Configure network (calls /etc/init.d/network)
10. **core-06-netfs.sh** - Mount network filesystems
11. **core-08-sysctl.sh** - Load sysctl settings
12. **core-10-runit-control.sh** - Create runit control files
13. **core-99-cleanup.sh** - Clean temporary directories

### Stage 2: Service Supervision
Location: `/etc/runit/2`

Starts runsvdir which supervises all services in `/var/service/`

### Stage 3: Shutdown
Location: `/etc/runit/3`

Runs shutdown scripts in order:
1. **shutdown-10-sv-stop.sh** - Stop all supervised services
2. **shutdown-30-random.sh** - Save random seed
3. **shutdown-40-hwclock.sh** - Save hardware clock
4. **shutdown-50-wtmp.sh** - Update wtmp
5. **shutdown-60-udev.sh** - Stop udev
6. **shutdown-70-pkill.sh** - Terminate remaining processes
7. **shutdown-80-filesystems.sh** - Unmount filesystems

## Adding New Services

Create a service directory:
```bash
mkdir -p /etc/sv/myservice/log
```

Create the main run script (`/etc/sv/myservice/run`):
```bash
#!/bin/sh
exec 2>&1
exec /path/to/daemon --foreground
```

Create the log run script (`/etc/sv/myservice/log/run`):
```bash
#!/bin/sh
exec svlogd -tt ./main
```

Make scripts executable:
```bash
chmod 755 /etc/sv/myservice/run
chmod 755 /etc/sv/myservice/log/run
mkdir -p /etc/sv/myservice/log/main
```

Enable the service:
```bash
ln -s /etc/sv/myservice /var/service/
```

## Logging

Service logs are stored in `/etc/sv/SERVICE/log/main/current`

View logs:
```bash
cat /etc/sv/SERVICE/log/main/current
# or for live viewing:
tail -f /etc/sv/SERVICE/log/main/current
```

## Rollback

If you need to rollback to sysvinit:

```bash
rm /sbin/init
ln -s /sbin/init.sysvinit /sbin/init
reboot
```

Your original sysvinit is backed up at `/sbin/init.sysvinit`

There is currently no rollback built for other init systems, but you get the idea here. Get init linked back to whatever your origninal init was.

## Troubleshooting

### System won't boot
1. Boot from rescue disk
2. Mount your root partition
3. Chroot into your system
4. Run rollback procedure above
5. Reboot

### Services won't start
Check service status:
```bash
sv status /var/service/SERVICE
```

View service logs:
```bash
cat /etc/sv/SERVICE/log/main/current
```

Test service script manually:
```bash
/etc/sv/SERVICE/run
```
(Press Ctrl+C to stop)

### Udev issues
Make sure udevd service is enabled FIRST before other services:
```bash
ls -la /var/service/udevd
```

### Desktop not working
Ensure these services are running:
- udevd
- dbus
- elogind

Check with:
```bash
sv status /var/service/{udevd,dbus,elogind}
```

## Important Notes

### DO NOT

- ❌ Delete /sbin/init.sysvinit (your rollback backup)
- ❌ Enable services that conflict with stage 1 scripts

### DO

- ✓ Test thoroughly before committing
- ✓ Keep /sbin/init.sysvinit as rollback
- ✓ Use service-specific logging (svlogd)
- ✓ Enable services one at a time and test

## Credits

runit project: https://smarden.org/runit/
runit project from Void Linux https://github.com/void-linux/runit


## Support

For issues specific to this package, refer to the migration log included in your source system.

For runit documentation: http://smarden.org/runit/

---

**Last Updated:** November 2025
**Tested On:** LFS-based custom system
**Runit Version:** 2.1.2 (compiled from source)
