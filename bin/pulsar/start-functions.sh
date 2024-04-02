#!/bin/bash

docker exec -it pulsar-broker sh -c \
  "./bin/pulsar-admin tenants create feeds"

sleep 5

docker exec -it pulsar-broker sh -c \
  "./bin/pulsar-admin namespaces create feeds/realtime"

sleep 5

docker exec -it pulsar-broker sh -c \
  "./bin/pulsar-admin functions create \
     --jar /etc/pulsar-functions/lib/coinbase-websocket-feed-router-1.0.0.nar \
     --function-config-file /etc/pulsar-functions/conf/coinbase-router-config.yaml"

sleep 5

docker exec -it pulsar-broker sh -c \
  "./bin/pulsar-admin sources create \
     --archive /etc/pulsar-functions/lib/coinbase-live-feed-1.0.0.nar \
     --source-config-file /etc/pulsar-functions/conf/coinbase-connector-all.yaml"