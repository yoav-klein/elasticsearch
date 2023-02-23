#!/bin/bash

curl -u elastic:$(cat elastic-pass) --cacert elasticsearch-8.6.2/config/certs/http_ca.crt https://localhost:9200/_cluster/health
