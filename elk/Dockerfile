FROM debian:jessie
MAINTAINER Ricky Chiang <metavige@gmail.com>

# ENV
ENV GOSU_VERSION 1.3

ENV ELASTICSEARCH_MAJOR 2.1
ENV ELASTICSEARCH_VERSION 2.1.1

ENV LOGSTASH_MAJOR 2.0
ENV LOGSTASH_VERSION 1:2.0.0-1

ENV KIBANA_VERSION 4.3.1
ENV KIBANA_SHA1 115ba22882df75eb5f07330b7ad8781a57569b00

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

ENV JAVA_VERSION 8u66
ENV JAVA_DEBIAN_VERSION 8u66-b17-1~bpo8+1
# Default to UTF-8 file.encoding
ENV LANG C.UTF-8
# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

# Install
RUN \
  echo "deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list && \
  echo "deb http://packages.elasticsearch.org/logstash/${LOGSTASH_MAJOR}/debian stable main" > /etc/apt/sources.list.d/logstash.list && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list && \
  echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4 && \
  \
  apt-get update && \
  apt-get install --no-install-recommends -y curl && \
  \
  # JAVA
  echo "Install java" && \
  { \
    echo '#!/bin/bash'; \
    echo 'set -e'; \
    echo; \
    echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
  } > /usr/local/bin/docker-java-home \
  && chmod +x /usr/local/bin/docker-java-home && \
  set -x \
  && apt-get update \
  && apt-get install -y \
    openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
    ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
  && rm -rf /var/lib/apt/lists/* \
  && [ "$JAVA_HOME" = "$(docker-java-home)" ] && \
  # see CA_CERTIFICATES_JAVA_VERSION notes above
  /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
  \
  echo "grab gosu for easy step-down from root ......" && \
  \
  arch="$(dpkg --print-architecture)" \
  && set -x \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$arch.asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu
  \
  echo "Install elasticsearch ......" && \
  \
  apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION && \
  set -ex \
  && for path in \
    /usr/share/elasticsearch/data \
    /usr/share/elasticsearch/logs \
    /usr/share/elasticsearch/config \
    /usr/share/elasticsearch/config/scripts \
  ; do \
    mkdir -p "$path"; \
    chown -R elasticsearch:elasticsearch "$path"; \
  done && \
  \
  echo "Install logstash ......" && \
  \
  apt-get install -y --no-install-recommends logstash=$LOGSTASH_VERSION && \
  \
  echo "Install kibana ......" && \
  \
  groupadd -r kibana && useradd -r -m -g kibana kibana && \
  set -x \
  && curl -fSL "https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz" -o kibana.tar.gz \
  && echo "${KIBANA_SHA1}  kibana.tar.gz" | sha1sum -c - \
  && mkdir -p /opt/kibana \
  && tar -xz --strip-components=1 -C /opt/kibana -f kibana.tar.gz \
  && chown -R kibana:kibana /opt/kibana \
  && rm kibana.tar.gz && \
  \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY elasticsearch /usr/share/elasticsearch/config
ENV PATH /opt/kibana/bin:/opt/logstash/bin:/usr/share/elasticsearch/bin:$PATH

EXPOSE 5601 9200 9300

CMD ["run.sh"]
