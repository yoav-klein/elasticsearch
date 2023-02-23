
cmd=$1

if [ -z "$ELASTIC_HOST" ]; then
    echo "ELASTIC_HOST is not set"
    exit 1
fi

function call() {
    method=$1
    uri=$2
    header=$3
    data=$4

    command="curl -X $method "
    if [ -n "$headers" ]; then
        command="$command -H $header"
    fi
    
    if [ -n "$data" ]; then
        command="$command -d $data"
    fi

    if [ -n "$AWS_SECRET_ACCESS_KEY" ]  && [ -n "$AWS_REGION" ] &&
       [ -n "$AWS_ACCESS_KEY_ID" ] && [ -z "$ELASTIC_IGNORE_AWS" ]; then
        echo "Calling AWS Elasticsearch..."
        command="$command --aws-sigv4 \"aws:amz:$AWS_REGION:es\" -u $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY"
    elif [ -z "$ELASTIC_USER" ] || [ -z "$ELASTIC_PASS" ] || [ -z "$ELATIC_CA" ]; then
        echo "set ELASTIC_USER, ELASTIC_PASS and ELASTIC_CA variables"
        exit 1
    else
        command="$command --cacert $ELASTIC_CA -u $ELASTIC_USER:$ELASTIC_PASS"
    fi
    command="$command https://${ELASTIC_HOST}${uri}"

    echo "DEBUG: executing command: $command"
    eval $command

}

function check_communication() {
    call "GET" ""
}

function health() {
    call "GET" "/_cluster/health"
}

function create_index() {
    echo "DEBUG: create index: $1"
    call "PUT" "/$1"
}

function index_documents() {
    while read p; do
        call "POST" "${1}/_doc" "Content-Type: application/json" "$p"
    done < $file
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
    create_index) create_index "$2";;
    index_documents) index_documents "$2" "$3";;
    *) usage;;
esac

