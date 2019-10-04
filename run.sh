#!/bin/bash

sed -i "/^admin_passwd/c\admin_passwd=$ODOO_ADMIN_PASSWD" $ODOO_CONF_FILE

if [ -f "$ODOO_UPD_FILE" ]; then
    /opt/odoo/openerp-server --data-dir=$ODOO_HOMEDIR/data_dir --config=$ODOO_CONF_FILE --database=$ODOO_DB --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD \
    --update=$(< $ODOO_UPD_FILE) --load-language=it_IT --i18n-overwrite --workers=0 --stop-after-init
    mkdir -p $ODOO_HOMEDIR/setup
    mv $ODOO_UPD_FILE $ODOO_HOMEDIR/setup/odoo-modules-updated-on-`date +%y%m%d`-at-`date +%H%M%S`.txt
fi

/opt/odoo/openerp-server --data-dir=$ODOO_HOMEDIR/data_dir --config=$ODOO_CONF_FILE --database=$ODOO_DB --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD
