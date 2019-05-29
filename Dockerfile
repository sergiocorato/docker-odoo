FROM debian:stretch

RUN apt update && apt -y upgrade

RUN apt -y install build-essential \
    curl \
    git \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libldap2-dev \
    libsasl2-dev \
    locales \
    nano \
    postgresql-client-9.6 \
    procps \
    python \
    python-pip \
    python-setuptools \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt -y install nodejs
RUN npm install -g less less-plugin-clean-css

RUN curl -L https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb -o /tmp/wkhtmltopdf.deb
RUN apt -y install /tmp/wkhtmltopdf.deb

RUN pip install --upgrade pip

RUN echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
ENV LANG=it_IT.UTF-8

RUN groupadd -g 109 odoo
RUN useradd -m -d /var/lib/odoo -s /bin/bash -u 105 -g 109 odoo
RUN mkdir -p /etc/odoo
RUN mkdir -p /mnt/extra-addons
RUN chown -R odoo:odoo /etc/odoo /mnt/extra-addons /opt

USER odoo
RUN git clone https://github.com/OCA/OCB.git --depth 1 --branch 10.0 --single-branch /opt/odoo

USER root
RUN pip install -r /opt/odoo/requirements.txt
RUN pip install -r /opt/odoo/doc/requirements.txt
RUN pip install codicefiscale configparser evdev future odooly passlib pyXB==1.2.6 unidecode unicodecsv validate_email
RUN pip install /opt/odoo

USER odoo
WORKDIR /var/lib/odoo

COPY odoo.conf /etc/odoo

EXPOSE 8069 8071 8072

VOLUME /mnt/extra-addons /var/lib/odoo

CMD /opt/odoo/odoo-bin --data-dir=/var/lib/odoo --config=/etc/odoo/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD
