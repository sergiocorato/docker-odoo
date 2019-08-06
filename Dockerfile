FROM debian:stretch

ARG ODOO_UID=1000
ARG ODOO_GID=1000

ENV ODOO_DATADIR=/var/lib/odoo
ENV ODOO_CONF=/var/lib/odoo/odoo.conf

ENV UPD_FILE=/var/lib/odoo/update.txt
ENV ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD
ENV POSTGRES_HOST=db
ENV POSTGRES_USER=odoo
ENV POSTGRES_PASSWORD=Us3rP4ssw0rD

RUN apt update && apt -y upgrade && apt -y install \
    apt-utils \
    aptitude \
    apt-transport-https \
    build-essential \
    bzip2 \
    curl \
    gdebi \
    geoip-database \
    git \
    gnupg \
    htop \
    libcups2 \
    libcups2-dev \
    libgeoip1 \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libldap2-dev \
    libsasl2-dev \
    locales \
    locate  \
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

RUN wget http://ftp.fr.debian.org/debian/pool/main/libp/libpng/\
libpng12-0_1.2.50-2+deb8u3_amd64.deb -O /tmp/libpng.deb
RUN dpkg -i /tmp/libpng.deb
RUN wget http://security.debian.org/debian-security/pool/updates/main/o/\
openssl/libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb -O /tmp/libssl.deb
RUN dpkg -i /tmp/libssl.deb

RUN wget -O /tmp/wkhtmltox.deb \
    https://nightly.odoo.com/extra/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb
RUN gdebi -n /tmp/wkhtmltox.deb
RUN cp /usr/local/bin/wkhtmlto* /usr/bin/

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
    geojson \
    googlemaps \
    num2words \
    openupgradelib \
    phonenumbers \
    pstats_print2list \
    PyPDF2 \
    pysftp \
    pyxb==1.2.5 \
    Shapely \
    unicodecsv \
    unidecode \
    xlrd \
    xlsxwriter

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
RUN git clone git://github.com/OCA/commission.git --depth 1 --branch 8.0 --single-branch /opt/commission
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
RUN git clone git://github.com/efatto/sale-workflow.git --depth 1 --branch 8.0-fix_sale_rental_move_in_missing --single-branch /opt/sale-workflow
RUN git clone git://github.com/OCA/server-tools.git --depth 1 --branch 8.0 --single-branch /opt/server-tools
RUN git clone git://github.com/OCA/social.git --depth 1 --branch 8.0 --single-branch /opt/social
RUN git clone git://github.com/OCA/stock-logistics-warehouse.git --depth 1 --branch 8.0 --single-branch /opt/stock-logistics-warehouse
RUN git clone git://github.com/OCA/stock-logistics-workflow.git --depth 1 --branch 8.0 --single-branch /opt/stock-logistics-workflow
RUN git clone git://github.com/OCA/web.git --depth 1 --branch 8.0 --single-branch /opt/web
RUN git clone git://github.com/sergiocorato/aeroo_reports.git --depth 1 --branch fix_logger --single-branch /opt/aeroo_reports
RUN git clone git://github.com/it-projects-llc/mail-addons.git --depth 1 --branch 8.0 --single-branch /opt/mail-addons
RUN git clone git://github.com/it-projects-llc/misc-addons.git --depth 1 --branch 8.0 --single-branch /opt/misc-addons
RUN git clone git://github.com/efatto/efatto.git --depth 1 --branch 8.0 --single-branch /opt/e-efatto
RUN git clone git://github.com/efatto/l10n-italy.git --depth 1 --branch 8.0 --single-branch /opt/l10n-italy

USER root
RUN git clone git://github.com/aeroo/aeroolib.git --depth 1 --branch py2.x --single-branch /tmp/aeroolib
RUN python /tmp/aeroolib/setup.py install
RUN apt update && apt -y install cabextract
RUN wget http://ftp.br.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb \
    -O /tmp/ttf.deb
RUN dpkg -i /tmp/ttf.deb

USER odoo
COPY odoo.conf /var/lib/odoo/
COPY run.sh /run.sh

EXPOSE 8069 8071 8072

VOLUME /var/lib/odoo

CMD /bin/bash /run.sh
