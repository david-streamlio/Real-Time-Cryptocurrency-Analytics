#!/bin/bash

docker exec -it superset superset import-dashboards --username admin --path /home/superset/dashboards/simple_dashboard_export.zip

docker exec -it superset superset import-dashboards --username admin --path /home/superset/dashboards/btc.zip