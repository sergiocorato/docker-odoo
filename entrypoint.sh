#!/bin/bash

set -e


# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the openerp process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='database'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='openerp'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='openerp'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$OPENERP_SERVER" ; then
	DB_ARGS+=("--${param}")
	DB_ARGS+=("${value}")
    fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    -- | openerp-server)
	shift
	if [[ "$1" == "scaffold" ]] ; then
	    exec python /opt/openerp/server/openerp-server  "$@"
	else
	    exec python /opt/openerp/server/openerp-server  "$@" "${DB_ARGS[@]}"
	fi
	;;
    -*)
	exec python /opt/openerp/server/openerp-server  "$@" "${DB_ARGS[@]}"
	;;
    *)
	exec "$@"
esac

exit 1
