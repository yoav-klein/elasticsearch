# Elasticsearch
---

This repository contains configuration code for working with Elasticsearch.

The `administration` folder contains code to deploy an Elasticsearch cluster.

The `elastic_lib.sh` script is a CLI for working agains Elasticsearch


## elastic_lib.sh
---

Environment variables:
* `ELASTIC_HOST` - the hostname of the Elasticsearch cluster.

If you're working with AWS OpenSearch:
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_REGION`

If you're working with an unmanaged cluster:
* `ELASTIC_USER`
* `ELASTIC_PASS`
* `ELASTIC_CA` - path to CA file to trust
