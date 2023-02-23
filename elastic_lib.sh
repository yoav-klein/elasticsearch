
cmd=$1

if [ -z "$ELASTIC_HOST" ]; then
    echo "ELASTIC_HOST is not set"
    exit 1
fi

function call() {
    method=$1
    uri=$2

    if [ -n "$AWS_SECRET_ACCESS_KEY" ]  && [ -n "$AWS_REGION" ] &&
       [ -n "$AWS_ACCESS_KEY_ID" ] && [ -z "$ELASTIC_IGNORE_AWS" ]; then
        echo "Calling AWS Elasticsearch..."
        curl -X${method} --aws-sigv4 "aws:amz:$AWS_REGION:es" -u $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY "https://${ELASTIC_HOST}${uri}"
    elif [ -z "$ELASTIC_USER" ] || [ -z "$ELASTIC_PASS" ] || [ -z "$ELATIC_CA" ]; then
        echo "set ELASTIC_USER, ELASTIC_PASS and ELASTIC_CA variables"
        exit 1
    else
        curl -X${method} --cacert $ELASTIC_CA -u $ELASTIC_USER:$ELASTIC_PASS "https://${ELASTIC_HOST}${uri}"
    fi

}

function check_communication() {
    call "GET" ""
}

function health() {
    call "GET" "/_cluster/health"
}

function create_index() {
    call "PUT" "$1"
}

function index_documents() {
#    call "POST" "/${1}"
    echo "index_docs"
}


usage() {
    echo "$0 <command>"
    echo "commands:"
    echo "check_communication"
    echo "health"
    echo "create_index <index_name>"
    echo "index_documents <index_name> <file>"
}

case "$cmd" in
    check_communication) check_communication;;
    health) health;;
    create_index) create_index;;
    index_documents) index_documents;;
    *) usage;;
esac

