#!/bin/bash

INFRA_DIR="infrastructure/pinot"

docker compose --project-name pinot --file $INFRA_DIR/cluster.yaml up -d