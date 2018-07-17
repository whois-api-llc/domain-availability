try:
    # For Python v.3 and later
    from urllib.request import urlopen, pathname2url
except ImportError:
    # For Python v.2
    from urllib import pathname2url
    from urllib2 import urlopen

import json
import xml.etree.ElementTree as ETree

########################
# Fill in your details #
########################
username = 'Your domain availability api username'
password = 'Your domain availability api password'
domain = 'google.com'

url = 'https://www.whoisxmlapi.com/whoisserver/WhoisService?'\
    + 'cmd=GET_DN_AVAILABILITY'\
    + '&domainName=' + pathname2url(domain)\
    + '&username=' + pathname2url(username)\
    + '&password=' + pathname2url(password)\
    + '&outputFormat='


# A function to recursively build a dict out of an ElementTree
def etree_to_dict(t):
    if len(list(t)) == 0:
        d = t.text
    else:
        d = {}
        for node in list(t):
            d[node.tag] = etree_to_dict(node)
            if isinstance(d[node.tag], dict):
                d[node.tag] = d[node.tag]
    return d


# A function to recursively print out multi-level dicts with indentation
def recursive_pretty_print(obj, indent):
    for x in list(obj):
        if isinstance(obj[x], dict):
            print(' '*indent + str(x)[0:50] + ': ')
            recursive_pretty_print(obj[x], indent + 5)
        elif isinstance(obj[x], list):
            print(' '*indent + str(x)[0:50] + ': ' + str(list(obj[x])))
        else:
            print(' '*indent + str(x)[0:50] + ': '
                  + str(obj[x])[0:50].replace('\n', ''))


#######################
# Use a JSON resource #
#######################
outputFormat = 'JSON'
apiUrl = url + pathname2url(outputFormat)

# Get and build the JSON object
result = json.loads(urlopen(apiUrl).read().decode('utf8'))

# Print out a nice informative string
recursive_pretty_print(result, 0)

#######################
# Use an XML resource #
#######################
outputFormat = 'XML'
apiUrl = url + pathname2url(outputFormat)

result = ETree.parse(urlopen(apiUrl))
root = result.getroot()

# Create the dict with the above function.
result = {root.tag: etree_to_dict(root)}

# Print out a nice informative string
recursive_pretty_print(result, 0)
