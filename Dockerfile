FROM debian:stretch-backports
MAINTAINER Sergio Corato <sergiocorato@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONIOENCODING utf-8
RUN echo "deb http://http.debian.net/debian stretch-backports main" >> \
    /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get -y install libreoffice
RUN apt-get install -y git python3-uno python3-pip supervisor \
    openjdk-8-jre openjdk-8-jre-headless tcpd uno-libs3 ure python-pip
# ? xvfb
RUN apt-get clean

RUN pip3 install jsonrpc2 daemonize
RUN pip install supervisor supervisor-stdout --ignore-installed --upgrade
RUN git clone https://github.com/sergiocorato/aeroo_docs.git /opt/aeroo_docs

EXPOSE 8989

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD supervisord -c /etc/supervisor/conf.d/supervisord.conf
