try:
    # For Python v.3 and later
    from urllib.request import urlopen
    from urllib.parse import quote
except ImportError:
    # For Python v.2
    from urllib2 import urlopen
    from urllib2 import quote
import json
import base64
import hmac
import hashlib
import time
username = 'Your domain availability api username'
apiKey = 'Your domain availability api api_key'
secret = 'Your domain availability api secret_key'
domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
]
url = 'https://whoisxmlapi.com/whoisserver/WhoisService?'
timestamp = 0
digest = 0

def generateDigest(username, timestamp, apikey, secret):
    digest = username + str(timestamp) + apikey
    hash = hmac.new(bytearray(secret.encode('utf-8')), bytearray(digest.encode('utf-8')), hashlib.md5)
    return quote(str(hash.hexdigest()))

def generateParameters(username, apikey, secret):
    timestamp = int(round(time.time() * 1000))
    digest = generateDigest(username, timestamp, apikey, secret)
    return timestamp, digest

def buildRequest(username, timestamp, digest, domain):
    requestString = "requestObject="
    data = {'u': username, 't': timestamp}
    dataJson = json.dumps(data)
    dataBase64 = base64.b64encode(bytearray(dataJson.encode('utf-8')))
    requestString += dataBase64.decode('utf-8')
    requestString += '&cmd=GET_DN_AVAILABILITY'
    requestString += "&digest="
    requestString += digest
    requestString += "&domainName="
    requestString += domain
    requestString += "&outputFormat=json"
    return requestString

def printResponse(response):
    responseJson = json.loads(response)
    if 'DomainInfo' in responseJson:
        if 'domainName' in responseJson['DomainInfo']:
            print("Domain Name: ")
            print(responseJson['DomainInfo']['domainName'])
        if 'domainAvailability' in responseJson['DomainInfo']:
            print("Domain availability: ")
            print(responseJson['DomainInfo']['domainAvailability'])

def request(url, username, timestamp, digest, domain):
    request = buildRequest(username, timestamp, digest, domain)
    response = urlopen(url + request).read().decode('utf8')
    return response

timestamp, digest = generateParameters(username, apiKey, secret)

for domain in domains:
    response = request(url, username, timestamp, digest, domain)
    if "Request timeout" in response:
        timestamp, digest = generateParameters(username, apiKey, secret)
        response = request(url, username, timestamp, digest, domain)
    printResponse(response)
    print("---------------------------\n")