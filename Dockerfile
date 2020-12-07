FROM debian:stretch

ARG ODOO_UID=3328
ARG ODOO_GID=3328
ARG ODOO_HOMEDIR=/var/lib/odoo
ENV ODOO_HOMEDIR=${ODOO_HOMEDIR}

ENV ODOO_DB=odoodb
ENV ODOO_CONF_FILE=${ODOO_HOMEDIR}/odoo.conf
ENV ODOO_UPD_FILE=${ODOO_HOMEDIR}/update.txt
ENV ODOO_REQ_FILE=${ODOO_HOMEDIR}/requirements.txt
ENV ODOO_ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD

ENV POSTGRES_HOST=db
ENV POSTGRES_USER=odoo
ENV POSTGRES_PASSWORD=Us3rP4ssw0rD

RUN apt update && apt -y upgrade && apt -y install \
    build-essential \
    bzip2 \
    curl \
    geoip-database \
    git \
    gnupg \
    libcups2 \
    libcups2-dev \
    libgeoip1 \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libldap2-dev \
    libsasl2-dev \
    locales \
    nano \
    poppler-utils \
    procps \
    python \
    python-pip \
    python-setuptools \
    rsync \
    unzip \
    vim \
    wget

# install utility for wkhtmltox
RUN apt -y install \
    fontconfig \
    libssl-dev \
    libssl-doc \
    xfonts-base \
    xfonts-75dpi \
    libgl1-mesa-glx \
    libqt5core5a \
    libqt5gui5 \
    libqt5network5 \
    libqt5printsupport5 \
    libqt5svg5 \
    libqt5widgets5 \
    libqt5xmlpatterns5 \
    libqt5webkit5

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt -y install nodejs
RUN npm install -g less less-plugin-clean-css

RUN wget -O /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN apt -y install /tmp/wkhtmltox.deb
RUN rm /tmp/wkhtmltox.deb

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update && apt -y upgrade
RUN apt -y install postgresql-client-9.6

RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/share/fonts/truetype/extra
COPY Gotham-Book.otf /usr/share/fonts/truetype/extra/Gotham-Book.otf
RUN fc-cache

RUN echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=it_IT.UTF-8
ENV LANG=it_IT.UTF-8
ENV LANGUAGE=it

RUN groupadd -g ${ODOO_GID} odoo
RUN useradd -m -d /var/lib/odoo -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} odoo
RUN mkdir -p /etc/odoo
RUN chown -R odoo:odoo /etc/odoo /opt

USER root
RUN pip install --upgrade pip
RUN pip install -r https://raw.githubusercontent.com/odoo/odoo/8.0/requirements.txt
RUN pip install \
    asn1crypto \
    codicefiscale \
    email_validator \
    geojson \
    googlemaps==3.0.2 \
    num2words \
    phonenumbers \
    pstats_print2list \
    PyPDF2 \
    pysftp \
    pyxb==1.2.6 \
    Shapely \
    unicodecsv \
    unidecode \
    xlrd \
    xlsxwriter \
    pycups \
    odoorpc

# install utility for afe-connector
RUN pip install pdfkit
RUN apt update && apt -y install xsltproc

RUN pip install git+https://github.com/OCA/openupgradelib.git@master
RUN apt update && apt -y install cabextract
RUN wget http://ftp.br.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb \
    -O /tmp/ttf.deb
RUN dpkg -i /tmp/ttf.deb

USER odoo
WORKDIR /var/lib/odoo
RUN git clone git://github.com/sergiocorato/OCB.git --depth 1 --branch imp_web_float_parse --single-branch /opt/odoo
RUN git clone git://github.com/OCA/account-analytic.git --depth 1 --branch 8.0 --single-branch /opt/account-analytic
RUN git clone git://github.com/OCA/account-closing.git --depth 1 --branch 8.0 --single-branch /opt/account-closing
RUN git clone git://github.com/OCA/account-financial-reporting.git --depth 1 --branch 8.0 --single-branch /opt/account-financial-reporting
RUN git clone git://github.com/OCA/account-financial-tools.git --depth 1 --branch 8.0 --single-branch /opt/account-financial-tools
RUN git clone git://github.com/OCA/account-fiscal-rule.git --depth 1 --branch 8.0 --single-branch /opt/account-fiscal-rule
RUN git clone git://github.com/OCA/account-invoice-reporting.git --depth 1 --branch 8.0 --single-branch /opt/account-invoice-reporting
RUN git clone git://github.com/OCA/account-invoicing.git --depth 1 --branch 8.0 --single-branch /opt/account-invoicing
RUN git clone git://github.com/OCA/account-payment.git --depth 1 --branch 8.0 --single-branch /opt/account-payment
RUN git clone git://github.com/OCA/bank-payment.git --depth 1 --branch 8.0 --single-branch /opt/bank-payment
RUN git clone git://github.com/sergiocorato/commission.git --depth 1 --branch 8.0 --single-branch /opt/commission
RUN git clone git://github.com/OCA/crm.git --depth 1 --branch 8.0 --single-branch /opt/crm
RUN git clone git://github.com/OCA/hr.git --depth 1 --branch 8.0 --single-branch /opt/hr
RUN git clone git://github.com/OCA/hr-timesheet.git --depth 1 --branch 8.0 --single-branch /opt/hr-timesheet
RUN git clone git://github.com/OCA/intrastat.git --depth 1 --branch 8.0 --single-branch /opt/intrastat
RUN git clone git://github.com/OCA/knowledge.git --depth 1 --branch 8.0 --single-branch /opt/knowledge
RUN git clone git://github.com/OCA/manufacture.git --depth 1 --branch 8.0 --single-branch /opt/manufacture
RUN git clone git://github.com/odoomrp/odoomrp-wip.git --depth 1 --branch 8.0 --single-branch /opt/odoomrp-wip
RUN git clone git://github.com/akretion/odoo-usability.git --depth 1 --branch 8.0 --single-branch /opt/odoo-usability
RUN git clone git://github.com/OCA/partner-contact.git --depth 1 --branch 8.0 --single-branch /opt/partner-contact
RUN git clone git://github.com/OCA/product-attribute.git --depth 1 --branch 8.0 --single-branch /opt/product-attribute
RUN git clone git://github.com/OCA/project.git --depth 1 --branch 8.0 --single-branch /opt/project
RUN git clone git://github.com/OCA/purchase-reporting.git --depth 1 --branch 8.0 --single-branch /opt/purchase-reporting
RUN git clone git://github.com/OCA/purchase-workflow.git --depth 1 --branch 8.0 --single-branch /opt/purchase-workflow
RUN git clone git://github.com/OCA/reporting-engine.git --depth 1 --branch 8.0 --single-branch /opt/reporting-engine
RUN git clone git://github.com/OCA/report-print-send.git --depth 1 --branch 8.0 --single-branch /opt/report-print-send
RUN git clone git://github.com/OCA/sale-reporting.git --depth 1 --branch 8.0 --single-branch /opt/sale-reporting
RUN git clone git://github.com/sergiocorato/sale-workflow.git --depth 1 --branch 8.0 --single-branch /opt/sale-workflow
RUN git clone git://github.com/OCA/server-tools.git --depth 1 --branch 8.0 --single-branch /opt/server-tools
RUN git clone git://github.com/OCA/social.git --depth 1 --branch 8.0 --single-branch /opt/social
RUN git clone git://github.com/OCA/stock-logistics-warehouse.git --depth 1 --branch 8.0 --single-branch /opt/stock-logistics-warehouse
RUN git clone git://github.com/OCA/stock-logistics-workflow.git --depth 1 --branch 8.0 --single-branch /opt/stock-logistics-workflow
RUN git clone git://github.com/OCA/web.git --depth 1 --branch 8.0 --single-branch /opt/web
RUN git clone git://github.com/sergiocorato/aeroo_reports.git --depth 1 --branch fix_logger --single-branch /opt/aeroo_reports
RUN git clone git://github.com/it-projects-llc/mail-addons.git --depth 1 --branch 8.0 --single-branch /opt/mail-addons
RUN git clone git://github.com/it-projects-llc/misc-addons.git --depth 1 --branch 8.0 --single-branch /opt/misc-addons
RUN git clone git://github.com/aeroo/aeroolib.git --depth 1 --branch py2.x --single-branch /opt/aeroolib
USER root
RUN cd /opt/aeroolib && python /opt/aeroolib/setup.py install

USER odoo
WORKDIR ${ODOO_HOMEDIR}
EXPOSE 8069 8071 8072
VOLUME ${ODOO_HOMEDIR}

COPY odoo.conf /var/lib/odoo/
COPY run.sh /run.sh
CMD /bin/bash /run.sh
