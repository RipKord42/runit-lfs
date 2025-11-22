#!/bin/sh
# Kill remaining processes

msg "Terminating remaining processes"

# Send TERM signal to all processes except session 0 and 1
pkill --inverse -s0,1 -TERM 2>/dev/null || true

# Wait a moment for graceful shutdown
sleep 1

# Send KILL signal to stubborn processes
msg "Killing remaining processes"
pkill --inverse -s0,1 -KILL 2>/dev/null || true
