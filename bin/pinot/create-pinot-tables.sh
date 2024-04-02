#!/bin/bash

docker exec -it pinot-controller sh -c \
  "./bin/pinot-admin.sh AddTable -tableConfigFile \
     /config/coinbase-rfq-match-table-config.json -schemaFile \
     /config/coinbase-rfq-match-schema.json -exec"

sleep 5

docker exec -it pinot-controller sh -c \
  "./bin/pinot-admin.sh AddTable -tableConfigFile \
     /config/coinbase-ticker-table-config.json -schemaFile \
     /config/coinbase-ticker-schema.json -exec"