#!/bin/sh
# Write environment variables to a file for msmtp wrapper
cat > /etc/msmtp/.env << ENVEOF
export CLIENT_ID="${CLIENT_ID}"
export CLIENT_SECRET="${CLIENT_SECRET}"
export TENANT_ID="${TENANT_ID}"
export MAIL_ADDRESS="${MAIL_ADDRESS}"
ENVEOF
chmod 644 /etc/msmtp/.env

sed -i -e 's/MAIL_ADDRESS/'"$MAIL_ADDRESS"'/' /etc/msmtprc
postconf -e "mynetworks=${MYNETWORKS}"

# Execute the CMD
exec "$@"