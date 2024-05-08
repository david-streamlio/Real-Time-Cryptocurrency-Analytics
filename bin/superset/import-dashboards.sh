#!/bin/bash

docker exec -it superset superset import-dashboards --username admin --path /home/superset/dashboards/dashboard.zip