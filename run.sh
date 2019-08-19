#!/bin/bash

if [ -f $REQ_FILE ]; then
    pip install --pre --user --upgrade -r $REQ_FILE
    mkdir -p $ODOO_DATADIR/setup
    mv $REQ_FILE $ODOO_DATADIR/setup/requirements-installed-on-`date +%y%m%d`-at-`date +%H%M%S`.txt
fi

if [ -f $UPD_FILE ]; then
    /opt/odoo/openerp-server --config=$ODOO_CONF -u $(< $UPD_FILE) -d $ODOO_DB --load-language=it_IT --i18n-overwrite --workers=0 --stop-after-init
    mkdir -p $ODOO_DATADIR/setup
    mv $UPD_FILE $ODOO_DATADIR/setup/updated-modules-on-`date +%y%m%d`-at-`date +%H%M%S`.txt
fi

/usr/local/bin/odoo --config=$ODOO_CONF
