require 'open-uri'
require 'json'
require 'rexml/document'
require 'rexml/xpath'
require 'yaml'
require 'uri'
require 'openssl'
require 'base64'

domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
]
url = 'https://whoisxmlapi.com/whoisserver/WhoisService?'
username = 'Your domain availability api username'
api_key = 'Your domain availability api api_key'
secret = 'Your domain availability api secret_key'

def generate_digest(username, timestamp, api_key, secret)
  digest = username + timestamp.to_s + api_key
  hash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, secret, digest)
  return URI.escape(hash)
end

def build_request(username, timestamp, digest, domain)
  request_string = "requestObject="
  data = {:u => username, :t => timestamp}
  data_json = data.to_json
  data_base64 = Base64.encode64(data_json)
  request_string += data_base64
  request_string += '&cmd=GET_DN_AVAILABILITY'
  request_string += '&digest='
  request_string += digest
  request_string += '&domainName='
  request_string += domain
  request_string += '&outputFormat=json'
  return request_string
end

def print_response(response)
  response_hash = JSON.parse(response)
  if response_hash.key? "DomainInfo"
    if response_hash["DomainInfo"].key? "domainName"
      puts "Domain name: "
      puts response_hash["DomainInfo"]["domainName"]
      puts "\n"
    end
    if response_hash["DomainInfo"].key? "domainAvailability"
      puts "Domain availability: "
      puts response_hash["DomainInfo"]["domainAvailability"]
      puts "\n"
    end
  end
end

timestamp = (Time.now.to_f * 1000).to_i
digest = generate_digest(username, timestamp, api_key, secret)

domains.each do |domain|
  request_string = build_request(username, timestamp, digest, domain)
  response = open(url + request_string).read
  if response.include? "Request timeout"
    timestamp = (Time.now.to_f * 1000).to_i
    digest = generate_digest(username, timestamp, api_key, secret)
    request_string = build_request(username, timestamp, digest, domain)
    response = open(url + request_string).read
  end
  print_response(response)
  puts "--------------------------------\n"
end