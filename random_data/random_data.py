import boto3

from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
from opensearchpy.helpers import bulk
from faker import Faker

#import http.client

host = "search-test-domain-737pcjexzuc3zf24zelxmeb3fa.us-east-1.es.amazonaws.com"
#host = 'vyz5r957clrv1joo7hza.us-east-1.aoss.amazonaws.com'  # serverless collection endpoint, without https://
region = 'us-east-1'  # e.g. us-east-1

service = 'es'
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

#http.client.HTTPConnection.debuglevel = 1

num_docs = 10000
index_name = "myindex2"
fake = Faker()
data = []
for i in range(num_docs):
    data.append({
        '_index': index_name,
        '_source': {
            'name': fake.name(),
            'email': fake.email(),
            'phone_number': fake.phone_number(),
            'street_address': fake.street_address(),
            'city': fake.city(),
            'state': fake.state(),
            'zip_code': fake.zipcode(),
            'country': fake.country()
        }
    })

print("first doc:")
print(data[0])
print(f"Bulk indexing ${num_docs} documents")
# create an index
index_name = "python-test-index"
response = bulk(client, data)
print("Adding documents using Bulk")
print(response)

