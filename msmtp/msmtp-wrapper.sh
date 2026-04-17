#!/bin/sh
# Load environment from file created at container startup
if [ -f /etc/msmtp/.env ]; then
    . /etc/msmtp/.env
fi
exec /usr/bin/msmtp "$@"
