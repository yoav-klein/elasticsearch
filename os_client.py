
"""
    This script demonstrates a more complex use-case, in which we have commands, and subcommands.
    for example:
    $ py elastic.py index create --name "my-index"
    $ py elastic.py index delete --name "my-index"


    capabilities:
    - ping
    - health
    - bulk index
    - cat shards for index
    - delete index
    - get index mapping


"""

import os
import argparse
from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import boto3
import requests



def index(args, client):
    def create():
        print(f"Creating {args.name}")
        client.indices.create(args.name)

    def get():
        print(client.indices.get(args.name))

    def delete():
        print(f"Deleting {args.name}")
    
    def stats():
        print(client.indices.stats(args.name))
    
    if args.subcommand == "delete":
        delete()
    
    if args.subcommand == "create":
        create()

    if args.subcommand == "get":
        get()
    
    if args.subcommand == "stats":
        stats()

def document(args, client):
    pass


def create_client():
    host = os.getenv('ELASTIC_HOST')
    service = 'es'
    region = os.getenv('AWS_REGION')
    credentials = boto3.Session().get_credentials()
    auth = AWSV4SignerAuth(credentials, region, service)

    if host == None:
        raise "no ELASTIC_HOST defined"

    client = OpenSearch(
        hosts=[{'host': host, 'port': 443}],
        http_auth=auth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection,
        pool_maxsize=20,
    )

    return client


def parse_arguments():
    # Create the top-level parser
    parser = argparse.ArgumentParser(description='My Elasticsearch tool')

    subparsers = parser.add_subparsers(title='Elasticsearch commands', dest='command')
    subparsers.required = True

    ### Add a subparser for the "index" command
    index_parser = subparsers.add_parser('index', help='Do index operations')
    index_subparsers = index_parser.add_subparsers(title='Index commands', dest='subcommand')
    index_subparsers.required = True
    
    ## create
    index_create_parser = index_subparsers.add_parser('create', help="Create index")
    index_create_parser.add_argument('--name', required=True, help="Name of index")
    
    ## delete
    index_delete_parser = index_subparsers.add_parser('delete', help="Delete index")
    index_delete_parser.add_argument('--name', required=True, help="Name of index")
    
    ## get
    index_get_parser = index_subparsers.add_parser('get', help="Get information about one or more indices")
    index_get_parser.add_argument('--name', required=True, help="comma-separated lists of indices, * for all")

     ## stats
    index_get_parser = index_subparsers.add_parser('stats', help="Stats information about one or more indices")
    index_get_parser.add_argument('--name', required=True, help="comma-separated lists of indices, * for all")


    index_parser.set_defaults(func=index)

    # Add a subparser for the "document" command
    document_parser = subparsers.add_parser('document', help='Do document operations')

    document_subparsers = document_parser.add_subparsers(title="Document commands", dest='subcommand')

    document_create_parser = document_subparsers.add_parser('create', help="Create document")
    document_create_parser.add_argument('--name', required=True, help="Name of document")

    document_delete_parser = document_subparsers.add_parser('delete', help="Delete document")
    document_delete_parser.add_argument('--name', required=True, help="Name of document")
    
    document_parser.set_defaults(func=document)

    # Parse the command-line arguments
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    client = create_client()
    args = parse_arguments()
    args.func(args, client)


