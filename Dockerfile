FROM debian:wheezy
MAINTAINER Sergio Corato <sergiocorato@gmail.com>

ARG ODOO_UID=105
ARG ODOO_GID=109

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONIOENCODING utf-8

RUN cp /etc/apt/sources.list /etc/apt/sources.list.back
RUN sed -i 's/deb http:\/\/security.debian.org.*/#NO/g' /etc/apt/sources.list
RUN sed -i 's/deb-src http:\/\/security.debian.org.*/#NO/g' /etc/apt/sources.list
RUN sed -i 's/deb http:\/\/deb.debian.org.*/#NO/g' /etc/apt/sources.list
RUN sed -i 's/deb-src http:\/\/deb.debian.org.*/#NO/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/
RUN echo "deb http://archive.debian.org/debian wheezy-backports main" >> \
 /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian wheezy-backports main" >> \
 /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian-security wheezy updates/main" >> \
 /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian-security wheezy updates/main" >> \
 /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian wheezy main" >> \
 /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian wheezy main" >> \
 /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install --allow-unauthenticated -y \
python-dateutil python-feedparser python-gdata python-ldap \
python-libxslt1 python-lxml python-mako python-openid python-psycopg2 \
python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
python-simplejson python-tz python-vatnumber python-vobject python-webdav \
python-werkzeug python-xlwt python-yaml python-zsi \
python-unittest2 python-mock python-docutils python-jinja2 \
python-psutil python-setuptools \
git vim wget openssh-client fontconfig \
xfonts-base xfonts-75dpi \
python-dev psmisc python-genshi python-cairo \
    locate unzip locales
RUN echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=it_IT.UTF-8
ENV LANG it_IT.UTF-8
ENV LANGUAGE it
RUN cd /tmp && wget -O wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb \
    https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/\
wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb \
    && dpkg -i wkhtmltox-0.12.2.1_linux-wheezy-amd64.deb \
    && cp /usr/local/bin/wkhtmltopdf /usr/bin \
    && cp /usr/local/bin/wkhtmltoimage /usr/bin

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN pip install --ignore-installed --upgrade mock PyPDF2 python-telegram-bot \
    codicefiscale \
    MarkupSafe==0.23 Pillow==5.2.0 pyyaml==3.10 unidecode==0.04.13 \
    pyxb==1.2.5 odfpy==0.9.6 pybarcode bs4 phonenumbers requests xlrd

RUN apt-get install -y libzbar0
RUN pip install pyzbar pyzbar[scripts] qrcode \
    git+https://github.com/ojii/pymaging.git#egg=pymaging \
    git+https://github.com/ojii/pymaging-png.git#egg=pymaging-png

RUN groupadd -g ${ODOO_GID} openerp
RUN useradd -m -d /var/lib/odoo -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} openerp
RUN mkdir -p /opt/openerp
RUN chown -R openerp:openerp /opt

RUN apt-get update
RUN apt-get install -y --force-yes net-tools telnet supervisor procps
RUN pip install supervisor --ignore-installed --upgrade
RUN apt-get upgrade -y
RUN apt-get -y --force-yes --no-install-recommends -t wheezy-backports install \
    libreoffice '^libreoffice-.*-it$'
RUN rm /usr/bin/soffice && cd /usr/bin && ln -s \
    ../lib/libreoffice/program/soffice.bin ./soffice
RUN sed -i 's/Logo=1/Logo=0/g' /etc/libreoffice/sofficerc && \
    sed -i 's/NativeProgress=false/NativeProgress=true/g' /etc/libreoffice/sofficerc
RUN cd /tmp && git clone https://github.com/sergiocorato/aeroolib \
    && cd /tmp/aeroolib/aeroolib && python ./setup.py  install
RUN cd /opt/openerp/ && \
    git clone https://github.com/efatto/server.git server --single-branch -b master && \
    git clone https://github.com/efatto/addons.git addons --single-branch -b master && \
    git clone https://github.com/efatto/web.git web --single-branch -b master && \
    git clone https://github.com/efatto/lp.git lp --single-branch -b master && \
    git clone https://github.com/efatto/l10n-italy.git l10n-italy --single-branch -b 7.0_imp_sr_fatturapa

RUN mkdir -p /etc/supervisor/conf.d
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisord.conf

COPY openerp.conf /var/lib/odoo/
EXPOSE 8069 8071

VOLUME /var/lib/odoo

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
