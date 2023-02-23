#!/bin/bash

elastic_rest() {
    curl -u elastic:$(cat elastic-pass) --cacert $ES_HOME/config/certs/http_ca.crt https://localhost:9200/
}

file=file0
index="shakespeer"

feed() {
    while read p; do
        curl -u elastic:$(cat elastic-pass) -H 'Content-Type: application/json' -X POST \
        --cacert $ES_HOME/config/certs/http_ca.crt "https://localhost:9200/$index/_doc" -d "$p"
        echo ""
    done < $file
}

feed
#elastic_rest
