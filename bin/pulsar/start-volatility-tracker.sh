#!/bin/bash

docker exec -it pulsar-broker sh -c \
  "./bin/pulsar-admin sources create \
     --archive /etc/pulsar-functions/lib/coinbase-volatility-tracker-1.0.0.nar \
     --source-config-file /etc/pulsar-functions/conf/coinbase-volatility-tracker.yaml"