FROM openjdk:8-jre

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    curl \
    git \
    gcc \
    python3-dev \
    python3-pip && \
  rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

RUN \
  mkdir -p /home/elasticsearch && \
  groupadd -r elasticsearch && useradd -r -g elasticsearch -d /home/elasticsearch elasticsearch && \
  chown -R elasticsearch:elasticsearch /home/elasticsearch

RUN \
  mkdir -p /opt/gradle && \
  cd /opt/gradle && \
  curl -O https://downloads.gradle.org/distributions/gradle-2.13-bin.zip && \
  unzip gradle-2.13-bin.zip && \
  rm gradle-2.13-bin.zip

ENV GRADLE_HOME /opt/gradle/gradle-2.13
ENV PATH $PATH:$GRADLE_HOME/bin

RUN \
  pip3 install psutil && \
  pip3 install esrally

RUN \
  python3 --version && \
  pip3 --version && \
  gradle --version

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

USER elasticsearch
