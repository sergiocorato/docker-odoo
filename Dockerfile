FROM debian:jessie

ARG ODOO_UID=105
ARG ODOO_GID=109

ENV ODOO_DATADIR=/var/lib/odoo
ENV ODOO_CONF=/var/lib/odoo/odoo.conf

ENV UPD_FILE=/var/lib/odoo/update.txt
ENV ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD
ENV POSTGRES_HOST=db
ENV POSTGRES_USER=odoo
ENV POSTGRES_PASSWORD=Us3rP4ssw0rD
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONIOENCODING utf-8

RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install --allow-unauthenticated -y \
    python-dateutil \
    python-feedparser \
    python-gdata \
    python-ldap \
    python-libxslt1 \
    python-lxml \
    python-mako \
    python-openid \
    python-psycopg2 \
    python-pybabel \
    python-pychart \
    python-pydot \
    python-pyparsing \
    python-reportlab \
    python-simplejson \
    python-tz \
    python-vatnumber \
    python-vobject \
    python-webdav \
    python-werkzeug \
    python-xlwt \
    python-yaml \
    python-zsi \
    python-unittest2 \
    python-mock \
    python-docutils \
    python-jinja2 \
    python-psutil \
    python-setuptools \
    git \
    vim \
    wget \
    fontconfig \
    xfonts-base \
    xfonts-75dpi \
    python-dev \
    python-genshi \
    python-cairo \
    unzip \
    locales \
    python-uno
RUN echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=it_IT.UTF-8
ENV LANG=it_IT.UTF-8
ENV LANGUAGE=it
RUN cd /tmp && wget -O wkhtmltox-0.12.2.1_linux-jessie-amd64.deb \
    https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/\
wkhtmltox-0.12.2.1_linux-jessie-amd64.deb \
    && dpkg -i wkhtmltox-0.12.2.1_linux-jessie-amd64.deb \
    && cp /usr/local/bin/wkhtmltopdf /usr/bin \
    && cp /usr/local/bin/wkhtmltoimage /usr/bin

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN pip install --ignore-installed --upgrade \
    mock \
    PyPDF2 \
    python-telegram-bot==5.3.1 \
    codicefiscale \
    MarkupSafe==0.23 \
    Pillow==5.2.0 \
    pyyaml==3.10 \
    unidecode==0.04.13 \
    pyxb==1.2.5 \
    odfpy==0.9.6 \
    pybarcode \
    bs4 \
    phonenumbers \
    requests==2.9.1 \
    xlrd \
    email-validator

RUN apt-get install -y libzbar0
RUN pip install pyzbar pyzbar[scripts] qrcode \
    git+https://github.com/ojii/pymaging.git#egg=pymaging \
    git+https://github.com/ojii/pymaging-png.git#egg=pymaging-png

RUN groupadd -g ${ODOO_GID} openerp
RUN useradd -m -d /var/lib/odoo -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} openerp
RUN mkdir -p /opt/openerp
RUN chown -R openerp:openerp /opt

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get -y --force-yes --no-install-recommends install \
    libreoffice '^libreoffice-.*-it$'
RUN rm /usr/bin/soffice && cd /usr/bin && ln -s \
    ../lib/libreoffice/program/soffice.bin ./soffice
RUN sed -i 's/Logo=1/Logo=0/g' /etc/libreoffice/sofficerc && \
    sed -i 's/NativeProgress=false/NativeProgress=true/g' /etc/libreoffice/sofficerc
RUN cd /tmp && git clone https://github.com/sergiocorato/aeroolib \
    && cd /tmp/aeroolib/aeroolib && python ./setup.py  install
USER openerp
WORKDIR /var/lib/odoo
RUN cd /opt/openerp/ && \
    git clone https://github.com/efatto/server.git server --single-branch -b master && \
    git clone https://github.com/efatto/addons.git addons --single-branch -b master && \
    git clone https://github.com/efatto/web.git web --single-branch -b master && \
    git clone https://github.com/efatto/lp.git lp --single-branch -b master && \
    git clone https://github.com/efatto/l10n-italy.git l10n-italy --single-branch -b 7.0_imp_sr_fatturapa

COPY odoo.conf /var/lib/odoo/
COPY run.sh /run.sh

EXPOSE 8069 8071

VOLUME /var/lib/odoo

CMD /bin/bash /run.sh
