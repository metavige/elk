FROM logstash
MAINTAINER Ricky Chiang <metavige@gmail.com>

ADD config /logstash-config

EXPOSE 5000

CMD ["logstash", "-f", "/logstash-config/logstash.conf"]
