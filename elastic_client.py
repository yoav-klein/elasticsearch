from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import boto3
import requests
import http.client
host = "uq2u3cwe6rqm0ry46j5c.us-east-1.aoss.amazonaws.com"
#host = 'vyz5r957clrv1joo7hza.us-east-1.aoss.amazonaws.com'  # serverless collection endpoint, without https://
region = 'us-east-1'  # e.g. us-east-1

service = 'aoss'
credentials = boto3.Session().get_credentials()
auth = AWSV4SignerAuth(credentials, region, service)

# create an opensearch client and use the request-signer
client = OpenSearch(
    hosts=[{'host': host, 'port': 443}],
    http_auth=auth,
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection,
    pool_maxsize=20,
)

http.client.HTTPConnection.debuglevel = 1
#print(requests.get(f"https://{host}", auth=auth))


# create an index
index_name = "python-test-index"
create_response = client.indices.create(
    index_name
)
print('\nCreating index:')
print(create_response)

# delete the index
delete_response = client.indices.delete(
    index_name
)
print('\nDeleting index:')
print(delete_response)
