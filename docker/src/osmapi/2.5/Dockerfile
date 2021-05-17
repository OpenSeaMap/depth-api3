FROM debian:10

LABEL maintainer="Steffen Volkmann (steffen@volkmann.com)"

ENV DEBIAN_FRONTEND=noninteractive

RUN    apt-get update \
    && apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" \
    && apt-get install -y --no-install-recommends \
    procps \
    nano \
    wget \
    unzip \
    software-properties-common \
  	procps \
  	nano \
  	git \
    build-essential \
    libpq-dev \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-dev

COPY requirements.txt /
RUN pip3 install --no-cache-dir -r requirements.txt

# Start running
USER root
COPY run.sh /
ENTRYPOINT ["/run.sh"]
CMD []
EXPOSE 8000/tcp
