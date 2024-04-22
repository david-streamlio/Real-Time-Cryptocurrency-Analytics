#!/bin/bash

docker exec -it pinot-controller sh -c \
  "./bin/pinot-admin.sh AddTable -tableConfigFile \
     /ddl/coinbase-volatility-table-config.json -schemaFile \
     /ddl/coinbase-volatility-schema.json -exec"