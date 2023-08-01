import os
import argparse
from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import boto3


def create_client():
    host = os.getenv('ELASTIC_HOST')
    service = 'es'
    region = os.getenv('AWS_REGION')
    credentials = boto3.Session().get_credentials()
    auth = AWSV4SignerAuth(credentials, region, service)

    if host == None:
        raise Exception("no ELASTIC_HOST defined")

    if region == None:
        raise Exception("no AWS_REGION defined")

    client = OpenSearch(
        hosts=[{'host': host, 'port': 443}],
        http_auth=auth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection,
        pool_maxsize=20,
    )

    return client.snapshot


def create_repo(client):
    repository_definition = {
        "type": "s3",
        "settings": {
            "bucket": "yoav-snapshot-repository",
            "region": "us-east-1",
            "role_arn": "arn:aws:iam::617611017005:role/SnapshotRole",
        }
    }
    
    client.create_repository("repo", repository_definition, verify=True)

def get_repo(client):
    print(client.get_repository("repo"))

def create_snapshot(client):
    print(client.create("repo", "2", wait_for_completion=True))

def main():
    client = create_client()
    #get_repo(client)
    create_snapshot(client)

   
if __name__ == "__main__":
    main()



