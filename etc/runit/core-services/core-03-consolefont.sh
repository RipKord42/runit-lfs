#!/bin/sh
# Set console font if available

if [ -x /etc/init.d/consolefont ]; then
    msg "Setting console font"
    /etc/init.d/consolefont start 2>/dev/null || true
fi
