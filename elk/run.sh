#!/bin/sh

# run elastcsearch
gosu logstash logstash &
gosu kibana kibana &
redis-server &

gosu elasticsearch elasticsearch
