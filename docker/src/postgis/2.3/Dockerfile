FROM debian:9

LABEL maintainer="Steffen Volkmann (steffen@volkmann.com)"

ENV DEBIAN_FRONTEND=noninteractive

RUN    apt-get update \
    && apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" \
    && apt-get install -y --no-install-recommends \
    procps \
    nano \
    wget \
    unzip \
    sudo \
    software-properties-common

RUN     apt-get install -y --no-install-recommends \
    postgresql-9.6-postgis-2.3 \
    postgresql-9.6-postgis-scripts


# Configure PosgtreSQL
COPY postgresql.custom.conf.tmpl /etc/postgresql/9.6/main/

RUN  mkdir /var/lib/postgresql/data \
  && chown -R postgres:postgres /var/lib/postgresql \
  && chown postgres:postgres /etc/postgresql/9.6/main/postgresql.custom.conf.tmpl \
  && echo "\ndata_directory = '/var/lib/postgresql/data'" >> /etc/postgresql/9.6/main/postgresql.conf \
  && echo "\ninclude 'postgresql.custom.conf'" >> /etc/postgresql/9.6/main/postgresql.conf


RUN  echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.6/main/pg_hba.conf \
  && echo "host all all ::/0 md5" >> /etc/postgresql/9.6/main/pg_hba.conf


# Start running
USER root
COPY run.sh /
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
CMD []
EXPOSE 5432
