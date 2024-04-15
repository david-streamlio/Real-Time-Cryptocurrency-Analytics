#!/bin/bash

docker exec -it pinot-controller sh -c \
  "./bin/pinot-admin.sh AddTable -tableConfigFile \
     /ddl/coinbase-rfq-match-table-config.json -schemaFile \
     /ddl/coinbase-rfq-match-schema.json -exec"

sleep 5

docker exec -it pinot-controller sh -c \
  "./bin/pinot-admin.sh AddTable -tableConfigFile \
     /ddl/coinbase-ticker-table-config.json -schemaFile \
     /ddl/coinbase-ticker-schema.json -exec"

sleep 5

docker exec -it pinot-controller sh -c \
  "./bin/pinot-admin.sh AddTable -tableConfigFile \
     /ddl/coinbase-ticker-stats-table-config.json -schemaFile \
     /ddl/coinbase-ticker-stats-schema.json -exec"