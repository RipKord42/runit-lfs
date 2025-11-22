#!/bin/sh
# Stop all supervised services

msg "Stopping supervised services"

# Kill runsvdir (the supervisor) - this will stop all service supervision
pkill -TERM runsvdir 2>/dev/null || true
sleep 1

# Kill all runsv processes (individual service supervisors)
pkill -TERM runsv 2>/dev/null || true
sleep 1

# Now kill the actual services (but not runit itself!)
# Kill everything except PID 1 and our current shell
for pid in /var/service/*/supervise/pid; do
    if [ -f "$pid" ]; then
        SERVICE_PID=$(cat "$pid" 2>/dev/null)
        if [ -n "$SERVICE_PID" ] && [ "$SERVICE_PID" != "1" ] && [ "$SERVICE_PID" != "$$" ]; then
            kill -TERM "$SERVICE_PID" 2>/dev/null || true
        fi
    fi
done

sleep 2

# Force kill any that didn't die
for pid in /var/service/*/supervise/pid; do
    if [ -f "$pid" ]; then
        SERVICE_PID=$(cat "$pid" 2>/dev/null)
        if [ -n "$SERVICE_PID" ] && [ "$SERVICE_PID" != "1" ] && [ "$SERVICE_PID" != "$$" ]; then
            kill -KILL "$SERVICE_PID" 2>/dev/null || true
        fi
    fi
done

msg "All services stopped"
