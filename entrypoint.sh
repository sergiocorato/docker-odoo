#!/bin/bash

set -e

sed -i "/^admin_passwd/c\admin_passwd=$ADMIN_PASSWD" "$ODOO_CONF"

ln -s /etc/supervisor/supervisord.conf /etc/supervisord.conf

if [ -z "$*" ]; then
  exec /usr/local/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
fi
exec /usr/local/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf --nodaemon
