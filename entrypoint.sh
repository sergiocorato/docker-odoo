#!/bin/bash

set -e

sed -i "/^admin_passwd/c\admin_passwd=$ADMIN_PASSWD" $ODOO_CONF
sed -i "/^addons_path/c\addons_path=$ADDONS_PATH" $ODOO_CONF

if [ -z "$@" ]; then
  exec /usr/local/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi
