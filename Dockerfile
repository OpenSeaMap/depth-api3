FROM debian:latest

LABEL maintainer="Wolfgang Schildbach (wschildbach@fermi.franken.de)"

RUN adduser --system tracksrv \
        && apt-get update \
        && apt-get -y upgrade \
        && apt-get -y install python3 python3-pip python3-gdal curl

RUN apt-get -y install procps nano

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# prepare python environment
COPY requirements.txt /usr/src/app/
RUN pip3 install --no-cache-dir -r requirements.txt

# prepare app directory
COPY tracksrv /usr/src/app
RUN sed -e "s/'HOST': '127.0.0.1',/'HOST': 'db',/" < /usr/src/app/tracksrv/settings.py >/tmp/t && mv /tmp/t /usr/src/app/tracksrv/settings.py
RUN chown -vR tracksrv /usr/src/app

# prepare the raw track storage directory
#RUN mkdir -p /srv/tracksrv/tracks
#RUN chown -vR tracksrv /srv/tracksrv/tracks

# prepare cron automation
# Add crontab file in the cron directory
#COPY dbmaintenance-cron /etc/cron.d/dbmaintenance-cron

# Give execution rights on the cron job
#RUN chmod 0644 /etc/cron.d/dbmaintenance-cron

# Create the log file to be able to run tail
#RUN touch /var/log/cron.log

EXPOSE 8000/tcp

# run with user rights
#USER tracksrv
# make sure that matplotlib writes into tmp directory
ENV MPLCONFIGDIR=/tmp
# set debug to "yes" to enable debugging functionality
ENV DEBUG=
ENV SERVER_HOST=localhost
ENV TMP=/tmp
ENV SUPERUSER=
ENV SUPERUSER_PASSWORD=
ENV SUPERUSER_EMAIL=

HEALTHCHECK --interval=1m --timeout=3s --start-period=10s \
  CMD curl -Ss ${SERVER_HOST}/admin || exit 1

ENTRYPOINT ["/bin/sh"]

CMD ["runserver"]
