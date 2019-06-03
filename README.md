# Odoo 10 Dockerized

This is a dockerized Odoo 10 setup.

It needs an external container for DB and some mapped folders for persistent data.
Odoo user will run with UID 105 and GID 109.

You can customize the odoo.conf file containing your Odoo settings:

```
[options]
admin_passwd = MyOdooDBAdminSuperSecretPassword
```


Then, if already using [Traefik](https://traefik.io/) and [Docker Compose](https://docs.docker.com/compose/), you can create the stack with something like:


```
version: "2"

services:
  app:
    image: kenayagi/odoo:10.0
    restart: unless-stopped
    volumes:
      - /srv/docker/odoo/app/data:/var/lib/odoo
      - /srv/docker/odoo/app/odoo.conf:/etc/odoo/odoo.conf
    networks:
      - traefik
      - net
    depends_on:
      - db
    environment:
      - TZ=Europe/Rome
      - POSTGRES_HOST=db
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=PassWooorD
    labels:
      - traefik.enable=true
      - traefik.odoo.port=8069
      - traefik.odoo.backend=main
      - traefik.odoo.frontend.rule=Host:odoo.domain.com
      - traefik.odoo.frontend.redirect.entryPoint=https
      - traefik.odoodm.port=8069
      - traefik.odoodm.backend=dm
      - traefik.odoodm.frontend.rule=Host:odoo.domain.com;Path:/web/database/manager
      - traefik.odoodm.frontend.redirect.entryPoint=https
      - traefik.odoodm.frontend.whiteList.sourceRange=192.168.1.0/24
      - traefik.odoolp.port=8072
      - traefik.odoolp.backend=lp
      - traefik.odoolp.frontend.rule=Host:odoo.domain.com;PathPrefix:/longpolling
      - traefik.odoolp.frontend.redirect.entryPoint=https
      
  db:
    image: postgres:11.3
    restart: unless-stopped
    volumes:
      - /srv/docker/odoo/db/data:/var/lib/postgresql/data
    networks:
      - net
    environment:
      - TZ=Europe/Rome
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=PassWooorD
      
networks:
  net:
  traefik:
    external:
      name: traefik
```

