

if [ -z "$ELASTIC_HOST" ]; then
    echo "ELASTIC_HOST is not set"
    exit 1
fi

function call() {
    local method=$1; shift
    local uri=$1; shift
    local curl_args=("$@")
    local args=()
    if [ -n "$header" ]; then
        command="$command -H \"$header\""
    fi
    
    echo "DEBUG: uri = ${uri}"
    echo "DEBUG: method = ${method}"

    if [ -n "$AWS_SECRET_ACCESS_KEY" ]  && [ -n "$AWS_REGION" ] &&
       [ -n "$AWS_ACCESS_KEY_ID" ] && [ -z "$ELASTIC_IGNORE_AWS" ]; then
        echo "Calling AWS Elasticsearch..."
        args+=(--aws-sigv4 "aws:amz:$AWS_REGION:es" -u $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY)
    elif [ -z "$ELASTIC_USER" ] || [ -z "$ELASTIC_PASS" ] || [ -z "$ELATIC_CA" ]; then
        echo "set ELASTIC_USER, ELASTIC_PASS and ELASTIC_CA variables"
        exit 1
    else
        args+=(--cacert $ELASTIC_CA -u $ELASTIC_USER:$ELASTIC_PASS)
    fi
 
    curl "${args[@]}" "${curl_args[@]}" "https://${ELASTIC_HOST}${uri}"

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
        call "POST" "/${1}/_doc" -H "Content-Type: application/json" -d "$p"
    done < $2
}

function bulk_index() {
    call "POST" "/_bulk" -H "Content-Type: application/x-ndjson" --data-binary "@$1"
}

function cat_indices() {
    call "GET" "/_cat/indices"
}

function cat_shards_for_index() {
    call "GET" "/_cat/shards/$1"
}

function delete_index() {
    call "DELETE" "/$1"
}

function index_stats() {
    call "GET" "/$1/_stats/$2"
}

usage() {
    echo "$0 <command>"
    echo "==============="
    echo "commands:"
    echo "check_communication"
    echo "health"
    echo "create_index <index_name>"
    echo "delete_index <index_name>"
    echo "bulk_index <file>"
    echo "cat_indices"
    echo "cat_shards_for_index <index_name>"
    echo "index_stats <index_name>"
}

cmd=$1
shift;

case "$cmd" in
    check_communication) check_communication;;
    health) health;;
    create_index) create_index "$1";;
    delete_index) delete_index "$1";;
    cat_indices) cat_indices;;
    bulk_index) bulk_index "$1";;
    cat_shards_for_index) cat_shards_for_index "$1";;
    index_stats) index_stats "$1" "$2";;
    *) usage;;
esac
echo ""

