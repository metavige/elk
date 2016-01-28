FROM kibana
MAINTAINER Ricky Chiang <metavige@gmail.com>

ADD config /opt/kibana/config
RUN /opt/kibana/bin/kibana plugin --install elasticsearch/marvel/latest

EXPOSE 5601
