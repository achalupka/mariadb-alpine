FROM debian:wheezy

RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN apt-get update
RUN apt-get install -y python-software-properties
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/5.5/debian wheezy main'
RUN apt-get update && \
    apt-get install -y curl binutils locales mariadb-server


EXPOSE 3306


ADD init.sh /scripts/init.sh
RUN chmod 755 /scripts/init.sh

RUN ./scripts/init.sh

ADD run.sh /scripts/run.sh
RUN chmod 755 /scripts/run.sh
ENTRYPOINT ["/scripts/run.sh"]