#!/bin/bash

set -e

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
  # Change the ownership of /usr/share/elasticsearch/data to elasticsearch
  chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

  set -- gosu elasticsearch "$@"
  #exec gosu elasticsearch "$BASH_SOURCE" "$@"
fi

########################################

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' ]; then
  if [ "$ELASTICSEARCH_URL" -o "$ELASTICSEARCH_PORT_9200_TCP" ]; then
    : ${ELASTICSEARCH_URL:='http://elasticsearch:9200'}
    sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 '$ELASTICSEARCH_URL'!" /opt/kibana/config/kibana.yml
  else
    echo >&2 'warning: missing ELASTICSEARCH_PORT_9200_TCP or ELASTICSEARCH_URL'
    echo >&2 '  Did you forget to --link some-elasticsearch:elasticsearch'
    echo >&2 '  or -e ELASTICSEARCH_URL=http://some-elasticsearch:9200 ?'
    echo >&2
  fi

  set -- gosu kibana "$@"
fi

########################################

# Run as user "logstash" if the command is "logstash"
if [ "$1" = 'logstash' ]; then
  set -- gosu logstash "$@"
fi

exec "$@"
