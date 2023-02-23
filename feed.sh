#!/bin/bash


elastic_url=$1
index=$2
file=$3
user=$4
pass=$5

usage() {
    echo "$0 <elastic_url> <index> <file> <user> <pass>"
}

if [ -z "$elastic_url" ] || [ -z "$file" ] || [ -z "$index" ] ||
    [ -z "$user" ] || [ -z "$pass" ]; then
    usage
    exit 1
fi

feed_aws() {
    while read p; do
        curl --aws-sigv4 "aws:amz:us-east-1:es" -u $user:$pass -H 'Content-Type: application/json' -X POST \
        "$elastic_url/$index/_doc" -d "$p"
        echo ""
    done < $file

}

feed() {
    while read p; do
        curl -u $user:$pass -H 'Content-Type: application/json' -X POST \
        "$elastic_url/$index/_doc" -d "$p"
        echo ""
    done < $file
}

feed_aws
