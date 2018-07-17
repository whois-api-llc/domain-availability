require 'erb'
require 'json'
require 'net/https'
require 'rexml/document'
require 'rexml/xpath'
require 'uri'
require 'yaml' # only needed to print the returned result in a very pretty way

########################
# Fill in your details #
########################
username = 'Your domain availability api username'
password = 'Your domain availability api password'
domain = 'google.com'

url = 'https://www.whoisxmlapi.com/whoisserver/WhoisService'\
      '?cmd=GET_DN_AVAILABILITY'\
      '&domainName=' + ERB::Util.url_encode(domain) +
      '&username=' + ERB::Util.url_encode(username) +
      '&password=' + ERB::Util.url_encode(password) +
      '&outputFormat='

#######################
# Use a JSON resource #
#######################
format = 'JSON'

# Open the resource
buffer = Net::HTTP.get(URI.parse(url + format))

# Parse the JSON result
result = JSON.parse(buffer)

# Print out a nice informative string
puts "JSON:\n" + result.to_yaml + "\n"

#######################
# Use an XML resource #
#######################
format = 'XML'

# Open the resource
buffer = Net::HTTP.get(URI.parse(url + format))

# Parse the XML result
result = REXML::Document.new(buffer)

# Get a few data members and make sure they aren't nil
da_path = '/DomainInfo/domainAvailability'
dom_path = '/DomainInfo/domainName'

if !(error_message = REXML::XPath.first(result, '/ErrorMessage/msg')).nil?
  puts "XML:\nErrorMessage:\n\t" + error_message.text
else
  info = (info = REXML::XPath.first(result, da_path)).nil? ? '' : info.text
  dom = (dom = REXML::XPath.first(result, dom_path)).nil? ? '' : dom.text
  puts "XML:\n---\n" + '  availability: ' + info + "\n  domainName: " + dom
end