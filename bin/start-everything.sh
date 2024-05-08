#!/bin/bash

echo "Starting Apache Pulsar..."
sh ./bin/pulsar/start-pulsar.sh

sleep 15

echo "Starting the data feed..."
sh ./bin/pulsar/start-coinbase-feed.sh

sleep 5

echo "Starting the content based routing function..."
sh ./bin/pulsar/start-coinbase-feed-router.sh

sleep 5

echo "Starting the ticker stats function..."
sh ./bin/pulsar/start-ticker-stats.sh

sleep 2

echo "Starting Apache Pinot..."
sh ./bin/pinot/start-pinot.sh

sleep 25

echo "Creating the Apache Pinot tables..."
sh ./bin/pinot/create-pinot-tables.sh

sleep 5

echo "Initializing Apache Superset..."
sh ./bin/superset/init-superset.sh

sleep 5

echo "Importing dashboards..."
sh ./bin/superset/import-dashboards.sh

sleep 10

echo "Starting continuous query"
sh ./bin/pulsar/start-volatility-tracker.sh

sleep 5

sh ./bin/pinot/create-volatility-table.sh
