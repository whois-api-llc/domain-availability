try:
    # For Python v.3 and later
    from urllib.request import urlopen, pathname2url
    from urllib.parse import quote
except ImportError:
    # For Python v.2
    from urllib import pathname2url
    from urllib2 import urlopen, quote

import base64
import hashlib
import hmac
import json
import time

username = 'Your domain availability api username'
api_key = 'Your domain availability api key'
secret = 'Your domain availability api secret key'

domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
]

url = 'https://whoisxmlapi.com/whoisserver/WhoisService'


def build_request(req_username, req_timestamp, req_digest, req_domain):
    res = '?requestObject='

    data = {
        'u': req_username,
        't': req_timestamp
    }

    data_json = json.dumps(data)
    data_b64 = base64.b64encode(bytearray(data_json.encode('utf-8')))

    res += pathname2url(data_b64.decode('utf-8'))
    res += '&cmd=GET_DN_AVAILABILITY'
    res += '&digest='
    res += pathname2url(req_digest)
    res += '&domainName='
    res += pathname2url(req_domain)
    res += '&outputFormat=json'

    return res


def generate_digest(req_username, req_timestamp, req_key, req_secret):
    res_digest = req_username + str(req_timestamp) + req_key

    res_hash = hmac.new(bytearray(req_secret.encode('utf-8')),
                        bytearray(res_digest.encode('utf-8')),
                        hashlib.md5)

    return quote(str(res_hash.hexdigest()))


def generate_parameters(req_username, req_key, req_secret):
    res_timestamp = int(round(time.time() * 1000))

    res_digest = generate_digest(req_username, res_timestamp,
                                 req_key, req_secret)

    return res_timestamp, res_digest


def print_response(req_response):
    response_json = json.loads(req_response)

    if 'DomainInfo' in response_json:
        if 'domainName' in response_json['DomainInfo']:
            print('Domain Name: ')
            print(response_json['DomainInfo']['domainName'])
        if 'domainAvailability' in response_json['DomainInfo']:
            print('Domain availability: ')
            print(response_json['DomainInfo']['domainAvailability'])


def request(req_url, req_username, req_timestamp, req_digest, req_domain):
    res_request = build_request(req_username, req_timestamp,
                                req_digest, req_domain)

    return urlopen(req_url + res_request).read().decode('utf8')


timestamp, digest = generate_parameters(username, api_key, secret)

for domain in domains:
    response = request(url, username, timestamp, digest, domain)
    if 'Request timeout' in response:
        timestamp, digest = generate_parameters(username, api_key, secret)
        response = request(url, username, timestamp, digest, domain)
    print_response(response)
    print('---------------------------\n')
