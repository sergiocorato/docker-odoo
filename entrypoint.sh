#!/bin/bash

set -e

if [ -z "$*" ]; then
  exec /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin "$@"
fi
exec /usr/local/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf --nodaemon
